//
//  ChessViewController.swift
//  Chess
//
//  Created by Kirby Gee on 12/17/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class ChessViewController: UIViewController {

    var boardView = BoardView()
    var boardModel = BoardModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightText
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        createBoard()
        boardView.createPieces()
    }
    
    var playerTurn = WHITE
    var human = WHITE

    var lastTouchLocation = CGPoint.zero
    
    
    
    func negamax(node: BoardModel, depth: Int, alpha: Float, beta: Float, color: String) -> Float //(Float, (CGPoint, CGPoint))
    {
        if depth == 0 {
            let flip = (color == BLACK) ? Float(1.0) : Float(-1.0)
            node.printBoard()
            print("intermediately returning \(node.scoreBoard() * flip)")
            return node.scoreBoard() * flip
//            return (node.scoreBoard() * flip, (CGPoint.zero, CGPoint.zero))
        }
        
        //get all moves for this player
        let playerPieces = (color == WHITE) ? node.whitePlayer : node.blackPlayer
        var allMoves = [(CGPoint, CGPoint)]()
        for key in playerPieces.allKeys {
            let piece = playerPieces[key] as! PieceModel
            let loc = piece.location
            let moves = node.getValidMovesAtLocation(location: piece.location, forPlayer: color)
            for move in moves {
                allMoves.append((loc, move))
            }
        }
        
        var bestValue = Float.infinity * -1.0
//        var bestValue = (Float.infinity * -1.0, (CGPoint.zero, CGPoint.zero))
//        var alpha = alpha
        
        //create copy of board
        let originalBoardCopy = node.copy() as! BoardModel
        for move in allMoves {
//            print("Depth (\(depth)) - about to apply move \(move.0) to \(move.1)")
            let boardCopy = originalBoardCopy.copy() as! BoardModel
            let p1 = boardCopy.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
            let p2 = boardCopy.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
//            print("Pre board")
//            boardCopy.printBoard()
            boardCopy.movePiece(from: move.0, to: move.1)
//            print("post board")
//            boardCopy.printBoard()

            //make a move on board copy and pass to recurse
            var recurse = -1.0 * negamax(node: boardCopy, depth: depth - 1, alpha: -1.0 * beta, beta: -1.0 * alpha, color: (color == WHITE) ? BLACK : WHITE)
            if recurse == 4.0{
                print("found it")
            }
            if depth == 2 {
                print("This board scored")
                print(boardCopy.printBoard())
                print("\(boardCopy.scoreBoard()) - \(recurse)")
                print("\n\n")
            }
            
            boardCopy.unmovePiece(original: p1, replacement: p2)

            bestValue = max(bestValue, recurse)
//            if bestValue < recurse.0 {
//                print("setting new best value")
//                bestValue = (recurse.0, move)
//            }
//            alpha = max(bestValue.0, alpha)
//            if alpha > beta { break }
        }
        print("at the end of depth \(depth), returning \(bestValue)")
        return bestValue
    }
    
    let DEPTH = 2
    
    
    func minimax(node: BoardModel, depth: Int, maximizingPlayer: String) -> Float
    {
        if depth == 0 {
            return node.scoreBoard()
        }
        
        print(node.printBoard())
        //get all moves
        let playerPieces = node.getPlayerPiece(player: maximizingPlayer)
        var allMoves = [(CGPoint, CGPoint)]()
        for piece in playerPieces {
            let loc = piece.location
            let moves = node.getValidMovesAtLocation(location: piece.location, forPlayer: maximizingPlayer)
            for move in moves {
                allMoves.append((loc, move))
            }
        }
        
        let originalBoardCopy = node.copy() as! BoardModel

        if maximizingPlayer == BLACK {
            var bestValue = Float.infinity * -1.0
            for move in allMoves {
                let boardCopy = originalBoardCopy.copy() as! BoardModel
                let p1 = boardCopy.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
                let p2 = boardCopy.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
                boardCopy.movePiece(from: move.0, to: move.1)
                let recurse = minimax(node: boardCopy, depth: depth - 1, maximizingPlayer: WHITE)
                print("recurse black depth \(depth) = \(recurse)")
                print("This board scores \(boardCopy.printBoard())")
                print("\(recurse) == \(boardCopy.scoreBoard())")
                print("\n")
                boardCopy.unmovePiece(original: p1, replacement: p2)
                bestValue = max(bestValue, recurse)
            }
            print("At depth \(depth) for BLACK, returning \(bestValue)")
            return bestValue
            
        } else {
            var bestValue = Float.infinity
            for move in allMoves {
                let boardCopy = originalBoardCopy.copy() as! BoardModel
                let p1 = boardCopy.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
                let p2 = boardCopy.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
                boardCopy.movePiece(from: move.0, to: move.1)
                let recurse = minimax(node: boardCopy, depth: depth - 1, maximizingPlayer: BLACK)
//                print("recurse white depth \(depth) = \(recurse)")
                boardCopy.unmovePiece(original: p1, replacement: p2)
                bestValue = min(bestValue, recurse)
            }
            print("At depth \(depth) for WHITE, returning \(bestValue)")
            return bestValue
        }
    }
    
    private func computerMove()
    {
        print("computer make a move")
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            let val = self.minimax(node: self.boardModel, depth: self.DEPTH, maximizingPlayer: BLACK)
            print("Final value is \(val)")
//            let val = self.negamax(node: self.boardModel, depth: self.DEPTH, alpha: Float.infinity * -1.0, beta: Float.infinity, color: BLACK)

            //            let move = self.boardModel.computerMove(depth: 3)
//            print("moving from \(move.0) to \(move.1)")
//            self.movePiece(from: move.0, to: move.1)
//            self.playerTurn = WHITE
//            print("Board score is \(self.boardModel.scoreBoard())")
        }
    }
    
    func movePiece(from: CGPoint, to: CGPoint)
    {
        self.boardView.movePiece(from: from, to: to)
        self.boardModel.movePiece(from: from, to: to)
    }
    
    func handleTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        if playerTurn == human {
            let touchPoint = gestureRecognizer.location(in: self.boardView)
            let gridLocation = boardView.tapAtLocation(tap: touchPoint)
            print("Touch location on grid \(gridLocation)")
            //check if gridLocation is highlighted
            if boardView.locationIsHighlighted(location: gridLocation) {
                movePiece(from: lastTouchLocation, to: gridLocation)
                self.boardView.shadeCheckers(shadeChecker: [])
                print("Board score is \(self.boardModel.scoreBoard())")
                playerTurn = BLACK
                computerMove()
            } else {
                lastTouchLocation = gridLocation
                let moves = boardModel.getValidMovesAtLocation(location: gridLocation, forPlayer: playerTurn)
                self.boardView.shadeCheckers(shadeChecker: moves)
            }
        }
    }
    
    private func createBoard()
    {
        // place board in center of view
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        boardView = BoardView(frame: CGRect(x: 0, y: height/2 - width/2, width: width, height: width))
        self.view.addSubview(boardView)
    }
}
