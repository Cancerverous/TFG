//
//  VehicleInfoViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class VehicleInfoViewController: UIViewController {

    @IBOutlet weak var imgVehicle: UIImageView!
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbYear: UILabel!
    @IBOutlet weak var lbMotor: UILabel!
    @IBOutlet weak var lbTopSpeed: UILabel!
    @IBOutlet weak var lbDrivetrain: UILabel!
    @IBOutlet weak var lbMotorCapacity: UILabel!
    @IBOutlet weak var lbFuelCapacity: UILabel!
    @IBOutlet weak var lbFuelEconomy: UILabel!
    @IBOutlet weak var lbTransmission: UILabel!
    @IBOutlet weak var lbHp: UILabel!
    @IBOutlet weak var lbKw: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    @IBOutlet weak var lbTitleMotorCapacity: UILabel!
    @IBOutlet weak var lbTitleDrivetrain: UILabel!
    @IBOutlet weak var btnAddVehicle: UIButton!
    @IBOutlet weak var btnFavorites: UIButton!
    
    
    var car: Car!
    var bike: Motorcycle!
    var ref: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        if car != nil {
            loadCar()
            setFavoriteButton(isFavorite: car.isFavorite)
        } else if bike != nil {
            loadBike()
            setFavoriteButton(isFavorite: bike.isFavorite)
        } else {
            print("No Data loaded")
            btnAddVehicle.setTitle("No Vehicle Available", for: .normal)
            btnAddVehicle.isEnabled = false
        }
    }
    
    func loadCar() {
        guard let car = car else {
            print("No car data available.")
            return
        }

        lbName.text = "\(car.make) \(car.model)"
        lbYear.text = "\(car.year)"
        lbMotor.text = "\(car.motor)"
        lbTopSpeed.text = "\(car.topSpeed) km/h"
        lbDrivetrain.text = "\(car.drivetrain)"
        lbTitleMotorCapacity.text = "Cm³"
        lbMotorCapacity.text = "\(car.engineCapacity) cm³"
        lbFuelCapacity.text = "\(car.fuel.capacity) liters"
        lbFuelEconomy.text = "\(car.fuel.economy) L/100km"
        lbTransmission.text = "\(car.transmission.type) \(car.transmission.speeds)-speed"
        lbHp.text = "\(car.power.hp) HP"
        lbKw.text = "\(car.power.kw) kW"
        lbPrice.text = "\(car.price) €"
        
        if let url = URL(string: car.imageUrl) {
            imgVehicle.loadImage(from: url)
        }
        
        btnAddVehicle.setTitle("Add Car", for: .normal)
    }
    
    func loadBike() {
        guard let bike = bike else {
            print("No bike data available.")
            return
        }

        lbName.text = "\(bike.make) \(bike.model)"
        lbYear.text = "\(bike.year)"
        lbMotor.text = "\(bike.motor)"
        lbTopSpeed.text = "\(bike.topSpeed) km/h"
        lbTitleDrivetrain.text = "Torque:"
        lbDrivetrain.text = "\(bike.power.torque) Nm"
        lbTitleMotorCapacity.text = "Cc:"
        lbMotorCapacity.text = "\(bike.cc) cc"
        lbFuelCapacity.text = "\(bike.fuel.capacity) liters"
        lbFuelEconomy.text = "\(bike.fuel.economy) L/100km"
        lbTransmission.text = "\(bike.transmission.type) \(bike.transmission.speeds)"
        lbHp.text = "\(bike.power.hp) HP"
        lbKw.text = "\(bike.power.kw) kW"
        lbPrice.text = "\(bike.price) €"
        
        if let url = URL(string: bike.imageUrl) {
            imgVehicle.loadImage(from: url)
        }
        
        btnAddVehicle.setTitle("Add Motorcycle", for: .normal)
    }
    
    private func setFavoriteButton(isFavorite: Bool) {
            let imageName = isFavorite ? "heart.fill" : "heart"
            btnFavorites.setImage(UIImage(systemName: imageName), for: .normal)
        }
    
    func toggleFavoriteStatus(for licensePlate: String, in node: String) {
            ref.child(node).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let self = self else { return }
                if let vehicles = snapshot.value as? [AnyObject] {
                    for (index, vehicle) in vehicles.enumerated() {
                        if let vehicleDict = vehicle as? [String: Any],
                           let storedLicense = vehicleDict["License_Plate"] as? String,
                           storedLicense == licensePlate,
                           let isFavorite = vehicleDict["isFavorite"] as? Bool {

                            let newFavoriteStatus = !isFavorite
                            self.updateIsFavorite(index: index, node: node, isFavorite: newFavoriteStatus)
                            self.setFavoriteButton(isFavorite: newFavoriteStatus)
                            print("Favorite status updated for \(licensePlate)")
                            break
                        }
                    }
                }
            }) { error in
                print("Error fetching \(node): \(error.localizedDescription)")
            }
        }

        private func updateIsFavorite(index: Int, node: String, isFavorite: Bool) {
            ref.child(node).child("\(index)").child("isFavorite").setValue(isFavorite) { error, _ in
                if let error = error {
                    print("Error updating favorite status: \(error.localizedDescription)")
                } else {
                    print("\(isFavorite ? "Added to" : "Removed from") favorites successfully.")
                }
            }
        }
    
    func saveToFavorites() {
        let vehicleInfo: [String: Any]
        let licensePlate: String
        if let car = car {
            vehicleInfo = [
                "Name": car.make,
                "Image": car.imageUrl,
                "Extra": car.model,
                "License_Plate": car.licensePlate,
                "Type": "Cars"
            ]
            licensePlate = car.licensePlate
        } else if let bike = bike {
            vehicleInfo = [
                "Name": bike.make,
                "Image": bike.imageUrl,
                "Extra": bike.model,
                "License_Plate": bike.licensePlate,
                "Type": "Motorcycles"
            ]
            licensePlate = bike.licensePlate
        } else {
            print("No vehicle data available.")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in")
            return
        }
        let uid = user.uid

        let favoritesRef = ref.child("Favorites").child(uid)

        favoritesRef.queryOrdered(byChild: "License_Plate").queryEqual(toValue: licensePlate).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("Vehicle already in favorites.")
            } else {
                favoritesRef.childByAutoId().setValue(vehicleInfo) { error, _ in
                    if let error = error {
                        print("Error adding vehicle to favorites: \(error.localizedDescription)")
                    } else {
                        print("Vehicle added to favorites successfully.")
                    }
                }
            }
        })
    }
    
    func deleteFromFavorites() {
        guard let identifier = car != nil ? "\(car.licensePlate)" : "\(bike.licensePlate)" else {
            print("No vehicle data available for deletion.")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in")
            return
        }
        let uid = user.uid

        let favoritesRef = ref.child("Favorites").child(uid)

        favoritesRef.queryOrdered(byChild: "License_Plate").queryEqual(toValue: identifier).observeSingleEvent(of: .value, with: { snapshot in
            if let result = snapshot.value as? [String: AnyObject] {
                for (key, _) in result {
                    favoritesRef.child(key).removeValue { error, _ in
                        if let error = error {
                            print("Error removing vehicle from favorites: \(error.localizedDescription)")
                        } else {
                            print("Vehicle removed from favorites successfully.")
                        }
                    }
                }
            } else {
                print("No matching vehicle found in favorites.")
            }
        })
    }


    
    @IBAction func btnServices(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "SERVICES") as! ServicesViewController
        ventana.bike = bike
        ventana.car = car
        self.navigationController?.pushViewController(ventana, animated: true)
    }
    
    @IBAction func btnRentVehicle(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "RENT") as! RentViewController
        ventana.bike = bike
        ventana.car = car
        self.navigationController?.pushViewController(ventana, animated: true)
    }
    
    @IBAction func btnFavorites(_ sender: Any) {
        if car != nil{
            toggleFavoriteStatus(for: car.licensePlate, in: "Cars")
            if !car.isFavorite{
                saveToFavorites()
            }else{
                deleteFromFavorites()
            }
        }else{
            toggleFavoriteStatus(for: bike.licensePlate, in: "Motorcycles")
            if !bike.isFavorite{
                saveToFavorites()
            }else{
                deleteFromFavorites()
            }
        }
    }
    
}
