//
//  OrderLogViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit
import CoreData

class OrderLogViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var orderNotes: UITextView!
    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var logOrderButton: UIButton!
    
    let date = Date()
    let calendar = Calendar.current
    
    var orderModel = OrderModel()
    var images = [UIImage]()
    
    var orders: [NSManagedObject] = []
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takePhotoButton.layer.cornerRadius = 15
        logOrderButton.layer.cornerRadius = 15
        
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        dateLabel.text = "\(month)/\(day)/\(year) - \(hour):\(minute):\(seconds)"
        orderModel.dateTime = dateLabel.text
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
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
        
        images.insert(image, at: 0)
        self.orderModel.photos.append(image)
        print(orderModel.photos)
        photoCollectionView.reloadData()
    
    }
    
    //MARK: - Log Order Button Functionality
    @IBAction func logOrderButtonPressed(_ sender: UIButton) {

        saveOrder(dateTime: dateLabel.text!, orderNotes: (orderNotes.text ?? "No notes.."), images: coreDataObjectFromImages(images: images))
    
        self.performSegue(withIdentifier: "unwindToOrderLog", sender: self)
        
        let notificationName = NSNotification.Name("reloadLog")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
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
    
    //MARK: - Saving data from form to CoreData
    
    func saveOrder(dateTime: String, orderNotes: String, images: Data?) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }

          // 1
          let managedContext =
            appDelegate.persistentContainer.viewContext

          // 2
          let entity =
            NSEntityDescription.entity(forEntityName: "Order",
                                       in: managedContext)!

          let order = NSManagedObject(entity: entity,
                                       insertInto: managedContext)

          // 3
        order.setValue(dateTime, forKeyPath: "dateTime")
        order.setValue(orderNotes, forKey: "notes")
        if let safeImages = images {
            order.setValue(safeImages, forKey: "photos")
        }

          // 4
          do {
            try managedContext.save()
            orders.append(order)
          } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
          }
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
