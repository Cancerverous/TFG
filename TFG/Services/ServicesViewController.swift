//
//  ServicesViewController.swift
//  TFG
//
//  Created by Luca Porzio on 5/4/24.
//

import UIKit
import Firebase

class ServicesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {

    @IBOutlet weak var servicesCollection: UICollectionView!
    
    
    var ref = Database.database().reference()
    var services: [Service] = []
    
    var car: Car!
    var bike: Motorcycle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "EXPERIENCIES"

        servicesCollection.delegate = self
        servicesCollection.dataSource = self
        configureCollectionViewLayout()
        getServiceInformation()
        print("View loaded. Configuring layout and fetching service data.")
    }
    
    func configureCollectionViewLayout(){
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = servicesCollection.frame.width - padding * 2 - minimumItemSpacing
        let itemWidth = availableWidth / 2

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: 10, right: padding)
        layout.minimumInteritemSpacing = minimumItemSpacing
        layout.minimumLineSpacing = 10

        servicesCollection.collectionViewLayout = layout
    }
    
    func getServiceInformation() {
        ref.child("Services").observeSingleEvent(of: .value, with: { [self] snapshot in
            var newServices: [Service] = []
            guard let serviceEntries = snapshot.value as? [Any] else {
                print("Failed to convert snapshot value to Array.")
                return
            }

            for entry in serviceEntries.dropFirst() {
                guard let serviceInfo = entry as? [String: Any] else {
                    continue
                }

                do {
                    guard let name = serviceInfo["Name"] as? String,
                          let location = serviceInfo["Location"] as? String,
                          let imageUrl = serviceInfo["Image"] as? String,
                          let detail = serviceInfo["Details"] as? String,
                          let price = serviceInfo["Price"] as? Int,
                          let isFavorite = serviceInfo["isFavorite"] as? Bool
                     else {
                        throw NSError(domain: "DataParsing", code: 100, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid data"])
                    }

                    let service = Service(name: name, location: location, detail: detail, imageUrl: imageUrl, price: price, isFavorite: isFavorite)
                    newServices.append(service)
                    
                } catch {
                    print("Error parsing car data: \(error)")
                }
            }

            self.services = newServices
            DispatchQueue.main.async {
                self.servicesCollection.reloadData()
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let selectedService = services[indexPath.item]

        if let serviceInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "SERVICE_INFO") as? ServiceInfoViewController {
                serviceInfoVC.service = selectedService
                serviceInfoVC.bike = bike
                serviceInfoVC.car = car
                self.navigationController?.pushViewController(serviceInfoVC, animated: true)
            }
        print("User tapped cell at section \(indexPath.section), row \(indexPath.row).")
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "servicesCollectionCell", for: indexPath) as? ServicesCollectionViewCell else {
                   print("Error: Could not dequeue a ServicesCollectionViewCell. Returning a default UICollectionViewCell instead.")
                   return UICollectionViewCell()
               }
               let service = services[indexPath.item]
               cell.configure(with: service)
        print("Configuring cell for item at index \(indexPath.item) with service \(service.name).")
               return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getServiceInformation()
    }
}
