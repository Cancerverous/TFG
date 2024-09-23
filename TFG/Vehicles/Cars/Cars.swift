//
//  Cars.swift
//  TFG
//
//  Created by Luca Porzio on 26/4/24.
//

import Foundation

struct Car {
    var make: String
    var model: String
    var imageUrl: String
    var drivetrain: String
    var motor: String
    var topSpeed: Int
    var year: Int
    var engineCapacity: Int
    var transmission: CarTransmission
    var power: CarPower
    var fuel: CarFuel
    var isActive: Bool
    var licensePlate: String
    var price: Int
    var isFavorite: Bool

    init(make: String, model: String, imageUrl: String, drivetrain: String, motor: String, topSpeed: Int, year: Int, engineCapacity: Int, transmission: CarTransmission, power: CarPower, fuel: CarFuel, isActive: Bool = true, licensePlate: String, price: Int, isFavorite: Bool) {
        self.make = make
        self.model = model
        self.imageUrl = imageUrl
        self.drivetrain = drivetrain
        self.motor = motor
        self.topSpeed = topSpeed
        self.year = year
        self.engineCapacity = engineCapacity
        self.transmission = transmission
        self.power = power
        self.fuel = fuel
        self.isActive = isActive
        self.licensePlate = licensePlate
        self.price = price
        self.isFavorite = isFavorite
    }
}


struct CarTransmission {
    var speeds: Int
    var type: String

    init(speeds: Int, type: String) {
        self.speeds = speeds
        self.type = type
    }
}

struct CarPower {
    var hp: Int
    var kw: Int

    init(hp: Int, kw: Int) {
        self.hp = hp
        self.kw = kw
    }
}

struct CarFuel {
    var capacity: Int
    var economy: String

    init(capacity: Int, economy: String) {
        self.capacity = capacity
        self.economy = economy
    }
}

