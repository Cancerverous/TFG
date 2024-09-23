//
//  ServicesCollectionViewCell.swift
//  TFG
//
//  Created by Luca Porzio on 1/5/24.
//

import UIKit

class ServicesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgServices: UIImageView!
    @IBOutlet weak var lbServicesName: UILabel!
    @IBOutlet weak var btnFavorites: UIButton!
    
    func configure(with service: Service) {
        lbServicesName.text = "\(service.name)"
        
        if service.isFavorite{
            btnFavorites.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            btnFavorites.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
            if let url = URL(string: service.imageUrl) {
                imgServices.loadImage(from: url)
            }
        }
}
