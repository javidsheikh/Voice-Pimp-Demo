//
//  RecordSoundsViewController.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    
    var recorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    // MARK: Helper functions
    func createAudioFileURL() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "recorded_audio.mp4"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        return filePath!
    }
}

// MARK: AudioRecorder delegate
extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordedAudio = RecordedAudio(mp4URL: NSURL(fileURLWithPath: ""), waaURL: NSURL(fileURLWithPath: ""), title: "", date: "")
            recordedAudio.mp4URL = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent!
            self.performSegueWithIdentifier("segueToPlaySoundsVC", sender: self)
        } else {
            print("Recording was unsuccessful")
        }
    }
}

