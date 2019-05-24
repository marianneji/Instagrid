//
//  PhotosLayoutView.swift
//  Instagrid
//
//  Created by Graphic Influence on 10/05/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit

class PhotosLayoutView: UIView {
    
    @IBOutlet weak var topLeftView: UIView?
    @IBOutlet weak var topRightView: UIView?
    @IBOutlet weak var bottomLeftView: UIView?
    @IBOutlet weak var bottomRightView: UIView?
    
    func setupLayout(_ layout: Layout) {
        self.topLeftView?.isHidden = false
        self.topRightView?.isHidden = layout.photosLayoutNumber.top == 1
        self.bottomLeftView?.isHidden = false
        self.bottomRightView?.isHidden = layout.photosLayoutNumber.bot == 1
        
    }
//    
//   func checkIfLayout(layout: Layout) -> Bool {
//        switch layout {
//        case .layout1:
//            if topLeftView == nil || bottomLeftView == nil || bottomRightView == nil {
//                return false
//            }
//        case .layout2:
//            if topLeftView == nil || bottomLeftView == nil || topRightView == nil {
//                return false
//            }
//        case .layout3:
//            if topLeftView == nil || bottomLeftView == nil || topRightView == nil || bottomRightView == nil {
//                return false
//            }
//        }
//        
//        return true
//    }
    
}
