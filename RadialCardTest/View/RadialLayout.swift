//
//  RadialLayout.swift
//  RadialCardTest
//
//  Created by 박찬휘 on 8/31/25.
//

//
//  RadialLayout.swift
//  RadialCardTest
//
//  Created by 박찬휘 on 8/31/25.
//

import SwiftUI

/// 원형(라디얼) 레이아웃 + 롱프레스 드래그로 개별 카드 집어 올리기
struct RadialLayout<Content: View, Item: RandomAccessCollection, ID: Hashable>: View where Item.Element: Identifiable {

    var content: (Item.Element, Int, CGFloat) -> Content
    var keyPathID: KeyPath<Item.Element, ID>
    var items: Item

    var spacing: CGFloat?
    var onIndexChange: (Int) -> Void
    var onCardSelected: ((Item.Element) -> Void)?
    var dropTargetRect: CGRect?

    init(
        items: Item,
        id: KeyPath<Item.Element, ID>,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping (Item.Element, Int, CGFloat) -> Content,
        onIndexChange: @escaping (Int) -> Void,
        onCardSelected: ((Item.Element) -> Void)? = nil,
        dropTargetRect: CGRect? = nil
    ) {
        self.items = items
        self.keyPathID = id
        self.spacing = spacing
        self.content = content
        self.onIndexChange = onIndexChange
        self.onCardSelected = onCardSelected
        self.dropTargetRect = dropTargetRect
    }

    // 링 회전
    @State private var dragRotation: Angle = .zero
    @State private var lastDragRotation: Angle = .zero
    @State private var activeIndex: Int = 0

    // 선택/드래그 상태
    @State private var selectedCardID: ID? = nil
    @State private var selectedItem: Item.Element? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var pickStartPoint: CGPoint? = nil

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let count = CGFloat(items.count)
            let spacing = spacing ?? 0
            let viewSize = (width - spacing) / (count / 2)
            let radius = (width - viewSize) / 2
            let layoutOrigin = geo.frame(in: .global).origin
            ZStack {
                // ===== 링 레이어 =====
                ringLayer(width: width, count: count, viewSize: viewSize, radius: radius)
                    .frame(width: width, height: width)
                    .rotationEffect(dragRotation)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard selectedCardID == nil else { return }
                                let progress = value.translation.width / (viewSize * 2)
                                let rotationFraction = 360.0 / count
                                dragRotation = .degrees(
                                    rotationFraction * progress + lastDragRotation.degrees
                                )
                                calculateIndex(count)
                            }
                            .onEnded { _ in
                                guard selectedCardID == nil else { return }
                                lastDragRotation = dragRotation
                            }
                    )

                // ===== 선택된 카드 (오버레이, 정방향) =====
                if let item = selectedItem, let start = pickStartPoint {
                    content(item, fetchIndex(item), viewSize)
                        .frame(width: viewSize, height: viewSize)
                        .scaleEffect(1.08)
                        .shadow(radius: 10)
                        .position(start)
                        .offset(dragOffset)
                        .zIndex(50)
                        .highPriorityGesture(
                            DragGesture()
                                .onChanged { drag in
                                    dragOffset = drag.translation
                                }
                                .onEnded { drag in
                                    // ⬇️ 로컬(start + translation)을 전역 좌표로 변환
                                    let endPointGlobal = CGPoint(
                                        x: layoutOrigin.x + start.x + drag.translation.width,
                                        y: layoutOrigin.y + start.y + drag.translation.height
                                    )

                                    if let dropRect = dropTargetRect,
                                       dropRect.contains(endPointGlobal) {
                                        onCardSelected?(item) // ✅ 이제 호출됨
                                    }

                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selectedCardID = nil
                                        selectedItem = nil
                                        dragOffset = .zero
                                        pickStartPoint = nil
                                    }
                                }
                        )
                }
            }
            .frame(width: width, height: width)
        }
    }

    /// 링에 표시될 카드들
    private func ringLayer(width: CGFloat, count: CGFloat, viewSize: CGFloat, radius: CGFloat) -> some View {
        ZStack {
            ForEach(items, id: keyPathID) { item in
                let idx = fetchIndex(item)
                let itemID = item[keyPath: keyPathID]
                let rotation = (CGFloat(idx) / count) * 360.0
                let isHidden = (selectedCardID == itemID)

                if !isHidden {
                    content(item, idx, viewSize)
                        .frame(width: viewSize, height: viewSize)
                        .rotationEffect(.degrees(90))
                        .offset(x: radius)
                        .rotationEffect(.degrees(rotation))
                        .onLongPressGesture(minimumDuration: 0.3) {
                            // 롱프레스 성공 시 → 오버레이로 이동
                            selectedCardID = itemID
                            selectedItem = item
                            dragOffset = .zero

                            // 현재 카드의 위치(화면 좌표)
                            let totalDeg = rotation + dragRotation.degrees
                            let rad = totalDeg * .pi / 180
                            let center = CGPoint(x: width/2, y: width/2)
                            let start = CGPoint(
                                x: center.x + radius * cos(rad),
                                y: center.y + radius * sin(rad)
                            )
                            pickStartPoint = start
                        }
                }
            }
        }
    }

    private func calculateIndex(_ count: CGFloat) {
        var active = (dragRotation.degrees / 360.0 * count).rounded()
            .truncatingRemainder(dividingBy: count)
        active = active == 0 ? 0 : (active < 0 ? -active : count - active)
        self.activeIndex = Int(active)
        onIndexChange(self.activeIndex)
    }

    private func fetchIndex(_ item: Item.Element) -> Int {
        if let idx = items.firstIndex(where: {
            $0[keyPath: keyPathID] == item[keyPath: keyPathID]
        }) as? Int {
            return idx
        }
        return 0
    }
}


#Preview {
    CardHome()
}
