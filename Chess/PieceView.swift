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
    var image: UIImageView? = nil
    init(frame: CGRect, type: String, location: CGPoint)
    {
        super.init(frame: frame)
        self.image = UIImageView(image: UIImage(named: type))
        self.image?.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        self.addSubview(self.image!)
        self.location = location
        return
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateType(type: String)
    {
        self.image?.image = UIImage(named: type)
    }
    
}
