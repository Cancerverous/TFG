//
//  RentViewController.swift
//  TFG
//
//  Created by Luca Porzio on 13/5/24.
//

import UIKit

class RentViewController: UIViewController {
    
    var car: Car?
    var bike: Motorcycle?
    var service: Service?

    
    @IBOutlet weak var lbVehicle: UILabel!
    @IBOutlet weak var imgVehicle: UIImageView!
    @IBOutlet weak var lbExperience: UILabel!
    @IBOutlet weak var imgExperience: UIImageView!
    @IBOutlet weak var dpDate: UIDatePicker!
    @IBOutlet weak var lbTotalPrice: UILabel!
    var vehiclePrice: Int = 0
    var experiencePrice: Int = 0
    var totalPrice: Int = 0
    
    @IBOutlet weak var lbTitleExperience: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "OVERVIEW"


        if service == nil {
            if car != nil {
                loadCar()
            } else if bike != nil {
                loadBike()
            }
            lbExperience.isHidden = true
            imgExperience.isHidden = true
            lbTitleExperience.isHidden = true
        } else{
            loadAll()
        }
    }
    
    func loadCar(){
        guard let car = car else {
            print("No car data available.")
            return
        }
        lbVehicle.text = "\(car.make) \(car.model). \(car.price) €"
        
        if let url = URL(string: car.imageUrl) {
            imgVehicle.loadImage(from: url)
        }
        
        vehiclePrice = car.price
        
        lbTotalPrice.text = "\(vehiclePrice) €"
    }
    
    func loadBike(){
        guard let bike = bike else {
            print("No bike data available.")
            return
        }
        lbVehicle.text = "\(bike.make) \(bike.model). \(bike.price) €"
        
        if let url = URL(string: bike.imageUrl) {
            imgVehicle.loadImage(from: url)
        }
        
        vehiclePrice = bike.price
        lbTotalPrice.text = "\(vehiclePrice) €"
    }
    
    func loadAll(){
        if car != nil {
            loadCar()
        } else if bike != nil {
            loadBike()
        }
        
        lbExperience.isHidden = false
        imgExperience.isHidden = false
        lbTitleExperience.isHidden = false
        
        guard let service = service else {
            print("No Service data available.")
            return
        }
        lbExperience.text = "\(service.name). \(service.price) €"
        if let url = URL(string: service.imageUrl) {
            imgExperience.loadImage(from: url)
        }
        experiencePrice = service.price
        
        totalPrice = vehiclePrice+experiencePrice
        lbTotalPrice.text = "\(totalPrice) €"
    }
    
    @IBAction func btnGoToPaymentMethod(_ sender: Any) {
        let ventana = self.storyboard?.instantiateViewController(identifier: "PAYMENT_METHODS") as! PaymentMethodsViewController
        ventana.bike = bike
        ventana.car = car
        self.navigationController?.pushViewController(ventana, animated: true)
    }
}
