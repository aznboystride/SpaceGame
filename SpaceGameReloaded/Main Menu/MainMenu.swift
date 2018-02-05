//
//  MainMenu.swift
//  SpaceGameReloaded
//
//  Created by Fair Aboshehwa on 10/15/17.
//  Copyright © 2017 A_NiNJa. All rights reserved.
//

import SpriteKit
import AVFoundation

class MainMenu: SKScene {
    var starField: SKEmitterNode!
    var audioPlayer = AVAudioPlayer()
    
    override func didMove(to view: SKView) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Sierra", ofType: "m4a")!))
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print(error)
        }
        
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: 380)
        starField.advanceSimulationTime(3)
        self.addChild(starField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location).name == "Start" {
                self.run(SKAction.playSoundFileNamed("steelsword.mp3", waitForCompletion: false))
                audioPlayer.stop()
                if let scene = GameScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    // Present the scene
                    view!.presentScene(scene, transition: SKTransition.crossFade(withDuration: TimeInterval(1)))
                }
            }
        }
    }
}
