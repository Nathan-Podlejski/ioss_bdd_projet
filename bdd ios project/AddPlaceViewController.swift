//
//  AddPlaceViewController.swift
//  bdd ios project
//
//  Created by lpiem on 31/01/2023.
//

import UIKit
import CoreData

class AddPlaceViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var coordX: UITextField!
    @IBOutlet weak var coordY: UITextField!
    @IBOutlet weak var descript: UITextView!
    
    @IBOutlet weak var validBtn: UIButton!
    
    public var category: Category?
    
    let imagePickerController = UIImagePickerController()
    
    private var viewContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func selectImageButPress(_ sender: UIButton) {
        showPickerOption()
    }
    
    @IBAction func validBtnPressed(_ sender: Any) {
        let newItem = Places(context: viewContext)
        newItem.image = img.image?.pngData()
        newItem.name = name.text
        newItem.creationDate = Date()
        newItem.modificationDate = Date()
        newItem.categoryLinked = category
        newItem.isFavorite = false
        
        let coordinate = Coordinates(context: viewContext)
        coordinate.coordX = coordX.text
        coordinate.coordY = coordY.text
        
        newItem.coordinateLinked = coordinate
        
        saveContext()
        dismiss(animated: true)
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func showPickerOption () {
        let alertVC = UIAlertController(title: "Pick a photo", message: "Choose a picture from camera or library", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            guard let self = self else {
                return
            }
            let cameraImagePicker = self.imagePicker(sourceType: .camera)
            
            self.present(cameraImagePicker, animated: true) {
                self.imagePickerController.delegate = self
            }
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] (action) in
            guard let self = self else {
                return
            }
            let libraryImagePicker = self.imagePicker(sourceType: .photoLibrary)
            
            self.present(libraryImagePicker, animated: true) {
                self.imagePickerController.delegate = self
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func imagePicker (sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {

        imagePickerController.sourceType = sourceType
        return imagePickerController
    }

}

extension AddPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.img.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
}
