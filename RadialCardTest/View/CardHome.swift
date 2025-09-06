//
//  CardHome.swift
//  RadialCardTest
//
//  Created by 박찬휘 on 9/2/25.
//

import SwiftUI

struct CardHome: View {
        /// 20개의 메뉴 데이터 배열
        @State private var menus: [MenuValue] = [
            // 한식 (10개)
            MenuValue(name: "김밥", category: .korean, image: "1"),
            MenuValue(name: "떡볶이", category: .korean, image: "2"),
            MenuValue(name: "라볶이", category: .korean, image: "3"),
            MenuValue(name: "비빔밥", category: .korean, image: "6"),
            MenuValue(name: "불고기", category: .korean, image: "1"),
            MenuValue(name: "갈비", category: .korean, image: "2"),
            MenuValue(name: "냉면", category: .korean, image: "3"),
            MenuValue(name: "삼겹살", category: .korean, image: "6"),
            MenuValue(name: "김치찌개", category: .korean, image: "1"),
            MenuValue(name: "된장찌개", category: .korean, image: "2"),
            
            // 중식 (5개)
            MenuValue(name: "짜장면", category: .chinese, image: "4"),
            MenuValue(name: "짬뽕", category: .chinese, image: "5"),
            MenuValue(name: "탕수육", category: .chinese, image: "7"),
            MenuValue(name: "양장피", category: .chinese, image: "4"),
            MenuValue(name: "마파두부", category: .chinese, image: "5"),

            
            // 일식 (5개)
            MenuValue(name: "초밥", category: .japanese, image: "1"),
            MenuValue(name: "라멘", category: .japanese, image: "2"),
            MenuValue(name: "우동", category: .japanese, image: "3"),
            MenuValue(name: "돈까스", category: .japanese, image: "6"),
            MenuValue(name: "회", category: .japanese, image: "1"),
        ]
    
    
    @State private var activeIndex: Int = 0
    @State private var droppedCard: MenuValue? = nil // 중앙에 놓인 카드 인식
    
    //중앙 카드의 전역 좌표 사각형
    @State private var centerDropRect: CGRect = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경색
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 여백 (전체 높이의 약 15%)
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                    
                    // 중앙 투명 카드 (189x325)
                    VStack(spacing: 20) {
                        
                        ZStack{
                            if let card = droppedCard {
                                Image("cardback")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 189, height: 325)
                                
                                VStack {
                                    Text(card.name)
                                        .font(.title)
                                        .foregroundColor(.white)
                                    Text(card.category.rawValue)
                                        .foregroundColor(.green)
                                }
                            } else {
                                Image("transparentCard") // 투명 카드 이미지
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 189, height: 325)
                                    .opacity(0.6)
                                
                                // 안내 텍스트
                                Text("위로 드래그해서\n카드를 선택해주세요")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .background(
                            GeometryReader {proxy in
                                Color.clear
                                    .onAppear{
                                        centerDropRect = proxy.frame(in: .global)
                                    }
                                    .onChange(of: proxy.size) {
                                        _ in centerDropRect = proxy.frame(in: .global)
                                    }
                            }
                        )

                    
                        // 하단 인디케이터 바
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: 80, height: 4)
                    }
                    
                    Spacer()
                    
                    // 하단 원형 카드 레이아웃
                    RadialLayout(
                        items: menus,
                        id: \.id,
                        spacing: 0,
                        content: { menuValue, index, size in
                            CardContent(menuValue: menuValue, index: index)
                        },
                        onIndexChange: { index in
                            activeIndex = index
                        },
                        onCardSelected: { selectedMenu in
                            droppedCard = selectedMenu
                        },
                        dropTargetRect: centerDropRect 
                    )
                    .frame(height: geometry.size.height * 0.2)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    CardHome()
}
