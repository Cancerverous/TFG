//
//  Favorites.swift
//  TFG
//
//  Created by Luca Porzio on 15/5/24.
//

import Foundation

struct Favorites {
    var name: String
    var imageUrl: String
    var extra: String
    var licensePlate: String
    var type: String

    init(name: String, imageUrl: String, extra: String, licensePlate: String, type: String) {
        self.name = name
        self.imageUrl = imageUrl
        self.extra = extra
        self.licensePlate = licensePlate
        self.type = type
    }
}
