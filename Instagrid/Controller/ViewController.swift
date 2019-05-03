//
//  ViewController.swift
//  Instagrid
//
//  Created by Graphic Influence on 16/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Use to set "SelectedButton" image to the corresponding disposition
    @IBOutlet private var selectedLayout: [UIImageView]!
    
    // Use to change the image "upArrow" to "leftArrow" when device is rotated
    @IBOutlet private weak var swipeDirectionArrow: UIImageView!
    
    // Use to change the label "swipe up" to "swipe left" when device is rotated
    @IBOutlet private weak var swipeLabel: UILabel!
    
    // should contain the image grid view
    @IBOutlet weak var gridViewLayout: GridView!
    
    // constant to access the layout dispositions
    let gridView = LayoutDisposition()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

