//
//  HomeViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var imgCars: UIImageView!
    
    @IBOutlet weak var imgBikes: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let carsTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.carsTapped(gesture:)))
        
        let bikesTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.bikesTapped(gesture:)))
        
        imgCars.addGestureRecognizer(carsTapGesture)
        imgCars.isUserInteractionEnabled = true
        
        imgBikes.addGestureRecognizer(bikesTapGesture)
        imgBikes.isUserInteractionEnabled = true
        
    }
    
    @IBAction func btnReturnVehicle(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "RETURN_VEHICLE") as! ReturnVehicleViewController
        self.navigationController?.pushViewController(ventana, animated: true)
    }
    
    @objc func carsTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Cars Tapped")
            let ventana = self.storyboard?.instantiateViewController(identifier: "CARS") as! CarsViewController
            self.navigationController?.pushViewController(ventana, animated: true)
        }
    }
    
    @objc func bikesTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Bikes Tapped")
            let ventana = self.storyboard?.instantiateViewController(identifier: "BIKES") as! BikesViewController
            self.navigationController?.pushViewController(ventana, animated: true)
        }
    }
}
