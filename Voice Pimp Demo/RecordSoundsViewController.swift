//
//  RecordSoundsViewController.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit
import AVFoundation


// MARK: Record Sounds VC
class RecordSoundsViewController: UIViewController {
    
    var recorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    var iMinSessions = 5
    var iTryAgainSessions = 3
    
    // MARK: IBOutlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordPrompt: UILabel!
    @IBOutlet weak var savedAudioButton: UIBarButtonItem!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav bar setup
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 53/255, blue: 53/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "MarkerFelt-Thin", size: 24)!]
        
        // Toolbar setup
        self.navigationController?.toolbar.barTintColor = UIColor(red: 255/255, green: 53/255, blue: 53/255, alpha: 1)
        self.navigationController?.toolbar.translucent = false
        self.navigationController?.toolbar.tintColor = UIColor.whiteColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //TODO: disable segue to saved audio button if savedAudio array is empty
        
        self.stopButton.hidden = true
        self.recordButton.enabled = true
        self.recordPrompt.text = "Tap above to start recording"
        
        self.rateMe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToPlaySoundsVC" {
            let controller = segue.destinationViewController as! PlaySoundsViewController
            controller.receivedAudio = recordedAudio
        }
    }
    
    // IBActions
    @IBAction func recordAudio(sender: UIButton) {
        // Update UI
        self.recordButton.enabled = false
        self.stopButton.hidden = false
        self.recordPrompt.text = "Recording..."
        
        // Create recording session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("Unable to initiate recording session.")
        }
        
        // Set output port to device speaker
        do {
            try session.overrideOutputAudioPort(.Speaker)
        } catch {
            print("Could not override output audio port.")
        }
        
        // Recording settings
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        // Start recording
        do {
            try recorder = AVAudioRecorder(URL: createAudioFileURL(), settings: recordSettings)
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
            recorder.record()
        } catch {
            print("Recording did not commence.")
        }
    }

    @IBAction func stopRecordAudio(sender: UIButton) {
        
        // Stop recording
        recorder.stop()
        
        // End recording session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("Unable to deactivate recording session.")
        }
    }

    @IBAction func segueToSavedAudio(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("segueToSavedSoundsVC", sender: self)
    }
    
    // MARK: Helper functions
    func createAudioFileURL() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "recorded_audio.aac"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        return filePath!
    }
    
    // MARK: Rate app functions
    func rateMe() {
        let neverRate = NSUserDefaults.standardUserDefaults().boolForKey("neverRate")
        var numLaunches = NSUserDefaults.standardUserDefaults().integerForKey("numLaunches") + 1
        if (!neverRate && (numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1))) {
            showRateMe()
            numLaunches = iMinSessions + 1
        }
        NSUserDefaults.standardUserDefaults().setInteger(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "Rate Us", message: "Do you love Voice Pimp? Please rate us on the app store.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Rate Voice Pimp", style: UIAlertActionStyle.Default, handler: { alertAction in
            //            UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=<iTUNES CONNECT APP ID>")!)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            // TODO: Amend URL
            UIApplication.sharedApplication().openURL(NSURL(string: "https://theysaidso.com/")!)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: AudioRecorder delegate
extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordedAudio = RecordedAudio(aacURL: NSURL(fileURLWithPath: ""), title: "", date: "")
            recordedAudio.aacURL = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent!
            self.performSegueWithIdentifier("segueToPlaySoundsVC", sender: self)
        } else {
            print("Recording was unsuccessful")
        }
    }
}

