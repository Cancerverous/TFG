//
//  FavoritesCollectionViewCell.swift
//  TFG
//
//  Created by Luca Porzio on 15/5/24.
//

import UIKit

protocol FavoritesCollectionViewCellDelegate: AnyObject {
    func didTapRemoveFavorite(_ cell: FavoritesCollectionViewCell)
}

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgImage: UIImageView!
    @IBOutlet weak var lbNameMake: UILabel!
    @IBOutlet weak var lbModel: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    
    weak var delegate: FavoritesCollectionViewCellDelegate?
    
    func configure(with favorites: Favorites) {
        lbNameMake.text = "\(favorites.name)"
        lbModel.text = "\(favorites.extra)"
        
        if let url = URL(string: favorites.imageUrl) {
            imgImage.loadImage(from: url)
        }
    }
    
    @IBAction func btnFavorites(_ sender: Any) {
        print("Favorite button tapped in cell for: \(lbNameMake.text ?? "")")
        delegate?.didTapRemoveFavorite(self)
    }
}
