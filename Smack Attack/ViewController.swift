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
import CoreData

class ViewController: UIViewController {

    /* Media Resources */
    var currentSongTitle: String!
    var currentSongURL: URL!
    var audioPlayer = AVPlayer()
    var isPlaying = false
    var musicVolume: Float = 0.5
    var soundEffectVolume: Float = 0.5
    
    /* Data Instance Variables */
    var showingEditView = false
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext!
    
    /* Media References */
    @IBOutlet weak var controlStackView: UIStackView!
    @IBOutlet weak var chooseMusicButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var editSoundsButton: UIButton!
    @IBOutlet weak var topSliderLabel: UILabel!
    @IBOutlet weak var bottomSliderLabel: UILabel!
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var bottomSlider: UISlider!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    /* Media Actions */
    @IBAction func chooseMusicButtonPressed(_ sender: Any) {
        print("This is now a segue")
        /*
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        present(mediaPicker, animated: true, completion: {})
        */
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if(!self.isPlaying){
            // Play
            DispatchQueue.main.async {
                self.audioPlayer.volume = self.musicVolume
                self.audioPlayer.play()
                self.isPlaying = true
                self.playButton.setTitle("Pause", for: .normal)
                print("Playing")
            }
        } else {
            // Pause
            DispatchQueue.main.async {
                self.audioPlayer.pause()
                self.isPlaying = false
                self.playButton.setTitle("Play", for: .normal)
                print("Pausing")
            }
        }
    }
    
