//
//  RadialCardView.swift
//  RadialView
//
//  Created by 박찬휘 on 8/29/25.
//

import SwiftUI

struct RadialCardLayout<Content: View, Item: RandomAccessCollection, ID: Hashable> : View where Item.Element: Identifiable {
    /// 인덱스와 뷰 크기를 추가로 반환
    
    var content: (Item.Element, Int, CGFloat) -> Content
    var keyPathID: KeyPath<Item.Element,ID>
    var items: Item
    /// 뷰 속성
    var spacing: CGFloat?
    var onIndexChange: (Int) -> ()
    /// 카드 선택 콜백
    var onCardSelected: ((Item.Element) -> Void)?
    
    init(items: Item,
         id: KeyPath<Item.Element,ID>,
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping (Item.Element, Int, CGFloat) -> Content,
         onIndexChange: @escaping (Int) -> (),
         onCardSelected: ((Item.Element) -> Void)? = nil) {
        self.content = content
        self.onIndexChange = onIndexChange
        self.spacing = spacing
        self.keyPathID = id
        self.items = items
        self.onCardSelected = onCardSelected
    }
    
    /// 제스처 속성
    @State private var dragRotation: Angle = .zero
    @State private var lastDragRotation: Angle = .zero
    @State private var activeIndex: Int = 0
    @State private var selectedCard: ID? = nil
    @State private var selectedItem: Item.Element? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var ghostPosition: CGPoint = .zero
        
    var body: some View {
        GeometryReader(content: {geometry in
            let size = geometry.size // 화면 사이즈
            let width = size.width // 화면 너비
            let count = CGFloat(items.count) // 아이템의 개수
            let spacing: CGFloat = spacing ?? 0 // 아직 X
            let viewSize = (width-spacing) / (count/2) // 자세히 모름
            
            
            ZStack(content: {
                ForEach(items, id: keyPathID) { item in
                    let index = fetchIndex(item) // 각 아이템의 인덱스
                    let rotation = (CGFloat(index) / count) * 360.0 // 각 아이템의 회전 각
                    let itemID = item[keyPath: keyPathID]
                    let isSelected = selectedCard == itemID // 서
                    
                    content(item, index, viewSize)
                        /// 선택된 카드는 드래그 오프셋 적용
                        .offset(isSelected ? dragOffset : .zero)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        /// 숫자들이 같은 방향으로 보이게끔
                        .rotationEffect(.init(degrees: 90) )
                        .rotationEffect(.init(degrees: -rotation))
                        .rotationEffect(-dragRotation)
                        .frame(width: viewSize, height: viewSize)
                        /// 원형 레이아웃 구성
                        .offset(x: (width - viewSize) / 2)
                        .rotationEffect(.init(degrees: -90) ) // 0을 최상단에 위치하도록
                        .rotationEffect(.init(degrees: rotation))
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                        .opacity(isSelected ? 0.5 : 1.0) // 선택된 원본 카드는 반투명
                        .gesture(
                            LongPressGesture(minimumDuration: 0.3)
                                .onEnded { _ in
                                    selectedCard = itemID
                                    selectedItem = item
                                    ghostPosition = CGPoint(x: width/2, y: width/2) // 초기 위치를 중앙으로
                                }
                        )
                }
                
                // 마우스를 따라다니는 Ghost 카드
                if let selectedItem = selectedItem, selectedCard != nil {
                    content(selectedItem, fetchIndex(selectedItem), viewSize)
                        .rotationEffect(.init(degrees: 90))
                        .frame(width: viewSize, height: viewSize)
                        .scaleEffect(1.2) // 조금 더 크게
                        .opacity(0.8)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .position(ghostPosition)
                        .allowsHitTesting(false) // 터치 이벤트 차단
                }
                
                // 중앙 드롭존 표시 (선택된 카드가 있을 때만)
                if selectedCard != nil {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("여기에 드롭")
                                .font(.caption)
                                .foregroundColor(.blue)
                        )
                        .position(x: width/2, y: width/2)
                }
            })
            .frame(width: width, height: width)
            /// 전체 회전 제스처
            .contentShape(.rect)
            .rotationEffect(dragRotation)
            .gesture(
                // 전체 영역에서의 드래그 제스처 (Ghost 카드 이동용)
                DragGesture()
                    .onChanged({ value in
                        if selectedCard != nil {
                            // Ghost 카드 위치 업데이트
                            ghostPosition = value.location
                        } else {
                            // 일반 회전 제스처
                            let translationX = value.translation.width
                            
                            let progress = translationX / (viewSize * 2)
                            let rotationFraction = 360.0 / count
                                
                            dragRotation = .init(degrees: (rotationFraction * progress) + lastDragRotation.degrees)
                            calculateIndex(count)
                        }
                    }).onEnded({ value in
                        if selectedCard != nil {
                            // 드롭존 체크
                            let centerX = width / 2
                            let centerY = width / 2
                            let dropZoneRadius: CGFloat = 50
                            
                            let distance = sqrt(
                                pow(value.location.x - centerX, 2) +
                                pow(value.location.y - centerY, 2)
                            )
                            
                            if distance < dropZoneRadius {
                                // 카드 선택 완료
                                if let item = selectedItem {
                                    onCardSelected?(item)
                                }
                            }
                            
                            // 상태 초기화
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCard = nil
                                selectedItem = nil
                                ghostPosition = .zero
                            }
                        } else {
                            // 일반 회전 제스처 종료
                            let velocityX =  value.velocity.width / 15
                            let translationX = value.translation.width + velocityX
                            
                            let progress = translationX / (viewSize * 2)
                            let rotationFraction = 360.0 / count
                            
                            withAnimation(.smooth) {
                                dragRotation = .init(degrees: (rotationFraction * progress) +
                                    lastDragRotation.degrees)
                            }
                            
                            lastDragRotation = dragRotation
                            calculateIndex(count)
                        }
                    })
            )
        })
    }
    
    /// 중앙 상단 인덱스 계산
    func calculateIndex(_ count : CGFloat) {
        var activeIndex =  (dragRotation.degrees / 360.0 * count).rounded().truncatingRemainder(dividingBy: count)
        activeIndex = activeIndex == 0 ? 0 : (activeIndex < 0 ? -activeIndex : count - activeIndex)
        self.activeIndex = Int(activeIndex)
        /// 뷰에 알림
        onIndexChange(self.activeIndex)
    }
    
    /// 아이템 인덱스 가져오기
    func fetchIndex(_ item: Item.Element) -> Int {
        if let index = items.firstIndex(where: {
            $0[keyPath: keyPathID] == item[keyPath: keyPathID]
        }) as? Int {
            return index
        }
        return 0
    }
}

#Preview {
    CardHome()
}
