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
    var boardModelCopy = BoardModel()
    var blackCaptureCase = CaptureView()
    var whiteCaptureCase = CaptureView()
    var progressView = AIProgressView()
    var humanCanMove = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightText
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        setUpChess()
        selectOpponentType()
    }
    
    private func setUpChess()
    {
        playerTurn = WHITE
        humanCanMove = true
        lastTouchLocation = nil
        blackCaptureCase.removeFromSuperview()
        whiteCaptureCase.removeFromSuperview()
        boardView.removeFromSuperview()
        progressView.removeFromSuperview()
        createBoard()
        boardModel = BoardModel()
        boardView.drawPieces(board: boardModel)
        boardModelCopy = boardModel.copy() as! BoardModel
    }
    
    ///hi kirby!!!! you're my fave <3
    var playerTurn = WHITE
    var lastTouchLocation: CGPoint? = nil
    var iterCount = 0
    let DEPTH = 2
    let MAX_ITER_COUNT:Float = 10000.0
    
    func minimax(node: BoardModel, depth: Int, alpha: Float, beta: Float, maximizingPlayer: String) -> (Float, (CGPoint, CGPoint))
    {
        iterCount += 1
        if iterCount % 50 == 0 {
            DispatchQueue.main.async {
                self.progressView.updateProgress(progress: Float(self.iterCount) / self.MAX_ITER_COUNT)
            }
        }

        if depth == 0 || iterCount > Int(MAX_ITER_COUNT) {
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
        
        var alpha = alpha
        var beta = beta
        if maximizingPlayer == BLACK {
            var bestValue = (Float.infinity * -1.0, (CGPoint.zero, CGPoint.zero))
            for move in allMoves {
                let p1 = boardModel.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
                let p2 = boardModel.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
                let moveResult = boardModel.movePiece(from: move.0, to: move.1, isSimulation: true)
                var recurse = (Float.infinity * -1.0, (CGPoint.zero, CGPoint.zero))
                if moveResult.checkType == .Draw {
                    recurse.0 = Float.infinity * -1.0
                } else {
                    recurse = minimax(node: boardModel, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: WHITE)
                }
                boardModel.unmovePiece(original: p1, replacement: p2)
 

                if (bestValue.0 < recurse.0 || bestValue.0 == Float.infinity * -1.0) && moveResult.checkType != .Draw {
                    bestValue = (recurse.0, move)
                }
                alpha = max(alpha, recurse.0)
                if beta <= alpha { break }
            }
            return bestValue
        } else {
            var bestValue = (Float.infinity, (CGPoint.zero, CGPoint.zero))
            for move in allMoves {
                let p1 = boardModel.getPieceAtLocation(location: move.0)!.copy() as! PieceModel
                let p2 = boardModel.getPieceAtLocation(location: move.1)!.copy() as! PieceModel
                let moveResult = boardModel.movePiece(from: move.0, to: move.1, isSimulation: true)
                var recurse = (Float.infinity, (CGPoint.zero, CGPoint.zero))

                if moveResult.checkType == .Draw {
                    recurse.0 = Float.infinity
                } else {
                    recurse = minimax(node: boardModel, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: BLACK)
                }
                
                boardModel.unmovePiece(original: p1, replacement: p2)

                if bestValue.0 > recurse.0 && moveResult.checkType != .Draw {
                    bestValue = (recurse.0, move)
                }
                beta = min(beta, recurse.0)
                if beta <= alpha { break }
            }
            return bestValue
        }
    }
    
    private func hapticFeedback(style: UIImpactFeedbackStyle)
    {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func computerMove()
    {
        humanCanMove = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            DispatchQueue.global(qos: .background).async {
                if self.playerTurn != GAME_OVER {
                    let bestMove = self.minimax(node: self.boardModel, depth: self.DEPTH, alpha: Float.infinity * -1.0, beta: Float.infinity, maximizingPlayer: self.playerTurn)
                    print("Final value is \(bestMove) after \(self.iterCount) iterations")
                    self.iterCount = 0
                    self.movePiece(from: bestMove.1.0, to: bestMove.1.1)
                    self.humanCanMove = true
                    self.boardModelCopy = self.boardModel.copy() as! BoardModel
                    
                    DispatchQueue.main.async {
                        self.progressView.reset()
                    }
                } else {
                    return
                }
                
                if self.gamemode == .AIvAI {
                    self.computerMove()
                }
            }
        }
    }
    
    private func simplifyBoard() -> NSDictionary
    {
        let simple = NSMutableDictionary()
        for (key, value) in boardModel.board {
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
    
    private func selectOpponentType()
    {
        let alert = UIAlertController(title: "Chess", message: "Play my chess game", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Human vs AI", style: UIAlertActionStyle.default, handler: { action in
                    self.setUpChess()
                    self.gamemode = GameplayMode.HumanVAI
        }))
        alert.addAction(UIAlertAction(title: "Human vs Human", style: UIAlertActionStyle.default, handler: { action in
            self.setUpChess()
            self.gamemode = GameplayMode.HumanVHuman
        }))
        alert.addAction(UIAlertAction(title: "AI vs AI", style: UIAlertActionStyle.default, handler: { action in
            self.setUpChess()
            self.gamemode = GameplayMode.AIvAI
            self.computerMove()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func movePiece(from: CGPoint, to: CGPoint)
    {
        let before = simplifyBoard()
        let moveResult = boardModel.movePiece(from: from, to: to)
        let after = simplifyBoard()
        
        playerTurn = (playerTurn == WHITE) ? BLACK : WHITE
        let tempPlayer = playerTurn
        
        DispatchQueue.main.async {
            self.hapticFeedback(style: (moveResult.pieceCapture == EMPTY) ? .light : .heavy)
            self.boardView.updateView(before: before, after: after, moveResult: moveResult, player: tempPlayer, board: self.boardModel)
            self.updateCaptureCases(moveResult: moveResult)
        }
        if moveResult.checkType == .Checkmate || moveResult.checkType == .Draw {
            playerTurn = GAME_OVER
        }
        
        boardModel.printBoard()
    }
    
    func handleTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        if playerTurn == GAME_OVER {
            self.selectOpponentType()
            return
        }
        
        if gamemode != .AIvAI {
            let touchPoint = gestureRecognizer.location(in: boardView)
            let gridLocation = boardView.tapAtLocation(tap: touchPoint)
            //check if gridLocation is highlighted
            if lastTouchLocation != nil && boardView.locationIsHighlighted(location: gridLocation) && (gamemode == .HumanVAI && humanCanMove) {
                hapticFeedback(style: .medium)
                movePiece(from: lastTouchLocation!, to: gridLocation)
                lastTouchLocation = nil
                print("Board score is \(boardModel.getBoardScoringHeuristic())")
                if gamemode == .HumanVAI {
                    boardModelCopy = boardModel.copy() as! BoardModel
                    computerMove()
                }
            } else {
                lastTouchLocation = gridLocation
                hapticFeedback(style: .light)
                let drawForPlayer = (gamemode == .HumanVHuman) ? playerTurn : WHITE
                let boardToUse = (humanCanMove) ? boardModel : boardModelCopy
                boardView.shadeCheckers(location: gridLocation, forPlayer: drawForPlayer, board: boardToUse)
                if !humanCanMove { lastTouchLocation = nil }
            }
        }
    }
    
    /**
     *  Restart the game on double tap
     */
    func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        setUpChess()
    }
    
    private func createBoard()
    {
        // place board in center of view
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        boardView = BoardView(frame: CGRect(x: 0, y: height/2 - width/2, width: width, height: width))
        self.view.addSubview(boardView)
        
        let captureHeight = width / 15
        blackCaptureCase = CaptureView(frame: CGRect(x: 0, y: boardView.frame.origin.y - captureHeight, width: width, height: captureHeight), color: BLACK)
        self.view.addSubview(blackCaptureCase)
        whiteCaptureCase = CaptureView(frame: CGRect(x: 0, y: boardView.frame.origin.y + boardView.frame.size.height, width: width, height: captureHeight), color: WHITE)
        self.view.addSubview(whiteCaptureCase)
        
        let progHeight = 15
        progressView = AIProgressView(frame: CGRect(x: 0, y: Int(Float(self.view.frame.size.height) - Float(progHeight)), width: Int(self.view.frame.size.width), height: progHeight))
        self.view.addSubview(progressView)
    }
}
