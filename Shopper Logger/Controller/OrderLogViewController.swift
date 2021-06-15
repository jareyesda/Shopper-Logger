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
    var orders: [NSManagedObject] = []
    
    let orderLogger = OrderLoggerManager()
                    
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
        
        dateLabel.text = "\(month)/\(day)/\(year) - \(formatHMS(formatHour(hour))):\(formatHMS(minute)):\(formatHMS(seconds))"
        orderModel.dateTime = dateLabel.text
        
        // CollectionView Delegate/Data Source
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        // TextView Delegate & Supporting func
        orderNotes.delegate = self
        setupToHideKeyboardOnTapOnView()
        
    }
    
    //MARK: - Time formatting functions
    func formatHMS(_ number: Int) -> String {
        var retVal = ""
        if (number < 10) {
            retVal = "0\(number)"
        } else {
            retVal = "\(number)"
        }
        return retVal
    }
    
    func formatHour(_ hour: Int) -> Int {
        var retVal = hour
        if hour > 12 {
            retVal -= 12
        }
        return retVal
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
        
        images.insert(image, at: 0)
        self.orderModel.photos.append(image)
        print(orderModel.photos)
        photoCollectionView.reloadData()
    
    }
    
    //MARK: - Log Order Button Functionality
    @IBAction func logOrderButtonPressed(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.orderLogger.saveOrder(dateTime: self.dateLabel.text!, orderNotes: self.orderNotes.text!, images: self.coreDataObjectFromImages(images: self.images))
        }
        
        self.performSegue(withIdentifier: "unwindToOrderLog", sender: self)
        
    }
    
    // Turning image array to data type for storage in CoreData
    func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
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
extension OrderLogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath) as? PhotoCollectionViewCell
        
        let image = self.orderModel.photos[indexPath.row]
        cell?.photo.image = image
            
        return cell!
        
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
