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
    var lastTouchLocation = CGPoint.zero
    
    func handleTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        let touchPoint = gestureRecognizer.location(in: self.boardView)
        let gridLocation = boardView.tapAtLocation(tap: touchPoint)
        print("Touch location on grid \(gridLocation)")
        //check if gridLocation is highlighted
        if boardView.locationIsHighlighted(location: gridLocation) {
            self.boardView.movePiece(from: lastTouchLocation, to: gridLocation)
            self.boardModel.movePiece(from: lastTouchLocation, to: gridLocation)
            self.boardView.shadeCheckers(shadeChecker: [])
            playerTurn = (playerTurn == WHITE) ? BLACK : WHITE
        } else {
            lastTouchLocation = gridLocation
            let moves = boardModel.getValidMovesAtLocation(location: gridLocation, forPlayer: playerTurn)
            self.boardView.shadeCheckers(shadeChecker: moves)
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
