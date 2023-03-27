//
//  CircularProgressNode.swift
//
//  Created by Changzhi Wang on 2023/3/27.
//

import Foundation
import SpriteKit

class CircularProgressBarNode: SKShapeNode {
    var progress: CGFloat = 0 {
        didSet {
            progress = max(0, min(1, progress))
            updateProgress()
        }
    }
    
    var onProgressChangedCallback: ((CGFloat) -> Void)?
    var onProgressCompletedCallback: (() -> Void)?
    
    private let progressPath = UIBezierPath()
    private let progressNode = SKShapeNode()
    private var touchStartProgress: CGFloat = 0
    
    override init() {
        super.init()
        progressPath.addArc(withCenter: .zero, radius: 25, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)
        path = progressPath.cgPath
        
        strokeColor = .white
        lineWidth = 10
        
        progressNode.path = progressPath.cgPath
        progressNode.strokeColor = .green
        progressNode.lineWidth = lineWidth
        addChild(progressNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateProgress() {
        let progressEndAngle = (progress * .pi * 2) - (.pi / 2)
        progressNode.path = UIBezierPath(arcCenter: .zero, radius: 25, startAngle: -.pi / 2, endAngle: progressEndAngle, clockwise: true).cgPath
        onProgressChangedCallback?(progress)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        touchStartProgress = progressForTouchLocation(touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let touchProgress = progressForTouchLocation(touchLocation)
        
        let deltaProgress = touchProgress - touchStartProgress
        progress += deltaProgress
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onProgressCompletedCallback?()
        touchStartProgress = 0
    }
    
    private func progressForTouchLocation(_ location: CGPoint) -> CGFloat {
        let touchAngle = atan2(location.y, location.x) + (.pi / 2)
        var touchProgress = touchAngle / (.pi * 2)
        if touchProgress < 0 {
            touchProgress += 1
        }
        return touchProgress
    }
}
