//
//  Model.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import Foundation
import SwiftData

@Model

final class Memory {
    var id: UUID
    var title: String
    var content: String
    var locationName: String
    var latitude: Double?
    var longitude: Double?
    var createdDate: Date
    var isAnonymous: Bool
    var likesCount: Int
    
    //OPTIONAL - FOR AUDIO RECORDINGS; TO BE ADDED LATER
//    var audioFileName: String?
    
    init(
         title: String,
         content: String,
         locationName: String,
         latitude: Double? = nil,
         longitude: Double? = nil,
         isAnonymous: Bool = false) {
             
        self.id = UUID()
        self.title = title
        self.content = content
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.createdDate = Date()
        self.isAnonymous = isAnonymous
        self.likesCount = 0
    }
    
}
