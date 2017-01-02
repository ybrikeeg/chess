//
//  AIProgressView.swift
//  Chess
//
//  Created by Kirby Gee on 1/2/17.
//  Copyright © 2017 Kirby Gee. All rights reserved.
//

import UIKit

class AIProgressView: UIView {

    var progressView = UIView()
    var progress: Float = 0.0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        progressView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: frame.size.height))
        progressView.backgroundColor = UIColor.orange
        addSubview(progressView)
        return
    }

    func updateProgress(progress: Float)
    {
        let newFrame = CGRect(x: 0, y: 0, width: Int(progress * Float(frame.size.width)), height: Int(frame.size.height))
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
            self.progressView.frame = newFrame
        })
    }
    
    func reset()
    {
        updateProgress(progress: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
