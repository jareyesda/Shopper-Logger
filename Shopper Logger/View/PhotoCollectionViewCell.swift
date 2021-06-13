//
//  PhotoCollectionViewCell.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photo: UIImageView!
    
    func configure(with image: UIImage) {
        photo.image = image
        photo.layer.cornerRadius = 10
    }
    
}
