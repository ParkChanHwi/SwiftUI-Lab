//
//  Home.swift
//  RadialView
//
//  Created by 박찬휘 on 8/27/25.
//

import SwiftUI

struct Home: View {
    @State private var colors: [ColorValue] = [.red, .yellow, .green, .purple, .pink, .orange, .brown, .cyan, .indigo, .mint].compactMap{color -> ColorValue? in return .init(color: color)}
    @State private var activeIndex:Int = 0
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                Spacer()
                
                Text("\(activeIndex)")
                    .font(.system(size: 80,weight: .bold))
                    
                Spacer(minLength: 0)
                RadialLayout(items: colors, id: \.id, spacing: 80 ){ ColorValue, index, size in Circle()
                        .fill(ColorValue.color.gradient)
                        .overlay{
                            Text("\(index)")
                                .fontWeight(.semibold)
                        }
                } onIndexChange: { index in
                    activeIndex = index
                }
                .padding(.horizontal, -100)
                .frame(width: geometry.size.width, height: geometry.size.width/2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .padding(15)
    }
}

#Preview {
    Home()
}
