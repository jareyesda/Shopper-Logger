//
//  ViewOrderViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/13/21.
//

import UIKit

class ViewOrderViewController: UIViewController {
        
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var orderNotes: UILabel!
    @IBOutlet var photos: UICollectionView!
    
    var orderModel = OrderModel()
    
    var dateTime: String? = ""
    var notes: String? = ""
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderModel.dateTime = dateTime
        orderModel.notes = notes
        orderModel.photos = images
        
        dateLabel.text = dateTime
        orderNotes.text = notes
        
        photos.delegate = self
        photos.dataSource = self
        photos.reloadData()

    }

}

//MARK: - CollectionView Delegate Methods

extension ViewOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderModel.photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photos.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        
        let image = self.images[indexPath.row]
        cell?.photo.image = image
            
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? PhotoViewController {
            vc.image = self.images[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}
