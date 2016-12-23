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
    var whitePlayer = NSMutableDictionary()
    var blackPlayer = NSMutableDictionary()
    var whiteKing: PieceModel? = nil
    var blackKing: PieceModel? = nil
    
    required init(_ model: BoardModel) {
        self.board = model.board
        self.whitePlayer = model.whitePlayer
        self.blackPlayer = model.blackPlayer
    }
    
    override init() {
        super.init()
        // initialize board and pieces
        for r in 0..<BOARD_DIMENSIONS {
            let color = (r < 4) ? BLACK: WHITE
            for c in 0..<BOARD_DIMENSIONS {
                var piece:PieceModel? = nil
                if r == 0 || r == BOARD_DIMENSIONS - 1 {
                    piece = PieceModel(type:PIECE_ORDER[c], color: color, location: CGPoint(x: c, y: r))
                    if piece?.type == KING {
                        if color == BLACK {
                            blackKing = piece
                        } else {
                            whiteKing = piece
                        }
                    }
                } else if r == 1 || r == BOARD_DIMENSIONS - 2 {
                    piece = PieceModel(type: PAWN,  color: color, location: CGPoint(x: c, y: r))
                } else {
                    piece = createEmptyPieceAtLocation(location: CGPoint(x: c, y: r))
                }
                if let piece = piece {
                    board.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                    if piece.type != EMPTY {
                        if color == BLACK {
                            blackPlayer.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                        } else {
                            whitePlayer.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                        }
                    }
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
    func movePiece(from: CGPoint, to: CGPoint, isSimulation: Bool = false)
    {
        if let piece = getPieceAtLocation(location: from) {
            piece.location = to
            piece.isAtStartingPosition = false
            if let toPiece = getPieceAtLocation(location: to) {
                if toPiece.type != EMPTY && isSimulation == false {
                    if piece.color == WHITE {
                        let count = blackPlayer.allKeys.count
                        blackPlayer.removeObject(forKey: convertCGPointToKey(location: toPiece.location))
                        assert(count - 1 == blackPlayer.allKeys.count)
                    } else {
                        let count = whitePlayer.allKeys.count
                        whitePlayer.removeObject(forKey: convertCGPointToKey(location: toPiece.location))
                        assert(count - 1 == whitePlayer.allKeys.count)
                    }
                }
            }
            self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
            self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
            
            if isSimulation == false {
                if piece.color == WHITE {
                    whitePlayer.removeObject(forKey: convertCGPointToKey(location: from))
                    whitePlayer.setValue(piece, forKey: convertCGPointToKey(location: to))
                } else {
                    blackPlayer.removeObject(forKey: convertCGPointToKey(location: from))
                    blackPlayer.setValue(piece, forKey: convertCGPointToKey(location: to))
                }
            }
            print("after moving \(from) to \(to)")
            
            //does the move put your opponent in check
            let isCheck = checkValidation(player: (piece.color == WHITE) ? WHITE : BLACK, piece: piece)
            if isCheck {
                print("+++++++++++++++++YOU ARE IN CHECK")
            }else {
                print("------------------you are not in check")
            }
            printBoard()
        }
    }
    
    func checkValidation(player: String, piece: PieceModel) -> Bool
    {
        //get opponent king
        let opponentKing = (player == WHITE) ? blackKing : whiteKing
        //get queen + knight moves from opponents king
        let superkingMoves = opponentKing?.getSuperKingmoves(board: self)
        print("super moves for king at \(opponentKing?.location)")
        print(superkingMoves)
        if (superkingMoves?.contains(piece.location))! {
            if let pieceInQuestionToCheck = getPieceAtLocation(location: piece.location) {
                //check if diagonal
                let diff = CGPoint(x: abs(piece.location.x - (opponentKing?.location.x)!), y: abs(piece.location.y - (opponentKing?.location.y)!))
                //diagonal
                if diff.x == diff.y {
                    //queen or bishop
                    if pieceInQuestionToCheck.type == QUEEN || pieceInQuestionToCheck.type == BISHOP {
                        return true
                    }
                    //pawn
                    return pieceInQuestionToCheck.type == PAWN
                }
                //on a file
                if diff.x * diff.y == 0 {
                    return pieceInQuestionToCheck.type == QUEEN || pieceInQuestionToCheck.type == ROOK
                }
                if (diff.x == 1 && diff.y == 2) || (diff.x == 2 && diff.y == 1) {
                    return pieceInQuestionToCheck.type == KNIGHT
                }
            }
        }

        return false
    }
    func unmovePiece(original: PieceModel, replacement: PieceModel)
    {
        self.board.setValue(original, forKey: convertCGPointToKey(location: original.location))
        self.board.setValue(replacement, forKey: convertCGPointToKey(location: replacement.location))
        print("after undoing")
        printBoard()
    }
    
    
    private func simulateMove(piece: PieceModel, moveTo: CGPoint) -> Bool
    {
        let originalPiece = piece.copy() as! PieceModel
        let replacedPiece = getPieceAtLocation(location: moveTo)
        let originalReplace = replacedPiece?.copy() as! PieceModel
        print("Original location: \(originalPiece.location)")
        //move piece
        movePiece(from: originalPiece.location, to: moveTo, isSimulation: true)
        //check if king is in check
        let king = (originalPiece.color == WHITE) ? whiteKing : blackKing
        print("King location \(king?.location)")
        //check pawn check
//        let pawnCheck = king!.checkValidationForType(type: PAWN, board: self)
//        for checkPosition in pawnCheck {
//            if let checkPiece = getPieceAtLocation(location: checkPosition) {
//                if checkPiece.color != king?.color && checkPiece.type == PAWN {
//                    print("in check by pawn")
//                }
//            }
//        }
//        print("pawn check \(pawnCheck)")
        //check bishop check
//        let bishopCheck = king!.checkValidationForType(type: ROOK, board: self)
//        for checkPosition in bishopCheck {
//            if let checkPiece = getPieceAtLocation(location: checkPosition) {
//                if checkPiece.color != king?.color && checkPiece.type == ROOK {
//                    print("in check by rook")
//                }
//            }
//        }
        //check knight check
        //check rook check
        //check queen check
        //check king check
        
        
        //undo move
        unmovePiece(original: originalPiece, replacement: originalReplace)
        return true
    }
    
    /**
    *   Given the grid coordinates of the touch, return the list of valid positions the piece can move to
    */
    func getValidMovesAtLocation(location: CGPoint, forPlayer: String) -> [CGPoint]
    {
        if let piece = getPieceAtLocation(location: location) {
            if piece.color != forPlayer { return [] }
            let validMoves = piece.getValidMoves(board: self)
            let originalPiece = piece.copy() as! PieceModel

            for move in validMoves {
                print(move)
//                let newBoard = simulateMove(piece: originalPiece, moveTo: move)
            }
//            print("Possible moves")
//            print(validMoves)
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
        return nil
    }
    
}