    @IBAction func editSoundsButtonPressed(_ sender: Any) {
        // Show Edit View
        self.showEditScreen()
    }
    @IBAction func topSliderChange(_ sender: Any) {
        // Change the song player voume
        self.musicVolume = self.topSlider.value
        self.audioPlayer.volume = self.topSlider.value
    }
    @IBAction func bottomSliderChanged(_ sender: Any) {
        // Change the Device Volume
        self.soundEffectVolume = self.bottomSlider.value
        for soundEffectPlayer in soundEffectPlayers {
            if(soundEffectPlayer.loaded){
                soundEffectPlayer.player.volume = self.bottomSlider.value
            }
            
        }
        
        /*
        DispatchQueue.main.async {
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(self.topSlider.value, animated: false)
        }
        */
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
    
    var buttons = [UIButton]()
    var soundEffectPlayers: [SoundEffect] = [SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect()]
    
    /* Sound Button Actions */
    @IBAction func soundEffectButtonPressed(_ sender: UIButton) {
        if(!self.showingEditView){
            // Play Sound Effect
            self.soundEffectPlayers[sender.tag] = SoundEffect(sound: SoundEffect.getSoundEffects()[buttonSettings[sender.tag]])
            self.soundEffectPlayers[sender.tag].play()
            self.soundEffectPlayers[sender.tag].player.volume = self.soundEffectVolume
        } else {
            // Change Sound Effect
            let newInstrument = self.getAvailableInstrument()
            sender.setTitle(SoundEffect.getEffect(newInstrument), for: .normal)
            self.saveSetting(position: sender.tag, instrument: newInstrument)
        }
        
    }
    
    /* Sound Button Data */
    var buttonSettings = [Int]()
    
    /* Edit View References */
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var restoreDefaultsButton: UIButton!
    
    /* Edit View Actions */
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.saveEditScreen()
    }
    @IBAction func restoreDefaultsButtonPressed(_ sender: Any) {
        // Restore Default Settings
        self.buttonSettings = self.loadSettings(resetToDefault: true)
        for i in 0..<self.buttonSettings.count {
            buttons[i].setTitle(SoundEffect.getEffect(i), for: .normal)
        }
    }
    
    
    /* Edit Methods */
    func showEditScreen(){
        self.showingEditView = true
        
        // Update UI
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.35, animations: {
                self.controlStackView.isHidden = true
                self.topSlider.isHidden = true
                self.bottomSlider.isHidden = true
                self.topSliderLabel.isHidden = true
                self.bottomSliderLabel.isHidden = true
                self.instructionsLabel.isHidden = false
                self.saveButton.isHidden = false
                self.restoreDefaultsButton.isHidden = false
                
                self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "2662B5")
                
                for button in self.buttons {
                    button.backgroundColor = UIColor.hexStringToUIColor(hex: "2662B5")
                    button.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                }
            })
        }
    }
    
    func saveEditScreen() {
        self.showingEditView = false
        
        // Update UI
        UIView.animate(withDuration: 0.35, animations: {
            DispatchQueue.main.async {
                self.controlStackView.isHidden = false
                self.topSlider.isHidden = false
                self.bottomSlider.isHidden = false
                self.topSliderLabel.isHidden = false
                self.bottomSliderLabel.isHidden = false
                self.instructionsLabel.isHidden = true
                self.saveButton.isHidden = true
                self.restoreDefaultsButton.isHidden = true
                
                self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "5C5E66")
                
                for button in self.buttons {
                    button.backgroundColor = UIColor.lightGray
                    button.layer.borderColor = UIColor.darkGray.cgColor
                    
                }
            }
        })
        
        
    }
    
    /* Settings Methods */
    func getAvailableInstrument() -> Int {
        // Get first available instrument
        let installedInstruments = SoundEffect.getSoundEffects()
        for i in 0..<installedInstruments.count {
            if(!self.buttonSettings.contains(i)){
                return i
            }
        }
        // Return the first non default instrument if failed
        return 8
    }
    
    func saveSetting(position: Int, instrument: Int) {
        // Delete Old Setting
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InstrumentSet")
        let positionIdPredicate = NSPredicate(format: "position = %d", position)
        request.predicate = positionIdPredicate
        do {
            let results = try context.fetch(request)
            
            if(results.count > 0){
                for result in results as! [NSManagedObject] {
                    context.delete(result)
                }
                do {
                    try context.save()
                } catch {
                    print("Error deleting saved setting")
                }
                self.context.reset()
                
            }
        } catch {
            print("Error deleting saved setting")
        }
        
        // Create New Setting
        let updatedSettings = NSEntityDescription.insertNewObject(forEntityName: "InstrumentSet", into: self.context)
        updatedSettings.setValue(position, forKey: "position")
        updatedSettings.setValue(instrument, forKey: "instrument")
        do {
            try context.save()
        } catch {
            print("Error saving")
        }
        self.context.reset()
        
        // Set New Setting in Memeory
        self.buttonSettings[position] = instrument
    }
    
    func loadSettings(resetToDefault: Bool) -> [Int]{
        
        // Flag to save initial settings
        var saveInitialSettings = resetToDefault
        
        // Load settings
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InstrumentSet")
        request.returnsObjectsAsFaults = false
        // Initialize settings to defaults
        var settings = SoundEffect.defaults()
        do {
            let results = try context.fetch(request)
            if(results.count > 0){
                for result in results as! [NSManagedObject] {
                    let position = result.value(forKey: "position") as! Int
                    let instrument = result.value(forKey: "instrument") as! Int
                    settings[position] = instrument
                }
            } else {
                saveInitialSettings = true
            }
        } catch {
            print("Error Loading Settings")
        }
        self.context.reset()
        
        // Save initial settings if necessary
        if(saveInitialSettings){
            self.buttonSettings = settings
            for i in 0..<settings.count {
                self.saveSetting(position: i, instrument: settings[i])
            }
        }
        
        return settings
    }
    
    
    /* Navigation Methods */
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        print("Current Song Title: " + self.currentSongTitle)
        
        if(segue.source is MediaSelectViewController){
            if(self.currentSongTitle != nil && self.currentSongTitle == "No Song"){
                // Handle No Song
                if(self.isPlaying){
                    // Stop playing
                    self.audioPlayer.pause()
                    self.isPlaying = false
                }
                // Update UI
                DispatchQueue.main.async {
                    self.nowPlayingLabel.text = "No Song"
                    self.playButton.setTitle("Play", for: .normal)
                    self.playButton.isEnabled = false
                }
            } else if(self.currentSongTitle != nil && self.currentSongTitle == "Cancel"){
                // The user canceled
            } else if(self.currentSongTitle != nil){
                if(self.isPlaying){
                    self.audioPlayer.pause()
                    self.isPlaying = false
                }
                // Load the song
                let playerItem = AVPlayerItem(url: self.currentSongURL)
                self.audioPlayer = AVPlayer(playerItem: playerItem)
                self.audioPlayer.volume = self.musicVolume
                
                // Update the UI
                DispatchQueue.main.async {
                    self.nowPlayingLabel.text = "Now Playing: \(self.currentSongTitle!)"
                    self.playButton.setTitle("Play", for: .normal)
                    self.playButton.isEnabled = true
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToMediaSelectSegue"){
            let vc = (segue.destination as! UINavigationController).viewControllers[0] as! MediaSelectViewController
            vc.chosenSongURL = nil
            vc.chosenSongTitle = "Cancel"
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    /* View Controller Load */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set Delegates
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        self.musicVolume = 0.5
        self.soundEffectVolume = 0.5
        
        // Setup UI
        DispatchQueue.main.async {
            self.instructionsLabel.isHidden = true
            self.saveButton.isHidden = true
            self.restoreDefaultsButton.isHidden = true
            self.playButton.isEnabled = false
            
            self.buttons.append(self.leftOne)
            self.buttons.append(self.leftTwo)
            self.buttons.append(self.leftThree)
            self.buttons.append(self.leftFour)
            self.buttons.append(self.rightOne)
            self.buttons.append(self.rightTwo)
            self.buttons.append(self.rightThree)
            self.buttons.append(self.rightFour)
            self.buttons.append(self.editSoundsButton)
            self.buttons.append(self.chooseMusicButton)
            self.buttons.append(self.playButton)
            self.buttons.append(self.saveButton)
            self.buttons.append(self.restoreDefaultsButton)
            
            // Load Settings
            var buttonNumber = 0
            self.buttonSettings = self.loadSettings(resetToDefault: false)
            for button in self.buttons {
                if(buttonNumber < 8){
                    button.tag = buttonNumber
                    button.setTitle(SoundEffect.getEffect(self.buttonSettings[buttonNumber]), for: .normal)
                    buttonNumber += 1
                }
                button.backgroundColor = UIColor.lightGray
                button.layer.cornerRadius = 3
                button.layer.borderColor = UIColor.darkGray.cgColor
                button.layer.borderWidth = 2
                button.clipsToBounds = true
                button.setTitleColor(UIColor.groupTableViewBackground, for: .normal)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIColor {
    // Extension to create a UIColor from a hex string
    public static func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

