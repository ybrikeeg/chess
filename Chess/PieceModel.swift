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
    var color: String = ""
    var isAtStartingPosition = true
    init(type: String, color: String, location: CGPoint)
    {
        super.init()
        self.type = type
        self.location = location
        self.color = color
        return
    }
    
    func getValidMoves(board: BoardModel) -> [CGPoint]
    {
        var moves = [CGPoint]()
        if self.type == PAWN {
            let direction = (self.color == BLACK) ? 1 : -1
            for i in -1...1 {
                let nextPoint = CGPoint(x: Int(Int(self.location.x) + i), y: Int(Int(self.location.y) + direction))
                let nextPiece = board.getPieceAtLocation(location: nextPoint)
                if i == 0 {
                    if nextPiece.type == EMPTY {
                        moves.append(nextPoint)
                    }
                    if self.isAtStartingPosition {
                        let nextPoint = CGPoint(x: Int(Int(self.location.x) + i), y: Int(Int(self.location.y) + (direction * 2)))
                        let nextPiece = board.getPieceAtLocation(location: nextPoint)
                        if (nextPiece.type == EMPTY) {
                            moves.append(nextPoint)
                        }
                    }
                } else {
                    if nextPiece.type != EMPTY  && nextPiece.color != self.color{
                        moves.append(nextPoint)
                    }
                }
            }
            
        }
        
        return moves
    }
    
}
