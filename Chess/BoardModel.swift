//
//  BoardModel.swift
//  Chess
//
//  Created by Kirby Gee on 12/18/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class BoardModel: NSObject {
    
    var board =  Array<Array<(type: String, position: CGPoint)>>()
    
    override init() {
        super.init()
        
        for r in 0..<BOARD_DIMENSIONS {
            var arr = [(type: String, position: CGPoint)]()
            let color = (r < 4) ? "Black" : "Whtie"
            for c in 0..<BOARD_DIMENSIONS {
                if r == 0 || r == BOARD_DIMENSIONS - 1 {
                    arr.append((type: color + PIECE_ORDER[c], position: CGPoint(x:c, y:r)))
                } else if r == 1 || r == BOARD_DIMENSIONS - 2 {
                    arr.append((type: color + "Pawn", position: CGPoint(x:c, y:r)))
                } else {
                    arr.append((type: "Empty", position: CGPoint(x:c, y:r)))
                }
            }
            self.board.append(arr)
        }
        
        for b in board {
            print(b)
        }
        
        return
    }
    
    /**
     *  Given a location on the board, return the name of the piece
     */
    func getPieceAtLocation(location: CGPoint) -> String
    {
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                let p = self.board[r][c]
                if p.position == location {
                    return p.type
                }
            }
        }
        return "not found"
    }

    
}
