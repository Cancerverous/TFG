//
//  CarsViewController.swift
//  TFG
//
//  Created by Luca Porzio on 5/4/24.
//

import UIKit
import Firebase

class CarsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var carsCollection: UICollectionView!
    
    var ref = Database.database().reference()
    var cars: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "CARS"

        carsCollection.delegate = self
        carsCollection.dataSource = self
        configureCollectionViewLayout()
        getCarInformation()
        print("View loaded. Configuring layout and fetching car data.")
    }
    
    func configureCollectionViewLayout(){
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = carsCollection.frame.width - padding * 2 - minimumItemSpacing
        let itemWidth = availableWidth / 2

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: 10, right: padding)
        layout.minimumInteritemSpacing = minimumItemSpacing
        layout.minimumLineSpacing = 10

        carsCollection.collectionViewLayout = layout
        print("Collection view layout configured.")
    }
    
    func getCarInformation() {
        ref.child("Cars").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            var newCars: [Car] = []
            guard let self = self else { return }

            guard let carEntries = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Failed to convert snapshot value to Array.")
                return
            }

            for carSnapshot in carEntries {
                if carSnapshot.value is NSNull {
                    continue
                }

                guard let carInfo = carSnapshot.value as? [String: Any],
                      let isActive = carInfo["IsActive"] as? Bool, isActive else {
                    continue
                }

                do {
                    guard let make = carInfo["Make"] as? String,
                          let model = carInfo["Model"] as? String,
                          let imageUrl = carInfo["Image"] as? String,
                          let drivetrain = carInfo["Drivetrain"] as? String,
                          let motor = carInfo["Motor"] as? String,
                          let topSpeed = carInfo["Top_Speed"] as? Int,
                          let year = carInfo["Year"] as? Int,
                          let engineCapacity = carInfo["cm3"] as? Int,
                          let transmissionData = carInfo["Transmission"] as? [String: Any],
                          let powerData = carInfo["Power"] as? [String: Any],
                          let fuelData = carInfo["Fuel"] as? [String: Any],
                          let licensePlate = carInfo["License_Plate"] as? String,
                          let price = carInfo["Price"] as? Int,
                          let isFavorite = carInfo["isFavorite"] as? Bool
                    else {
                        throw NSError(domain: "DataParsing", code: 100, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid data"])
                    }

                    guard let transmission = parseTransmission(from: transmissionData),
                          let power = parsePower(from: powerData),
                          let fuel = parseFuel(from: fuelData) else {
                        throw NSError(domain: "DataParsing", code: 101, userInfo: [NSLocalizedDescriptionKey: "Transmission, power, or fuel data parsing failed"])
                    }

                    let car = Car(make: make, model: model, imageUrl: imageUrl, drivetrain: drivetrain, motor: motor, topSpeed: topSpeed, year: year, engineCapacity: engineCapacity, transmission: transmission, power: power, fuel: fuel, licensePlate: licensePlate, price: price, isFavorite: isFavorite)
                    newCars.append(car)

                } catch {
                    print("Error parsing car data: \(error)")
                }
            }

            self.cars = newCars
            DispatchQueue.main.async {
                self.carsCollection.reloadData()
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    func parseTransmission(from data: [String: Any]) -> CarTransmission? {
            guard let speeds = data["Speeds"] as? Int, let type = data["Type"] as? String else {
                print("Failed to parse transmission.")
                return nil
            }
            print("Transmission parsed successfully.")
            return CarTransmission(speeds: speeds, type: type)
        }

    func parsePower(from data: [String: Any]) -> CarPower? {
        guard let hp = data["HP"] as? Int, let kw = data["KW"] as? Int else {
            print("Failed to parse power.")
            return nil
        }
        print("Power parsed successfully.")
        return CarPower(hp: hp, kw: kw)
    }

    func parseFuel(from data: [String: Any]) -> CarFuel? {
        guard let capacity = data["Capacity"] as? Int, let economy = data["Economy"] as? String else {
            print("Failed to parse fuel.")
            return nil
        }
        print("Fuel parsed successfully.")
        return CarFuel(capacity: capacity, economy: economy)
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedCar = cars[indexPath.item]
        
        if let vehicleInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "VEHICLE_INFO") as? VehicleInfoViewController {
                vehicleInfoVC.car = selectedCar
                self.navigationController?.pushViewController(vehicleInfoVC, animated: true)
            }
        print("User tapped cell at section \(indexPath.section), row \(indexPath.row).")
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carsCollectionCell", for: indexPath) as? CarsCollectionViewCell else {
                   print("Error: Could not dequeue a CarsCollectionViewCell. Returning a default UICollectionViewCell instead.")
                   return UICollectionViewCell()
               }
               let car = cars[indexPath.item]
               cell.configure(with: car)
               print("Configuring cell for item at index \(indexPath.item) with car \(car.make) \(car.model).")
               return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCarInformation()
    }
    
}
