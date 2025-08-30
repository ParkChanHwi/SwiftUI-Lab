//
//  RadialView.swift
//  RadialView
//
//  Created by 박찬휘 on 8/27/25.
//

import SwiftUI

struct RadialLayout<Content: View, Item: RandomAccessCollection, ID: Hashable> : View where Item.Element: Identifiable {
    /// Additionally Returning Index and View Size
    
    var content: (Item.Element, Int, CGFloat) -> Content
    var keyPathID: KeyPath<Item.Element,ID>
    var items: Item
    ///View Properties
    var spacing: CGFloat?
    var onIndexChange: (Int) -> ()
    
    init(items: Item,id:KeyPath<Item.Element,ID>, spacing: CGFloat? = nil, @ViewBuilder content: @escaping (Item.Element, Int, CGFloat) -> Content, onIndexChange: @escaping (Int) -> ())  {
        self.content = content
        self.onIndexChange = onIndexChange
        self.spacing = spacing
        self.keyPathID = id
        self.items = items
    }
    /// Gesture Propertes
    @State private var dragRotation: Angle = .zero
    @State private var lastDragRotation: Angle = .zero
    @State private var activeIndex: Int = 0
        
    var body: some View {
        GeometryReader(content: {geometry in
            let size = geometry.size
            let width = size.width
            let count = CGFloat(items.count)
            let spacing: CGFloat = spacing ?? 0
            let viewSize = (width-spacing) / (count/2)
            
            
            ZStack(content: {
                ForEach(items, id: keyPathID) { item in
                    let index = fetchIndex(item)
                    let rotation = (CGFloat(index) / count) * 360.0
                    content(item, index, viewSize)
                    /// 숫자들이 같은 방향으로 보이게끔
                        .rotationEffect(.init(degrees: 90) )
                        .rotationEffect(.init(degrees: -rotation))
                        .rotationEffect(-dragRotation)
                        .frame(width: viewSize, height: viewSize)
                        /// building Radial Layout
                        .offset(x: (width - viewSize) / 2)
                        .rotationEffect(.init(degrees: -90) ) // 0를 최 상단에 위치하도록
                        .rotationEffect(.init(degrees: rotation))
                }
            })
            .frame(width: width, height: width)
            ///Gesture
            .contentShape(.rect)
            .rotationEffect(dragRotation)
            .gesture(
                DragGesture()
                    .onChanged({value in
                        let translationX = value.translation.width
                        
                        let progress = translationX / (viewSize * 2)
                        let rotationFraction = 360.0 / count
                            
                        dragRotation = .init(degrees: (rotationFraction * progress) + lastDragRotation.degrees)
                        calculateIndex(count)
                    }).onEnded({ value in
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
                    })
            )
        })
    }
    
    /// calculate the center Top index
    func calculateIndex(_ count : CGFloat) {
        var activeIndex =  (dragRotation.degrees / 360.0 * count).rounded().truncatingRemainder(dividingBy: count)
        activeIndex = activeIndex == 0 ? 0 : (activeIndex < 0 ? -activeIndex : count - activeIndex)
        self.activeIndex = Int(activeIndex)
        /// Notifying the View
        onIndexChange(self.activeIndex)
        // print(activeIndex)
    }
    /// Fetching Item Index
    func fetchIndex(_ item: Item.Element) -> Int {
        if let index = items.firstIndex(where: {
            $0.id == item.id
        }) as? Int {
            return index
        }
        return 0
    }
}

#Preview {
    ContentView()
}
