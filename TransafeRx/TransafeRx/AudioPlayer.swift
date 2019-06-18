//
//  AudioPlayer.swift
//  TransafeRx
//
//  Created by Tachl on 10/4/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import AVFoundation

open class AudioPlayer{
    
    static let sharedManager = AudioPlayer()
    let aniticipateFile = "anticipate.mp3"
    
    var player: AVAudioPlayer?
    
    // MARK: - Initialization
    public init(){
        
    }
    
    func playAudioFile(withName: String){
        let path = String(format: "%@/%@", Bundle.main.resourcePath!, withName)
        let url = URL(fileURLWithPath: path)
        
        do{
            try player = AVAudioPlayer(contentsOf: url)
            player!.play()
        }catch{
            
        }
    }
    
    func playSystemSound(withId: SystemSoundID){
        AudioServicesPlaySystemSound(withId)
    }
}
