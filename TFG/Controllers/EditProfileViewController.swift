//
//  EditProfileViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var dpDateBirth: UIDatePicker!
    @IBOutlet weak var swPassword: UISwitch!
    @IBOutlet weak var lbError: UILabel!
    
    private var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        setupHideKeyboardOnTap()
        
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        txtUsername.delegate = self
        txtName.delegate = self
        lbError.isHidden = true
        
        ref = Database.database().reference()
        
        dpDateBirth.maximumDate = Date()
        dpDateBirth.datePickerMode = .date
        
        loadUserData()

    }
    
    private func loadUserData() {
            guard let userID = Auth.auth().currentUser?.uid else { return }

            ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? [String: Any] {
                    self.txtEmail.text = dict["Email"] as? String ?? ""
                    self.txtName.text = dict["Name"] as? String ?? ""
                    self.txtUsername.text = dict["Username"] as? String ?? ""
                    if let dobString = dict["Date_of_Birth"] as? String {
                        self.dpDateBirth.date = self.dateFromString(dobString) ?? Date()
                    }
                }
            })
        }
    
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        guard let email = txtEmail.text, !email.isEmpty,
              let name = txtName.text, !name.isEmpty,
              let username = txtUsername.text, !username.isEmpty else {
            lbError.text = "Fields must not be empty."
            lbError.isHidden = false
            return
        }

        let dob = stringFromDate(dpDateBirth.date)
        updateUserData(email: email, name: name, username: username, dob: dob)

        if swPassword.isOn {
            guard let newPassword = txtPassword.text, newPassword == txtConfirmPassword.text else {
                displayError(error: NSError(domain: "App", code: 0, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"]))
                return
            }
            
            updatePasswordWithReauthentication(newPassword: newPassword)
        } else {
            navigateToProfile()
        }
    }

    private func updatePasswordWithReauthentication(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error as NSError?, error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    self?.promptForReauthentication { currentPassword in
                        self?.reauthenticateUser(currentPassword: currentPassword) { success, reauthError in
                            if success {
                                self?.updatePassword(newPassword: newPassword)
                            } else {
                                self?.displayError(error: reauthError ?? NSError(domain: "AuthError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to reauthenticate"]))
                            }
                        }
                    }
                } else if let error = error {
                    self?.displayError(error: error)
                } else {
                    self?.displaySuccess(message: "Password updated successfully.")
                    self?.navigateToProfile()
                }
            }
        }
    }

    private func promptForReauthentication(completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Reauthenticate", message: "Enter your current password", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Current Password"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let currentPassword = alertController.textFields?.first?.text {
                completion(currentPassword)
            }
        }
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    private func reauthenticateUser(currentPassword: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            completion(false, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User email is not available"]))
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }


    func displayError(error: Error) {
        lbError.text = error.localizedDescription
        lbError.isHidden = false
    }

    func displaySuccess(message: String) {
        lbError.text = message
        lbError.textColor = .green
        lbError.isHidden = false
    }

    func navigateToProfile() {
        let ventana = self.storyboard?.instantiateViewController(identifier: "PROFILE") as! ProfileViewController
        self.navigationController?.pushViewController(ventana, animated: true)
    }

    
    private func updatePassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { [weak self] error in
            if let error = error {
                if (error as NSError).code == AuthErrorCode.requiresRecentLogin.rawValue {
                    DispatchQueue.main.async {
                        self?.lbError.text = "Please re-authenticate to update your password."
                        self?.lbError.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.lbError.text = "Error updating password: \(error.localizedDescription)"
                        self?.lbError.isHidden = false
                    }
                }
                return
            }
            DispatchQueue.main.async {
            }
        }
    }
    
    private func stringFromDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
    
    private func updateUserData(email: String, name: String, username: String, dob: String) {
           guard let userID = Auth.auth().currentUser?.uid else { return }

           let userRef = ref.child("Users").child(userID)
        let updatedUserData = ["Email": email, "Name": name, "Username": username, "Date_of_Birth": dob]
           userRef.updateChildValues(updatedUserData) { error, _ in
               if let error = error {
                   print("Error updating user: \(error)")
                   return
               }
           }

           if swPassword.isOn, let newPassword = txtPassword.text {
               Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                   if let error = error {
                       print("Error updating password: \(error)")
                   }
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
