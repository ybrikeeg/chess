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

let PIECE_ORDER = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]

let BLACK = "Black"
let WHITE = "White"
let NOT_FOUND = "Not Found"
let EMPTY = "Empty"


let NOT_FOUND_PIECE = PieceModel(type:NOT_FOUND, location: CGPoint(x: -1, y: -1))


func createEmptyPieceAtLocation(location: CGPoint) -> PieceModel
{
    return PieceModel(type: EMPTY, location: location)
}
