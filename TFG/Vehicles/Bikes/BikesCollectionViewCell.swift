//
//  BikesCollectionViewCell.swift
//  TFG
//
//  Created by Luca Porzio on 12/4/24.
//

import UIKit

class BikesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lbMakeBikes: UILabel!
    @IBOutlet weak var lbModelBikes: UILabel!
    @IBOutlet weak var btnFavorites: UIButton!
    @IBOutlet weak var imgBikes: UIImageView!
    
    
    func configure(with bike: Motorcycle) {
        lbMakeBikes.text = "\(bike.make)"
        lbModelBikes.text = "\(bike.model)"
        
        if bike.isFavorite{
            btnFavorites.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            btnFavorites.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
            if let url = URL(string: bike.imageUrl) {
                imgBikes.loadImage(from: url)
            }
        }
}
