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
    var pictureToSend: [UIImage] {
        // use to transform object
        return self.imagesArrayImageView.compactMap { $0.image }
    }
    
    
    
    var selectedLayout: Layout?
    
    @IBOutlet weak var gridView: PhotosLayoutView!
    
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        displaySelectedOverlay(sender)
        displaySelectedLayout(sender)
    }
    
    @IBAction func swipeToShare(_ sender: UIPanGestureRecognizer) {
        //        let screenWidth = UIScreen.main.bounds.width
        //        var translationTransform: CGAffineTransform
        
        switch sender.state {
        case .began, .changed:
            transformGridViewWith(gesture: sender)
        case .ended, .cancelled :
            if imagesArrayImageView.count < 3 {
                let photosMissingAlert = UIAlertController(title: "Missing Pictures", message: "Add photos before sharing", preferredStyle: .alert)
                photosMissingAlert.addAction(UIAlertAction(title: "Add Photos", style: .default, handler: nil))
                present(photosMissingAlert, animated: true)
                gridView.transform = .identity
                return
                
                
            } else {
                shareImage()
                resetLayout()
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
        
        gridView.transform = .identity
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
    
    // use to empty the layout
    func resetLayout() {
        showButtonsOnImages()
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
    
    func chooseSourceTypeForPicture (at tag: Int) {
        
        self.index = tag
        let actionPopUp = UIAlertController(title: "Photo Source", message: "Choose between", preferredStyle: .actionSheet)
        actionPopUp.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.presentImageFromCamera(at: tag)
        }))
        actionPopUp.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.presentImagePicker(at: tag)
        }))
        actionPopUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present((actionPopUp), animated: true, completion: nil)
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


