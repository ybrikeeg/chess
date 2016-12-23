//
//  PieceModel.swift
//  Chess
//
//  Created by Kirby Gee on 12/18/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class PieceModel: NSObject, NSCopying {

    var type: String = ""
    var location: CGPoint = CGPoint.zero
    var color: String = ""
    var isAtStartingPosition = false
    
    init(type: String, color: String, location: CGPoint, starting: Bool = true)
    {
        super.init()
        self.type = type
        self.location = location
        self.color = color
        self.isAtStartingPosition = starting
        return
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = PieceModel(type: type, color: color, location: location, starting: isAtStartingPosition)
        return copy
    }
    
    func getValidMoves(board: BoardModel) -> [CGPoint]
    {
        var moves = [CGPoint]()
        if self.type == PAWN {
            let direction = (self.color == BLACK) ? 1 : -1
            for i in -1...1 {
                let nextPoint = CGPoint(x: Int(Int(self.location.x) + i), y: Int(Int(self.location.y) + direction))
                if let nextPiece = board.getPieceAtLocation(location: nextPoint) {
                    if nextPiece.color == self.color { continue }
                    if i == 0 {
                        if nextPiece.type == EMPTY {
                            moves.append(nextPoint)
                            if self.isAtStartingPosition {
                                let nextPoint = CGPoint(x: Int(Int(self.location.x) + i), y: Int(Int(self.location.y) + (direction * 2)))
                                if let nextPiece = board.getPieceAtLocation(location: nextPoint) {
                                    if nextPiece.type == EMPTY { moves.append(nextPoint) }
                                }
                            }
                        }
                    } else {
                        if nextPiece.type != EMPTY { moves.append(nextPoint) }
                    }
                }
            }
        } else if self.type == ROOK {
            moves.append(contentsOf: getMoves(type: file, board: board))
        } else if self.type == BISHOP {
            moves.append(contentsOf: getMoves(type: diag, board:board))
        } else if self.type == QUEEN {
            moves.append(contentsOf: getMoves(type: file, board: board))
            moves.append(contentsOf: getMoves(type: diag, board:board))
        } else if self.type == KNIGHT {
            moves.append(contentsOf: getMoves(type: kni, board: board, singleIter: true))
        } else if self.type == KING {
            moves.append(contentsOf: getMoves(type: neighbors, board: board, singleIter: true))
        }
        return moves
    }
    
    
    let file = [(0, 1), (1, 0), (0, -1), (-1, 0)] // rook
    let diag = [(1, 1), (-1, 1), (-1, -1), (1, -1)] // bishop
    let kni = [(2, 1), (1, 2), (-1, 2), (-2, 1), (-2, -1), (-1, -2), (1, -2), (2, -1)] //knight
    let neighbors = [(0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), (1, 0), (1, 1)] // king

    private func getMoves(type: [(Int, Int)], board: BoardModel, singleIter: Bool = false) -> [CGPoint]
    {
        var moves = [CGPoint]()
        for direction in type {
            var idx = 1
            while true {
                let newPoint = CGPoint(x: Int(self.location.x) + direction.0 * idx, y: Int(self.location.y) + direction.1 * idx)
                if let newPiece = board.getPieceAtLocation(location: newPoint) {
                    if newPiece.type == EMPTY {
                        moves.append(newPoint)
                    } else if newPiece.color != self.color {
                        moves.append(newPoint)
                        break
                    } else { break }
                } else { break }
                if singleIter { break }
                idx += 1
            }
        }
        return moves
    }
    
    func getSuperKingmoves(board: BoardModel) -> [CGPoint]
    {
        var moves = [CGPoint]()
        moves.append(contentsOf: getMoves(type: file, board: board))
        moves.append(contentsOf: getMoves(type: diag, board:board))
        moves.append(contentsOf: getMoves(type: kni, board: board, singleIter: true))
        return moves
    }
}
