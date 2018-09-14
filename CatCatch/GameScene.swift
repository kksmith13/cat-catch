//
//  GameScene.swift
//  CatCatch
//
//  Created by Kyle Smith on 4/4/17.
//  Copyright © 2017 Smith Coding. All rights reserved.
//

import SpriteKit

let tickLengthLevelOne = TimeInterval(600)

class GameScene: SKScene {
    
    var viewController: GameViewController!
    
    var highScore = 0
    var strikes = 0
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    struct PhysicsCategory {
        static let Cat: UInt32 = 1
        static let Basket: UInt32 = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    let scoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.fontName = "ChalkboardSE-Regular"
        label.fontSize = 20
        label.horizontalAlignmentMode = .left
        label.text = "Score: 0"
        return label
    }()
    
    let strikesLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.fontName = "ChalkboardSE-Regular"
        label.fontSize = 20
        label.horizontalAlignmentMode = .left
        label.text = "Strikes: "
        return label
    }()
    
    let strikeOne:SKSpriteNode = {
        let strike = SKSpriteNode()
        strike.texture = SKTexture(imageNamed: "strike")
        return strike
    }()
    
    let strikeTwo:SKSpriteNode = {
        let strike = SKSpriteNode()
        strike.texture = SKTexture(imageNamed: "strike")
        return strike
    }()
    
    let strikeThree:SKSpriteNode = {
        let strike = SKSpriteNode()
        strike.texture = SKTexture(imageNamed: "strike")
        return strike
    }()

    let switchLeft: SKSpriteNode = {
        let button = SKSpriteNode()
        button.name = "switchLeft"
        button.color = .blue
        return button
    }()
    
    let switchRight: SKSpriteNode = {
        let button = SKSpriteNode()
        button.name = "switchRight"
        button.color = .green
        return button
    }()
    
    let pauseButton: SKSpriteNode = {
        let button = SKSpriteNode()
        button.name = "pause"
        button.texture = SKTexture(imageNamed: "pause")
        return button
    }()
    
    var tick:(() -> ())?
    var tickLengthMillis = tickLengthLevelOne
    var lastTick: NSDate?
    
    let colors = [SKColor.black, SKColor.red, SKColor.orange, SKColor.white, SKColor.purple]
    
    var basket: SKNode?
    var background = SKSpriteNode(imageNamed: "background")
    
    var cat: Cat?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let lastTick = lastTick else {
            return
        }
        
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            
            tick?()
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
        
        physicsWorld.gravity.dy = -3
        
        setupButtons()
        setupScoreboard()
        setupPlayerAndObstacles()
    }
    
    func setupScoreboard() {
        scoreLabel.position = CGPoint(x: 8, y: size.height - 24)
        addChild(scoreLabel)
        
        strikesLabel.position = CGPoint(x: 8, y: size.height - 48)
        addChild(strikesLabel)
    }
    
    func setupButtons() {
        addPauseButton()
        
        switchLeft.position = CGPoint(x: size.width * 0.175, y: size.height * 0.12)
        switchLeft.size = CGSize(width: size.width * 0.2, height: size.width * 0.2)
        
        switchRight.position = CGPoint(x: size.width * 0.825, y: size.height * 0.12)
        switchRight.size = CGSize(width: size.width * 0.2, height: size.width * 0.2)
        
        addChild(switchLeft)
        addChild(switchRight)
        
        
    }
    
    func addPauseButton() {
        pauseButton.position = CGPoint(x: size.width - 24, y: size.height - 24)
        pauseButton.size = CGSize(width: size.width * 0.11, height: size.width * 0.11)
        addChild(pauseButton)
    }
    
    
    func setupPlayerAndObstacles() {
        addObstacle()
        spawnCat()
        
    }
    
    func addObstacle() {
        addBasket()
    }
    
    func addBasket() {
        
        let ratio = size.width * 0.16
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -ratio))
        path.addLine(to: CGPoint.zero)
        path.addArc(withCenter: CGPoint.zero, radius: ratio, startAngle: CGFloat((19 * M_PI)/10), endAngle: CGFloat((19 * M_PI)/10), clockwise: false)
        
        
        basket = basketByDuplicatingPath(path, clockwise: true)
        basket?.position = CGPoint(x: size.width/2, y: 0 + 85)
        
        addChild(basket!)
        
    }
    
    func basketByDuplicatingPath(_ path: UIBezierPath, clockwise: Bool) -> SKNode {
        let container = SKNode()
        
        var rotationFactor = CGFloat((2 * M_PI)/5)
        if !clockwise {
            rotationFactor *= -1
        }
        
        for i in 0...4 {
            let section = SKShapeNode(path: path.cgPath)
            section.fillColor = colors[i]
            section.strokeColor = colors[i]
            section.zRotation = rotationFactor * CGFloat(i);
            
            let sectionBody = SKPhysicsBody(polygonFrom: path.cgPath)
            sectionBody.categoryBitMask = PhysicsCategory.Basket
            sectionBody.collisionBitMask = 0
            sectionBody.contactTestBitMask = PhysicsCategory.Cat
            sectionBody.affectedByGravity = false
            section.physicsBody = sectionBody
            
            container.addChild(section)
        }
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == "switchLeft" {
                let rotateAction = SKAction.rotate(byAngle: CGFloat((2*M_PI)/5), duration: 0.17)
                basket?.run(rotateAction)
            } else if node.name == "switchRight" {
                let rotateAction = SKAction.rotate(byAngle: CGFloat(-(2*M_PI)/5), duration: 0.17)
                basket?.run(rotateAction)
            } else if node.name == "pause" {
                let skView = self.view! as SKView
                skView.isPaused = true
            }
        }
        super.touchesBegan(touches, with: event)
        
    }
    
    func gameOver() {
        print("gameOver")
        cat?.sprite?.physicsBody?.velocity.dy = 0
        cat?.sprite?.removeFromParent()
        viewController.showGameOver()
    }
    
    func strike(num: Int) {
        switch num {
        case 1:
            strikeOne.position = CGPoint(x: 90, y: size.height - 42)
            strikeOne.size = CGSize(width: size.width * 0.06, height: size.width * 0.06)
            addChild(strikeOne)
            spawnCat()
        case 2:
            strikeTwo.position = CGPoint(x: 110, y: size.height - 42)
            strikeTwo.size = CGSize(width: size.width * 0.06, height: size.width * 0.06)
            addChild(strikeTwo)
            spawnCat()
        case 3:
            strikeThree.position = CGPoint(x: 130, y: size.height - 42)
            strikeThree.size = CGSize(width: size.width * 0.06, height: size.width * 0.06)
            addChild(strikeThree)
            gameOver()
        default:
            break;
            
        }
        
    }
    
    func spawnCat() {
        let sizeRatio = size.width * 0.0300
        cat = Cat(catType: CatType.random())
        cat?.sprite = SKShapeNode(circleOfRadius: sizeRatio)
        cat?.sprite?.fillColor = (cat?.catType.color)!
        cat?.sprite?.strokeColor = (cat?.catType.color)!
        cat?.sprite?.position = CGPoint(x: size.width / 2, y: size.height * 0.96)
        
        let catBody = SKPhysicsBody(circleOfRadius: sizeRatio)
        catBody.mass = 0
        //catBody.velocity = CGVector(dx: 0, dy: -200)
        catBody.categoryBitMask = PhysicsCategory.Cat
        catBody.collisionBitMask = 4
        cat?.sprite?.physicsBody = catBody
        
        addChild((cat?.sprite)!)
    }
    
    func deleteCat() {
        cat?.sprite?.physicsBody?.velocity.dy = 0
        cat?.sprite?.removeFromParent()
    }
    
    func doSomething() {
        deleteCat()
        strikes += 1
        strike(num: strikes)
    }
    
    func doSomethingElse() {
        print("nice")
        score += 1
        deleteCat()
        spawnCat()
    }
}


extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let nodeA = contact.bodyA.node as? SKShapeNode, let nodeB = contact.bodyB.node as? SKShapeNode {
            if nodeA.fillColor != nodeB.fillColor {
                doSomething()
            } else {
                doSomethingElse()
            }
        }
    }
}
