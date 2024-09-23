//
//  BikesViewController.swift
//  TFG
//
//  Created by Luca Porzio on 5/4/24.
//

import UIKit
import Firebase

class BikesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var bikesCollection: UICollectionView!
    
    var ref = Database.database().reference()
    var bikes: [Motorcycle] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "MOTORCYCLES"

        bikesCollection.delegate = self
        bikesCollection.dataSource = self
        configureCollectionViewLayout()
        getBikeInformation()
        print("View loaded. Configuring layout and fetching car data.")
        
    }
    
    func configureCollectionViewLayout(){
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = bikesCollection.frame.width - padding * 2 - minimumItemSpacing
        let itemWidth = availableWidth / 2

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: 10, right: padding)
        layout.minimumInteritemSpacing = minimumItemSpacing
        layout.minimumLineSpacing = 10

        bikesCollection.collectionViewLayout = layout
    }
    
    func getBikeInformation() {
        ref.child("Motorcycles").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            var newBikes: [Motorcycle] = []
            guard let self = self else { return }

            // Check that the snapshot contains a value.
            guard let bikeEntries = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Failed to convert snapshot value to Array.")
                return
            }

            for bikeSnapshot in bikeEntries {
                if bikeSnapshot.value is NSNull {
                    continue
                }

                guard let bikeInfo = bikeSnapshot.value as? [String: Any],
                      let isActive = bikeInfo["IsActive"] as? Bool, isActive else {
                    continue
                }

                do {
                    guard let make = bikeInfo["Make"] as? String,
                          let model = bikeInfo["Model"] as? String,
                          let imageUrl = bikeInfo["Image"] as? String,
                          let motor = bikeInfo["Motor"] as? String,
                          let topSpeed = bikeInfo["Top_Speed"] as? Int,
                          let year = bikeInfo["Year"] as? Int,
                          let cc = bikeInfo["cc"] as? String,
                          let transmissionData = bikeInfo["Transmission"] as? [String: Any],
                          let powerData = bikeInfo["Power"] as? [String: Any],
                          let fuelData = bikeInfo["Fuel"] as? [String: Any],
                          let licensePlate = bikeInfo["License_Plate"] as? String,
                          let price = bikeInfo["Price"] as? Int,
                          let isFavorite = bikeInfo["isFavorite"] as? Bool
                    else {
                        throw NSError(domain: "DataParsing", code: 100, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid data"])
                    }

                    guard let transmission = parseTransmission(from: transmissionData),
                          let power = parsePower(from: powerData),
                          let fuel = parseFuel(from: fuelData) else {
                        throw NSError(domain: "DataParsing", code: 101, userInfo: [NSLocalizedDescriptionKey: "Transmission, power, or fuel data parsing failed"])
                    }
                    
                    let bike = Motorcycle(make: make, model: model, imageUrl: imageUrl, motor: motor, topSpeed: topSpeed, year: year, cc: cc, transmission: transmission, power: power, fuel: fuel, licensePlate: licensePlate, price: price, isFavorite: isFavorite)
                    newBikes.append(bike)

                } catch {
                    print("Error parsing car data: \(error)")
                }
            }

            self.bikes = newBikes
            DispatchQueue.main.async {
                self.bikesCollection.reloadData()
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    func parseTransmission(from data: [String: Any]) -> BikeTransmission? {
            guard let gearbox = data["Gearbox"] as? String, let type = data["Type"] as? String else {
                print("Failed to parse transmission.")
                return nil
            }
            print("Transmission parsed successfully.")
            return BikeTransmission(speeds: gearbox, type: type)
        }

        func parsePower(from data: [String: Any]) -> BikePower? {
            guard let hp = data["HP"] as? String, let kw = data["KW"] as? String, let torque = data["Torque"] as? String else {
                print("Failed to parse power.")
                return nil
            }
            print("Power parsed successfully.")
            return BikePower(hp: hp, kw: kw, torque: torque)
        }

        func parseFuel(from data: [String: Any]) -> BikeFuel? {
            guard let capacity = data["Capacity"] as? Int, let economy = data["Economy"] as? String else {
                print("Failed to parse fuel.")
                return nil
            }
            print("Fuel parsed successfully.")
            return BikeFuel(capacity: capacity, economy: economy)
        }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let selectedBike = bikes[indexPath.item]
        
        if let vehicleInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "VEHICLE_INFO") as? VehicleInfoViewController {
                vehicleInfoVC.bike = selectedBike
                self.navigationController?.pushViewController(vehicleInfoVC, animated: true)
            }
        print("User tapped cell at section \(indexPath.section), row \(indexPath.row).")
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bikes.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bikesCollectionCell", for: indexPath) as? BikesCollectionViewCell else {
                   print("Error: Could not dequeue a BikesCollectionViewCell. Returning a default UICollectionViewCell instead.")
                   return UICollectionViewCell()
               }
               let bike = bikes[indexPath.item]
               cell.configure(with: bike)
               print("Configuring cell for item at index \(indexPath.item) with car \(bike.make) \(bike.model).")
               return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBikeInformation()
    }
}
