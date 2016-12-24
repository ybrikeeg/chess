//
//  TileView.swift
//  Chess
//
//  Created by Kirby Gee on 12/18/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class TileView: UIView {

    var dot = UIView()
    let DOT_WIDTH = CGFloat(10)
    init(frame: CGRect, row: Int, col: Int) {
        super.init(frame: frame)
        
        dot = UIView(frame: CGRect(x: frame.size.width/2 - CGFloat(DOT_WIDTH/2), y: frame.size.height/2 - CGFloat(DOT_WIDTH/2), width: DOT_WIDTH, height: DOT_WIDTH))
        dot.layer.cornerRadius = CGFloat(DOT_WIDTH) / CGFloat(2)
        dot.backgroundColor = UIColor.green
        self.addSubview(dot)
        dot.isHidden = true
        
        let lab = UILabel()
        lab.text = "(\(col), \(row))"
        lab.font = UIFont.boldSystemFont(ofSize: 8)
        lab.sizeToFit()
        lab.frame.origin = CGPoint.zero
//        self.addSubview(lab)
    }

    func showDot(value: Bool)
    {
        self.dot.isHidden = !value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
