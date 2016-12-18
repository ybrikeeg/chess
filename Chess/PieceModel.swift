//
//  PieceModel.swift
//  Chess
//
//  Created by Kirby Gee on 12/18/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class PieceModel: NSObject {

    var type: String = ""
    var location: CGPoint = CGPoint.zero
    
    init(type: String, location: CGPoint)
    {
        super.init()
        self.type = type
        self.location = location
        
        return
    }
    
}
