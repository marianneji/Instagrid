//
//  ViewController.swift
//  Instagrid
//
//  Created by Graphic Influence on 16/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Use to hide the button on the image
    @IBOutlet var imagesButtons: [UIButton]!
    
    @IBOutlet var imagesArrayImageView: [UIImageView]!
    
    // Use to set "SelectedButton" image to the corresponding disposition
    @IBOutlet private var tappedOnSelectedLayoutImageViews: [UIImageView]!
    
    // Use to change the image "upArrow" to "leftArrow" when device is rotated
    @IBOutlet private weak var swipeDirectionArrowImageView: UIImageView!
    
    // Use to change the label "swipe up" to "swipe left" when device is rotated
    @IBOutlet private weak var swipeLabel: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    var index = 0
    
    
    
    var selectedLayout: Layout?
    
    @IBOutlet weak var gridView: PhotosLayoutView!
    
    
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        displaySelectedOverlay(sender)
        displaySelectedLayout(sender)
    }
    
    fileprivate func hideButtonsOnImages(_ sender: UIButton) {
        let button = imagesButtons[index]
            button.isHidden = true
        
    }
    fileprivate func showButtonsOnImages(_ sender: UIButton) {
        let button = imagesButtons[index]
        button.isHidden = false
        
    }
    
    @IBAction func tappedOnImageButton(_ sender: UIButton) {
        presentImagePicker(at: sender.tag)
        hideButtonsOnImages(sender)
        
        
    }
    // use to empty the layout
    func resetLayout() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        swipeDevice()
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
    func swipeDevice() {
        if UIDevice.current.orientation.isLandscape {
            swipeLabel.text = "Swipe left to share"
            swipeDirectionArrowImageView.image = UIImage(named: "Swipe Left")
        } else if UIDevice.current.orientation.isPortrait {
            swipeLabel.text = "Swipe up to share"
            swipeDirectionArrowImageView.image = UIImage(named: "Swipe Up")
        }
    }
    
    func presentImagePicker(at tag: Int) {
        
        self.index = tag
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagesArrayImageView[index].image = image
            
        }
        dismiss(animated: true, completion: nil)
    }
}















