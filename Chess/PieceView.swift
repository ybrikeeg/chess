//
//  PieceView.swift
//  Chess
//
//  Created by Kirby Gee on 12/17/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class PieceView: UIView {

    var location = CGPoint.zero
    init(frame: CGRect, type: String, location: CGPoint)
    {
        super.init(frame: frame)
        let image = UIImageView(image: UIImage(named: type))
        image.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        self.addSubview(image)
        self.location = location
        return
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
