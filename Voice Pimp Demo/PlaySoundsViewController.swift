//
//  PlaySoundsViewController.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: Play Sounds VC
class PlaySoundsViewController: UIViewController {
    
    var engine: AudioEngine!
    
    var receivedAudio: RecordedAudio!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        for button in self.buttons {
            button.layer.cornerRadius = 30
        }
        
        // Audio engine setup
        self.engine = AudioEngine()
        self.engine.createEngineAndAttachNodes()
        self.engine.loadAudioLoop(receivedAudio)
        self.engine.makeEngineConnections()
        self.engine.startEngine()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.stopSaveButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBOutlets
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var stopSaveButton: UIButton!
    
    // MARK: IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        engine.playbackPitch(800)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        engine.playbackPitch(-800)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func playbackEcho(sender: UIButton) {
        engine.playbackDelay(1.5)
        self.stopSaveButton.hidden = false
    }

    @IBAction func playbackAlien(sender: UIButton) {
        engine.playbackDistortion(.MultiCellphoneConcert)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        engine.playbackDistortion(.SpeechCosmicInterference)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func playbackGoldenPi(sender: UIButton) {
        engine.playbackDistortion(.MultiEverythingIsBroken)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func playbackRadio(sender: UIButton) {
        engine.playbackVarispeed(2.0)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func playbackWaves(sender: UIButton) {
        engine.playbackVarispeed(0.7)
        self.stopSaveButton.hidden = false
    }
    
    @IBAction func stopPlaybackRecord(sender: AnyObject) {
        
        self.engine.stopActivePlayer()
        
        self.showSaveAlertPopup()

    }
    
    // MARK: Helper functions
    func showSaveAlertPopup() {
        
        // Configure alert popup
        let alert = UIAlertController(title: "Save", message: "Add file to saved audio notes", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Enter title for audio note"
            textField.autocapitalizationType = .Words
        }
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            let title = textField.text!
            self.engine.saveNewAudio(title)
            self.performSegueWithIdentifier("segueToSavedSoundsTableVC", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}


