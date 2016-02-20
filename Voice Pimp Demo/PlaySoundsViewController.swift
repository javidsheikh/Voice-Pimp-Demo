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
    
    var savedAudio = [RecordedAudio]()
    
    var receivedAudio: RecordedAudio!
    
    var engine: AVAudioEngine!
    var delayPlayer: AVAudioPlayerNode!
    var delay: AVAudioUnitDelay!
    var pitchPlayer: AVAudioPlayerNode!
    var pitch: AVAudioUnitTimePitch!
    var distortionPlayer: AVAudioPlayerNode!
    var distortion: AVAudioUnitDistortion!
    var loopBuffer: AVAudioPCMBuffer!
    
    var mixerOutputFileURL: NSURL?
    var mixerOutputFilePlayer: AVAudioPlayerNode!
    var mixerOutputFilePlayerIsPaused: Bool = true
    var isRecording: Bool = false
    
    var recording: Bool = false
    var playing: Bool = false
    var canPlayback: Bool = false
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedAudioArray").path!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [RecordedAudio] {
            savedAudio = array
        }

        // Do any additional setup after loading the view.
        delayPlayer = AVAudioPlayerNode()
        pitchPlayer = AVAudioPlayerNode()
        distortionPlayer = AVAudioPlayerNode()
        delay = AVAudioUnitDelay()
        pitch = AVAudioUnitTimePitch()
        distortion = AVAudioUnitDistortion()
        engine = AVAudioEngine()
        
        mixerOutputFilePlayer = AVAudioPlayerNode()
        mixerOutputFilePlayerIsPaused = false
        mixerOutputFileURL = nil
        isRecording = false
        
        // Create an instance of the engine and attach the nodes
        self.createEngineAndAttachNodes()
        
        // Load audio loop
        let audioLoopURL = receivedAudio.filePathURL
        let audioLoopFile: AVAudioFile
        do {
            audioLoopFile = try AVAudioFile(forReading: audioLoopURL)
            loopBuffer = AVAudioPCMBuffer(PCMFormat: audioLoopFile.processingFormat, frameCapacity: AVAudioFrameCount(audioLoopFile.length))
            try audioLoopFile.readIntoBuffer(loopBuffer)
        } catch let error as NSError {
            fatalError("Couldn't read audioLoopFile into buffer, \(error.localizedDescription)")
        }
        
        // Make engine connections
        self.makeEngineConnections()
        
        // Start engine
        self.startEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createEngineAndAttachNodes() {
        engine = AVAudioEngine()
        engine.attachNode(delayPlayer)
        engine.attachNode(pitchPlayer)
        engine.attachNode(distortionPlayer)
        engine.attachNode(delay)
        engine.attachNode(pitch)
        engine.attachNode(distortion)
        engine.attachNode(mixerOutputFilePlayer)
    }
    
    func makeEngineConnections() {
        let mainMixer = engine.mainMixerNode
        
        engine.connect(pitchPlayer, to: pitch, format: loopBuffer.format)
        engine.connect(pitch, to: mainMixer, format: loopBuffer.format)
        
        engine.connect(delayPlayer, to: delay, format: loopBuffer.format)
        engine.connect(delay, to: mainMixer, format: loopBuffer.format)
        
        engine.connect(distortionPlayer, to: distortion, format: loopBuffer.format)
        engine.connect(distortion, to: mainMixer, format: loopBuffer.format)
        
        engine.connect(mixerOutputFilePlayer, to: mainMixer, format: mainMixer.outputFormatForBus(0))
    }
    
    func startEngine() {
        if !engine.running {
            do {
                try engine.start()
            } catch let error as NSError {
                fatalError("Couldn't start engine, \(error.localizedDescription)")
            }
        }
    }
    
    func audioFileURL() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime) + ".mp4.waa"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)!
        return filePath
    }
    
    func startRecordingMixerOutput() {
        // install a tap on the main mixer output bus and write output buffers to file
        if mixerOutputFileURL == nil {
            mixerOutputFileURL = audioFileURL()
        }
                
        let mainMixer = engine.mainMixerNode
        let mixerOutputFile: AVAudioFile
        // Recording settings
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        do {
            mixerOutputFile = try AVAudioFile(forWriting: mixerOutputFileURL!, settings: recordSettings)
        } catch let error as NSError {
            fatalError("mixerOutputFile is nil, \(error.localizedDescription)")
        }
        
        self.startEngine()
        mainMixer.installTapOnBus(0, bufferSize: 4096, format: mainMixer.outputFormatForBus(0)) {buffer, when in
            do {
                try mixerOutputFile.writeFromBuffer(buffer)
            } catch let error as NSError {
                fatalError("error writing buffer data to file, \(error.localizedDescription)")
            } catch _ {
                fatalError()
            }
        }
        isRecording = true
    }
    
    func stopRecordingMixerOutput() {
        // stop recording really means remove the tap on the main mixer that was created in startRecordingMixerOutput
        if isRecording {
            engine.mainMixerNode.removeTapOnBus(0)
            isRecording = false
        }
    }
    
    func playRecordedFile() {
        self.startEngine()
        if mixerOutputFilePlayerIsPaused {
            mixerOutputFilePlayer.play()
        } else {
            if mixerOutputFileURL != nil {
                let recordedFile: AVAudioFile
                do {
                    recordedFile = try AVAudioFile(forReading: mixerOutputFileURL!)
                } catch let error as NSError {
                    fatalError("recordedFile is nil, \(error.localizedDescription)")
                }
                mixerOutputFilePlayer.scheduleFile(recordedFile, atTime: nil) {
                    self.mixerOutputFilePlayerIsPaused = false
                    
                    // the data in the file has been scheduled but the player isn't actually done playing yet
                    // calculate the approximate time remaining for the player to finish playing and then dispatch the notification to the main thread
                    let playerTime = self.mixerOutputFilePlayer.playerTimeForNodeTime(self.mixerOutputFilePlayer.lastRenderTime!)
                    let delayInSecs = Double(recordedFile.length - playerTime!.sampleTime) / recordedFile.processingFormat.sampleRate
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecs) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        self.mixerOutputFilePlayer.stop()
                    }
                }
                mixerOutputFilePlayer.play()
                mixerOutputFilePlayerIsPaused = false
            }
        }
    }
    
    func stopPlayingRecordedFile() {
        mixerOutputFilePlayer.stop()
        mixerOutputFilePlayerIsPaused = false
    }
    
    func pausePlayingRecordedFile() {
        mixerOutputFilePlayer.pause()
        mixerOutputFilePlayerIsPaused = true
    }
    
    func playbackPitch(pitchLevel: Float) {
        if !pitchPlayer.playing {
            pitch.pitch = pitchLevel
            self.startEngine()
            pitchPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            pitchPlayer.play()
        } else {
            pitchPlayer.stop()
            
        }
    }
    
    func playbackDistortion(distortionPreset: AVAudioUnitDistortionPreset) {
        if !distortionPlayer.playing {
            distortion.loadFactoryPreset(distortionPreset)
            self.startEngine()
            distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            distortionPlayer.play()
        } else {
            distortionPlayer.stop()
        }
    }
    
    // IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        playbackPitch(1000)
        if !pitchPlayer.playing {
            sender.setTitle("Chipmunk Pause", forState: .Normal)
        } else {
            sender.setTitle("Chipmunk Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        playbackPitch(-1000)
        if !pitchPlayer.playing {
            sender.setTitle("Vader Pause", forState: .Normal)
        } else {
            sender.setTitle("Vader Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackEcho(sender: UIButton) {
        if !delayPlayer.playing {
            delay.delayTime = 1.5
            self.startEngine()
            delayPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            delayPlayer.play()
            sender.setTitle("Echo Pause", forState: .Normal)
        } else {
            delayPlayer.stop()
            sender.setTitle("Echo Play", forState: .Normal)
        }
    }

    @IBAction func playbackAlien(sender: UIButton) {
        playbackDistortion(.SpeechAlienChatter)
        if !distortionPlayer.playing {
            sender.setTitle("Alien Pause", forState: .Normal)
        } else {
            sender.setTitle("Alien Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        playbackDistortion(.SpeechCosmicInterference)
        if !distortionPlayer.playing {
            sender.setTitle("Cosmic Pause", forState: .Normal)
        } else {
            sender.setTitle("Cosmic Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackGoldenPi(sender: UIButton) {
        playbackDistortion(.SpeechGoldenPi)
        if !distortionPlayer.playing {
            sender.setTitle("Golden Pi Pause", forState: .Normal)
        } else {
            sender.setTitle("Golden Pi Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackRadio(sender: UIButton) {
        playbackDistortion(.SpeechRadioTower)
        if !distortionPlayer.playing {
            sender.setTitle("Radio Pause", forState: .Normal)
        } else {
            sender.setTitle("Radio Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackWaves(sender: UIButton) {
        playbackDistortion(.SpeechWaves)
        if !distortionPlayer.playing {
            sender.setTitle("Waves Pause", forState: .Normal)
        } else {
            sender.setTitle("Waves Play", forState: .Normal)
        }
    }

    @IBAction func recordMixerOutput(sender: UIButton) {
        // recording stops playback and recording if we are already recording
        playing = false
        recording = !recording
        canPlayback = true
        
        stopPlayingRecordedFile()
        if recording {
            startRecordingMixerOutput()
            sender.setTitle("Stop", forState: .Normal)
        } else {
            stopRecordingMixerOutput()
            sender.setTitle("Record", forState: .Normal)
        }
    }
    
    @IBAction func playbackMixerOutput(sender: UIButton) {
        recording = false
        playing = !playing
        
        stopRecordingMixerOutput()
        if playing {
            playRecordedFile()
        } else {
            pausePlayingRecordedFile()
        }
    }
    
    @IBAction func saveMixerOutput(sender: UIButton) {
        let newSavedAudio = RecordedAudio(filePathURL: NSURL(fileURLWithPath: ""), title: "")
        
        newSavedAudio.filePathURL = mixerOutputFileURL!
        print(newSavedAudio.filePathURL)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let title = formatter.stringFromDate(NSDate())
        newSavedAudio.title = title
        
        savedAudio.insert(newSavedAudio, atIndex: 0)
        
        NSKeyedArchiver.archiveRootObject(savedAudio, toFile: filePath)
        
        self.performSegueWithIdentifier("segueToSavedSoundsTableVC", sender: self)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToSavedSoundsTableVC"{
            let controller = segue.destinationViewController as! SavedSoundsTableViewController
            controller.savedAudio = savedAudio
        }
    }

}
