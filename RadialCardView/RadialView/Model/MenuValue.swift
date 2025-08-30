//
//  MenuValue.swift
//  RadialView
//
//  Created by 박찬휘 on 8/29/25.
//

import SwiftUI

struct MenuValue: Identifiable {
    var id: UUID = .init()
    var name: String
    var category: FoodCategory
    var image: String
    
    
    
    enum FoodCategory: String, Codable {
        case korean = "한식"
        case chinese = "중식"
        case western = "양식"
        case japanese = "일식"
        case etc = "기타"
    }

}


