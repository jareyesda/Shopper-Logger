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
    var newImages = [UIImage]()
    
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
        
        for image in images {
            newImages.append(image.rotate(radians: .pi/2)!)

        }

    }

}

//MARK: - CollectionView Delegate Methods

extension ViewOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderModel.photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photos.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        
        let image = self.newImages[indexPath.row]
        cell?.photo.image = image
            
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? PhotoViewController {
            vc.image = self.newImages[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
