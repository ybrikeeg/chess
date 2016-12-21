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
                if let nextPiece = board.getPieceAtLocation(location: nextPoint) {
                    if nextPiece.color == self.color {
                        break
                    }
                    if i == 0 {
                        if nextPiece.type == EMPTY {
                            moves.append(nextPoint)
                        }
                        if self.isAtStartingPosition {
                            let nextPoint = CGPoint(x: Int(Int(self.location.x) + i), y: Int(Int(self.location.y) + (direction * 2)))
                            if let nextPiece = board.getPieceAtLocation(location: nextPoint) {
                                if (nextPiece.type == EMPTY) {
                                    moves.append(nextPoint)
                                }
                            }
                        }
                    } else {
                        if nextPiece.type != EMPTY {
                            moves.append(nextPoint)
                        }
                    }
                }
            }
        } else if self.type == ROOK {
            let fileMoves = getFileMoves(board: board)
            moves.append(contentsOf: fileMoves)
        } else if self.type == BISHOP {
            
        }
        
        return moves
    }
    
    let file = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    private func getFileMoves(board: BoardModel) -> [CGPoint]
    {
        var moves = [CGPoint]()
        for direction in file {
            var idx = 1
            while true {
                let newPoint = CGPoint(x: Int(self.location.x) + direction.0 * idx, y: Int(self.location.y) + direction.1 * idx)
                if let newPiece = board.getPieceAtLocation(location: newPoint) {
                    if newPiece.type == EMPTY {
                        moves.append(newPoint)
                    } else if newPiece.color != self.color {
                        moves.append(newPoint)
                        break
                    } else {
                        break
                    }
                } else {
                    break
                }
                
                idx += 1
            }
        }
        return moves
    }
}
