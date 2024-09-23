//
//  ProfileViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbDateBirth: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        fetchUserData()
    }
    
    @IBAction func btnLogOut(_ sender: Any) {
        do {
                   try Auth.auth().signOut()
                   switchToLoginScreen()
               } catch let signOutError as NSError {
                   print("Error signing out: \(signOutError)")
               }
    }
    
    func switchToLoginScreen() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
               
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "NAVIGATIONLOGIN")
                window.rootViewController = loginViewController
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    
    
    @IBAction func btnEditProfile(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "EDIT_PROFILE") as! EditProfileViewController
        self.navigationController?.pushViewController(ventana, animated: true)
    }
    
    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in.")
            return
        }

        let userId = currentUser.uid
        let ref = Database.database().reference()

        ref.child("Users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String: Any] {
                let name = userData["Name"] as? String ?? "No name"
                let email = userData["Email"] as? String ?? "No email"
                let dateOfBirth = userData["Date_of_Birth"] as? String ?? "No date of birth"
                let username = userData["Username"] as? String ?? "No username"

                self.lbName.text = "Name: \(name)"
                self.lbEmail.text = "Email: \(email)"
                self.lbUsername.text = "Username: \(username)"
                self.lbDateBirth.text = "Date of Birth: \(dateOfBirth)"
            } else {
                print("User data not found.")
            }
        }) { (error) in
            print("Database error: \(error.localizedDescription)")
        }
    }

    
}
