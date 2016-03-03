//
//  AudioEngine.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 03/03/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit
import AVFoundation

class AudioEngine: NSObject {
    
    var savedAudio = [RecordedAudio]()
    
    var engine: AVAudioEngine!
    var delayPlayer: AVAudioPlayerNode!
    var delay: AVAudioUnitDelay!
    var pitchPlayer: AVAudioPlayerNode!
    var pitch: AVAudioUnitTimePitch!
    var distortionPlayer: AVAudioPlayerNode!
    var distortion: AVAudioUnitDistortion!
    var varispeed: AVAudioUnitVarispeed!
    var varispeedPlayer: AVAudioPlayerNode!
    var loopBuffer: AVAudioPCMBuffer!
    
    var mixerOutputFileURL: NSURL?
    var waaMixerOutputFileURL: NSURL?
    var isRecording: Bool = false
    
    var activePlayer = ActivePlayer.None
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedAudioArray").path!
    }
    
    override init() {
        
        super.init()
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [RecordedAudio] {
            savedAudio = array
        }
        
        delayPlayer = AVAudioPlayerNode()
        pitchPlayer = AVAudioPlayerNode()
        distortionPlayer = AVAudioPlayerNode()
        varispeedPlayer = AVAudioPlayerNode()
        delay = AVAudioUnitDelay()
        pitch = AVAudioUnitTimePitch()
        distortion = AVAudioUnitDistortion()
        varispeed = AVAudioUnitVarispeed()
        engine = AVAudioEngine()
        
        mixerOutputFileURL = nil
        isRecording = false
        
        // Create an instance of the engine and attach the nodes
        self.createEngineAndAttachNodes()
        
        // Load audio loop
//        let audioLoopURL = receivedAudio.mp4URL
//        let audioLoopFile: AVAudioFile
//        do {
//            audioLoopFile = try AVAudioFile(forReading: audioLoopURL)
//            loopBuffer = AVAudioPCMBuffer(PCMFormat: audioLoopFile.processingFormat, frameCapacity: AVAudioFrameCount(audioLoopFile.length))
//            try audioLoopFile.readIntoBuffer(loopBuffer)
//        } catch let error as NSError {
//            fatalError("Couldn't read audioLoopFile into buffer, \(error.localizedDescription)")
//        }
        
//        // Make engine connections
//        self.makeEngineConnections()
//        
//        // Start engine
//        self.startEngine()
        
    }
    
    func loadAudioLoop(receivedAudio: RecordedAudio) {
        let audioLoopURL = receivedAudio.mp4URL
        let audioLoopFile: AVAudioFile
        do {
            audioLoopFile = try AVAudioFile(forReading: audioLoopURL)
            loopBuffer = AVAudioPCMBuffer(PCMFormat: audioLoopFile.processingFormat, frameCapacity: AVAudioFrameCount(audioLoopFile.length))
            try audioLoopFile.readIntoBuffer(loopBuffer)
        } catch let error as NSError {
            fatalError("Couldn't read audioLoopFile into buffer, \(error.localizedDescription)")
        }
    }
    
    func createEngineAndAttachNodes() {
        engine = AVAudioEngine()
        engine.attachNode(delayPlayer)
        engine.attachNode(pitchPlayer)
        engine.attachNode(distortionPlayer)
        engine.attachNode(varispeedPlayer)
        engine.attachNode(delay)
        engine.attachNode(pitch)
        engine.attachNode(distortion)
        engine.attachNode(varispeed)
        //        engine.attachNode(mixerOutputFilePlayer)
    }
    
    func makeEngineConnections() {
        let mainMixer = engine.mainMixerNode
        
        engine.connect(pitchPlayer, to: pitch, format: loopBuffer.format)
        engine.connect(pitch, to: mainMixer, format: loopBuffer.format)
        
        engine.connect(delayPlayer, to: delay, format: loopBuffer.format)
        engine.connect(delay, to: mainMixer, format: loopBuffer.format)
        
        engine.connect(distortionPlayer, to: distortion, format: loopBuffer.format)
        engine.connect(distortion, to: mainMixer, format: loopBuffer.format)
        
        engine.connect(varispeedPlayer, to: varispeed, format: loopBuffer.format)
        engine.connect(varispeed, to: mainMixer, format: loopBuffer.format)
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
    
    func audioFileURL(fileExtension: String) -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime) + fileExtension
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)!
        return filePath
    }
    
    func startRecordingMixerOutput() {
        // install a tap on the main mixer output bus and write output buffers to file
        if mixerOutputFileURL == nil {
            mixerOutputFileURL = audioFileURL(".mp4")
        }
        
        if waaMixerOutputFileURL == nil {
            waaMixerOutputFileURL = audioFileURL(".mp4.waa")
        }
        
        let mainMixer = engine.mainMixerNode
        let mixerOutputFile: AVAudioFile
        let waaMixerOutputFile: AVAudioFile
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
            waaMixerOutputFile = try AVAudioFile(forWriting: waaMixerOutputFileURL!, settings: recordSettings)
        } catch let error as NSError {
            fatalError("mixerOutputFile is nil, \(error.localizedDescription)")
        }
        
        self.startEngine()
        mainMixer.installTapOnBus(0, bufferSize: 4096, format: mainMixer.outputFormatForBus(0)) {buffer, when in
            do {
                try mixerOutputFile.writeFromBuffer(buffer)
                try waaMixerOutputFile.writeFromBuffer(buffer)
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
    
    func playbackPitch(pitchLevel: Float) {
        stopActivePlayer()
        activePlayer = .PitchPlayer
        pitch.pitch = pitchLevel
        self.startEngine()
        pitchPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
        pitchPlayer.play()
        startRecordingMixerOutput()
    }
    
    func playbackDelay(delayLevel: Double) {
        stopActivePlayer()
        activePlayer = .DelayPlayer
        delay.delayTime = delayLevel
        self.startEngine()
        delayPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
        delayPlayer.play()
        startRecordingMixerOutput()
    }
    
    func playbackDistortion(distortionPreset: AVAudioUnitDistortionPreset) {
        stopActivePlayer()
        activePlayer = .DistortionPlayer
        distortion.loadFactoryPreset(distortionPreset)
        self.startEngine()
        distortionPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
        distortionPlayer.play()
        startRecordingMixerOutput()
    }
    
    func playbackVarispeed(varispeedLevel: Float) {
        stopActivePlayer()
        activePlayer = .VarispeedPlayer
        varispeed.rate = varispeedLevel
        self.startEngine()
        varispeedPlayer.scheduleBuffer(loopBuffer, atTime: nil, options: .Loops, completionHandler: nil)
        varispeedPlayer.play()
        startRecordingMixerOutput()
    }
    
    func stopActivePlayer() {
        
        stopRecordingMixerOutput()
        
        switch activePlayer {
        case .PitchPlayer: pitchPlayer.stop()
        case .DelayPlayer: delayPlayer.stop()
        case .DistortionPlayer: distortionPlayer.stop()
        case .VarispeedPlayer: varispeedPlayer.stop()
        default: break
        }
        
        self.engine.stop()
        self.engine.reset()
    }
    
    func saveNewAudio(title: String) {
        let newSavedAudio = RecordedAudio(mp4URL: NSURL(fileURLWithPath: ""), waaURL: NSURL(fileURLWithPath: ""), title: "", date: "")
        
        newSavedAudio.mp4URL = mixerOutputFileURL!
        
        newSavedAudio.waaURL = waaMixerOutputFileURL!
        
        newSavedAudio.title = title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy - HH:mm"
        let formattedDate = formatter.stringFromDate(NSDate())
        newSavedAudio.date = formattedDate
        
        savedAudio.insert(newSavedAudio, atIndex: 0)
        
        NSKeyedArchiver.archiveRootObject(savedAudio, toFile: filePath)
        
    }
}

enum ActivePlayer {
    case DelayPlayer, PitchPlayer, DistortionPlayer, VarispeedPlayer, None
}
