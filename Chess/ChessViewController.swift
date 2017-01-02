//
//  ChessViewController.swift
//  Chess
//
//  Created by Kirby Gee on 12/17/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class ChessViewController: UIViewController {

    var gamemode = GameplayMode.HumanVAI
    var boardView = BoardView()
    var boardModel = BoardModel()
    var blackCaptureCase = CaptureView()
    var whiteCaptureCase = CaptureView()

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
        boardView.drawPieces(board: self.boardModel)
        
        if gamemode == .AIvAI {
            computerMove()
        }
    }
    
    var playerTurn = WHITE
    var human = WHITE
    var lastTouchLocation: CGPoint? = nil
    
    var iterCount = 0
    let DEPTH = 2
    
    func minimax(node: BoardModel, depth: Int, alpha: Float, beta: Float, maximizingPlayer: String) -> (Float, (CGPoint, CGPoint))
    {
        iterCount += 1
        if iterCount % 1000 == 0 { print("Iteration \(iterCount)") }
        if depth == 0 {
            return (node.getBoardScoringHeuristic(), (CGPoint.zero, CGPoint.zero))
        }
        
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
        var alpha = alpha
        var beta = beta
        if maximizingPlayer == BLACK {
            var bestValue = (Float.infinity * -1.0, (CGPoint.zero, CGPoint.zero))
            for move in allMoves {
                let boardCopy = originalBoardCopy.copy() as! BoardModel
                let p1 = boardCopy.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
                let p2 = boardCopy.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
                _ = boardCopy.movePiece(from: move.0, to: move.1, isSimulation: true)
                let recurse = minimax(node: boardCopy, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: WHITE)
                boardCopy.unmovePiece(original: p1, replacement: p2)
                if bestValue.0 < recurse.0 || bestValue.0 == Float.infinity * -1.0{
                    bestValue = (recurse.0, move)
                }
                alpha = max(alpha, recurse.0)
                if beta <= alpha { break }
            }
            return bestValue
        } else {
            var bestValue = (Float.infinity, (CGPoint.zero, CGPoint.zero))
            for move in allMoves {
                let boardCopy = originalBoardCopy.copy() as! BoardModel
                let p1 = boardCopy.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
                let p2 = boardCopy.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
                _ = boardCopy.movePiece(from: move.0, to: move.1, isSimulation: true)
                let recurse = minimax(node: boardCopy, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: BLACK)
                boardCopy.unmovePiece(original: p1, replacement: p2)
                if bestValue.0 > recurse.0 {
                    bestValue = (recurse.0, move)
                }
                beta = min(beta, recurse.0)
                if beta <= alpha { break }
            }
            return bestValue
        }
    }
    
    private func computerMove()
    {
        if playerTurn == BLACK {
            let bestMove = self.minimax(node: self.boardModel, depth: self.DEPTH, alpha: Float.infinity * -1.0, beta: Float.infinity, maximizingPlayer: BLACK)
            print("Final value is \(bestMove) after \(self.iterCount) iterations")
            self.iterCount = 0
            self.movePiece(from: bestMove.1.0, to: bestMove.1.1)
        } else if playerTurn == WHITE {
            let bestMove = self.minimax(node: self.boardModel, depth: self.DEPTH, alpha: Float.infinity * -1.0, beta: Float.infinity, maximizingPlayer: WHITE)
            print("Final value is \(bestMove) after \(self.iterCount) iterations")
            self.iterCount = 0
            self.movePiece(from: bestMove.1.0, to: bestMove.1.1)
        } else {
            return
        }
        
        if gamemode == .AIvAI {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                print("computer make a move")
                self.computerMove()
            }
        }
    }
    
    private func simplifyBoard() -> NSDictionary
    {
        let simple = NSMutableDictionary()
        for (key, value) in self.boardModel.board {
            let piece = value as! PieceModel
            simple.setValue(piece.id, forKey: key as! String)
        }
        return simple
    }
    
    private func updateCaptureCases(moveResult: MoveResult)
    {
        if playerTurn == BLACK {
            if moveResult.pieceCapture != EMPTY {
                whiteCaptureCase.addPiece(piece: moveResult.pieceCapture)
            }
        } else if playerTurn == WHITE {
            if moveResult.pieceCapture != EMPTY {
                blackCaptureCase.addPiece(piece: moveResult.pieceCapture)
            }
        }
    }
    
    func movePiece(from: CGPoint, to: CGPoint)
    {
        let before = simplifyBoard()
        let moveResult = self.boardModel.movePiece(from: from, to: to)
        let after = simplifyBoard()
        
        playerTurn = (self.playerTurn == WHITE) ? BLACK : WHITE
        
        self.boardView.updateView(before: before, after: after, moveResult: moveResult, player: playerTurn, board: self.boardModel)
        updateCaptureCases(moveResult: moveResult)
        
        if moveResult.checkType == .Checkmate {
            print("CHECKMATE")
            playerTurn = GAME_OVER
        }
        
        self.boardModel.printBoard()
    }
    
    func handleTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        if gamemode != .AIvAI {
            if playerTurn == human {
                let touchPoint = gestureRecognizer.location(in: self.boardView)
                let gridLocation = boardView.tapAtLocation(tap: touchPoint)
                //check if gridLocation is highlighted
                if lastTouchLocation != nil && boardView.locationIsHighlighted(location: gridLocation) {
                    movePiece(from: lastTouchLocation!, to: gridLocation)
                    lastTouchLocation = nil
                    print("Board score is \(self.boardModel.getBoardScoringHeuristic())")
                    if gamemode == .HumanVAI {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            print("computer make a move")
                            self.computerMove()
                        }
                    }
                } else {
                    lastTouchLocation = gridLocation
                    self.boardView.shadeCheckers(location: gridLocation, forPlayer: playerTurn, board: boardModel)
                }
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
        
        let captureHeight = width / 15
        self.blackCaptureCase = CaptureView(frame: CGRect(x: 0, y: boardView.frame.origin.y - captureHeight, width: width, height: captureHeight), color: BLACK)
        self.view.addSubview(self.blackCaptureCase)
        self.whiteCaptureCase = CaptureView(frame: CGRect(x: 0, y: boardView.frame.origin.y + boardView.frame.size.height, width: width, height: captureHeight), color: WHITE)
        self.view.addSubview(self.whiteCaptureCase)
    }
}
