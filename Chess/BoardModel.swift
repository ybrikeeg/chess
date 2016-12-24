//
//  BoardModel.swift
//  Chess
//
//  Created by Kirby Gee on 12/18/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class BoardModel: NSObject, NSCopying {
    
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
    
    init(board: NSMutableDictionary, whitePlayer: NSMutableDictionary, blackPlayer: NSMutableDictionary, whiteKing: PieceModel?, blackKing: PieceModel?)
    {
        super.init()
        self.board = board
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.whiteKing = whiteKing
        self.blackKing = blackKing
        return
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = BoardModel(board: board, whitePlayer: whitePlayer, blackPlayer: blackPlayer, whiteKing: whiteKing, blackKing: blackKing)
        return copy
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
    
    func printBoard()
    {
        let keys = self.board.allKeys as! [String]
        let sortedArray = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        var arr = [String]()
        var masterArr = [[String]]()
        var count = 0
        for key in sortedArray {
            let piece = self.board[key] as! PieceModel
            var st = piece.type
            let t = (piece.color == WHITE) ? "W" : "B"
            if piece.type != EMPTY { st += " (" + t + ")" }
            st = st.padding(toLength: 10, withPad: " ", startingAt: 0)
            arr.append(st)
            count += 1
            
            if count == BOARD_DIMENSIONS {
                masterArr.append(arr)
                arr.removeAll()
                count = 0
            }
        }
    
        for r in 0..<BOARD_DIMENSIONS {
            var a = [String]()
            for c in 0..<BOARD_DIMENSIONS {
                a.append(masterArr[c][r])
            }
            print(a)
        }
    }
    func getPlayerPiece(player: String) -> [PieceModel]
    {
        var pieces = [PieceModel]()
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                if let piece = getPieceAtLocation(location: CGPoint(x: r, y: c)) {
                    if piece.color == player {
                        pieces.append(piece)
                    }
                }
            }
        }
        return pieces
    }
    
    func scoreBoard() -> Float
    {
        //assume computer is black
        var whitePieceTotal = 0
        var blackPieceTotal = 0
        var whiteLocationTotal = 0
        var blackLocationTotal = 0
        
        
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                if let piece = getPieceAtLocation(location: CGPoint(x: r, y: c)) {
                    if piece.color == WHITE {
                        whiteLocationTotal += HEAT_MAP_WHITE[Int(piece.location.y)][Int(piece.location.x)]
                    } else if piece.color == BLACK {
                        blackLocationTotal += HEAT_MAP_BLACK[Int(piece.location.y)][Int(piece.location.x)]

                    }
                }
                
            }
        }
//        for (_, piece) in whitePlayer {
//            let piece = piece as! PieceModel
//            whitePieceTotal += piece.value
//            if HEAT_MAP_WHITE[Int(piece.location.y)][Int(piece.location.x)] != 0 {
//                print("adding value of \(HEAT_MAP_WHITE[Int(piece.location.x)][Int(piece.location.y)])")
//            }
//            whiteLocationTotal += HEAT_MAP_WHITE[Int(piece.location.y)][Int(piece.location.x)]
//        }
//        
//        for (_, piece) in blackPlayer {
//            let piece = piece as! PieceModel
//            blackPieceTotal += piece.value
//            //flip loc to get heat map score
//            blackLocationTotal += HEAT_MAP_BLACK[Int(piece.location.y)][Int(piece.location.x)]
//        }
        
        return Float(blackLocationTotal - whiteLocationTotal)
//        return Float((blackPieceTotal - whitePieceTotal) * 2) + Float(blackLocationTotal - whiteLocationTotal)
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
            //does the move put your opponent in check
            var player = (piece.color == WHITE) ? BLACK : WHITE
            if isSimulation {
                player = (piece.color == BLACK) ? BLACK : WHITE
            }
            let isCheck = playerIsInCheck(player: player)
