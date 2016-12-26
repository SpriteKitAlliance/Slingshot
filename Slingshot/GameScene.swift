//
//  GameScene.swift
//  Slingshot
//
//  Created by Skyler Lauren on 12/23/16.
//  Copyright © 2016 Sprite Kit Alliance. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum CollisionBody:UInt32 {
        case None = 1
        case Ball = 2
        case Coin = 3
        case Wall = 4
    }
    
    //Ball
    private var ball : SKShapeNode!
    private let ballRadius: CGFloat = 25

    //Coin label
    private var coinIcon: SKSpriteNode!
    private var coinLabel: SKLabelNode!
    
    //Sling outlets
    private var sling : SKNode!

    private var leftSlingPosition: CGPoint!
    private var leftSling: SKShapeNode!
    
    private var rightSlingPosition: CGPoint!
    private var rightSling: SKShapeNode!
    
    //Game info
    private var movingBall = false
    private var coinsCollected = 0
    private var gameOver = false
    private var ballIsFlying = false

    //MARK: - View Lifecycle
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        //coin label
        self.coinIcon = self.childNode(withName: "//coinIcon") as! SKSpriteNode
        self.coinLabel = self.childNode(withName: "//coinLabel") as! SKLabelNode
        
        //sling
        self.sling = self.childNode(withName: "//sling")
        
        self.leftSlingPosition = self.childNode(withName: "//leftSling")!.position
        
        var path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: sling.position.subtract(point: leftSlingPosition))
        path.closeSubpath()
        
        self.leftSling = SKShapeNode(path: path)
        self.leftSling.lineWidth = 8
        self.leftSling.zPosition = 2
        self.leftSling.fillColor = SKColor.green
        self.leftSling.strokeColor = SKColor.green
        self.addChild(self.leftSling)
        
        leftSling.position = self.leftSlingPosition
        
        self.rightSlingPosition = self.childNode(withName: "//rightSling")!.position
        
        path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: sling.position.subtract(point: rightSlingPosition))
        path.closeSubpath()
        
        self.rightSling = SKShapeNode(path: path)
        self.rightSling.lineWidth = 8
        self.rightSling.zPosition = 2
        self.rightSling.fillColor = SKColor.green
        self.rightSling.strokeColor = SKColor.green
        self.addChild(self.rightSling)
        
        self.rightSling.position = self.rightSlingPosition
        
        //ball
        self.ball = SKShapeNode(circleOfRadius: ballRadius)
        self.ball.fillColor = SKColor.blue
        self.ball.position = sling.position
        self.addChild(self.ball)
        
        //walls
        enumerateChildNodes(withName: "wall") { (node, done) in
            if let sprite = node as? SKSpriteNode{
                sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                sprite.physicsBody?.affectedByGravity = false
                sprite.physicsBody?.categoryBitMask = CollisionBody.Wall.rawValue
                sprite.physicsBody?.collisionBitMask = CollisionBody.None.rawValue
                sprite.physicsBody?.contactTestBitMask = CollisionBody.None.rawValue
            }
        }
        
        //coins
        enumerateChildNodes(withName: "coin") { (node, done) in
            if let sprite = node as? SKSpriteNode{
                sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                sprite.physicsBody?.affectedByGravity = false
                sprite.physicsBody?.categoryBitMask = CollisionBody.Coin.rawValue
                sprite.physicsBody?.collisionBitMask = CollisionBody.Wall.rawValue
                sprite.physicsBody?.contactTestBitMask = CollisionBody.Ball.rawValue
            }
        }
    }
    
    //MARK: - Custom Methods
    func removeCoin(coin: SKSpriteNode){

        //remove physics
        coin.physicsBody = nil
        coin.name = ""
        
        //animating coin to score
        let moveAction = SKAction.move(to: self.coinIcon.position, duration: 0.5)
        let scaleAction = SKAction.scale(to: coinIcon.size, duration: 0.5)
        let moveAndScaleGroup = SKAction.group([moveAction, scaleAction])
        let scoreAction = SKAction.run {
            self.coinsCollected += 1
            self.coinLabel.text = "x \(self.coinsCollected)"
        }
        let removeAction = SKAction.removeFromParent()
        
        let sequenceAction = SKAction.sequence([moveAndScaleGroup, scoreAction, removeAction])
        
        coin.run(sequenceAction)
    }
    
    //MARK: - Update Logic
    override func update(_ currentTime: TimeInterval) {
        
        // look to see if ball is off screen
        if ball.position.y < -self.size.height/2-100 && !gameOver{
            
            if self.childNode(withName: "coin") == nil{
                gameOver = true
                ball.removeFromParent()
            }else{
                ball.physicsBody = nil
                ball.position = sling.position
                self.ballIsFlying = false
            }
        }
    }
    
    //MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {

        //looking to see if a coin was hit
        if contact.bodyA.node?.name == "coin"{
            removeCoin(coin: contact.bodyA.node as! SKSpriteNode)
        }
        
        if contact.bodyB.node?.name == "coin"{
            removeCoin(coin: contact.bodyB.node as! SKSpriteNode)
        }

    }
    
    //MARK: - Touch Logic
    func touchDown(atPoint pos : CGPoint) {
        for node in self.nodes(at: pos){
            if node == ball && !self.ballIsFlying{
                movingBall = true
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if movingBall {
            
            //Distance from sling
            let movePosition = CGPoint(x:(pos.x-sling.position.x), y:(pos.y-sling.position.y))

            //Clamp
            let standardDistance = ballRadius * 6
            let normalX = movePosition.x.clamped(v1: -standardDistance, standardDistance)
            let normalY = movePosition.y.clamped(v1: -standardDistance, standardDistance)
            
            let convertedDistance = CGPoint(x: normalX, y: normalY)
            
            ball.position = convertedDistance.addPoint(point: sling.position)
            
            //Updating sling position
            var path = CGMutablePath()
            path.move(to: CGPoint.zero)
            path.addLine(to: ball.position.subtract(point: leftSlingPosition))
            path.closeSubpath()
            self.leftSling.path = path
            
            path = CGMutablePath()
            path.move(to: CGPoint.zero)
            path.addLine(to: ball.position.subtract(point: rightSlingPosition))
            path.closeSubpath()
            self.rightSling.path = path
            
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if movingBall{
            
            //Create physics body
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
            ball.physicsBody?.categoryBitMask = CollisionBody.Ball.rawValue
            ball.physicsBody?.collisionBitMask = CollisionBody.Wall.rawValue
            ball.physicsBody?.contactTestBitMask = CollisionBody.Coin.rawValue
            
            //Calculate impulse
            let speed: CGFloat = 2
            let force = CGVector(dx: (sling.position.x-ball.position.x) * speed, dy: (sling.position.y-ball.position.y) * speed)
            ball.physicsBody?.applyImpulse(force)
            
            //Reset sling
            var path = CGMutablePath()
            path.move(to: CGPoint.zero)
            path.addLine(to: sling.position.subtract(point: leftSlingPosition))
            path.closeSubpath()
            self.leftSling.path = path
            
            path = CGMutablePath()
            path.move(to: CGPoint.zero)
            path.addLine(to: sling.position.subtract(point: rightSlingPosition))
            path.closeSubpath()
            self.rightSling.path = path
            
            self.ballIsFlying = true
        }
        
        movingBall = false
        
        if gameOver {
            if let gameScene = SKScene(fileNamed: "GameScene") {
                gameScene.scaleMode = self.scaleMode
                self.view?.presentScene(gameScene)
            }
        }
    }

    
    //MARK: - Touch Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}
