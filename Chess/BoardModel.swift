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
                    let piece = PieceModel(type:PIECE_ORDER[c], color: color, location: CGPoint(x: c, y: r))
                    board.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                } else if r == 1 || r == BOARD_DIMENSIONS - 2 {
                    let piece = PieceModel(type: PAWN,  color: color, location: CGPoint(x: c, y: r))
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
        var arr = [(String, String)]()
        var count = 0
        for key in sortedArray {
            let piece = self.board[key] as! PieceModel
            arr.append((piece.type, key))
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
        if let piece = getPieceAtLocation(location: from) {
            piece.location = to
            piece.isAtStartingPosition = false
            self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
            self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
            printBoard()
        }
    }
    
    /**
    *   Given the grid coordinates of the touch, return the list of valid positions the piece can move to
    */
    func getValidMovesAtLocation(location: CGPoint, forPlayer: String) -> [CGPoint]
    {
        if let piece = getPieceAtLocation(location: location) {
            if piece.color != forPlayer { return [] }
            let validMoves = piece.getValidMoves(board: self)
            print("Possible moves")
            print(validMoves)
            return validMoves
        }
        return []
    }
    
    /**
     *  Given a location on the board, return the name of the piece
     */
    func getPieceAtLocation(location: CGPoint) -> PieceModel?
    {
        if let piece = self.board[convertCGPointToKey(location: location)] {
            return piece as? PieceModel
        }
        print("No piece for \(convertCGPointToKey(location: location))")
        return nil
    }
    
}
