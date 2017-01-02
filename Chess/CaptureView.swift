//
//  CaptureView.swift
//  Chess
//
//  Created by Kirby Gee on 1/1/17.
//  Copyright © 2017 Kirby Gee. All rights reserved.
//

import UIKit

class CaptureView: UIView {
    
    private var pieces = [(String, Int)]()
    private var views = [UIImageView]()
    private var sideLength: Int = -1
    private var color: String = EMPTY
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        return
    }
    
    init(frame: CGRect, color: String)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
        self.sideLength = Int(frame.width) / 15
        self.color = (color == WHITE) ? BLACK : WHITE
        return
    }
    
    private func update()
    {
        for v in views {
            v.removeFromSuperview()
        }
        views.removeAll()
        var idx = 0
        for (piece, _) in pieces {
            let v = UIImageView(frame: CGRect(x: idx * sideLength, y: 0, width: sideLength, height: sideLength))
            v.image = UIImage(named: self.color + piece)
            addSubview(v)
            views.append(v)
            idx += 1
        }
    }
    
    
    func addPiece(piece: String)
    {
        var value = 1
        if piece == PAWN { value = 1 }
        else if piece == BISHOP { value = 3 }
        else if piece == KNIGHT { value = 4 }
        else if piece == ROOK { value = 5 }
        else if piece == QUEEN { value = 9 }
        pieces.append((piece, value))
        pieces.sort(by: {$0.1 > $1.1})
        print("updated pieces \(pieces)")
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
