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

let NOT_FOUND_PIECE = PieceModel(type:NOT_FOUND, color: EMPTY, location: CGPoint(x: -1, y: -1))

func createEmptyPieceAtLocation(location: CGPoint) -> PieceModel
{
    return PieceModel(type: EMPTY, color: EMPTY, location: location)
}

func convertCGPointToKey(location: CGPoint) -> String
{
    let newPoint = CGPoint(x: Int(location.x), y: Int(location.y))
    return NSStringFromCGPoint(newPoint)
}

func getPieceFromId(dictionary: NSDictionary, id: Int) -> PieceModel?
{
    for (_, value) in dictionary {
        if let piece = value as? PieceModel {
            if piece.id == id { return piece }
        }
    }
    return nil
}

let HEAT_MAP_BLACK = [[0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [1, 1, 1, 1, 1, 1, 1, 1],
                      [1, 2, 3, 5, 5, 3, 2, 1],
                      [1, 2, 3, 5, 5, 3, 2, 1],
                      [2, 2, 2, 2, 2, 2, 2, 2],
                      [2, 2, 2, 2, 2, 2, 2, 2],
                      [2, 2, 2, 2, 2, 2, 2, 2]]

let HEAT_MAP_WHITE = [[2, 2, 2, 2, 2, 2, 2, 2],
                      [2, 2, 2, 2, 2, 2, 2, 2],
                      [2, 2, 2, 2, 2, 2, 2, 2],
                      [1, 2, 3, 5, 5, 3, 2, 1],
                      [1, 2, 3, 5, 5, 3, 2, 1],
                      [1, 1, 1, 1, 1, 1, 1, 1],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0]]
