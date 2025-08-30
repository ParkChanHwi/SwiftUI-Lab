//
//  CardHome.swift
//  RadialView
//
//  Created by 박찬휘 on 8/29/25.
//

import SwiftUI

struct CardHome: View {
    /// 30개의 메뉴 데이터 배열
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
        
        // 중식 (10개)
        MenuValue(name: "짜장면", category: .chinese, image: "4"),
        MenuValue(name: "짬뽕", category: .chinese, image: "5"),
        MenuValue(name: "탕수육", category: .chinese, image: "7"),
        MenuValue(name: "양장피", category: .chinese, image: "4"),
        MenuValue(name: "마파두부", category: .chinese, image: "5"),
        MenuValue(name: "깐풍기", category: .chinese, image: "7"),
        MenuValue(name: "볶음밥", category: .chinese, image: "4"),
        MenuValue(name: "유산슬", category: .chinese, image: "5"),
        MenuValue(name: "팔보채", category: .chinese, image: "7"),
        MenuValue(name: "고추잡채", category: .chinese, image: "4"),
        
        // 일식 (5개)
        MenuValue(name: "초밥", category: .japanese, image: "1"),
        MenuValue(name: "라멘", category: .japanese, image: "2"),
        MenuValue(name: "우동", category: .japanese, image: "3"),
        MenuValue(name: "돈까스", category: .japanese, image: "6"),
        MenuValue(name: "회", category: .japanese, image: "1"),
        
        // 양식 (5개)
        MenuValue(name: "파스타", category: .western, image: "2"),
        MenuValue(name: "피자", category: .western, image: "3"),
        MenuValue(name: "스테이크", category: .western, image: "6"),
        MenuValue(name: "리조또", category: .western, image: "1"),
        MenuValue(name: "샐러드", category: .western, image: "2")
    ]
    
    @State private var activeIndex: Int = 0 // 현재 활성화된 카드 인덱스
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경색
                Color.purple.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 활성 인덱스 표시
                    ActiveCardDisplay(activeIndex: activeIndex, menus: menus)
                        .padding(.top, 80)
                    
                    Spacer()
                    
                    // 하단 반원형 카드 레이아웃
                    RadialCardLayout(
                        items: menus,
                        id: \.id,
                        spacing: 0
                    ) { menuValue, index, size in
                        // 각 카드의 내용
                        CardContent(menuValue: menuValue, index: index)
                    } onIndexChange: { index in
                        // 활성 인덱스가 변경될 때 호출
                        activeIndex = index
                    } onCardSelected: { selectedMenu in
                        // 카드가 드롭존에 드롭될 때 호출
                        print("선택된 메뉴: \(selectedMenu)")
                    }
                    .frame(height: geometry.size.height * 0.4) // 화면 하단 40% 영역 사용
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom) // 하단 안전 영역 무시
    }
}

// MARK: - 활성 카드 표시 (상단 중앙)
struct ActiveCardDisplay: View {
    let activeIndex: Int
    let menus: [MenuValue]
    
    var body: some View {
        VStack {
            Text("현재 선택된 카드")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(activeIndex)")
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.primary)
            
            if activeIndex < menus.count {
                Text(menus[activeIndex].name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    CardHome()
}
