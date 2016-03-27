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
        
        // Audio engine setup
        self.engine = AudioEngine()
        self.engine.createEngineAndAttachNodes()
        self.engine.loadAudioLoop(receivedAudio)
        self.engine.makeEngineConnections()
        self.engine.startEngine()
    }

    override func viewWillAppear(animated: Bool) {
        self.stopButton.enabled = false
        self.saveButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        self.engine.playbackPitch(800)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        self.engine.playbackPitch(-800)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func playbackEcho(sender: UIButton) {
        self.engine.playbackDelay(1.5)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }

    @IBAction func playbackCellphone(sender: UIButton) {
        self.engine.playbackDistortion(.MultiCellphoneConcert)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        self.engine.playbackDistortion(.SpeechCosmicInterference)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func playbackBroken(sender: UIButton) {
        self.engine.playbackDistortion(.MultiEverythingIsBroken)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func playbackFast(sender: UIButton) {
        self.engine.playbackVarispeed(2.0)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func playbackSlow(sender: UIButton) {
        self.engine.playbackVarispeed(0.7)
        self.stopButton.enabled = true
        self.saveButton.enabled = true
    }
    
    @IBAction func stopPlaybackRecord(sender: AnyObject) {
        self.engine.stopActivePlayer()
        self.stopButton.enabled = false
        self.saveButton.enabled = false
    }
    
    @IBAction func savePlaybackRecord(sender: AnyObject) {
        self.engine.stopActivePlayer()
        self.stopButton.enabled = false
        self.saveButton.enabled = false
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


