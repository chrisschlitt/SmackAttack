//
//  ViewController.swift
//  Smack Attack
//
//  Created by Christopher Schlitt on 3/23/17.
//  Copyright © 2017 Smack Innovations. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController, MPMediaPickerControllerDelegate {

    /* Media Resources */
    var currentSong: MPMediaItem!
    var currentSongURL: URL!
    var audioPlayer = AVPlayer()
    var isPlaying = false
    
    /* Media References */
    @IBOutlet weak var chooseMusicButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var editSoundsButton: UIButton!
    @IBOutlet weak var topSliderLabel: UILabel!
    @IBOutlet weak var bottomSliderLabel: UILabel!
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var bottomSlider: UISlider!
    
    /* Media Actions */
    @IBAction func chooseMusicButtonPressed(_ sender: Any) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        present(mediaPicker, animated: true, completion: {})
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if(!self.isPlaying){
            DispatchQueue.main.async {
                self.audioPlayer.play()
                self.isPlaying = true
                self.playButton.setTitle("Pause", for: .normal)
                print("Playing")
            }
        } else {
            DispatchQueue.main.async {
                self.audioPlayer.pause()
                self.isPlaying = false
                self.playButton.setTitle("Play", for: .normal)
                print("Pausing")
            }
        }
    }
    
    @IBAction func editSoundsButtonPressed(_ sender: Any) {
        
    }
    @IBAction func topSliderChange(_ sender: Any) {
        // Change the song player voume
        self.audioPlayer.volume = self.topSlider.value
    }
    @IBAction func bottomSliderChanged(_ sender: Any) {
        // Change the Device Volume
        DispatchQueue.main.async {
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(self.topSlider.value, animated: false)
        }
    }
    
    
    /* Sound Button References */
    @IBOutlet weak var leftOne: UIButton!
    @IBOutlet weak var leftTwo: UIButton!
    @IBOutlet weak var leftThree: UIButton!
    @IBOutlet weak var leftFour: UIButton!
    @IBOutlet weak var rightOne: UIButton!
    @IBOutlet weak var rightTwo: UIButton!
    @IBOutlet weak var rightThree: UIButton!
    @IBOutlet weak var rightFour: UIButton!
    
    var soundEffectPlayers: [SoundEffect] = [SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect()]
    
    /* Sound Button Actions */
    @IBAction func soundEffectButtonPressed(_ sender: UIButton) {
        self.soundEffectPlayers[sender.tag] = SoundEffect(sound: self.sounds[buttonSettings[sender.tag]])
        self.soundEffectPlayers[sender.tag].play()
    }
    
    /* Sound Button Data */
    var sounds: [String] {
        get {
            return SoundEffect.getSoundEffects()
        }
        set {
            print("This is a get only property")
        }
    };
    var buttonSettings = [0, 1, 2, 3, 4, 5, 6, 7]
    
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print("The user closed the media picker")
        
        dismiss(animated: true, completion: nil)
        
        //User selected a/an item(s).
        if(mediaItemCollection.count > 0){
            print("The user selected \(mediaItemCollection.items.first!)")
            self.currentSong = mediaItemCollection.items.first!
            
            if((self.currentSong.value(forProperty: MPMediaItemPropertyIsCloudItem) as! Bool)){
                let alert = UIAlertController(title: "Not Supported", message: "Songs stored in the cloud are not supported. Open the music app and download the song first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.currentSongURL = currentSong.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
                print(self.currentSongURL)
                let playerItem = AVPlayerItem(url: self.currentSongURL)
                self.audioPlayer = AVPlayer(playerItem: playerItem)
                self.nowPlayingLabel.text = "Now Playing: \(self.currentSong.title!)"
                // self.audioPlayer.play()
            }
            
            
            
            
            
            
        }
        
        
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("User selected Cancel")
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        DispatchQueue.main.async {
            let buttons = [self.leftOne, self.leftTwo, self.leftThree, self.leftFour, self.rightOne, self.rightTwo, self.rightThree, self.rightFour, self.editSoundsButton, self.chooseMusicButton, self.playButton]
            for button in buttons {
                button?.backgroundColor = UIColor.lightGray
                button?.layer.cornerRadius = 3
                button?.layer.borderColor = UIColor.darkGray.cgColor
                button?.layer.borderWidth = 2
                button?.clipsToBounds = true
                button?.setTitleColor(UIColor.groupTableViewBackground, for: .normal)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

