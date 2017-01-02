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
    let NO_CASTLE = 0
    let KING_SIDE_CASTLE = 1
    let QUEEN_SIDE_CASTLE = 2
    
    required init(_ model: BoardModel) {
        self.board = model.board
    }
    
    init(board: NSMutableDictionary)
    {
        super.init()
        self.board = board
        return
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = BoardModel(board: board)
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
//                    piece = PieceModel(type:PIECE_ORDER[c], color: color, location: CGPoint(x: c, y: r))
                    if PIECE_ORDER[c] == KING {
                        piece = PieceModel(type:PIECE_ORDER[c], color: color, location: CGPoint(x: c, y: r))
                    } else {
                        piece = createEmptyPieceAtLocation(location: CGPoint(x: c, y: r))
                    }
                } else if r == 1 || r == BOARD_DIMENSIONS - 2 {
//                    piece = PieceModel(type: PAWN,  color: color, location: CGPoint(x: c, y: r))
                    if abs(c) < 2 && color == WHITE {
                        piece = PieceModel(type:QUEEN, color: color, location: CGPoint(x: c, y: r))
                    } else {
                        piece = createEmptyPieceAtLocation(location: CGPoint(x: c, y: r))
                    }
                } else {
                    piece = createEmptyPieceAtLocation(location: CGPoint(x: c, y: r))
                }
                if let piece = piece {
                    board.setValue(piece, forKey: convertCGPointToKey(location: piece.location))
                }
            }
        }
        printBoard()
        return
    }
    
    /*
     *  Get the king for the specificed player
     */
    func getKingForPlayer(player: String) -> PieceModel? {
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                if let piece = getPieceAtLocation(location: CGPoint(x: r, y: c)) {
                    if piece.color == player && piece.type == KING {
                        return piece
                    }
                }
            }
        }
        return nil
    }
    
    /*
     *  Get all the pieces for the specificed player
     */
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
    
    /*
     *  Score the board based on piece differential, piece location, and more to come
     */
    func getBoardScoringHeuristic() -> Float
    {
        //assume computer is black
        var whitePieceTotal:Float = 0.0
        var blackPieceTotal:Float = 0.0
        var whiteLocationTotal:Float = 0.0
        var blackLocationTotal:Float = 0.0
        
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                if let piece = getPieceAtLocation(location: CGPoint(x: r, y: c)) {
                    if piece.color == WHITE {
                        whiteLocationTotal += piece.getLocationScore()
                        whitePieceTotal += piece.value
                    } else if piece.color == BLACK {
                        blackLocationTotal += piece.getLocationScore()
                        blackPieceTotal += piece.value
                    }
                }
            }
        }
        return Float((blackPieceTotal - whitePieceTotal) * 10) + Float(blackLocationTotal - whiteLocationTotal)
    }
    
    /**
     *   Move a piece from location to location
     */
    func movePiece(from: CGPoint, to: CGPoint, isSimulation: Bool = false, isCastle: Int = 0) -> MoveResult
    {
        var result = MoveResult(pieceCapture: EMPTY, checkType: .None)
        if let piece = getPieceAtLocation(location: from) {
            piece.location = to
            piece.isAtStartingPosition = false
            
            if let capture = getPieceAtLocation(location: to) {
                result.pieceCapture = capture.type
            }
            
            var isCastle = isCastle
            if piece.type == KING && (to.x - from.x == 2) {
                isCastle = KING_SIDE_CASTLE
            } else if piece.type == KING && (to.x - from.x == -2) {
                isCastle = QUEEN_SIDE_CASTLE
            }
            
            if piece.type == PAWN && ((piece.location.y == 0 && piece.color == WHITE) || (Int(piece.location.y) == BOARD_DIMENSIONS - 1 && piece.color == BLACK)) {
                piece.type = QUEEN
                self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
                self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
            } else if isCastle == NO_CASTLE {
                self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
                self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
            } else if isCastle == KING_SIDE_CASTLE {
                //move king
                self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
                self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
                //move rook
                let cornerLoc = CGPoint(x: BOARD_DIMENSIONS - 1, y: Int(piece.location.y))
                if let rook = getPieceAtLocation(location: cornerLoc){
                    let newRookPos = CGPoint(x: from.x + 1, y: piece.location.y)
                    rook.isAtStartingPosition = false
                    rook.location = newRookPos
                    self.board.setValue(rook, forKey: convertCGPointToKey(location: newRookPos))
                    self.board.setValue(createEmptyPieceAtLocation(location: cornerLoc), forKey: convertCGPointToKey(location: cornerLoc))
                } else { assertionFailure("Rook not found") }
            } else if isCastle == QUEEN_SIDE_CASTLE {
                //move king
                self.board.setValue(piece, forKey: convertCGPointToKey(location: to))
                self.board.setValue(createEmptyPieceAtLocation(location: from), forKey: convertCGPointToKey(location: from))
                //move rook
                let cornerLoc = CGPoint(x: 0, y: Int(piece.location.y))
                if let rook = getPieceAtLocation(location: cornerLoc){
                    let newRookPos = CGPoint(x: from.x - 1, y: piece.location.y)
                    rook.isAtStartingPosition = false
                    rook.location = newRookPos
                    self.board.setValue(rook, forKey: convertCGPointToKey(location: newRookPos))
                    self.board.setValue(createEmptyPieceAtLocation(location: cornerLoc), forKey: convertCGPointToKey(location: cornerLoc))
                } else { assertionFailure("Rook not found") }
            }
            //does the move put your opponent in check
            var player = (piece.color == WHITE) ? BLACK : WHITE
            //make sure
            if isSimulation {
                player = (piece.color == BLACK) ? BLACK : WHITE
            } else {
                result.checkType = isCheckmate(player: player)
            }
            
            if result.checkType != .Checkmate {
                result.checkType = isCheck(player: player)
            }
            
        }
        return result
    }
    
    /**
     *  Given the player and the piece just moved, check the player's opponent is in check
     */
    func isCheck(player: String) -> CheckType
    {
        let king = getKingForPlayer(player: player)
        //assert(king == nil, "Could not find king")
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
            let diff = CGPoint(x: candidate.location.x - (king?.location.x)!, y: candidate.location.y - (king?.location.y)!)
            //diagonal
            if abs(diff.x) == abs(diff.y) {
                //queen or bishop
                if candidate.type == QUEEN || candidate.type == BISHOP { return .Check }
                //pawn
                let direction = (king?.color == BLACK) ? 1 : -1
                if candidate.type == PAWN && Int(diff.y) == direction { return .Check }
                if (abs(diff.x) == 1 && abs(diff.y) == 1) && candidate.type == KING { return .Check }
            }
            //on a file
            else if diff.x * diff.y == 0 {
                if candidate.type == QUEEN || candidate.type == ROOK { return .Check }
                if (abs(diff.x) + abs(diff.y) == 1) && candidate.type == KING { return .Check }
            }
            //knight
            else if candidate.type == KNIGHT && ((abs(diff.x) == 1 && abs(diff.y) == 2) || (abs(diff.x) == 2 && abs(diff.y) == 1)) { return .Check }
        }
        return .None
    }
    
    /**
     *  Unmoves a piece to restore the state of the board
     */
    func unmovePiece(original: PieceModel, replacement: PieceModel, isCastle: Int = 0)
    {
        var isCastle = isCastle
        if original.type == KING && (replacement.location.x - original.location.x == 2) {
            isCastle = KING_SIDE_CASTLE
        } else if original.type == KING && (replacement.location.x - original.location.x == -2) {
            isCastle = QUEEN_SIDE_CASTLE
        }
        if isCastle == NO_CASTLE {
            self.board.setValue(original, forKey: convertCGPointToKey(location: original.location))
            self.board.setValue(replacement, forKey: convertCGPointToKey(location: replacement.location))
        } else if isCastle == KING_SIDE_CASTLE {
            //get rook
            let cornerLoc = CGPoint(x: BOARD_DIMENSIONS - 1, y: Int(original.location.y))
            let currentRookLoc = CGPoint(x: Int(original.location.x + 1), y: Int(original.location.y))
            if let rook = getPieceAtLocation(location: currentRookLoc){
                rook.isAtStartingPosition = true
                rook.location = cornerLoc
                self.board.setValue(rook, forKey: convertCGPointToKey(location: cornerLoc))
            } else { assertionFailure("Rook not found") }
            self.board.setValue(original, forKey: convertCGPointToKey(location: original.location))
            let emptyBishopLoc = currentRookLoc
            let emptyKnightLoc = CGPoint(x: Int(original.location.x + 2), y: Int(original.location.y))
            self.board.setValue(createEmptyPieceAtLocation(location: emptyBishopLoc), forKey: convertCGPointToKey(location: emptyBishopLoc))
            self.board.setValue(createEmptyPieceAtLocation(location: emptyKnightLoc), forKey: convertCGPointToKey(location: emptyKnightLoc))
        } else if isCastle == QUEEN_SIDE_CASTLE {
            //get rook
            let cornerLoc = CGPoint(x: 0, y: Int(original.location.y))
            let currentRookLoc = CGPoint(x: Int(original.location.x - 1), y: Int(original.location.y))
            if let rook = getPieceAtLocation(location: currentRookLoc){
                rook.isAtStartingPosition = true
                rook.location = cornerLoc
                self.board.setValue(rook, forKey: convertCGPointToKey(location: cornerLoc))
            } else { assertionFailure("Rook not found") }
            self.board.setValue(original, forKey: convertCGPointToKey(location: original.location))
            let emptyQueenLoc = currentRookLoc
            let emptyBishopLoc = CGPoint(x: Int(original.location.x - 2), y: Int(original.location.y))
            let emptyKnightLoc = CGPoint(x: Int(original.location.x - 3), y: Int(original.location.y))
            self.board.setValue(createEmptyPieceAtLocation(location: emptyQueenLoc), forKey: convertCGPointToKey(location: emptyQueenLoc))
            self.board.setValue(createEmptyPieceAtLocation(location: emptyBishopLoc), forKey: convertCGPointToKey(location: emptyBishopLoc))
            self.board.setValue(createEmptyPieceAtLocation(location: emptyKnightLoc), forKey: convertCGPointToKey(location: emptyKnightLoc))
        }
    }
    
    /**
     *  Simulate moving a piece to a point. Return true if the move is valid, false is not (puts player in check)
     */
    private func simulateMove(piece: PieceModel, moveTo: CGPoint) -> Bool
    {
        let originalPiece = piece.copy() as! PieceModel
        let replacedPiece = getPieceAtLocation(location: moveTo)
        let originalReplace = replacedPiece?.copy() as! PieceModel
        var isCastle = NO_CASTLE
        if originalPiece.type == KING && ((replacedPiece?.location.x)! - originalPiece.location.x == 2) {
            isCastle = KING_SIDE_CASTLE
        } else if originalPiece.type == KING && ((replacedPiece?.location.x)! - originalPiece.location.x == -2) {
            isCastle = QUEEN_SIDE_CASTLE
        }
        //move piece
        let result = movePiece(from: originalPiece.location, to: moveTo, isSimulation: true, isCastle: isCastle)

        //undo move
        unmovePiece(original: originalPiece, replacement: originalReplace, isCastle: isCastle)
        
        //only valid if simulated move does not put yourself in check
        return result.checkType != .Check
    }
    
    /**
     *   Given the grid coordinates of the touch, return the list of valid positions the piece can move to
     */
    func getValidMovesAtLocation(location: CGPoint, forPlayer: String) -> [CGPoint]
    {
        if let piece = getPieceAtLocation(location: location) {
            if piece.color != forPlayer { return [] }
            let inCheck = isCheck(player: forPlayer)
            var validMoves = piece.getValidMoves(board: self, inCheck: inCheck == .Check)
            let originalPiece = piece.copy() as! PieceModel
            
            for move in validMoves {
                let isValid = simulateMove(piece: originalPiece, moveTo: move)
                if !isValid {
                    if let idx = validMoves.index(of: move) {
                        validMoves.remove(at: idx)
                    }
                }
            }
            return validMoves
        }
        return []
    }
    
    func isCheckmate(player: String) -> CheckType
    {
        //check if player in is check mate
        for piece in getPlayerPiece(player: player) {
            let moves = getValidMovesAtLocation(location: piece.location, forPlayer: player)
            if moves.count > 0 {
                return .None
            }
        }
        return .Checkmate
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
    
    private func createEmptyPieceAtLocation(location: CGPoint) -> PieceModel
    {
        return PieceModel(type: EMPTY, color: EMPTY, location: location)
    }
    
    func printBoard()
    {
        var str = ""
        let keys = self.board.allKeys as! [String]
        let sortedArray = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        var arr = [String]()
        var masterArr = [[String]]()
        var count = 0
        for key in sortedArray {
            let piece = self.board[key] as! PieceModel
            var st = piece.type
            let t = (piece.color == WHITE) ? "W" : "B"
            if piece.type != EMPTY { st += " (" + t + "\(piece.id)" + ")" }
            st = st.padding(toLength: 13, withPad: " ", startingAt: 0)
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
            str += a.description
        }
    }
}
