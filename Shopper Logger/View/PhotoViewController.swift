//
//  PhotoViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/13/21.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet var photo: UIImageView!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photo.image = image!
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Use", style: .plain, target: self, action: #selector(share(sender:)))

    }
    
    @objc func share(sender:UIView){
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()


        let objectsToShare = [image as Any] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        //Excluded Activities
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        //

        activityVC.popoverPresentationController?.sourceView = sender
        self.present(activityVC, animated: true, completion: nil)
    }
    
}


