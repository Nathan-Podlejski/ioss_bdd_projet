//
//  DetailPlaceViewController.swift
//  bdd ios project
//
//  Created by lpiem on 28/02/2023.
//

import UIKit

class DetailPlaceViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var coordX: UILabel!
    @IBOutlet weak var coordY: UILabel!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var modifBtn: UIButton!
    
    public var place: Places?
    
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
        
        saveContext()
        
        navigationController?.popViewController(animated: true)
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}
