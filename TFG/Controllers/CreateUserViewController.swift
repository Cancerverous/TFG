//
//  CreateUserViewController.swift
//  TFG
//
//  Created by Alejandro Saiz on 21/3/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dpCreateDate: UIDatePicker!
    @IBOutlet weak var txtCreatePassword: UITextField!
    @IBOutlet weak var txtCreateEmail: UITextField!
    @IBOutlet weak var txtCreateUser: UITextField!
    @IBOutlet weak var txtCreateName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHideKeyboardOnTap()
        
        txtCreateEmail.delegate = self
        txtCreateName.delegate = self
        txtCreateUser.delegate = self
        txtCreatePassword.delegate = self
    }
    

    @IBAction func btnRegister(_ sender: Any) {
        guard let email = txtCreateEmail.text, !email.isEmpty,
                 let password = txtCreatePassword.text, !password.isEmpty,
                 let username = txtCreateUser.text, !username.isEmpty,
                 let name = txtCreateName.text, !name.isEmpty else {
            
            let alert = UIAlertController(title: "ERROR", message: "Los campos no pueden estar vacíos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default))
            self.present(alert, animated: true, completion: nil)
            
               return
           }
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           let birthDateString = dateFormatter.string(from: dpCreateDate.date)
           
           Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
               if let error = error {
                   print("Error en la creación del usuario: \(error.localizedDescription)")
                   return
               }
               
               guard let uid = authResult?.user.uid else { return }
               
               let userData = ["Username": username,
                               "Name": name,
                               "Date_of_Birth": birthDateString,
                               "Email": email]
               
               Database.database().reference().child("Users").child(uid).setValue(userData) { error, _ in
                   if let error = error {
                       print("Error al guardar la información del usuario: \(error.localizedDescription)")
                       return
                   }
                   
                   let ventana = self.storyboard?.instantiateViewController(identifier: "TABBAR") as! TabBarViewController
                   self.navigationController?.pushViewController(ventana, animated: true)
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
