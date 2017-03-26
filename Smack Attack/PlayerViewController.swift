//
//  PlayerViewController.swift
//  Smack Attack
//
//  Created by Christopher Schlitt on 3/23/17.
//  Copyright © 2017 Smack Innovations. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import CoreData

class PlayerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    /* Media Resources */
    var currentSongTitle: String!
    var currentSongArtist: String!
    var currentSongURL: URL!
    var audioPlayer = AVPlayer()
    var editSoundEffect = SoundEffect()
    var isPlaying = false
    var musicVolume: Float = 0.5
    var soundEffectVolume: Float = 0.5
    var recorder = AVAudioRecorder()
    var volumeHidden = false
    var smallScreen = false
    
    /* Data Instance Variables */
    var showingEditView = false
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext!
    var editingItemTag = 0
    var toolBar = UIToolbar()
    
    /* Media References */
    @IBOutlet weak var controlStackView: UIStackView!
    @IBOutlet weak var controlStackViewContainer: UIView!
    @IBOutlet weak var chooseMusicButton: UIButton!
    @IBOutlet weak var playButtonContainer: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editButtonContainer: UIStackView!
    @IBOutlet weak var nowPlayingContainer: UIView!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var nowPlayingHeaderLabel: UILabel!
    @IBOutlet weak var editSoundsButton: UIButton!
    @IBOutlet weak var topSliderLabel: UILabel!
    @IBOutlet weak var bottomSliderContainer: UIStackView!
    @IBOutlet weak var bottomSliderLabel: UILabel!
    @IBOutlet weak var topSliderContainer: UIStackView!
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var bottomSlider: UISlider!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var editActionButtonsContainer: UIStackView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var nowPlayingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSliderConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSliderConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSliderTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSliderTrailingConstraint: NSLayoutConstraint!
    var toolBarShowingConstraint: NSLayoutConstraint!
    var toolBarHiddenConstraint: NSLayoutConstraint!
    
    /* Media Actions */
    @IBAction func playButtonPressed(_ sender: Any) {
        if(!self.isPlaying){
            // Play
            self.audioPlayer.volume = self.musicVolume
            self.audioPlayer.play()
            self.isPlaying = true
            
            DispatchQueue.main.async {
                self.playButton.setTitle("Pause", for: .normal)
                print("Playing")
            }
        } else {
            // Pause
            self.audioPlayer.pause()
            self.isPlaying = false
            DispatchQueue.main.async {
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
    }
    @IBAction func volumeButtonPressed(_ sender: Any) {
        if(self.volumeHidden){
            self.showVolume()
        } else {
            self.hideVolume()
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
    
    var buttons = [UIButton]()
    var soundEffectPlayers: [SoundEffect] = [SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect(), SoundEffect()]
    
    /* Sound Button Actions */
    @IBAction func soundEffectButtonPressed(_ sender: UIButton) {
        if(!self.showingEditView){
            // Play Sound Effect
            self.soundEffectPlayers[sender.tag] = SoundEffect(sound: SoundEffect.getSoundEffects()[buttonSettings[sender.tag]])
            self.soundEffectPlayers[sender.tag].play()
            self.soundEffectPlayers[sender.tag].player.volume = self.soundEffectVolume
        }
    }
    
    @IBAction func soundEffectButtonEditPressed(_ sender: UIButton){
        if(self.showingEditView){
            // Change Sound Effect
            let newInstrument = self.getAvailableInstrument(buttonSettings[sender.tag])
            sender.setTitle(SoundEffect.getEffect(newInstrument), for: .normal)
            self.saveSetting(position: sender.tag, instrument: newInstrument)
            
            self.editSoundEffect = SoundEffect(sound: SoundEffect.getEffect(newInstrument))
            self.editSoundEffect.play()
        }
    
    }
    
    @IBAction func soundEffectButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.began && self.showingEditView){
            // Show picker
            self.editingItemTag = (sender.view?.tag)!
            self.showpicker()
        }
    }
    
    
    
    /* Sound Button Data */
    var buttonSettings = [Int]()
    
    /* Edit View References */
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var restoreDefaultsButton: UIButton!
    
    /* Edit View Actions */
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.hidePicker()
        self.saveEditScreen()
    }
    @IBAction func restoreDefaultsButtonPressed(_ sender: Any) {
        // Restore Default Settings
        self.hidePicker()
        self.buttonSettings = self.loadSettings(resetToDefault: true)
        for i in 0..<self.buttonSettings.count {
            buttons[i].setTitle(SoundEffect.getEffect(i), for: .normal)
        }
    }
    
    
    /* Edit Resources */
    var pickerView = UIPickerView()
    
    /* Edit Methods */
    func showEditScreen(){
        self.showingEditView = true
        
        // Update UI
        DispatchQueue.main.async {
            self.topSliderContainer.isHidden = true
            self.bottomSliderContainer.isHidden = true
            UIView.animate(withDuration: 0.35, animations: {
                self.controlStackViewContainer.isHidden = true
                self.settingsStackView.isHidden = false
                
                self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "2662B5")
                self.controlStackViewContainer.backgroundColor = UIColor.hexStringToUIColor(hex: "2662B5")
                
                var buttonCount = 0
                for button in self.buttons {
                    if(buttonCount < 8){
                        let borderLayer = CAShapeLayer.dashedBorderLayerWithColor(frame: button.frame, color: UIColor.groupTableViewBackground)
                        button.layer.addSublayer(borderLayer)
                        button.layer.borderWidth = 0
                        buttonCount += 1
                    } else if(buttonCount < 10) {
                        button.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                        buttonCount += 1
                    } else {
                        break
                    }
                    
                    button.backgroundColor = UIColor.hexStringToUIColor(hex: "2662B5")
                }
            })
        }
    }
    
    func saveEditScreen() {
        self.showingEditView = false
        
        // Update UI
        DispatchQueue.main.async {
            if(!self.smallScreen){
                self.topSliderContainer.isHidden = false
                self.bottomSliderContainer.isHidden = false
            }
            
            UIView.animate(withDuration: 0.35, animations: {
            
                self.controlStackViewContainer.isHidden = false
                self.settingsStackView.isHidden = true
                
                self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "2C2C2C")
                self.controlStackViewContainer.backgroundColor = UIColor.hexStringToUIColor(hex: "2C2C2C")
                
                var buttonCount = 0
                for button in self.buttons {
                    if(buttonCount < 8){
                        for layer in button.layer.sublayers! {
                            if layer.name == "borderLayer" {
                                layer.removeFromSuperlayer()
                            }
                        }
                        button.layer.borderWidth = 2
                        buttonCount += 1
                    } else if(buttonCount < 10) {
                        button.layer.borderColor = UIColor.darkGray.cgColor
                        buttonCount += 1
                    } else {
                        break
                    }
                    button.backgroundColor = UIColor.hexStringToUIColor(hex: "5C5E66")
                    
                    
                }
            })
        }
    }
    
    func showpicker(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, animations: {
                self.pickerView.reloadAllComponents()
                self.toolBarHiddenConstraint.isActive = false
                self.toolBarShowingConstraint.isActive = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.pickerView.selectedRow(inComponent: 0)
            })
        }
    }
    
    func hidePicker(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, animations: {
                self.pickerView.selectRow(0, inComponent: 0, animated: false)
                self.toolBarShowingConstraint.isActive = false
                self.toolBarHiddenConstraint.isActive = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func savePicker(){
        DispatchQueue.main.async {
            let newInstrument = self.getAvailableInstruments(self.editingItemTag)[self.pickerView.selectedRow(inComponent: 0)]
            self.saveSetting(position: self.editingItemTag, instrument: newInstrument)
            self.buttons[self.editingItemTag].setTitle(SoundEffect.getEffect(self.buttonSettings[self.editingItemTag]), for: .normal)
            self.hidePicker()
        }
        
        
    }
    
    
    /* Settings Resources */
    @IBOutlet weak var settingsStackView: UIStackView!
    
    
    /* Settings Methods */
    func getAvailableInstrument(_ start: Int) -> Int {
        // Get first available instrument
        var index = start + 1
        let installedInstruments = SoundEffect.getSoundEffects()
        for _ in 0..<installedInstruments.count {
            if(index >= installedInstruments.count){
                index = 0
            }
            if(!self.buttonSettings.contains(index)){
                return index
            }
            index += 1
            
        }
        // Return the first non default instrument if failed
        return 8
    }
    
    func getAvailableInstruments(_ start: Int) -> [Int] {
        // Get first available instrument
        var index = start + 1
        let installedInstruments = SoundEffect.getSoundEffects()
        var availableInstruments = [Int]()
        if(self.buttonSettings.count > start){
            availableInstruments.append(self.buttonSettings[start])
        }
        for _ in 0..<installedInstruments.count {
            if(index >= installedInstruments.count){
                index = 0
            }
            if(!self.buttonSettings.contains(index)){
                availableInstruments.append(index)
            }
            index += 1
            
        }
        // Return the first non default instrument if failed
        return availableInstruments
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
        // print("Saved [\(position)] = \(instrument)")
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
            // print("Loading \(results.count) settings")
            if(results.count > 0){
                for result in results as! [NSManagedObject] {
                    let position = result.value(forKey: "position") as! Int
                    let instrument = result.value(forKey: "instrument") as! Int
                    // print("Loaded [\(position)] = \(instrument)")
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
            // print("Saving initial settings")
            self.buttonSettings = SoundEffect.defaults()
            settings = self.buttonSettings
            for i in 0..<settings.count {
                self.saveSetting(position: i, instrument: buttonSettings[i])
            }
            
        }
        
        return settings
    }
    
    /* PickerView Methods */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.getAvailableInstruments(editingItemTag).count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Play a demo sound while scrolling through the instruments
        let newInstrument = self.getAvailableInstruments(self.editingItemTag)[self.pickerView.selectedRow(inComponent: 0)]
        self.editSoundEffect = SoundEffect(sound: SoundEffect.getEffect(newInstrument))
        self.editSoundEffect.play()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let availableInstruments = self.getAvailableInstruments(editingItemTag)
        
        var rowTitle = " "
        if(row < availableInstruments.count){
            rowTitle = SoundEffect.getEffect(availableInstruments[row])
        }
        let attributedString = NSAttributedString(string: rowTitle, attributes: [NSForegroundColorAttributeName : UIColor.hexStringToUIColor(hex: "487DB5")])
        return attributedString
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
                    self.nowPlayingHeaderLabel.isHidden = true
                    self.nowPlayingLabel.text = "No Song"
                    self.playButton.setTitle("Play", for: .normal)
                    self.playButton.isEnabled = false
                    self.playButton.backgroundColor = UIColor.darkGray
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
                    self.nowPlayingHeaderLabel.isHidden = false
                    self.nowPlayingLabel.text = self.currentSongTitle!
                    self.nowPlayingHeaderLabel.text = self.currentSongArtist!
                    self.playButton.setTitle("Play", for: .normal)
                    self.playButton.isEnabled = true
                    self.playButton.backgroundColor = UIColor.hexStringToUIColor(hex: "5C5E66")
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func hideVolume(){
        self.volumeHidden = true
        DispatchQueue.main.async {
            self.topSliderContainer.isHidden = true
            self.bottomSliderContainer.isHidden = true
            self.editSoundsButton.isHidden = false
            self.chooseMusicButton.isHidden = false
            self.playButton.isHidden = false
        }
    }
    
    func showVolume(){
        self.volumeHidden = false
        DispatchQueue.main.async {
            self.topSliderContainer.isHidden = false
            self.bottomSliderContainer.isHidden = false
            self.editSoundsButton.isHidden = true
            self.chooseMusicButton.isHidden = true
            self.playButton.isHidden = true
        }
    }
    
    /* View Controller Load */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Determine screen size
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        if((screenWidth * screenHeight) < 200000.0){
            self.smallScreen = true
            // Small Screen, Hide Volume
            self.hideVolume()
            DispatchQueue.main.async {
                // Show Volume Button
                self.topSliderContainer.removeArrangedSubview(self.topSliderLabel)
                self.topSliderContainer.addArrangedSubview(self.topSliderLabel)
                self.topSliderContainer.spacing = 8
                self.bottomSliderContainer.spacing = 8
                self.topSliderContainer.distribution = UIStackViewDistribution.fillEqually
                self.bottomSliderContainer.distribution = .fillEqually
                self.topSliderLabel.text = "Music"
                self.bottomSliderLabel.text = "Instruments"
                self.editActionButtonsContainer.axis = UILayoutConstraintAxis.horizontal
                self.editActionButtonsContainer.spacing = 8
                self.volumeButton.isHidden = false
                self.topSliderConstraint.constant = -90
                self.bottomSliderConstraint.constant = -55
                self.topSliderContainer.axis = UILayoutConstraintAxis.horizontal
                self.bottomSliderContainer.axis = UILayoutConstraintAxis.horizontal
                self.topSliderTrailingConstraint.isActive = false
                self.bottomSliderTrailingConstraint.isActive = false
            }
        } else {
            // Larger Screen, Show Volume
            DispatchQueue.main.async {
                self.nowPlayingConstraint.constant = 0
                self.volumeButton.isHidden = true
                self.topSliderConstraint.constant = 8
                self.bottomSliderConstraint.constant = 8
                self.topSliderContainer.axis = UILayoutConstraintAxis.vertical
                self.bottomSliderContainer.axis = UILayoutConstraintAxis.vertical
                self.editActionButtonsContainer.removeArrangedSubview(self.saveButton)
                self.editActionButtonsContainer.addArrangedSubview(self.saveButton)
            }
            
        }
        
        // Set Delegates
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        self.musicVolume = 0.5
        self.soundEffectVolume = 0.5
        self.audioPlayer.allowsExternalPlayback = true
        
        // Setup UI
        DispatchQueue.main.async {
            // Now Playing UI
            self.nowPlayingHeaderLabel.isHidden = true
            self.playButton.setTitleColor(UIColor.lightGray, for: .disabled)
            self.playButton.backgroundColor = UIColor.darkGray
            self.nowPlayingContainer.clipsToBounds = true
            self.nowPlayingContainer.layer.cornerRadius = 2
            self.nowPlayingContainer.layer.borderColor = UIColor.hexStringToUIColor(hex: "801727").adjust(by: -15.0)?.cgColor
            self.nowPlayingContainer.layer.borderWidth = 1
            let leftTopButtonsConstraint = NSLayoutConstraint(item: self.leftOne, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: self.controlStackViewContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: -5.0)
            let rightTopButtonsConstraint = NSLayoutConstraint(item: self.rightOne, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: self.controlStackViewContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 5.0)
            NSLayoutConstraint.activate([leftTopButtonsConstraint, rightTopButtonsConstraint])
            
            // Setup Edit UI
            self.restoreDefaultsButton.setTitle("Restore Defaults", for: .normal)
            self.saveButton.setTitle("Done", for: .normal)
            self.instructionsLabel.text = "Tap on a button to change the sound effect. Tap and hold on a button to choose from a list"
            
            // PickerView
            self.pickerView.dataSource = self
            self.pickerView.delegate = self
            self.pickerView.frame = CGRect(x: 0, y: Int(self.view.frame.height - 180), width: Int(self.view.frame.width), height: 180)
            self.pickerView.backgroundColor = UIColor.groupTableViewBackground
            self.pickerView.tintColor = UIColor.hexStringToUIColor(hex: "487DB5")
            // self.pickerView.layer.borderColor = UIColor.darkGray.cgColor
            // self.pickerView.layer.borderWidth = 1
            self.pickerView.showsSelectionIndicator = true
            self.view.addSubview(self.pickerView)
            // PickerView Toolbar
            self.toolBar = UIToolbar()
            self.toolBar.barStyle = UIBarStyle.default
            self.toolBar.isTranslucent = false
            self.toolBar.backgroundColor = UIColor.lightGray
            self.toolBar.sizeToFit()
            // PickerView Toolbar Buttons
            let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlayerViewController.savePicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlayerViewController.hidePicker))
            self.toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
            self.toolBar.isUserInteractionEnabled = true
            self.view.addSubview(self.toolBar)
            // PickerView Constraints
            self.pickerView.translatesAutoresizingMaskIntoConstraints = false
            self.toolBar.translatesAutoresizingMaskIntoConstraints = false
            self.toolBarShowingConstraint = NSLayoutConstraint(item: self.pickerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0) // Show
            let leftConstraint = NSLayoutConstraint(item: self.pickerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: self.pickerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
            let toolBarLeftConstraint = NSLayoutConstraint(item: self.toolBar, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.pickerView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
            let toolBarRightConstraint = NSLayoutConstraint(item: self.toolBar, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.pickerView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
            let toolBarBottomConstraint = NSLayoutConstraint(item: self.toolBar, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.pickerView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            self.toolBarHiddenConstraint = NSLayoutConstraint(item: self.toolBar, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 150)
            let pickerViewHeightConstraint = NSLayoutConstraint(item: self.pickerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 130)
            
            NSLayoutConstraint.activate([self.toolBarHiddenConstraint, leftConstraint, rightConstraint, toolBarLeftConstraint, toolBarRightConstraint, toolBarBottomConstraint, pickerViewHeightConstraint])
            
            self.settingsStackView.isHidden = true
            self.playButton.isEnabled = false
            
            self.buttons.append(self.leftOne)
            self.buttons.append(self.leftTwo)
            self.buttons.append(self.leftThree)
            self.buttons.append(self.leftFour)
            self.buttons.append(self.rightOne)
            self.buttons.append(self.rightTwo)
            self.buttons.append(self.rightThree)
            self.buttons.append(self.rightFour)
            self.buttons.append(self.saveButton)
            self.buttons.append(self.restoreDefaultsButton)
            self.buttons.append(self.editSoundsButton)
            self.buttons.append(self.chooseMusicButton)
            self.buttons.append(self.playButton)
            
            // Load Settings
            var buttonNumber = 0
            self.buttonSettings = self.loadSettings(resetToDefault: false)
            for button in self.buttons {
                if(buttonNumber < 8){
                    button.tag = buttonNumber
                    button.setTitle(SoundEffect.getEffect(self.buttonSettings[buttonNumber]), for: .normal)
                    buttonNumber += 1
                }
                button.backgroundColor = UIColor.hexStringToUIColor(hex: "5C5E66")
                button.layer.cornerRadius = 3
                button.layer.borderColor = UIColor.darkGray.cgColor
                button.layer.borderWidth = 2
                button.clipsToBounds = true
                button.setTitleColor(UIColor.groupTableViewBackground, for: .normal)
            }
            self.editSoundsButton.backgroundColor = UIColor.hexStringToUIColor(hex: "2662B5")
            self.editSoundsButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "2662B5").adjust(by: -15.0)?.cgColor
            self.chooseMusicButton.backgroundColor = UIColor.hexStringToUIColor(hex: "fff43d")
            self.chooseMusicButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "fff43d").adjust(by: -15.0)?.cgColor
            self.chooseMusicButton.setTitleColor(UIColor.darkText, for: .normal)
            
            // Control View UI Touches
            self.controlStackViewContainer.layer.borderColor = UIColor.darkGray.cgColor
            self.controlStackViewContainer.layer.borderWidth = 2
            self.controlStackViewContainer.clipsToBounds = true
            self.controlStackViewContainer.layer.cornerRadius = 3
            self.controlStackViewContainer.backgroundColor = UIColor.darkText
            
            
        }
        
        // Setup Background Audio Session
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
        } catch {
            print(error)
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
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

// Sashed border layer extension
extension CAShapeLayer {
    static func dashedBorderLayerWithColor(frame: CGRect, color: UIColor) -> CAShapeLayer {
        
        let  borderLayer = CAShapeLayer()
        borderLayer.name  = "borderLayer"
        let shapeRect = frame
        
        borderLayer.bounds = shapeRect
        borderLayer.position = CGPoint(x: frame.width/2, y: frame.height/2)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = 3
        borderLayer.lineJoin = kCALineJoinRound
        borderLayer.lineDashPattern = NSArray(array: [NSNumber(value: 8),NSNumber(value:4)]) as? [NSNumber]
        
        let path = UIBezierPath.init(roundedRect: shapeRect, cornerRadius: 0)
        
        borderLayer.path = path.cgPath
        
        return borderLayer
        
    }
}

