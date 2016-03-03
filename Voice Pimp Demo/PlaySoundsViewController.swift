//
//  PlaySoundsViewController.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var engine: AudioEngine!
    
    var receivedAudio: RecordedAudio!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.engine = AudioEngine()

        self.engine.loadAudioLoop(receivedAudio)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Make engine connections
        self.engine.makeEngineConnections()
        
        // Start engine
        self.engine.startEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        engine.playbackPitch(800)
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        engine.playbackPitch(-800)
    }
    
    @IBAction func playbackEcho(sender: UIButton) {
        engine.playbackDelay(1.5)
    }

    @IBAction func playbackAlien(sender: UIButton) {
        engine.playbackDistortion(.MultiCellphoneConcert)
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        engine.playbackDistortion(.SpeechCosmicInterference)
    }
    
    @IBAction func playbackGoldenPi(sender: UIButton) {
        engine.playbackDistortion(.MultiEverythingIsBroken)
    }
    
    @IBAction func playbackRadio(sender: UIButton) {
        engine.playbackVarispeed(2.0)
    }
    
    @IBAction func playbackWaves(sender: UIButton) {
        engine.playbackVarispeed(0.7)
    }
    
    @IBAction func stopPlaybackRecord(sender: AnyObject) {
        
        engine.stopActivePlayer()
        
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


