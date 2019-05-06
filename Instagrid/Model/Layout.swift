//
//  Layout.swift
//  Instagrid
//
//  Created by Graphic Influence on 25/04/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import Foundation

//
enum Layout: Int {
    case layout1 = 1
    case layout2
    case layout3
}

struct LayoutDisposition {
    
    // Default disposition of the layout is set to 1
    var selectedLayout: Layout = .layout1
    
    // Button selected for set an image
    var currentButton = 0
    
    // Check if the selected disposition is avalaible
    func dispositionIsAvalaible(_ selectedLayout: Layout) -> Bool {
        return self.selectedLayout != selectedLayout
    }
}
