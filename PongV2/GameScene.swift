//
//  GameScene.swift
//  PongV2
//
//  Created by Christopher Walter on 12/14/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var paddle = SKSpriteNode() // dummy node that will change in DidMove
    var ball = SKSpriteNode()
    var compPaddle = SKSpriteNode()
    var left = SKSpriteNode()
    var right = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var playerScore = 0 {
        didSet {
            scoreLabel.text = "\(playerScore) - \(compScore)"
        }
    }
    
    
    
    var compScore = 0 {
        didSet {
            scoreLabel.text = "\(playerScore) - \(compScore)"
        }
    }
    
    override func didMove(to view: SKView)
    {
        // add border around the scene
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        paddle = childNode(withName: "paddle") as! SKSpriteNode
        ball = childNode(withName: "ball") as! SKSpriteNode
        
        
        createCompPaddle()
        createLeftAndRightNodes()
        setupContacts()
        createScoreLabels()
        createMagic()
    }
    
    func createMagic()
    {
        if let magic = SKEmitterNode(fileNamed: "Fire")
        {
            magic.position = CGPoint(x: 0, y: 0)
            magic.zPosition = 10
            
            
//            magic.physicsBody = SKPhysicsBody(circleOfRadius: 20)
            ball.addChild(magic)
        }
        
    }
    

    
    func createScoreLabels() {
        scoreLabel = SKLabelNode(text: "0 - 0")
        scoreLabel.fontSize = 75
        scoreLabel.position = CGPoint(x: frame.width/2, y: self.frame.height * 0.8)
        scoreLabel.fontColor = UIColor.white
        addChild(scoreLabel)
    }
    
    func resetBall()
    {
        // stop the ball
        ball.physicsBody?.velocity = .zero
        
        let wait = SKAction.wait(forDuration: 1.0)
        let move = SKAction.move(to: CGPoint(x: self.frame.width/2, y: self.frame.height/2), duration: 1.0)
        let push = SKAction.applyImpulse(CGVector(dx: 50, dy: 50), at: .zero, duration: 0.1)
        ball.run(SKAction.sequence([wait, move, wait, push]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    
//        print(contact.contactPoint)
        
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.node?.name == "left"
        {
            print("Computer scored!!!")
            resetBall()
            compScore += 1
//            scoreLabel.text = "\(playerScore) - \(compScore)"
        }
        if contact.bodyB.categoryBitMask == 1 && contact.bodyA.node?.name == "left"
        {
            print("Computer scored!!!")
            resetBall()
            compScore += 1
//            scoreLabel.text = "\(playerScore) - \(compScore)"
        }
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.node?.name == "right"
        {
            print("player scored!!!")
            resetBall()
            playerScore += 1
//            scoreLabel.text = "\(playerScore) - \(compScore)"
        }
        if contact.bodyB.categoryBitMask == 1 && contact.bodyA.node?.name == "right"
        {
            print("player scored!!!")
            resetBall()
            playerScore += 1
//            scoreLabel.text = "\(playerScore) - \(compScore)"
        }
        
        
    }
    
    func setupContacts()
    {
        ball.physicsBody?.categoryBitMask = 1
        left.physicsBody?.categoryBitMask = 4
        right.physicsBody?.categoryBitMask = 4
        
        ball.physicsBody?.contactTestBitMask = 4
        
        physicsWorld.contactDelegate = self
        
    }
    
    func createLeftAndRightNodes()
    {
        left = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: frame.height))
        left.position = CGPoint(x: 0, y: frame.height/2)
        addChild(left)
        left.physicsBody = SKPhysicsBody(rectangleOf: left.frame.size)
        left.physicsBody?.isDynamic = false
        left.name = "left"
        
        right = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: frame.height))
        right.position = CGPoint(x: frame.width, y: frame.height/2)
        addChild(right)
        right.physicsBody = SKPhysicsBody(rectangleOf: right.frame.size)
        right.physicsBody?.isDynamic = false
        right.name = "right"
        
    }
    
    
    func createCompPaddle()
    {
        // create the skSpritenode on the screen
        compPaddle = SKSpriteNode(color: UIColor.cyan, size: CGSize(width: 50, height: 200))
        
        // set size, position, and other visual components
        compPaddle.position = CGPoint(x: self.frame.width * 0.9, y: self.frame.height * 0.5)
        addChild(compPaddle)
        
        // add physics to the paddle
        compPaddle.physicsBody = SKPhysicsBody(rectangleOf: compPaddle.frame.size)
        compPaddle.physicsBody?.allowsRotation = false
        compPaddle.physicsBody?.friction = 0
        compPaddle.physicsBody?.affectedByGravity = false
        compPaddle.physicsBody?.isDynamic = false
        compPaddle.physicsBody?.restitution = 1
        compPaddle.physicsBody?.angularDamping = 0
        compPaddle.physicsBody?.linearDamping = 0
        
        // Make the paddle move ... Follow ball
        let follow = SKAction.sequence([SKAction.run(followBall), SKAction.wait(forDuration: 0.1)])
        
        run(SKAction.repeatForever(follow))
    }
    
    func followBall()
    {
        let move = SKAction.moveTo(y: ball.position.y, duration: 0.1)
        compPaddle.run(move)
    }
    
    
    var isTouchingPaddle = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        if paddle.frame.contains(location) {
            isTouchingPaddle = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouchingPaddle == true
        {
            let location = touches.first!.location(in: self)
            paddle.position = CGPoint(x: paddle.position.x, y: location.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingPaddle = false
    }
    
    
    
    
}
