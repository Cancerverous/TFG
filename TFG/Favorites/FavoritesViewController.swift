//
//  FavoritesViewController.swift
//  TFG
//
//  Created by Luca Porzio on 2/4/24.
//

import UIKit
import Firebase

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FavoritesCollectionViewCellDelegate {
    
    @IBOutlet weak var favoritesCollection: UICollectionView!
    
    var ref = Database.database().reference()
    var favorites: [Favorites] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        favoritesCollection.delegate = self
        favoritesCollection.dataSource = self
        configureCollectionViewLayout()
        getFavoriteInformation()
        print("View loaded. Configuring layout and fetching favorite data.")

    }
    
    func configureCollectionViewLayout(){
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = favoritesCollection.frame.width - padding * 2 - minimumItemSpacing
        let itemWidth = availableWidth / 2

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: 10, right: padding)
        layout.minimumInteritemSpacing = minimumItemSpacing
        layout.minimumLineSpacing = 10

        favoritesCollection.collectionViewLayout = layout
    }
    
    func getFavoriteInformation() {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in")
            return
        }
        let uid = user.uid
        
        ref.child("Favorites").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            var newFavorites: [Favorites] = []
            
            guard let favoriteEntries = snapshot.value as? [String: Any] else {
                print("Failed to convert snapshot value to [String: Any]")
                return
            }
            
            print("Successfully fetched snapshot: \(favoriteEntries)")

            for (key, value) in favoriteEntries {
                print("Processing entry with key: \(key)")
                
                guard let favoriteInfo = value as? [String: Any] else {
                    print("Failed to cast entry to [String: Any]: \(value)")
                    continue 
                }

                do {
                    guard let name = favoriteInfo["Name"] as? String,
                          let imageUrl = favoriteInfo["Image"] as? String,
                          let extra = favoriteInfo["Extra"] as? String,
                          let licensePlate = favoriteInfo["License_Plate"] as? String,
                            let type = favoriteInfo["Type"] as? String
                    else {
                        print("Missing or invalid data in entry: \(favoriteInfo)")
                        throw NSError(domain: "DataParsing", code: 100, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid data"])
                    }

                    let favorite = Favorites(name: name, imageUrl: imageUrl, extra: extra, licensePlate: licensePlate, type: type)
                    newFavorites.append(favorite)
                    print("Added new favorite: \(favorite)")

                } catch {
                    print("Error parsing favorite data: \(error)")
                }
            }

            self.favorites = newFavorites
            print("Final favorites list: \(self.favorites)")

            DispatchQueue.main.async {
                self.favoritesCollection.reloadData()
                print("Favorites collection reloaded")
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoritesCollectionCell", for: indexPath) as? FavoritesCollectionViewCell else {
            print("Error: Could not dequeue a FavoritesCollectionViewCell. Returning a default UICollectionViewCell instead.")
            return UICollectionViewCell()
        }
        let favorites = favorites[indexPath.item]
        cell.configure(with: favorites)
        cell.delegate = self
        print("Configuring cell for item at index \(indexPath.item) with service \(favorites.name).")
        return cell
    }
    
    func didTapRemoveFavorite(_ cell: FavoritesCollectionViewCell) {
            print("didTapRemoveFavorite called")
            guard let indexPath = favoritesCollection.indexPath(for: cell) else {
                print("Error: Could not find index path for cell.")
                return
            }
            print("Found index path: \(indexPath.row)")
            
            guard let user = Auth.auth().currentUser else {
                print("Error: User is not authenticated.")
                return
            }
            let uid = user.uid
            let favorite = favorites[indexPath.row]
            
            print("Attempting to remove favorite with license plate: \(favorite.licensePlate) at index: \(indexPath.row)")

            // Remove the favorite from Firebase
            ref.child("Favorites").child(uid).queryOrdered(byChild: "License_Plate").queryEqual(toValue: favorite.licensePlate).observeSingleEvent(of: .value) { snapshot in
            print("Firebase query completed. Processing snapshot.")
                
            if snapshot.exists() {
                print("Snapshot exists. Proceeding with deletion.")
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        print("Found matching favorite entry in Firebase. Removing it now.")
                        snapshot.ref.removeValue { error, _ in
                            if let error = error {
                                print("Error removing favorite from Firebase: \(error.localizedDescription)")
                            } else {
                                print("Favorite removed from Firebase successfully")
                                // Remove the favorite from the local array
                                self.favorites.remove(at: indexPath.row)
                                // Reload the collection view
                                self.favoritesCollection.deleteItems(at: [indexPath])
                                print("Favorite removed from local array and collection view updated.")
                                // Update the isFavorite property in the corresponding table
                                if favorite.type == "Services"{
                                    self.updateIsFavoriteService(for: favorite.name, in: favorite.type)
                                }else{
                                    self.updateIsFavorite(for: favorite.licensePlate, in: favorite.type)
                                }
                            }
                        }
                    }
                }
            } else {
                print("Snapshot does not exist. Nothing to delete.")
            }
        } withCancel: { error in
            print("Error occurred during Firebase query: \(error.localizedDescription)")
        }
    }
        
    func updateIsFavorite(for licensePlate: String, in table: String) {
        print("Attempting to update isFavorite property for \(table) with license plate: \(licensePlate)")
        ref.child(table).observeSingleEvent(of: .value) { snapshot in
            guard let items = snapshot.value as? [Any] else {
                print("Failed to cast \(table) snapshot to array")
                return
            }

            for (index, item) in items.enumerated() {
                if var itemDict = item as? [String: Any], let itemLicensePlate = itemDict["License_Plate"] as? String, itemLicensePlate == licensePlate {
                    itemDict["isFavorite"] = false
                    self.ref.child("\(table)/\(index)").updateChildValues(itemDict) { error, _ in
                        if let error = error {
                            print("Error updating isFavorite property: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated isFavorite property for \(table) with license plate: \(licensePlate)")
                        }
                    }
                    break
                }
            }
        } withCancel: { error in
            print("Error occurred while updating isFavorite property: \(error.localizedDescription)")
        }
    }
    
    func updateIsFavoriteService(for name: String, in table: String) {
        print("Attempting to update isFavorite property for \(table) with name: \(name)")
        ref.child(table).observeSingleEvent(of: .value) { snapshot in
            guard let items = snapshot.value as? [Any] else {
                print("Failed to cast \(table) snapshot to array")
                return
            }

            for (index, item) in items.enumerated() {
                if var itemDict = item as? [String: Any], let itemName = itemDict["Name"] as? String, itemName == name {
                    itemDict["isFavorite"] = false
                    self.ref.child("\(table)/\(index)").updateChildValues(itemDict) { error, _ in
                        if let error = error {
                            print("Error updating isFavorite property: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated isFavorite property for \(table) with name: \(name)")
                        }
                    }
                    break
                }
            }
        } withCancel: { error in
            print("Error occurred while updating isFavorite property: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavoriteInformation()
    }
}
