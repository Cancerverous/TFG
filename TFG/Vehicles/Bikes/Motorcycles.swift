//
//  Motorcycles.swift
//  TFG
//
//  Created by Luca Porzio on 26/4/24.
//

import Foundation

struct Motorcycle {
    var make: String
    var model: String
    var imageUrl: String
    var motor: String
    var topSpeed: Int
    var year: Int
    var cc: String
    var transmission: BikeTransmission
    var power: BikePower
    var fuel: BikeFuel
    var isActive: Bool
    var licensePlate: String
    var price: Int
    var isFavorite: Bool
    
    init(make: String, model: String, imageUrl: String, motor: String, topSpeed: Int, year: Int, cc: String, transmission: BikeTransmission, power: BikePower, fuel: BikeFuel, isActive: Bool = true, licensePlate: String, price: Int, isFavorite: Bool) {
        self.make = make
        self.model = model
        self.imageUrl = imageUrl
        self.motor = motor
        self.topSpeed = topSpeed
        self.year = year
        self.cc = cc
        self.transmission = transmission
        self.power = power
        self.fuel = fuel
        self.isActive = isActive
        self.licensePlate = licensePlate
        self.price = price
        self.isFavorite = isFavorite
    }
}
    struct BikeTransmission {
        var speeds: String
        var type: String
        
        init(speeds: String, type: String) {
            self.speeds = speeds
            self.type = type
        }
    }
    
    struct BikePower {
        var hp: String
        var kw: String
        var torque: String
        
        init(hp: String, kw: String, torque: String) {
            self.hp = hp
            self.kw = kw
            self.torque = torque
        }
    }
    
    struct BikeFuel {
        var capacity: Int
        var economy: String
        
        init(capacity: Int, economy: String) {
            self.capacity = capacity
            self.economy = economy
        }
    }
