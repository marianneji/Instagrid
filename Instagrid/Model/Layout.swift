//
//  Layout.swift
//  Instagrid
//
//  Created by Graphic Influence on 25/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import Foundation

import UIKit

enum Layout: Int {
    case layout1 = 1, layout2, layout3
    
    var photosLayoutNumber: (top: Int, bot: Int) {
        switch self {
        case .layout1:
            return (top: 1, bot: 2)
        case .layout2:
            return (top: 2, bot: 1)
        case .layout3:
            return (top: 2, bot: 2)
        }
    }
}
