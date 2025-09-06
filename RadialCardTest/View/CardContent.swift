//
//  CardContent.swift
//  RadialCardTest
//
//  Created by 박찬휘 on 9/2/25.
//


import SwiftUI

struct CardContent: View {
    let menuValue: MenuValue
    let index: Int
    
    var body: some View {
        Image("cardback") // 카드 뒷면 이미지
            .resizable()
            .scaledToFit()
            .frame(width: 125, height: 215)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    CardHome()
}
