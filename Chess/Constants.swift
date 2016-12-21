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

//let PIECE_ORDER = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]
let PIECE_ORDER = [ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK]
let BLACK = "Black"
let WHITE = "White"
let NOT_FOUND = "Not Found"
let EMPTY = "Empty"


let NOT_FOUND_PIECE = PieceModel(type:NOT_FOUND, color: EMPTY, location: CGPoint(x: -1, y: -1))


func createEmptyPieceAtLocation(location: CGPoint) -> PieceModel
{
    return PieceModel(type: EMPTY, color: EMPTY, location: location)
}
