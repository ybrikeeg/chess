//
//  BoardModel.swift
//  Chess
//
//  Created by Kirby Gee on 12/18/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class BoardModel: NSObject {
    
    var board = NSMutableDictionary()
    
    
    override init() {
        super.init()
        
        // initialize board and pieces
        for r in 0..<BOARD_DIMENSIONS {
            let color = (r < 4) ? BLACK: WHITE
            for c in 0..<BOARD_DIMENSIONS {
                if r == 0 || r == BOARD_DIMENSIONS - 1 {
                    let piece = PieceModel(type: color + PIECE_ORDER[c], location: CGPoint(x: c, y: r))
                    board.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                } else if r == 1 || r == BOARD_DIMENSIONS - 2 {
                    let piece = PieceModel(type: color + "Pawn", location: CGPoint(x: c, y: r))
                    board.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                } else {
                    let piece = createEmptyPieceAtLocation(location: CGPoint(x: c, y: r))
                    board.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                }
            }
        }
        
        printBoard()
        return
    }
    
    
    private func convertCGPointToKey(location: CGPoint) -> String
    {
        let newPoint = CGPoint(x: Int(location.x), y: Int(location.y))
        return NSStringFromCGPoint(newPoint)
    }
    
    private func printBoard()
    {
        print("printing board")
        let keys = self.board.allKeys as! [String]
        let sortedArray = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        var arr = [String]()
        var count = 0
        for key in sortedArray {
            arr.append(key)
            count += 1
            
            
            if count == BOARD_DIMENSIONS {
                print(arr)
                arr.removeAll()
                count = 0
            }
        }

    }

    /**
    *   Move a piece from location to location
    */
    func movePiece(from: CGPoint, to: CGPoint)
    {
        let piece = self.board[convertCGPointToKey(location: from)] as! PieceModel
        piece.location = to
        self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
        self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
        printBoard()
    }
    
    /**
    *   Given the grid coordinates of the touch, return the list of valid positions the piece can move to
    */
    func getValidMovesAtLocation(location: CGPoint, forPlayer: String) -> [CGPoint]
    {
        let piece = getPieceAtLocation(location: location)
        let type = piece.type
        let color = (type.contains(BLACK)) ? BLACK : WHITE
        if color != forPlayer {
            return []
        }
        var moves = [CGPoint]()
        
        if type.contains("Rook") {
            var path = [true, true, true, true]
            for d in 1..<BOARD_DIMENSIONS - 1{
                let pN = getPieceAtLocation(location: CGPoint(x: Int(piece.location.x), y: Int(piece.location.y) + d))
                let pE = getPieceAtLocation(location: CGPoint(x: Int(piece.location.x) + d, y: Int(piece.location.y)))
                let pS = getPieceAtLocation(location: CGPoint(x: Int(piece.location.x), y: Int(piece.location.y) - d))
                let pW = getPieceAtLocation(location: CGPoint(x: Int(piece.location.x) - d, y: Int(piece.location.y)))
                let possibilities = [pN, pE, pS, pW]
                
                for i in 0..<4 {
                    let possiblePiece = possibilities[i]
                    if possiblePiece.type == NOT_FOUND {
                        continue
                    }
                    let possiblePieceColor = (possiblePiece.type.contains(BLACK)) ? BLACK : WHITE
                    
                    if path[i] {
                        if possiblePiece.type == EMPTY {
                            moves.append(possiblePiece.location)
                        } else if (color != possiblePieceColor){
                            moves.append(possiblePiece.location)
                            path[i] = false
                        } else {
                            path[i] = false
                        }
                    }
                }
            }
        }
        if type.contains("Pawn") {
            let direction = (color == BLACK) ? 1 : -1
            for i in -1...1{
                let next = getPieceAtLocation(location: CGPoint(x: Int(piece.location.x) + i, y: Int(piece.location.y) + direction))
                if next.type == NOT_FOUND {
                    continue
                }
                
                if i != 0 {
                    let possiblePieceColor = (next.type.contains(BLACK)) ? BLACK : WHITE
                    if possiblePieceColor != color && next.type != EMPTY {
                        moves.append(next.location)
                    }
                } else {
                    moves.append(next.location)
                    let two = getPieceAtLocation(location: CGPoint(x: Int(piece.location.x) + i, y: Int(piece.location.y) + (direction * 2)))
                    if two.type == EMPTY {
                        moves.append(two.location)
                    }
                }
            }
        }
        print("Possible moves")
        print(moves)
        return moves
    }
    
    /**
     *  Given a location on the board, return the name of the piece
     */
    private func getPieceAtLocation(location: CGPoint) -> PieceModel
    {
        if let piece = self.board[convertCGPointToKey(location: location)] {
            return piece as! PieceModel
        }
        print("No piece for \(convertCGPointToKey(location: location))")
        return NOT_FOUND_PIECE
    }
    
}
