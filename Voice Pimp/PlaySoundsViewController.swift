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
        self.engine.loadAudioLoop(receivedAudio: receivedAudio)
        self.engine.makeEngineConnections()
        self.engine.startEngine()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.stopButton.isEnabled = false
        self.saveButton.isEnabled = false
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
        self.engine.playbackPitch(pitchLevel: 800)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        self.engine.playbackPitch(pitchLevel: -800)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func playbackEcho(sender: UIButton) {
        self.engine.playbackDelay(delayLevel: 1.5)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }

    @IBAction func playbackCellphone(sender: UIButton) {
        self.engine.playbackDistortion(distortionPreset: .multiCellphoneConcert)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        self.engine.playbackDistortion(distortionPreset: .speechCosmicInterference)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func playbackBroken(sender: UIButton) {
        self.engine.playbackDistortion(distortionPreset: .multiEverythingIsBroken)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func playbackFast(sender: UIButton) {
        self.engine.playbackVarispeed(varispeedLevel: 2.0)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func playbackSlow(sender: UIButton) {
        self.engine.playbackVarispeed(varispeedLevel: 0.7)
        self.stopButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
    
    @IBAction func stopPlaybackRecord(sender: AnyObject) {
        self.engine.stopActivePlayer()
        self.stopButton.isEnabled = false
        self.saveButton.isEnabled = false
    }
    
    @IBAction func savePlaybackRecord(sender: AnyObject) {
        self.engine.stopActivePlayer()
        self.stopButton.isEnabled = false
        self.saveButton.isEnabled = false
        self.showSaveAlertPopup()
    }
    
    // MARK: Helper functions
    func showSaveAlertPopup() {
        
        // Configure alert popup
        let alert = UIAlertController(title: "Save", message: "Add file to saved audio notes", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Enter title for audio note"
            textField.autocapitalizationType = .words
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            let title = textField.text!
            self.engine.saveNewAudio(title: title)
            self.performSegue(withIdentifier: "segueToSavedSoundsTableVC", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}


