//
//  ServiceInfoViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class ServiceInfoViewController: UIViewController {

    var service: Service!
    var car: Car!
    var bike: Motorcycle!
    var ref: DatabaseReference!
    
    @IBOutlet weak var imgService: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbLocation: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbDetails: UITextView!
    @IBOutlet weak var btnFavorites: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
                
        guard let service = service else {
                print("No Service data available.")
                return
            }

        lbName.text = "\(service.name)"
        lbLocation.text = "\(service.location)"
        lbPrice.text = "\(service.price) €"
        lbDetails.text = "\(service.detail)"
        
        if let url = URL(string: service.imageUrl) {
            imgService.loadImage(from: url)
        }
        
        setFavoriteButton(isFavorite: service.isFavorite)
    }
    
    private func setFavoriteButton(isFavorite: Bool) {
            let imageName = isFavorite ? "heart.fill" : "heart"
            btnFavorites.setImage(UIImage(systemName: imageName), for: .normal)
        }
    
    func toggleFavoriteStatus(for serviceName: String, in node: String) {
            ref.child(node).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let self = self else { return }
                if let services = snapshot.value as? [AnyObject] {
                    for (index, service) in services.enumerated() {
                        if let serviceDict = service as? [String: Any],
                           let storedName = serviceDict["Name"] as? String,
                           storedName == serviceName,
                           let isFavorite = serviceDict["isFavorite"] as? Bool {

                            let newFavoriteStatus = !isFavorite
                            self.updateIsFavorite(index: index, node: node, isFavorite: newFavoriteStatus)
                            self.setFavoriteButton(isFavorite: newFavoriteStatus)
                            print("Favorite status updated for \(serviceName)")
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
        guard let user = Auth.auth().currentUser else {
                    print("No user is signed in")
                    return
                }
                let uid = user.uid

        let serviceInfo: [String: Any]
            serviceInfo = [
                "Name": service.name,
                "Image": service.imageUrl,
                "Extra": "",
                "License_Plate": "",
                "Type": "Services"
            ]

        let favoritesRef = ref.child("Favorites").child(uid)

        favoritesRef.queryOrdered(byChild: "Name").queryEqual(toValue: service.name).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("Service already in favorites.")
            } else {
                favoritesRef.childByAutoId().setValue(serviceInfo) { error, _ in
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
        guard let user = Auth.auth().currentUser else {
                    print("No user is signed in")
                    return
                }
                let uid = user.uid

        let favoritesRef = ref.child("Favorites").child(uid)

        favoritesRef.queryOrdered(byChild: "Name").queryEqual(toValue: service.name).observeSingleEvent(of: .value, with: { snapshot in
            if let result = snapshot.value as? [String: AnyObject] {
                for (key, _) in result {
                    favoritesRef.child(key).removeValue { error, _ in
                        if let error = error {
                            print("Error removing service from favorites: \(error.localizedDescription)")
                        } else {
                            print("Service removed from favorites successfully.")
                        }
                    }
                }
            } else {
                print("No matching service found in favorites.")
            }
        })
    }
    
    @IBAction func btnFavorites(_ sender: Any) {
        toggleFavoriteStatus(for: service.name, in: "Services")
        if !service.isFavorite{
            saveToFavorites()
        }else{
            deleteFromFavorites()
        }
    }
    
    @IBAction func btnAddService(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "RENT") as! RentViewController
        ventana.service = service
        ventana.bike = bike
        ventana.car = car
        self.navigationController?.pushViewController(ventana, animated: true)
    }
}
