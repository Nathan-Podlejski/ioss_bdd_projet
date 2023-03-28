//
//  DetailPlaceViewController.swift
//  bdd ios project
//
//  Created by lpiem on 28/02/2023.
//

import UIKit

class DetailPlaceViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var coordX: UITextField!
    @IBOutlet weak var coordY: UITextField!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var modifBtn: UIButton!
    
    public var place: Places?
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.text = place?.name
        if(place?.image != nil) {
            img.image = UIImage(data: place!.image!)
        }
        coordX.text = place?.coordinateLinked?.coordX
        coordY.text = place?.coordinateLinked?.coordY
        descript.text = place?.descripionCity
        

        
    }
    
    @IBAction func modifBtnPressed(_ sender: Any) {
        place?.name = name.text
        place?.coordinateLinked?.coordX = coordX.text
        place?.coordinateLinked?.coordY = coordY.text
        place?.descripionCity = descript.text
        place?.image = img.image?.pngData()
        
        saveContext()
        
        navigationController?.popViewController(animated: true)
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func selectImgBtnPressed(_ sender: Any) {
        showPickerOption()
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

extension DetailPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.img.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
}
