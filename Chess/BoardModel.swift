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
            let color = (r < 4) ? "Black" : "White"
            for c in 0..<BOARD_DIMENSIONS {
                if r == 0 || r == BOARD_DIMENSIONS - 1 {
                    arr.append((type: color + PIECE_ORDER[c], position: CGPoint(x:c, y:r)))
                } else if r == 1 || r == BOARD_DIMENSIONS - 2 {
                    if color == "White" {
                        arr.append((type: color + "Pawn", position: CGPoint(x:c, y:r)))

                    }else {
                        arr.append((type: "Empty", position: CGPoint(x:c, y:r)))

                    }

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
    
    func getValidMovesAtLocation(location: CGPoint) -> [CGPoint]
    {
        let piece = getPieceAtLocation(location: location)
        let type = piece.type
        let color = (type.contains("Black")) ? "Black" : "White"
        var moves = [CGPoint]()
    
        if type.contains("Rook") {
            var path = [true, true, true, true]
            for d in 1..<BOARD_DIMENSIONS - 1{
                let pN = getPieceAtLocation(location: CGPoint(x: Int(piece.position.x), y: Int(piece.position.y) + d))
                let pE = getPieceAtLocation(location: CGPoint(x: Int(piece.position.x) + d, y: Int(piece.position.y)))
                let pS = getPieceAtLocation(location: CGPoint(x: Int(piece.position.x), y: Int(piece.position.y) - d))
                let pW = getPieceAtLocation(location: CGPoint(x: Int(piece.position.x) - d, y: Int(piece.position.y)))
                let possibilities = [pN, pE, pS, pW]
                
                for i in 0..<4 {
                    let possiblePiece = possibilities[i]
                    let possiblePieceColor = (possiblePiece.type.contains("Black")) ? "Black" : "White"

                    if path[i] {
                        if possiblePiece.type == "Empty"{
                            moves.append(possiblePiece.position)
                        } else if (color != possiblePieceColor){
                            moves.append(possiblePiece.position)
                            path[i] = false
                        } else {
                            path[i] = false
                        }
                    }
                }
            }
        }
        if type.contains("King"){
        
        }
        if type == "Pawn" {
            
        }
        print("Allowed moves for Rook")
        print(moves)
        return moves
    }
    /**
     *  Given a location on the board, return the name of the piece
     */
    private func getPieceAtLocation(location: CGPoint) -> (type: String, position: CGPoint)
    {
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                let p = self.board[r][c]
                if p.position == location {
                    return p
                }
            }
        }
        return ("Not Found", CGPoint.zero)
    }

    
}
