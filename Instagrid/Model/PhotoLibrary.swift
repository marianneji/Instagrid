//
//  PhotoLibrary.swift
//  Instagrid
//
//  Created by Graphic Influence on 20/05/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import Foundation

class PHPhotolibrary : NSObject {
    
    enum PHAuthorizationStatus: Int {
        case notDetermined = 1, restricted, denied, authorized
    }
}