//            if isCheck {
//                print("+++++++++++++++++YOU ARE IN CHECK")
//            }else {
//                print("------------------you are not in check")
//            }
//            printBoard()
        }
    }
    
    /**
     *  Given the player and the piece just moved, check the player's opponent is in check
     */
    func playerIsInCheck(player: String) -> Bool
    {
        let king = (player == WHITE) ? whiteKing : blackKing
        //get queen + knight moves from opponents king
        let superkingMoves = king?.getSuperKingmoves(board: self)
        
        var checkCandidates = [PieceModel]()
        //get list of all pieces touching kings super-view
        for point in superkingMoves! {
            if let piece = getPieceAtLocation(location: point) {
                if piece.type != EMPTY { checkCandidates.append(piece) }
            }
        }
        for candidate in checkCandidates {
            //the piece just moved is in the king's super-view. Determine if this piece is of the appropriate type to check him
            if let pieceInQuestionToCheck = getPieceAtLocation(location: candidate.location) {
                let diff = CGPoint(x: abs(candidate.location.x - (king?.location.x)!), y: abs(candidate.location.y - (king?.location.y)!))
                //diagonal
                if diff.x == diff.y {
                    //queen or bishop
                    if pieceInQuestionToCheck.type == QUEEN || pieceInQuestionToCheck.type == BISHOP { return true }
                    //pawn
                    if pieceInQuestionToCheck.type == PAWN && diff.x == 1 { return true }
                }
                    //on a file
                else if diff.x * diff.y == 0 {
                    if pieceInQuestionToCheck.type == QUEEN || pieceInQuestionToCheck.type == ROOK { return true }
                }
                    //knight
                else if (diff.x == 1 && diff.y == 2) || (diff.x == 2 && diff.y == 1) { return pieceInQuestionToCheck.type == KNIGHT }
            }
        }
        return false
    }
    
    func unmovePiece(original: PieceModel, replacement: PieceModel)
    {
        self.board.setValue(original, forKey: convertCGPointToKey(location: original.location))
        self.board.setValue(replacement, forKey: convertCGPointToKey(location: replacement.location))
        if original.type == KING {
            if original.color == WHITE {
                whiteKing = original
            } else {
                blackKing = original
            }
        }
//        print("after undoing")
//        printBoard()
    }
    
    
    private func simulateMove(piece: PieceModel, moveTo: CGPoint) -> Bool
    {
        var isValidMove = true
        let originalPiece = piece.copy() as! PieceModel
        let replacedPiece = getPieceAtLocation(location: moveTo)
        let originalReplace = replacedPiece?.copy() as! PieceModel
        
//        print("Original location: \(originalPiece.location)")
        //move piece
        movePiece(from: originalPiece.location, to: moveTo, isSimulation: true)        
        //assume player is the current player
        if playerIsInCheck(player: originalPiece.color) {
            isValidMove = false
        }
        //undo move
        unmovePiece(original: originalPiece, replacement: originalReplace)
        
        if originalPiece.color == WHITE {
            self.whitePlayer[convertCGPointToKey(location: originalPiece.location)] = originalPiece
        } else {
            self.blackPlayer[convertCGPointToKey(location: originalPiece.location)] = originalPiece
        }

        return isValidMove
    }
    
    /**
     *   Given the grid coordinates of the touch, return the list of valid positions the piece can move to
     */
    func getValidMovesAtLocation(location: CGPoint, forPlayer: String) -> [CGPoint]
    {
        if let piece = getPieceAtLocation(location: location) {
            if piece.color != forPlayer { return [] }
            var validMoves = piece.getValidMoves(board: self)
            let originalPiece = piece.copy() as! PieceModel
            
            for move in validMoves {
                let isValid = simulateMove(piece: originalPiece, moveTo: move)
                if !isValid {
                    if let idx = validMoves.index(of: move) {
                        validMoves.remove(at: idx)
                    }
                    print("\(move) is NOT valid")
                }
            }
            
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
