//
//  ViewController.swift
//  Instagrid
//
//  Created by Graphic Influence on 16/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
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
    
    // Use to share the PhotosLayoutView
    @IBOutlet weak var gridView: PhotosLayoutView!
    
    //MARK: Variables
    
    let imagePicker = UIImagePickerController()
    // Use to add images at tag
    var index = 0
    var selectedLayout: Layout = .layout1
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySelectedLayout(at: 1)
        displaySelectedLayoutButton()
        imagePicker.delegate = self
        swipeGesture()
        changeSwipeLabelWithNotification()
    }
    //MARK: Actions
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        displaySelectedOverlay(sender)
        displaySelectedLayout(at: sender.tag)
    }
    
    @IBAction func tappedOnImageButton(_ sender: UIButton) {
        chooseSourceTypeForPicture(at: sender.tag)
        hideButtonsOnImages(sender)
    }
    
    //Mark: Swipe
    fileprivate func swipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(HandleOrientationToShare(_:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(HandleOrientationToShare(_:)))
        
        swipeLeft.direction = .left
        swipeUp.direction = .up
        gridView.addGestureRecognizer(swipeLeft)
        gridView.addGestureRecognizer(swipeUp)
    }
    // Use to change label and arrow when device has been rotated
    @objc func swipeDevice(deviceOrientation: UIDeviceOrientation) {
        if UIDevice.current.orientation.isLandscape {
            swipeLabel.text = "Swipe left to share"
            swipeDirectionArrowImageView.image = UIImage(named: "Swipe Left")
        } else if UIDevice.current.orientation.isPortrait {
            swipeLabel.text = "Swipe up to share"
            swipeDirectionArrowImageView.image = UIImage(named: "Swipe Up")
        }
    }
    
    private func changeSwipeLabelWithNotification() {    // Use device orientation observer with notifications
        NotificationCenter.default.addObserver(self, selector: #selector(swipeDevice(deviceOrientation:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc fileprivate func HandleOrientationToShare(_ sender: UISwipeGestureRecognizer) {
        if UIDevice.current.orientation.isLandscape {
            sender.direction = .left
            swipeAnimation(translationX: -view.frame.width, y: 0)
        } else {
            sender.direction = .up
            swipeAnimation(translationX: 0, y: -view.frame.height)
        }
        checkLayoutIsFilledBeforeSharing()
    }
    
    private func swipeAnimation(translationX x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.7, animations: {
            self.gridView.transform = CGAffineTransform(translationX: x, y: y)
        })
    }
    
    fileprivate func checkLayoutIsFilledBeforeSharing() {
        let imageCount = imagesArrayImageView.filter { $0.image != nil }.count
        switch selectedLayout {
        case .layout1, .layout2:
            if imageCount < 3 {
                photosMissingAlert()
            } else {
                shareImage()
            }
        case .layout3:
            if imageCount < 4 {
                photosMissingAlert()
            } else {
                shareImage()
            }
        }
    }
    
     func photosMissingAlert() {
        let photosMissingAlert = UIAlertController(title: "Missing Pictures", message: "Add photos before sharing", preferredStyle: .alert)
        photosMissingAlert.addAction(UIAlertAction(title: "Add Photos", style: .default, handler: nil))
        present(photosMissingAlert, animated: true)
        gridView.transform = .identity
        return
    }
    
    private func shareImage() {
        let image = createImageOfGridView(gridView: gridView)
        let activityViewController = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, completed, item, error in
            self.resetLayout()
        }
    }
    // use to empty the layout
    func resetLayout() {
        showButtonsOnImages()
        for image in imagesArrayImageView {
            image.image = nil
        }
        gridView.transform = .identity
        index = 0
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
    // Use to show or hide the selected button on the selected layout
    fileprivate func displaySelectedOverlay(_ sender: UIButton) {
        for selectedLayoutImageView in tappedOnSelectedLayoutImageViews {
            selectedLayoutImageView.isHidden = selectedLayoutImageView.tag != sender.tag
        }
    }
    // Use to set up the grid of the selected layout
    fileprivate func displaySelectedLayout(at tag: Int) {
        for _ in tappedOnSelectedLayoutImageViews.enumerated() {
            switch tag {
            case 1:
                gridView.setupLayout(Layout.layout1)
                selectedLayout = .layout1
            case 2:
                gridView.setupLayout(Layout.layout2)
                selectedLayout = .layout2
            case 3:
                gridView.setupLayout(Layout.layout3)
                selectedLayout = .layout3
            default:
                break
            }
        }
    }
    func displaySelectedLayoutButton() {
        for selectedButton in tappedOnSelectedLayoutImageViews {
            switch selectedButton.tag {
            case 1:
                selectedButton.isHidden = false
            case 2, 3:
                selectedButton.isHidden = true
            default:
                break
            }
        }
    }
    
    // Use to choose between camera or Photo libray with a popup alert
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
    // call the camera
    func presentImageFromCamera(at tag: Int) {
        self.index = tag
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    // call the photo library
    func presentImagePicker(at tag: Int) {
        self.index = tag
        if checkPermission() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
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
    // This function check the permission to access the photo library
    func checkPermission() -> Bool {
        // By default, we consider we don't have it
        var status = false
        // We go catch the current status
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            // We do have the autorisation. Everything is good!
            status = true
        case .notDetermined:
            // The user didn't gave the autorisation yet. So we go ask him
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                if newStatus ==  PHAuthorizationStatus.authorized {
                    // the user gave us the permission
                    status = true
                }
            })
        case .denied, .restricted:
            // The user denied..
            break
        @unknown default:
            // Unknown case - update for swift 5
            break
        }
        // Value ready to be returned
        return status
    }

}


