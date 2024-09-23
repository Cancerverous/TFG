//
//  ReturnVehicleViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class ReturnVehicleViewController: UIViewController {
    
    @IBOutlet weak var txtLicensePlate: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupHideKeyboardOnTap()
        ref = Database.database().reference()
    }
    
    
    @IBAction func btnReturn(_ sender: Any) {
        guard let licensePlate = txtLicensePlate.text?.trimmingCharacters(in: .whitespacesAndNewlines), !licensePlate.isEmpty else {
            print("License plate field is empty.")
            return
        }
        
        reactivateVehicle(licensePlate: licensePlate, node: "Cars")
        reactivateVehicle(licensePlate: licensePlate, node: "Motorcycles")
    }
    
    func reactivateVehicle(licensePlate: String, node: String) {
        ref.child(node).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            if let vehicles = snapshot.value as? [AnyObject] {
                for (index, vehicle) in vehicles.enumerated() {
                    if let carDict = vehicle as? [String: Any],
                       let storedLicense = carDict["License_Plate"] as? String,
                       storedLicense == licensePlate,
                       let isActive = carDict["IsActive"] as? Bool, !isActive {
                        
                        self.updateIsActive(index: index, node: node, isActive: true)
                        
                        let ventana = self.storyboard?.instantiateViewController(identifier: "HOME") as! HomeViewController
                        self.navigationController?.pushViewController(ventana, animated: true)
                        
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
                print("Vehicle reactivated successfully.")
            }
        }
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() 
        return true
    }
}
