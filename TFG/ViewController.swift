//
//  ViewController.swift
//  TFG
//
//  Created by Luca Porzio on 11/3/24.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    private let database = Database.database(url: "https://tfgluca-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    
    var id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHideKeyboardOnTap() // Set up to dismiss keyboard
        txtEmail.delegate = self
        txtPassword.delegate = self
        
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        guard let email = txtEmail.text, !email.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
           
            
            let alert = UIAlertController(title: "ERROR", message: "Los campos no pueden estar vacíos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let email = txtEmail.text, let password = txtPassword.text {
            Auth.auth().signIn(withEmail: email, password: password){
                (result, error) in
                
                if let res = result, error == nil{
                    //Si ha podido autenticar al usuario pasamos de vista
                    let ventana = self.storyboard?.instantiateViewController(identifier: "TABBAR") as! TabBarViewController
                    self.navigationController?.pushViewController(ventana, animated: true)
                }else{
                    //si no lo ha podido autentificar muestro alerta
                    let alert = UIAlertController(title: "ERROR", message: "Error Inesperado: \(error.debugDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Utility function to set up a tap gesture recognizer
        private func setupHideKeyboardOnTap() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
        
        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
        
        // UITextFieldDelegate methods
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard when the return key is pressed
            return true
        }
}
