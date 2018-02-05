//
//  GameScene.swift
//  SpaceGameReloaded
//
//  Created by Fair Aboshehwa on 10/14/17.
//  Copyright © 2017 A_NiNJa. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var powerUp_2           : SKSpriteNode!
    var timeIncreaser       : Double = 0
    var powerUp             : SKSpriteNode!
    var starfield           : SKEmitterNode!
    var player              : SKSpriteNode!
    var fire                : SKEmitterNode!
    var scoreLabel          : SKLabelNode!
    var score               : Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var powerUpLabel        : SKLabelNode!
    
    var powerUpCount        : Int = 0 {
        didSet {
            powerUpLabel.text = "Power Ups: \(powerUpCount)"
        }
    }
    
    var hearts              = [SKSpriteNode]()
    
    var gameTimer           : Timer!
    
    var possibleAliens      = ["alien", "alien2", "alien3"]
    
    let powerUpFireCategory : UInt32    = 0x1 << 5
    
    let powerUpCategory     : UInt32    = 0x1 << 4
    
    let heartCategory       : UInt32    = 0x1 << 3
    
    let playerCategory      : UInt32    = 0x1 << 2
    
    let alienCategory       : UInt32    = 0x1 << 1
    
    let photonTorpedoCategory: UInt32   = 0x1 << 0
    
    let motionManager       = CMMotionManager()

    let defaults = UserDefaults.standard
    
    var xAcceleration       :CGFloat = 0
    
    var heartCheckTimer     : Timer!
    
    var powerCheckTimer     : Timer!
    
    var powerUpFire         : SKEmitterNode!
    
    var alienTimeInterval   : Double = 0.75
    
    var magicIsCurrent      : Bool = false
    
    var powerUpButton       : SKSpriteNode!
    
    //let myBackground: SKSpriteNode! = SKSpriteNode(imageNamed: "background")
    
    @objc func doesPowerShowUp() {
        let chanceOfPower: UInt32 = 2
        let rand = arc4random_uniform(chanceOfPower)
        if rand == 1 {
            addRandomPower()
        }
    }
    
    func addRandomPower() {
        powerUp = SKSpriteNode(imageNamed: "PowerUp")
        let xPosition = GKRandomDistribution(lowestValue: -200, highestValue: 200)
        powerUp.position = CGPoint(x: CGFloat(xPosition.nextInt()), y: 350 + powerUp.size.height)
        powerUp.name = "powerup"
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.width/2)
        powerUp.physicsBody?.isDynamic = true
        powerUp.physicsBody?.collisionBitMask = 0
        powerUp.physicsBody?.categoryBitMask = powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = playerCategory
        self.addChild(powerUp)
        
        let animationDuration: TimeInterval = 6 - timeIncreaser
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.moveBy(x: 0, y: -390*2, duration: animationDuration))
        
        actionArray.append(SKAction.removeFromParent())
        
        powerUp.run(SKAction.sequence(actionArray))
    }
    
     func addHeart() {
        if hearts.count < 4 {
             let heart = SKSpriteNode(imageNamed: "hearts")
             hearts.append(heart)
             heart.position = CGPoint(x: 75 + Int(heart.size.width) * 3 - Int(heart.size.width + 5) * hearts.count, y: 320)
             heart.name = "heart"
             heart.physicsBody = SKPhysicsBody(circleOfRadius: heart.size.width/2)
             heart.physicsBody?.isDynamic = true
             heart.physicsBody?.collisionBitMask = 0
             heart.physicsBody?.contactTestBitMask = playerCategory
             heart.physicsBody?.categoryBitMask = heartCategory
             self.addChild(heart)
        }
     }
    
     @objc func doesHeartShowUp() {
        let rand = arc4random_uniform(2)
        if rand == 1 {
            addRandomHeart()
        }
     }
    
     func addRandomHeart() {
         let heart: SKSpriteNode! = SKSpriteNode(imageNamed: "hearts")
         let randomPosition = GKRandomDistribution(lowestValue: -200, highestValue: 200)
         let heartPosition = CGFloat(randomPosition.nextInt())
        
         heart.position = CGPoint(x: heartPosition, y: 350 + heart.size.height)
         heart.physicsBody = SKPhysicsBody(circleOfRadius: heart.size.width/2)
         heart.physicsBody?.isDynamic = true
         heart.physicsBody?.categoryBitMask = heartCategory
         heart.physicsBody?.collisionBitMask = 0
         heart.physicsBody?.contactTestBitMask = playerCategory
         heart.name = "heart"
         self.addChild(heart)
         var actionArray = [SKAction]()
         actionArray.append(SKAction.moveBy(x: 0, y: -390*2, duration: 6 - timeIncreaser))
         actionArray.append(SKAction.removeFromParent())
         heart.run(SKAction.sequence(actionArray))
     }
    
    func initializePowerUpCount() {
        powerUpLabel.fontSize = 26
        powerUpLabel.position = CGPoint(x: scoreLabel.position.x , y: -330)
        self.addChild(powerUpLabel)
    }
    
    override func didMove(to view: SKView) {
        
        //myBackground.position = CGPoint(x: 0, y: 0)
        //myBackground.zPosition = -2
        //self.addChild(myBackground)
        
        starfield = SKEmitterNode(fileNamed: "Rain")
        starfield.zPosition = -1
        self.addChild(starfield)
        
         for _ in (0...2) {
             addHeart()
         }
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: 0, y: -355 + player.size.height + 20)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = alienCategory  | heartCategory | powerUpCategory
        player.physicsBody?.isDynamic = true
        player.name = "player"
        
        self.addChild(player)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: -player.size.width*2 - 30, y: 320)
        scoreLabel.fontName = "American Typewriter"
        self.addChild(scoreLabel)
        
        powerUpLabel = SKLabelNode(text: "Power Ups: 0")
        powerUpLabel.fontName = "American Typewriter"
        initializePowerUpCount()
        
        fire = SKEmitterNode(fileNamed: "Fire")
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: alienTimeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        heartCheckTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(doesHeartShowUp), userInfo: nil, repeats: true)
        powerCheckTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(doesPowerShowUp), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x * 0.75) + self.xAcceleration * 0.25
            }
        }
        
        powerUpButton = SKSpriteNode(color: UIColor.blue, size: (self.childNode(withName: "heart") as! SKSpriteNode).size)
        powerUpButton.position = CGPoint(x: powerUpLabel.position.x, y: powerUpLabel.position.y + 30)
        powerUpButton.name = "powerButton"
        self.addChild(powerUpButton)
        
    }
    
    @objc func addAlien() {
        if(alienTimeInterval > 0.20) {
            alienTimeInterval -= 0.01
        } else {
            alienTimeInterval = 0.75
        }
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomAlienPosition = GKRandomDistribution(lowestValue: -200, highestValue: 200)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: 350 + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory | playerCategory | powerUpFireCategory
        alien.physicsBody?.collisionBitMask = 0
        alien.name = "alien"
        
        self.addChild(alien)
        
        let animationDuration: TimeInterval = 6 - timeIncreaser
        if(6 - timeIncreaser < 1) {
            timeIncreaser = 3
        }
        timeIncreaser += 0.03
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.moveBy(x: 0, y: -390*2, duration: animationDuration))
        
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
    }
    
    func fireTorpedo() {
        let torpedo: SKSpriteNode! = SKSpriteNode(imageNamed: "torpedo")
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width/2)
        torpedo.physicsBody?.isDynamic = true
        torpedo.position = CGPoint(x: player.position.x, y: player.position.y + player.size.height / 2)
        torpedo.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.name = "torpedo"
        
        var action = [SKAction]()
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        self.addChild(torpedo)
        
        action.append(SKAction.move(by: CGVector(dx: 0, dy: 390*2), duration: 1))
        action.append(SKAction.removeFromParent())
        torpedo.run(SKAction.sequence(action))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let _ = contact.bodyA.node as? SKSpriteNode , let _ = contact.bodyB.node as? SKSpriteNode {
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if((firstBody.name == "torpedo" && secondBody.name == "alien")) {
                torpedoDidCollideWithAlien(alien: secondBody)
                firstBody.removeFromParent()
                secondBody.removeFromParent()
            } else if(firstBody.name == "alien" && secondBody.name == "torpedo") {
                torpedoDidCollideWithAlien(alien: firstBody)
                firstBody.removeFromParent()
                secondBody.removeFromParent()
            } else if(firstBody.name == "player" && secondBody.name == "alien") {
                alienDidCollideWithPlayer(player: secondBody)
                var actionArray = [SKAction]()
                actionArray.append(SKAction.fadeOut(withDuration: 0.7))
                actionArray.append(SKAction.fadeIn(withDuration: 0.7))
                player.run(SKAction.sequence(actionArray))
            } else if(firstBody.name == "alien" && secondBody.name == "player") {
                alienDidCollideWithPlayer(player: secondBody)
                var actionArray = [SKAction]()
                actionArray.append(SKAction.fadeOut(withDuration: 0.7))
                actionArray.append(SKAction.fadeIn(withDuration: 0.7))
                player.run(SKAction.sequence(actionArray))
            } else if(firstBody.name == "heart" && secondBody.name == "player") {
                heartDidCollideWithPlayer()
                firstBody.removeFromParent()
             } else if(firstBody.name == "player" && secondBody.name == "heart") {
                heartDidCollideWithPlayer()
                secondBody.removeFromParent()
            } else if(firstBody.name == "player" && secondBody.name == "powerup") {
                powerUpDidCollideWithPlayer()
                secondBody.removeFromParent()
            } else if(firstBody.name == "powerup" && secondBody.name == "player") {
                powerUpDidCollideWithPlayer()
                firstBody.removeFromParent()
            }
        }
    }
    
    func powerUpDidCollideWithPlayer() {
        powerUp.removeFromParent()
        powerUpCount += 1
    }
    
     func heartDidCollideWithPlayer() {
        addHeart()
     }
    
    func alienDidCollideWithPlayer(player: SKSpriteNode) {
        self.removeHeart()
        let fire: SKEmitterNode! = SKEmitterNode(fileNamed: "Fire")
        fire.position = player.position
        self.addChild(fire)
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        self.run(SKAction.wait(forDuration: 2)) {
            fire.removeFromParent()
        }
    }
    
     func removeHeart() {
     if hearts.count == 0 {
        defaults.set(score, forKey: "scoreKey")
        defaults.synchronize()
         player.physicsBody?.isDynamic = false
         if let scene = Gameover(fileNamed: "GameoverScene") {
             // Set the scale mode to scale to fit the window
             scene.scaleMode = .aspectFill
            
             // Present the scene
             view!.presentScene(scene, transition: SKTransition.crossFade(withDuration: 4))
         }
     } else {
         hearts[hearts.count-1].removeFromParent()
         hearts.remove(at: hearts.count-1)
         }
     }
    
    func torpedoDidCollideWithAlien(alien: SKSpriteNode) {
        let fire: SKEmitterNode! = SKEmitterNode(fileNamed: "Fire")
        fire.position = alien.position
        self.addChild(fire)
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        self.run(SKAction.wait(forDuration: 0.2)) {
            fire.removeFromParent()
            self.score += 5
        }
    }
    
    func firePowerUp() {
        if !magicIsCurrent {
            magicIsCurrent = true
            powerUpCount -= 1
            powerUpFire = SKEmitterNode(fileNamed: "Magic")
            powerUpFire.physicsBody = SKPhysicsBody(rectangleOf: powerUpFire.particleSize)
            powerUpFire.physicsBody?.collisionBitMask = 0
            powerUpFire.physicsBody?.categoryBitMask = powerUpFireCategory
            powerUpFire.physicsBody?.contactTestBitMask = alienCategory
            powerUpFire.physicsBody?.isDynamic = false
            powerUpFire.particleSize = CGSize(width: 40, height: 650)
            powerUpFire.name = "magic"
            self.addChild(powerUpFire)
            powerUpFire.run(SKAction.wait(forDuration: 2)) {
                self.powerUpFire.removeFromParent()
                self.magicIsCurrent = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchX = touch.location(in: self)
            if let _ = atPoint(touchX).name {
                if(!magicIsCurrent && atPoint(touchX).name! != "powerButton") {
                    fireTorpedo()
                } else if !magicIsCurrent && powerUpCount > 0 && atPoint(touchX).name! == "powerButton" {
                    firePowerUp()
                    self.run(SKAction.playSoundFileNamed("Fire2.mp3", waitForCompletion: false))
                }
            } else {
                if !magicIsCurrent {
                    fireTorpedo()
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        self.player.position.x += self.xAcceleration * 50
        if player.position.x > 220 {
            player.position.x = -220
        } else if player.position.x < -220 {
            player.position.x = 220
        }
        if let powerF = powerUpFire {
            powerF.position = CGPoint(x: player.position.x, y: player.position.y+CGFloat(650/2))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.enumerateChildNodes(withName: "alien", using:
            {
                (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            // do something with node or stop
                if let _ = self.powerUpFire {
                    if (self.powerUpFire.parent != nil) {
                        if abs(Int(node.position.x) - Int(self.powerUpFire.position.x)) < 40 {
                            let fire: SKEmitterNode! = SKEmitterNode(fileNamed: "Fire")
                            fire.position = node.position
                            self.addChild(fire)
                            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                            node.removeFromParent()
                            self.run(SKAction.wait(forDuration: 2)) {
                                fire.removeFromParent()
                            }
                        }
                    }
                }
            }
       )
    }
}
