//
//  Layout.swift
//  Instagrid
//
//  Created by Graphic Influence on 25/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import Foundation



enum Layout: Int {
    case layout1 = 1
    case layout2
    case layout3
    
    var photosLayoutNumber: PhotosLayoutNumber {
        switch self {
        case .layout1:
            return PhotosLayoutNumber(top: 1, bot: 2)
        case .layout2:
            return PhotosLayoutNumber(top: 2, bot: 1)
        case .layout3:
            return PhotosLayoutNumber(top: 2, bot: 2)
        }
    }
    
}

struct PhotosLayoutNumber {
    
    let top: Int
    
    let bot: Int
}

