//
//  BankTransferViewController.swift
//  TFG
//
//  Created by Luca Porzio on 14/5/24.
//

import UIKit
import Firebase

class BankTransferViewController: UIViewController, UITextFieldDelegate {
    
    var car: Car!
    var bike: Motorcycle!
    var ref: DatabaseReference!

    @IBOutlet weak var txtAccountHolder: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtRoutingNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHideKeyboardOnTap()
        ref = Database.database().reference()
    }

    @IBAction func btnPay(_ sender: Any) {
        guard let accountHolder = txtAccountHolder.text, !accountHolder.isEmpty,
              let accountNumber = txtAccountNumber.text, !accountNumber.isEmpty,
              let routingNumber = txtRoutingNumber.text, !routingNumber.isEmpty else {
            showAlert(message: "Please fill all fields.")
            return
        }
        
        print("Submitted Bank Information: \(accountHolder), \(accountNumber), \(routingNumber)")
        
        if car != nil{
            deactivateVehicle(licensePlate: car.licensePlate, node: "Cars")
            print(car.licensePlate)
        }else if bike != nil{
            deactivateVehicle(licensePlate: bike.licensePlate, node: "Motorcycles")
            print(bike.licensePlate)
        }else{
            print("No vehicle with that license plate.")
        }
        let ventana = self.storyboard?.instantiateViewController(identifier: "HOME") as! HomeViewController
        self.navigationController?.pushViewController(ventana, animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
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
