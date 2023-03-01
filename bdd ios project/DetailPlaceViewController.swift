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
    
}
