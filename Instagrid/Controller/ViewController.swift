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
    
    //Use to store pictures in an array
    @IBOutlet var imagesArrayImageView: [UIImageView]!
    
    // Use to set "SelectedButton" image to the corresponding disposition
    @IBOutlet private var tappedOnSelectedLayoutImageViews: [UIImageView]!
    
    // Use to change the image "upArrow" to "leftArrow" when device is rotated
    @IBOutlet private weak var swipeDirectionArrowImageView: UIImageView!
    
    // Use to change the label "swipe up" to "swipe left" when device is rotated
    @IBOutlet private weak var swipeLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var index = 0
   
    @IBOutlet weak var gridView: PhotosLayoutView!
    
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        displaySelectedOverlay(sender)
        displaySelectedLayout(sender)
    }
    
    fileprivate func photosMissingAlert() {
        let photosMissingAlert = UIAlertController(title: "Missing Pictures", message: "Add photos before sharing", preferredStyle: .alert)
        photosMissingAlert.addAction(UIAlertAction(title: "Add Photos", style: .default, handler: nil))
        present(photosMissingAlert, animated: true)
        gridView.transform = .identity
        return
    }
    
    @IBAction func swipeToShare(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            transformGridViewWith(gesture: sender)
        case .ended, .cancelled :
            if index < 3 {
                return photosMissingAlert()
            } else {
                shareImage()
            }
        default:
            break
        }
    }
    
    private func transformGridViewWith(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gridView)
        gridView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
    }
    
    private func shareImage() {
        let image = createImageOfGridView(gridView: gridView)
        let activityViewController = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        resetLayout()
    }
    
    // use to empty the layout
    func resetLayout() {
        showButtonsOnImages()
        for image in imagesArrayImageView {
            image.image = nil
        }
        gridView.transform = .identity
        //        index = 0
    }
    
    fileprivate func hideButtonsOnImages(_ sender: UIButton) {
        let button = imagesButtons[index]
        button.alpha = 0.1
    }
    
    fileprivate func showButtonsOnImages() {
        for button in imagesButtons {
            button.alpha = 1
        }
    }
    
    @IBAction func tappedOnImageButton(_ sender: UIButton) {
        chooseSourceTypeForPicture(at: sender.tag)
        hideButtonsOnImages(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func chooseSourceTypeForPicture (at tag: Int) {
        self.index = tag
        let actionPopUpAlert = UIAlertController(title: "Photo Source", message: "Choose between", preferredStyle: .actionSheet)
        actionPopUpAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.presentImageFromCamera(at: tag)
        }))
        actionPopUpAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.presentImagePicker(at: tag)
        }))
        actionPopUpAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present((actionPopUpAlert), animated: true, completion: nil)
    }
    
    func presentImageFromCamera(at tag: Int) {
        self.index = tag
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    func presentImagePicker(at tag: Int) {
        self.index = tag
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagesArrayImageView[index].image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func createImageOfGridView(gridView: PhotosLayoutView) -> UIImage? {
        // Creates a bitmap-based graphics context and makes it the current context.
        UIGraphicsBeginImageContext(gridView.frame.size)
        // Renders the layer and its sublayers into the specified context.
        gridView.layer.render(in: UIGraphicsGetCurrentContext()!)
        // Returns an image based on the contents of the current bitmap-based graphics context.
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        
        return image
    }
}


