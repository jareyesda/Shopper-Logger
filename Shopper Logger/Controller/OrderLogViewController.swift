//
//  OrderLogViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit
import CoreData

class OrderLogViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var orderNotes: UITextView!
    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var logOrderButton: UIButton!
    
    //MARK: - ViewController Variables
    
    // Date vars
    let date = Date()
    let calendar = Calendar.current
    
    // Order loggig vars
    var orderModel = OrderModel()
    var images = [UIImage]()
    var imagesURLs = [String]()
    var orders: [NSManagedObject] = []
    
    let orderLogger = OrderLoggerManager()
    let timerManager = TimerManager()
                    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        takePhotoButton.layer.cornerRadius = 15
        logOrderButton.layer.cornerRadius = 15
        
        // Time stamping order
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        dateLabel.text = "\(month)/\(day)/\(year) - \(timerManager.formatHMS(timerManager.formatHour(hour))):\(timerManager.formatHMS(minute)):\(timerManager.formatHMS(seconds))"
        orderModel.dateTime = dateLabel.text
        
        // CollectionView Delegate/Data Source
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        // TextView Delegate & Supporting func
        orderNotes.delegate = self
        setupToHideKeyboardOnTapOnView()
                
    }
    
    //MARK: - Add Photos Button functionality
    @IBAction func addPhotosButtonPressed(_ sender: UIButton) {
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    //MARK: - UIImagePickerController Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        picker.dismiss(animated: true)
        
        images.append(image)
        print(images)
        self.orderModel.photos.append(image)
        print(orderModel.photos)
        photoCollectionView.reloadData()
    
    }
    
    //MARK: - Log Order Button Functionality
    @IBAction func logOrderButtonPressed(_ sender: UIButton) {
        
//        if images.count > 0 {
//            for image in images {
//                self.imagesURLs.append(self.orderLogger.saveImages(image: image))
//            }
//        }
//
//        let imagesURLsCombined = self.imagesURLs.joined(separator: ", ")
        
//        self.orderLogger.saveOrder(dateTime: self.dateLabel.text!, orderNotes: self.orderNotes.text!, images: imagesURLsCombined)
        
        //// //// //// //// ////
        DispatchQueue.main.async {
            self.orderLogger.saveOrder(dateTime: self.dateLabel.text!, orderNotes: self.orderNotes.text!, images: self.orderLogger.coreDataObjectFromImages(images: self.images))
        }
        
        self.performSegue(withIdentifier: "unwindToOrderLog", sender: self)
        //// //// //// //// ////
        
    }
    
    //MARK: - Function that dismisses keyboard when outside is tapped
    
    func setupToHideKeyboardOnTapOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))

            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

        @objc func dismissKeyboard()
        {
            view.endEditing(true)
        }
    
}

//MARK: - UICollectionView Delegate Methods
extension OrderLogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        
        cell?.photo.image = images[indexPath.row]
            
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

//MARK: - UITextField Delegate Methods
extension OrderLogViewController: UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        orderNotes.endEditing(true)
        print(orderNotes.text!)
        return true
    }
    
}
