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
    *   Get the PieceView at a given location
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
     * Given an array of position, show the dot for the corresponding tile
     */
    func shadeCheckers(shadeChecker: [(CGPoint, Bool)])
    {
        //if bool is true, then the tile contains a piece and should be shaded differently
        var toShade = [(TileView, Bool)]()
        for shade in shadeChecker {
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
    
    
    func createPieces()
    {
        layPieces(color: BLACK)
        layPieces(color: WHITE)
    }
    
    private func layPieces(color: String)
    {
        let offset = (color == BLACK) ? 0 : 6
        for r in 0..<2 {
            for c in 0..<BOARD_DIMENSIONS {
                if (r == 0 && color == BLACK) || (r == 1 && color == WHITE) {
                    let name = color + PIECE_ORDER[c]
                    let piece = PieceView(frame: CGRect(x: CGFloat(c) * CHECKER_WIDTH, y: CGFloat(r + offset) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH), type: name, location: CGPoint(x: c, y: r + offset))
                    self.addSubview(piece)
                    self.pieces.append(piece)
                } else {
                    let name = color + PAWN
                    let piece = PieceView(frame: CGRect(x: CGFloat(c) * CHECKER_WIDTH, y: CGFloat(r + offset) * CHECKER_WIDTH, width: CHECKER_WIDTH, height: CHECKER_WIDTH), type: name, location: CGPoint(x: c, y: r + offset))
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
