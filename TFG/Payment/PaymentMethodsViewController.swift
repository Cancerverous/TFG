//
//  PaymentMethodsViewController.swift
//  TFG
//
//  Created by Luca Porzio on 14/5/24.
//

import UIKit
import SafariServices
import Firebase

class PaymentMethodsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var car: Car!
    var bike: Motorcycle!
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

    }
    
    @IBAction func btnPayPal(_ sender: Any) {
        let urlString = "https://www.paypal.com/signin"
                if let url = URL(string: urlString) {
                    let safariVC = SFSafariViewController(url: url)
                    safariVC.delegate = self
                    self.present(safariVC, animated: true, completion: nil)
                } else {
                    print("Invalid URL")
                }
    }
    
    @IBAction func btnBankTransfer(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "BANK_TRANSFER") as! BankTransferViewController
        ventana.bike = bike
        ventana.car = car
        self.navigationController?.pushViewController(ventana, animated: true)
    }
    
    func deactivateVehicle(licensePlate: String, node: String) {
        ref.child(node).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            if let vehicles = snapshot.value as? [AnyObject] {
                for (index, vehicle) in vehicles.enumerated() {
                    if let carDict = vehicle as? [String: Any],
                        let storedLicense = carDict["License_Plate"] as? String,
                        storedLicense == licensePlate {
                        
                        self.updateIsActive(index: index, node: node, isActive: false)
                        break
                    }
                }
            }
        }) { error in
            print("Error fetching \(node): \(error.localizedDescription)")
        }
    }
        
    func updateIsActive(index: Int, node: String, isActive: Bool) {
        ref.child(node).child("\(index)").child("IsActive").setValue(isActive) { error, _ in
            if let error = error {
                print("Error updating vehicle status: \(error.localizedDescription)")
            } else {
                print("Vehicle deactivated successfully.")
            }
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if car != nil{
            deactivateVehicle(licensePlate: car.licensePlate, node: "Cars")
            print(car.licensePlate)
        }else if bike != nil{
            deactivateVehicle(licensePlate: bike.licensePlate, node: "Motorcycles")
            print(bike.licensePlate)
        }else{
            print("No vehicle with that license plate.")
        }
        
        if let ventana = self.storyboard?.instantiateViewController(identifier: "HOME") as? HomeViewController {
            self.navigationController?.pushViewController(ventana, animated: true)
        }
    }
}
