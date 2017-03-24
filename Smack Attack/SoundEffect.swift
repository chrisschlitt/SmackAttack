//
//  SoundEffect.swift
//  Smack Attack
//
//  Created by Christopher Schlitt on 3/23/17.
//  Copyright © 2017 Smack Innovations. All rights reserved.
//

import Foundation
import AVFoundation

class SoundEffect {
    
    var player: AVAudioPlayer
    var sound: String
    
    init(sound: String){
        self.sound = sound
        self.player = AVAudioPlayer()
    }
    
    init(){
        self.sound = SoundEffect.getSoundEffects()[0]
        self.player = AVAudioPlayer()
    }
    
    static func getSoundEffects() -> [String] {
        return ["kick_drum", "tom", "crash", "splash", "snare", "high_hat", "ride", "cowbell"]
    }
    
    
    
    func play() {
        let url = Bundle.main.url(forResource: self.sound, withExtension: "m4a")!
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
