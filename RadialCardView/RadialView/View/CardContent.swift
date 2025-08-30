//
//  CardContent.swift
//  RadialView
//
//  Created by 박찬휘 on 8/30/25.
//
import SwiftUI

struct CardContent: View {
    let menuValue: MenuValue
    let index: Int
    
    var body: some View {
        CardBackView()
            .overlay {
                VStack(spacing: 4) {
                    // 카드 이미지 (카테고리별 아이콘)
                    Image(systemName: categoryIcon(for: menuValue.category))
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    // 메뉴 이름
                    Text(menuValue.name)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // 인덱스 번호
                    Text("\(index)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(4)
            }
    }
    
    /// 카테고리별 아이콘 반환
    private func categoryIcon(for category: MenuValue.FoodCategory) -> String {
        switch category {
        case .korean: return "leaf.fill" // 한식 - 잎사귀
        case .chinese: return "chopsticks" // 중식 - 젓가락  
        case .japanese: return "fish.fill" // 일식 - 물고기
        case .western: return "fork.knife" // 양식 - 포크나이프
        case .etc: return "star.fill" // 기타 - 별
        }
    }
}


#Preview {
    CardHome()
}
