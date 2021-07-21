//
//  OrderLogViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit
import RealmSwift

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
    
    let orderLogger = OrderLoggerManager()
    let timerManager = TimerManager()
    
    let layout = UICollectionViewFlowLayout()
                    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height / 8
        logOrderButton.layer.cornerRadius = logOrderButton.frame.height / 8
        orderNotes.layer.cornerRadius = orderNotes.frame.height / 8
        photoCollectionView.layer.cornerRadius = photoCollectionView.frame.height / 8
        
        // Time stamping order
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        dateLabel.text = "\(month)/\(day)/\(year) - \(timerManager.formatHMS(timerManager.formatHour(hour))):\(timerManager.formatHMS(minute)):\(timerManager.formatHMS(seconds))"
        orderModel.dateTime = dateLabel.text
        
        // CollectionView Delegate/Data Source/Styling
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // TextView Delegate & Supporting func
        orderNotes.delegate = self
        orderNotes.keyboardDismissMode = .onDrag
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
        self.orderModel.photos.append(image)
        print(orderModel.photos)
        photoCollectionView.reloadData()
    
    }
    
    //MARK: - Log Order Button Functionality
    @IBAction func logOrderButtonPressed(_ sender: UIButton) {
        
        if images.count > 0 {
            for image in images {
                self.imagesURLs.append(self.orderLogger.saveImage(image: image)!)
            }
        }
        
        let newOrder = Order()
        newOrder.dateTime = dateLabel.text!
        newOrder.notes = orderNotes.text
        for imageURL in imagesURLs {
            newOrder.photos.append(imageURL)
        }

        self.orderLogger.save(order: newOrder)
                
        self.performSegue(withIdentifier: "unwindToOrderLog", sender: self)
        
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        
        cell?.photo.image = images[indexPath.row].withRoundedCorners(radius: 200)
        cell?.photo.clipsToBounds = true
            
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    
        return 10.0
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

//MARK: - Extension to Polish up UI
extension CALayer {
    
    func makeCapsule() {
        cornerRadius = frame.height / 4
    }
    
}

extension UIImage {
   // image with rounded corners
   public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
       let maxRadius = min(size.width, size.height) / 2
       let cornerRadius: CGFloat
       if let radius = radius, radius > 0 && radius <= maxRadius {
           cornerRadius = radius
       } else {
           cornerRadius = maxRadius
       }
       UIGraphicsBeginImageContextWithOptions(size, false, scale)
       let rect = CGRect(origin: .zero, size: size)
       UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
       draw(in: rect)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return image
   }
}
