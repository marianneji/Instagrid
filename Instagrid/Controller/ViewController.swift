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

    // MARK: Outlets
    //Use to hide the button on the image
    @IBOutlet var imagesButtons: [UIButton]!

    //Use to store pictures in an array
    @IBOutlet var imagesArrayImageView: [UIImageView]!

    // Use to set "SelectedButton" image to the corresponding disposition
    @IBOutlet private var selectedLayoutImageViews: [UIImageView]!

    // Use to change the image "upArrow" to "leftArrow" when device is rotated
    @IBOutlet private weak var swipeDirectionArrowImageView: UIImageView!

    // Use to change the label "swipe up" to "swipe left" when device is rotated
    @IBOutlet private weak var swipeLabel: UILabel!

    // Use to share the PhotosLayoutView
    @IBOutlet weak var gridView: PhotosLayoutView!

    // MARK: Variables
    let imagePicker = UIImagePickerController()
    // Use to add images at tag
    var index = 0
    var selectedLayout: Layout = .layout1

    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySelectedLayout(at: 3)
        swipeGesture()
        changeSwipeLabelWithNotification()
    }

    // MARK: Actions
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        displaySelectedOverlay(sender)
        displaySelectedLayout(at: sender.tag)
    }

    @IBAction func tappedOnImageButton(_ sender: UIButton) {
        chooseSourceTypeForPicture(at: sender.tag)
        hideButtonsOnImages(sender)
    }

    // MARK: Swipe
    fileprivate func swipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleOrientationToShare(_:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleOrientationToShare(_:)))

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
    // Use device orientation observer with notifications
    private func changeSwipeLabelWithNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(swipeDevice(deviceOrientation:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc fileprivate func handleOrientationToShare(_ sender: UISwipeGestureRecognizer) {
        if UIDevice.current.orientation.isLandscape {
            sender.direction = .left
            swipeAnimation(translationX: -view.frame.width, y: 0)
        } else {
            sender.direction = .up
            swipeAnimation(translationX: 0, y: -view.frame.height)
        }
        checkLayoutIsFilledBeforeSharing()
    }
    // swiftlint:disable:next identifier_name
    private func swipeAnimation(translationX x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.7, animations: {
            self.gridView.transform = CGAffineTransform(translationX: x, y: y)
        })
    }

    // MARK: Checks
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
    // This function check the permission to access the photo library
    // swiftlint:disable:next cyclomatic_complexity
    func checkPermission(for sourceType: UIImagePickerController.SourceType) {
        if sourceType == .photoLibrary {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied, .restricted:
            accessDeniedAlert()
        case .authorized: // We do have the autorisation. Everything is good!
            openPhotoLibrary(at: index)
        case .notDetermined: // The user didn't gave the autorisation yet. So we go ask him
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus ==  PHAuthorizationStatus.authorized { // the user gave us the permission
                    self.openPhotoLibrary(at: self.index)
                } else if newStatus == PHAuthorizationStatus.denied {
                    self.accessDeniedAlert()
                }
            })
        @unknown default: // Unknown case - update for swift 5
            break
            }
        } else if sourceType == .camera {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .denied, .restricted:
                accessDeniedAlert()
            case .authorized: // We do have the autorisation. Everything is good!
                openCamera(at: index)
            case .notDetermined: // The user didn't gave the autorisation yet. So we go ask him
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCamera(at: self.index)
                    } else {
                        self.accessDeniedAlert()
                    }
                }
            @unknown default: // Unknown case - update for swift 5
                break
            }
        }
    }

    // MARK: Alerts/ActionSheets
    fileprivate func accessDeniedAlert() {
        // The user denied..
        let acDenied = UIAlertController(title: "Access Denied",
                                         message: "Go to settings and change it",
                                         preferredStyle: .alert)
        acDenied.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.showPlusButton(at: self.index)
        }))
        self.present(acDenied, animated: true)
    }

    func photosMissingAlert() {
        let pMA = UIAlertController(title: "Missing Pictures",
                                    message: nil,
                                    preferredStyle: .alert)
        pMA.addAction(UIAlertAction(title: "Add Photos", style: .default, handler: nil))
        present(pMA, animated: true)
        gridView.transform = .identity
        return
    }

    // Use to choose between camera or Photo library with a popup alert
    func chooseSourceTypeForPicture (at tag: Int) {
        index = tag
        let asSourceType = UIAlertController(title: "Photo Source",
                                                message: "Choose between",
                                                preferredStyle: .actionSheet)
        asSourceType.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.checkPermission(for: .camera)
        }))
        asSourceType.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.checkPermission(for: .photoLibrary)
        }))
        asSourceType.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.showPlusButton(at: tag)
        }))
        present(asSourceType, animated: true, completion: nil)
    }

    private func shareImage() {
        let image = createImageOfGridView(gridView: gridView)
        let activityViewController = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, completed, item, error in
            self.resetLayout()
        }
    }
    // MARK: Reset and Buttons
    func showPlusButton(at tag: Int) {
        if imagesArrayImageView[index].image == nil {
            imagesButtons[tag].alpha = 1
        }
    }

    func resetLayout() { // use to empty the Grid
        showButtonsOnImages()
        for image in imagesArrayImageView {
            image.image = nil
        }
        gridView.transform = .identity
    }

    fileprivate func hideButtonsOnImages(_ sender: UIButton) {
        let button = imagesButtons[index]
        button.alpha = 0.02
    }

    fileprivate func showButtonsOnImages() {
        for button in imagesButtons {
            button.alpha = 1
        }
    }
    // Use to show or hide the selected button on the selected layout
    fileprivate func displaySelectedOverlay(_ sender: UIButton) {
        for selectedLayoutImageView in selectedLayoutImageViews {
            selectedLayoutImageView.isHidden = selectedLayoutImageView.tag != sender.tag
        }
    }
    // Use to set up the grid of the selected layout
    fileprivate func displaySelectedLayout(at tag: Int) {
        for _ in selectedLayoutImageViews.enumerated() {
            switch tag {
            case 1:
                gridView.setupLayout(Layout.layout1)
                selectedLayout = .layout1
                selectedLayoutImageViews[0].isHidden = false
            case 2:
                gridView.setupLayout(Layout.layout2)
                selectedLayout = .layout2
                selectedLayoutImageViews[1].isHidden = false

            case 3:
                gridView.setupLayout(Layout.layout3)
                selectedLayout = .layout3
                selectedLayoutImageViews[2].isHidden = false

            default:
                break
            }
        }
    }
    // MARK: Picture
    func openCamera(at tag: Int) { // call the camera
        index = tag
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alertNoCamera = UIAlertController(title: "No camera Found",
                                                  message: "try on a real device",
                                                  preferredStyle: .alert)
            alertNoCamera.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alertNoCamera, animated: true)
            showPlusButton(at: tag)
        }
    }

    func openPhotoLibrary(at tag: Int) { // call the photo library
        index = tag
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imagesArrayImageView[index].image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        showPlusButton(at: index)
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

extension UIImagePickerController {
    open override var shouldAutorotate: Bool { return true }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
}
