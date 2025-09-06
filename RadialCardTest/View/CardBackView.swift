//
//  CardBackView.swift
//  RadialCardTest
//
//  Created by 박찬휘 on 9/2/25.
//


import SwiftUI


struct CardBackView: View {
    var body: some View {
        Image("transparentCard") // 투명 카드 이미지
            .resizable()
            .scaledToFit()
            .frame(width: 189, height: 325)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
