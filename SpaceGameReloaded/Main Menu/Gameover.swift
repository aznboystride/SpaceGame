//
//  Gameover.swift
//  SpaceGameReloaded
//
//  Created by Fair Aboshehwa on 10/16/17.
//  Copyright © 2017 A_NiNJa. All rights reserved.
//

import SpriteKit
import AVFoundation

class Gameover: SKScene {
    
    var audioPlayer = AVAudioPlayer()
    
    override func didMove(to view: SKView) {
        
        let defaults = UserDefaults.standard
        let score = defaults.integer(forKey: "scoreKey")
        
        let scoreLabel = SKLabelNode(text: "Final Score: \(score)")
        scoreLabel.position = CGPoint(x: 0, y: 0)
        scoreLabel.fontName = "American Typewriter"
        self.addChild(scoreLabel)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Sierra", ofType: "m4a")!))
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print(error)
        }
        
        let starfield: SKEmitterNode! = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 360)
        starfield.advanceSimulationTime(4)
        self.addChild(starfield)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location).name == "Retry" {
                self.run(SKAction.playSoundFileNamed("steelsword.mp3", waitForCompletion: false))
                audioPlayer.stop()
                if let scene = GameScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view!.presentScene(scene, transition: SKTransition.doorway(withDuration: 3))
                }
            } else if atPoint(location).name == "Exit" {
                audioPlayer.stop()
                self.run(SKAction.playSoundFileNamed("steelsword.mp3", waitForCompletion: false))
                if let scene = MainMenu(fileNamed: "MainMenu") {
                    scene.scaleMode = .aspectFill
                    view!.presentScene(scene, transition: SKTransition.doorsCloseVertical(withDuration: 2))
                }
            }
        }
    }
}
