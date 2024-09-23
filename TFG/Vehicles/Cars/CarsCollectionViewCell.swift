//
//  CarsCollectionViewCell.swift
//  TFG
//
//  Created by Luca Porzio on 26/4/24.
//

import UIKit

class CarsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lbMakeCars: UILabel!
    @IBOutlet weak var lbModelCars: UILabel!
    @IBOutlet weak var imgCars: UIImageView!
    @IBOutlet weak var btnFavorites: UIButton!
    
    func configure(with car: Car) {
            lbMakeCars.text = "\(car.make)"
        lbModelCars.text = "\(car.model)"
        
        if car.isFavorite {
            btnFavorites.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            btnFavorites.setImage(UIImage(systemName: "heart"), for: .normal)
        }

            if let url = URL(string: car.imageUrl) {
                imgCars.loadImage(from: url)  
            }
        }
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}

