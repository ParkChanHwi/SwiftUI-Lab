//
//  CardBackView.swift
//  RadialView
//
//  Created by 박찬휘 on 8/29/25.
//
import SwiftUI


struct CardBackView: View {
    var body: some View {
        Image("cardback") // Assets에 "카드 뒷면.png" 추가했다고 가정
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 180) // 카드 크기 조절
            .shadow(radius: 10) // 테두리 그림자 효과
    }
}
