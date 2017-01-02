//
//  Constants.swift
//  Chess
//
//  Created by Kirby Gee on 12/17/16.
//  Copyright © 2016 Kirby Gee. All rights reserved.
//

import Foundation
import UIKit

let BOARD_DIMENSIONS = 8


let PAWN = "Pawn"
let ROOK = "Rook"
let KNIGHT = "Knight"
let BISHOP = "Bishop"
let QUEEN = "Queen"
let KING = "King"

let PIECE_ORDER = [ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK]
let BLACK = "Black"
let WHITE = "White"
let NOT_FOUND = "Not Found"
let EMPTY = "Empty"
let GAME_OVER = "Game Over"

enum CheckType {
    case None
    case Check
    case Checkmate
}

struct MoveResult {
    var pieceCapture: String
    var checkType: CheckType
}

func convertCGPointToKey(location: CGPoint) -> String
{
    let newPoint = CGPoint(x: Int(location.x), y: Int(location.y))
    return NSStringFromCGPoint(newPoint)
}


let PAWN_LOCATIONS = [[0, 0, 0, 0, 0, 0, 0, 0],
                      [50, 50, 50, 50, 50, 50, 50, 50],
                      [10, 10, 10, 10, 10, 10, 10, 10],
                      [5, 5, 10, 25, 25, 10, 5, 5],
                      [0, 0, 0, 20, 20, 0, 0, 0],
                      [5, -5, -10, 0, 0, -10, -5, 5],
                      [5, 10, 10, -20, -20, 10, 10, 5],
                      [0, 0, 0, 0, 0, 0, 0, 0]]

let KNIGHT_LOCATIONS = [[-50, -40, -30, -30, -30, -30, -40, -50],
                      [-40, -20, 0, 0, 0, 0, -20, -40],
                      [-30, 0, 10, 15, 15, 10, 0, -30],
                      [-30, 5, 15, 20, 20, 15, 5, -30],
                      [-30, 0, 15, 20, 20, 15, 0, -30],
                      [-30, 5, 10, 15, 15, 10, 5, -30],
                      [-40, -20, 0, 5, 5, 0, -20, -40],
                      [-50, -40, -30, -30, -30, -30, -30, -30]]

let BISHOP_LOCATIONS = [[-20, -10, -10, -10, -10, -10, -10, -20],
                        [-10, 0, 0, 0, 0, 0, 0, -10],
                        [-10, 0, 5, 10, 10, 5, 0, -10],
                        [-10, 5, 5, 10, 10, 5, 5, -10],
                        [-10, 0, 10, 10, 10, 10, 0, -10],
                        [-10, 10, 10, 10, 10, 10, 10, -10],
                        [-10, 5, 0, 0, 0, 0, 5, -10],
                        [-10, -10, -10, -10, -10, -10, -10, -10]]

let ROOK_LOCATIONS = [[0, 0, 0, 0, 0, 0, 0, 0],
                       [5, 10, 10, 10, 10, 10, 10, 5],
                       [-5, 0, 0, 0, 0, 0, 0, -5],
                       [-5, 0, 0, 0, 0, 0, 0, -5],
                       [-5, 0, 0, 0, 0, 0, 0, -5],
                       [-5, 0, 0, 0, 0, 0, 0, -5],
                       [-5, 0, 0, 0, 0, 0, 0, -5],
                       [0, 0, 0, 5, 5, 0, 0, 0]]


let QUEEN_LOCATIONS = [[-20, -10, -10, -5, -5, -10, -10, -20],
                        [-10, 0, 0, 0, 0, 0, 0, -10],
                        [-10, 0, 5, 5, 5, 5, 0, -10],
                        [-5, 0, 5, 5, 5, 5, 0, -5],
                        [0, 0, 5, 5, 5, 5, 0, 0],
                        [-10, 5, 5, 5, 5, 5, 0, -10],
                        [-10, 0, 5, 0, 0, 0, 0, -10],
                        [-20, -10, -10, -5, -5, -10, -10, -20]]
