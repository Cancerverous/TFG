//
//  Services.swift
//  TFG
//
//  Created by Luca Porzio on 1/5/24.
//

import Foundation

struct Service {
    var name: String
    var location: String
    var detail: String
    var imageUrl: String
    var price: Int
    var isFavorite: Bool

    init(name: String, location: String, detail: String, imageUrl: String, price: Int, isFavorite: Bool) {
        self.name = name
        self.location = location
        self.detail = detail
        self.imageUrl = imageUrl
        self.price = price
        self.isFavorite = isFavorite
    }
}
