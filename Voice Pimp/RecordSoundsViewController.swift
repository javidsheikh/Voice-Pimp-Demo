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
    var savedAudio: [RecordedAudio]!
    
    var minSessions = 5
    var tryAgainSessions = 3
    
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        return url.appendingPathComponent("savedAudioArray")!.path
    }
    
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
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "MarkerFelt-Thin", size: 24)!]
        
        // Toolbar setup
        self.navigationController?.toolbar.barTintColor = UIColor(red: 255/255, green: 53/255, blue: 53/255, alpha: 1)
        self.navigationController?.toolbar.isTranslucent = false
        self.navigationController?.toolbar.tintColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Disable segue to saved audio button if savedAudio array is empty
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [RecordedAudio] {
            self.savedAudio = array
            self.savedAudioButton.isEnabled = true
        } else {
            self.savedAudioButton.isEnabled = false
        }
        
        self.stopButton.isHidden = true
        self.recordButton.isEnabled = true
        self.recordPrompt.text = "Tap above to start recording"
        
        self.rateMe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // IBActions
    @IBAction func recordAudio(sender: UIButton) {
        // Update UI
        self.recordButton.isEnabled = false
        self.stopButton.isHidden = false
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
            try session.overrideOutputAudioPort(.speaker)
        } catch {
            print("Could not override output audio port.")
        }
        
        // Recording settings
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 320000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        
        // Start recording
        do {
            try recorder = AVAudioRecorder(url: createAudioFileURL() as URL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
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
        self.performSegue(withIdentifier: "segueToSavedSoundsVC", sender: self)
    }
    
    // MARK: Helper functions
    func createAudioFileURL() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recorded_audio.aac"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        return filePath! as NSURL
    }
    
    // MARK: Rate app functions - to be uncommented once App ID is received
    func rateMe() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        var numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        if (!neverRate && (numLaunches == minSessions || numLaunches >= (minSessions + tryAgainSessions + 1))) {
            showRateMe()
            numLaunches = minSessions + 1
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "Rate Us", message: "Do you love Voice Pimp? Please rate us on the app store.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Rate Voice Pimp", style: UIAlertActionStyle.default, handler: { alertAction in
            UIApplication.shared.openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1100673414")! as URL)
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later", style: UIAlertActionStyle.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: AudioRecorder delegate
extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordedAudio = RecordedAudio(aacURL: NSURL(fileURLWithPath: ""), title: "", date: "")
            recordedAudio.aacURL = recorder.url as NSURL
            recordedAudio.title = recorder.url.lastPathComponent
            let controller = storyboard?.instantiateViewController(withIdentifier: "PlaySoundsViewController") as! PlaySoundsViewController
            controller.receivedAudio = recordedAudio
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            print("Recording was unsuccessful")
        }
    }
}

