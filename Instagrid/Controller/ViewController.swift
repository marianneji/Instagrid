//
//  ViewController.swift
//  Instagrid
//
//  Created by Graphic Influence on 16/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imagesArrayImageView: [UIImageView]!
    // Use to set "SelectedButton" image to the corresponding disposition
    @IBOutlet private var tappedOnSelectedLayoutImageViews: [UIImageView]!
    
    // Use to change the image "upArrow" to "leftArrow" when device is rotated
    @IBOutlet private weak var swipeDirectionArrowImageView: UIImageView!
    
    // Use to change the label "swipe up" to "swipe left" when device is rotated
    @IBOutlet private weak var swipeLabel: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    
    
    var selectedLayout: Layout?
    
    @IBOutlet weak var gridView: PhotosLayoutView!
    
    
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        displaySelectedOverlay(sender)
        displaySelectedLayout(sender)
    }
    
    @IBAction func TappedOnImageButton(_ sender: UIButton) {
        setImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deviceHasBeenRotated()
    }

    // Use to show or hide the selected button on the selected layout
    fileprivate func displaySelectedOverlay(_ sender: UIButton) {
        for selectedLayoutImageView in tappedOnSelectedLayoutImageViews {
            selectedLayoutImageView.isHidden = selectedLayoutImageView.tag != sender.tag
        }
    }
    
    // Use to set up the grid of the selected layout
    fileprivate func displaySelectedLayout(_ sender: UIButton) {
        for _ in tappedOnSelectedLayoutImageViews.enumerated() {
            switch sender.tag {
            case 1:
                gridView.setupLayout(Layout.layout1)
            case 2:
                gridView.setupLayout(Layout.layout2)
            case 3:
                gridView.setupLayout(Layout.layout3)
            default:
                break
            }
        }
    }
    
    // Use to change label and arrow when device has been rotated
    func deviceHasBeenRotated() {
        if UIDevice.current.orientation.isLandscape {
            swipeLabel.text = "Swipe left to share"
            swipeDirectionArrowImageView.image = UIImage(named: "Swipe Left")
        } else if UIDevice.current.orientation.isPortrait {
            swipeLabel.text = "Swipe up to share"
            swipeDirectionArrowImageView.image = UIImage(named: "Swipe Up")
        }
    }
    
    func setImage() {

        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImageView {
            imagesArrayImageView.append(chosenImage)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

    



