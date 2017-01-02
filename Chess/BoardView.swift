//
//  BoardView.swift
//  Chess
//
//  Created by Kirby Gee on 12/17/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var checkers = [(view: TileView, position:CGPoint)]()
    var pieces = [PieceView]()
    var CHECKER_WIDTH = CGFloat(0.0)
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
        CHECKER_WIDTH = CGFloat(CGFloat(frame.size.width) / CGFloat(BOARD_DIMENSIONS))
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                let v = TileView(frame: CGRect(x: CGFloat(c) * CHECKER_WIDTH, y: CGFloat(r) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH), row: r, col: c)
                v.backgroundColor = ((r + c) % 2 == 0) ? UIColor(red:(234.0/255.0), green:(212.0/255.0), blue:(177.0/255.0), alpha:1.0) : UIColor(red:(181.0/255.0), green:(136.0/255.0), blue:(99.0/255.0), alpha:1.0)
                self.addSubview(v)
                checkers.append((v, CGPoint(x: c, y: r)))
            }
        }
        return
    }
    
    
    func locationIsHighlighted(location: CGPoint) -> Bool
    {
        for checker in checkers {
            if checker.position == location {
                return checker.view.isHighlighted()
            }
        }
        return false
    }
    
    /**
    *   Get the PieceView at a given board location (ex {0, 0}, ..., {7, 7}
    */
    private func getPieceAtLocation(location: CGPoint) -> PieceView?
    {
        for p in pieces {
            if p.location == location {
                return p
            }
        }
        return nil
    }
    
    /**
    *   Covnert a location to a UIView position
    */
    private func convertLocationToPosition(location: CGPoint) -> CGPoint
    {
        return CGPoint(x: location.x * CHECKER_WIDTH, y: location.y * CHECKER_WIDTH)
    }

    private func getLocationFromId(dictionary: NSDictionary, id: Int) -> CGPoint?
    {
        for key in dictionary.allKeys {
            if let key = key as? String {
                let val = dictionary[key] as! Int
                if val == id {
                    return CGPointFromString(key)
                }
            }
        }
        return nil
    }
    
    private func getCheckerAtLocation(location: CGPoint) -> TileView?
    {
        for checker in checkers {
            if checker.position == location {
                return checker.view
            }
        }
        assertionFailure("Could not find tile")
        return nil
    }
    
    func updateView(before: NSDictionary, after: NSDictionary, moveResult: MoveResult, player: String, board: BoardModel)
    {
        var viewsToUpdate = [(PieceView, CGPoint)]()
        var viewsToRemove = [PieceView]()
        for r in 0..<BOARD_DIMENSIONS {
            for c in 0..<BOARD_DIMENSIONS {
                let startLoc = CGPoint(x:c, y:r)
                let startKey = convertCGPointToKey(location: startLoc)
                let beforeId = before[startKey] as! Int
                if beforeId == -1 { continue }
                if let afterLoc = getLocationFromId(dictionary: after, id: beforeId) {
                    //this piece needs to move
                    if beforeId != -1 && startLoc != afterLoc {
                        viewsToUpdate.append((getPieceAtLocation(location: startLoc)!, afterLoc))
                    }
                } else {
                    viewsToRemove.append(getPieceAtLocation(location: startLoc)!)
                }
            }
        }
        
        for viewToUpdate in viewsToUpdate {
            let positionToMoveTo = convertLocationToPosition(location: viewToUpdate.1)
            let pieceModel = board.getPieceAtLocation(location: viewToUpdate.1)!
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                viewToUpdate.0.frame = CGRect(x: positionToMoveTo.x, y: positionToMoveTo.y, width: self.CHECKER_WIDTH, height: self.CHECKER_WIDTH)
                viewToUpdate.0.updateType(type: pieceModel.color + pieceModel.type)
            }) { (finished) in
                viewToUpdate.0.location = viewToUpdate.1
            }
        }
        
        if moveResult.checkType != .Checkmate {
            for viewToRemove in viewsToRemove {
                UIView.animate(withDuration: 0.2, animations: {
                    viewToRemove.alpha = 0.0
                }, completion: { (finished) in
                    self.pieces.remove(at: self.pieces.index(of: viewToRemove)!)
                    viewToRemove.removeFromSuperview()
                })
            }
        }
        
        shadeCheckers(location: CGPoint(x: -1, y: -1), forPlayer: EMPTY, board: board)
        
        if moveResult.checkType == .Check || moveResult.checkType == .Checkmate {
            if let king = board.getKingForPlayer(player: player) {
                if let loc = getCheckerAtLocation(location: king.location) {
                    if moveResult.checkType == .Checkmate { loc.inCheckmate(value: true) }
                    else if moveResult.checkType == .Check { loc.inCheck(value: true) }
                }
            }
        } else {
            if let king = board.getKingForPlayer(player: player) {
                if let loc = getCheckerAtLocation(location: king.location) {
                    loc.inCheck(value: false)
                    loc.inCheckmate(value: false)
                }
            }
        }
    }
    
    /**
    *   Move a piece from point to point
    */
    func movePiece(from: CGPoint, to: CGPoint)
    {
        let pieceToMove = getPieceAtLocation(location: from)!
        let positionToMoveTo = convertLocationToPosition(location: to)
        let pieceToRemove = getPieceAtLocation(location: to)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            pieceToMove.frame = CGRect(x: positionToMoveTo.x, y: positionToMoveTo.y, width: self.CHECKER_WIDTH, height: self.CHECKER_WIDTH)
        }) { (finished) in
            pieceToMove.location = to
            if let remove = pieceToRemove {
                self.pieces.remove(at: self.pieces.index(of: remove)!)
                remove.removeFromSuperview()
            }
        }
    }
    
    /**
     * Given the touch location and player, show animate the tiles that the piece can move to
     */
    func shadeCheckers(location: CGPoint, forPlayer: String, board: BoardModel)
    {
        let moves = board.getValidMovesAtLocation(location: location, forPlayer: forPlayer)
        var detailedMoves = [(CGPoint, Bool)]()
        for move in moves {
            var added = false
            if let piece = board.getPieceAtLocation(location: move) {
                if piece.type != EMPTY && piece.color != forPlayer {
                    detailedMoves.append((move, true))
                    added = true
                }
            }
            if !added {
                detailedMoves.append((move, false))
            }
        }
        
        //if bool is true, then the tile contains a piece and should be shaded differently
        var toShade = [(TileView, Bool)]()
        for shade in detailedMoves {
            for checker in checkers {
                if checker.position == shade.0 {
                    toShade.append((checker.view, shade.1))
                    break
                }
            }
        }
        for t in checkers {
            t.view.showDot(value: false)
            t.view.showBorder(value: false)
        }
        for t in toShade {
            if t.1 == false {
                t.0.showDot(value: true)
            } else {
                t.0.showBorder(value: true)
            }
        }
    }
    
    /**
     * Given a position on the board, return the grid coordinates -> 0 - CHECKER_WIDTH
     */
    func tapAtLocation(tap: CGPoint) -> CGPoint
    {
        return CGPoint(x: Int(tap.x / CHECKER_WIDTH), y: Int(tap.y / CHECKER_WIDTH))
    }
    
    func drawPieces(board: BoardModel)
    {
        for key in board.board.allKeys {
            if let piece = board.board[key] as? PieceModel {
                if piece.type != EMPTY {
                    let name = piece.color + piece.type
                    let piece = PieceView(frame: CGRect(x: CGFloat(piece.location.x) * CHECKER_WIDTH, y: CGFloat(piece.location.y) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH), type: name, location: CGPoint(x: piece.location.x, y: piece.location.y))
                    self.addSubview(piece)
                    self.pieces.append(piece)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
