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
    
    private func computerMove()
    {
        print("computer make a move")
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            let move = self.boardModel.computerMove(depth: 3)
            print("moving from \(move.0) to \(move.1)")
            self.movePiece(from: move.0, to: move.1)
            self.playerTurn = WHITE
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
