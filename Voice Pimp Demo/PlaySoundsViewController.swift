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

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
//        do {
//            audioFile = try AVAudioFile(forReading: receivedAudio.filePathURL)
//        } catch {
//            print("Could not read recorded audio file")
//        }
        
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
    
    func startRecordingMixerOutput() {
        // install a tap on the main mixer output bus and write output buffers to file
        if mixerOutputFileURL == nil {
            mixerOutputFileURL = NSURL(string: NSTemporaryDirectory() + "mixerOutput.caf")
        }
        
        let mainMixer = engine.mainMixerNode
        let mixerOutputFile: AVAudioFile
        do {
            mixerOutputFile = try AVAudioFile(forWriting: mixerOutputFileURL!, settings: mainMixer.outputFormatForBus(0).settings)
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
    
//    // Function to set variable pitch
//    func setVariablePitch(pitch: Float) {
//        engine.stop()
//        engine.reset()
//        
//        let audioPlayerNode = AVAudioPlayerNode()
//        engine.attachNode(audioPlayerNode)
//        
//        let changePitchEffect = AVAudioUnitTimePitch()
//        changePitchEffect.pitch = pitch
//        engine.attachNode(changePitchEffect)
//        
//        engine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
//        engine.connect(changePitchEffect, to: engine.outputNode, format: nil)
//        
//        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
//        
//        do {
//            try engine.start()
//        } catch {
//            print("Unable to start audio engine")
//        }
//        
//        audioPlayerNode.play()
//    }
//    
//    // Function to set variable delay
//    func setVariableDelay(delay: Double) {
//        engine.stop()
//        engine.reset()
//        
//        let audioPlayerNode = AVAudioPlayerNode()
//        engine.attachNode(audioPlayerNode)
//        
//        let changeDelayEffect = AVAudioUnitDelay()
//        changeDelayEffect.delayTime = delay
//        engine.attachNode(changeDelayEffect)
//        
//        engine.connect(audioPlayerNode, to: changeDelayEffect, format: nil)
//        engine.connect(changeDelayEffect, to: engine.outputNode, format: nil)
//        
//        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
//        
//        do {
//            try engine.start()
//        } catch {
//            print("Unable to start audio engine")
//        }
//        
//        audioPlayerNode.play()
//    }
//    
//    // Function to set distortion preset
//    func setDistortionPreset(preset: AVAudioUnitDistortionPreset) {
//        engine.stop()
//        engine.reset()
//        
//        let audioPlayerNode = AVAudioPlayerNode()
//        engine.attachNode(audioPlayerNode)
//        
//        let addDistortionEffect = AVAudioUnitDistortion()
//        addDistortionEffect.loadFactoryPreset(preset)
//        engine.attachNode(addDistortionEffect)
//        
//        engine.connect(audioPlayerNode, to: addDistortionEffect, format: nil)
//        engine.connect(addDistortionEffect, to: engine.outputNode, format: nil)
//        
//        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
//        
//        do {
//            try engine.start()
//        } catch {
//            print("Unable to start audio engine")
//        }
//        
//        audioPlayerNode.play()
//    }
    
    // IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        if !pitchPlayer.playing {
            pitch.pitch = 1000
            self.startEngine()
            pitchPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            pitchPlayer.play()
            sender.setTitle("Chipmunk Pause", forState: .Normal)
        } else {
            pitchPlayer.stop()
            sender.setTitle("Chipmunk Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        if !pitchPlayer.playing {
            pitch.pitch = -1000
            self.startEngine()
            pitchPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            pitchPlayer.play()
            sender.setTitle("Vader Pause", forState: .Normal)
        } else {
            pitchPlayer.stop()
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
        if !distortionPlayer.playing {
            distortion.loadFactoryPreset(.SpeechAlienChatter)
            self.startEngine()
            distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            distortionPlayer.play()
            sender.setTitle("Alien Pause", forState: .Normal)
        } else {
            distortionPlayer.stop()
            sender.setTitle("Alien Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        if !distortionPlayer.playing {
            distortion.loadFactoryPreset(.SpeechCosmicInterference)
            self.startEngine()
            distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            distortionPlayer.play()
            sender.setTitle("Cosmic Pause", forState: .Normal)
        } else {
            distortionPlayer.stop()
            sender.setTitle("Cosmic Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackGoldenPi(sender: UIButton) {
        if !distortionPlayer.playing {
            distortion.loadFactoryPreset(.SpeechGoldenPi)
            self.startEngine()
            distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            distortionPlayer.play()
            sender.setTitle("Golden Pi Pause", forState: .Normal)
        } else {
            distortionPlayer.stop()
            sender.setTitle("Golden Pi Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackRadio(sender: UIButton) {
        if !distortionPlayer.playing {
            distortion.loadFactoryPreset(.SpeechRadioTower)
            self.startEngine()
            distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            distortionPlayer.play()
            sender.setTitle("Radio Pause", forState: .Normal)
        } else {
            distortionPlayer.stop()
            sender.setTitle("Radio Play", forState: .Normal)
        }
    }
    
    @IBAction func playbackWaves(sender: UIButton) {
        if !distortionPlayer.playing {
            distortion.loadFactoryPreset(.SpeechWaves)
            self.startEngine()
            distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            distortionPlayer.play()
            sender.setTitle("Waves Pause", forState: .Normal)
        } else {
            distortionPlayer.stop()
            sender.setTitle("Waves Play", forState: .Normal)
        }
    }
    
//    @IBAction func stopPlayback(sender: UIButton) {
//        engine.stop()
//        engine.reset()
//    }

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
