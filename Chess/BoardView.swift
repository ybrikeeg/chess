//
//  BoardView.swift
//  Chess
//
//  Created by Kirby Gee on 12/17/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class BoardView: UIView {

    var checkers = [UIView]()
    var CHECKER_WIDTH = CGFloat(0.0)
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
        CHECKER_WIDTH = CGFloat(CGFloat(frame.size.width) / CGFloat(BOARD_DIMENSIONS))
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                let v = UIView(frame: CGRect(x: CGFloat(c) * CHECKER_WIDTH, y: CGFloat(r) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH))
                v.backgroundColor = ((r + c) % 2 == 0) ? UIColor(red:(234.0/255.0), green:(212.0/255.0), blue:(177.0/255.0), alpha:1.0) : UIColor(red:(181.0/255.0), green:(136.0/255.0), blue:(99.0/255.0), alpha:1.0)
                self.addSubview(v)
                checkers.append(v)
            }
        }
        return
    }
    
    func createPieces()
    {
        layPieces(color: "Black")
        layPieces(color: "White")
    }
    
    private func layPieces(color: String)
    {
        let offset = (color == "Black") ? 0 : 6
        for r in 0..<2 {
            for c in 0..<BOARD_DIMENSIONS {
                if (r == 0 && color == "Black") || (r == 1 && color == "White") {
                    let name = color + PIECE_ORDER[c]
                    let piece = PieceView(frame: CGRect(x: CGFloat(c) * CHECKER_WIDTH, y: CGFloat(r + offset) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH), type: name)
                    self.addSubview(piece)
                } else {
                    let name = color + "Pawn"
                    let piece = PieceView(frame: CGRect(x: CGFloat(c) * CHECKER_WIDTH, y: CGFloat(r + offset) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH), type: name)
                    self.addSubview(piece)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
