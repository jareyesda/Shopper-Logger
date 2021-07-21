//
//  ViewOrderViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/13/21.
//

import UIKit

class ViewOrderViewController: UIViewController {
        
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var orderNotes: UITextView!
    @IBOutlet var photos: UICollectionView!
    
    var orderModel = OrderModel()
    
    var dateTime: String? = ""
    var notes: String? = ""
    var images = [UIImage]()
    
    var cornRad = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderModel.dateTime = dateTime
        orderModel.notes = notes
        orderModel.photos = images
        
        cornRad = photos.frame.height / 8
        
        orderNotes.layer.cornerRadius = cornRad
        orderNotes.isEditable = false
        orderNotes.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        orderNotes.keyboardDismissMode = .onDrag
        
        photos.layer.cornerRadius = cornRad
        photos.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        dateLabel.text = dateTime
        orderNotes.text = notes
        
        photos.delegate = self
        photos.dataSource = self
        photos.reloadData()


    }

}

//MARK: - CollectionView Delegate Methods

extension ViewOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderModel.photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photos.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        
        let image = self.images[indexPath.row]
        cell?.photo.image = image.withRoundedCorners(radius: 200)
            
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? PhotoViewController {
            vc.image = self.images[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 128)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}
