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
    
    // MARK: Variables
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
    var isRecording: Bool = false
    
    var activePlayer = ActivePlayer.None
    
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        return url.appendingPathComponent("savedAudioArray")!.path
    }
    
    // MARK: Initialization
    override init() {
        
        super.init()
        
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [RecordedAudio] {
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
    }
    
    // MARK: Setup functions
    func createEngineAndAttachNodes() {
        engine = AVAudioEngine()
        engine.attach(delayPlayer)
        engine.attach(pitchPlayer)
        engine.attach(distortionPlayer)
        engine.attach(varispeedPlayer)
        engine.attach(delay)
        engine.attach(pitch)
        engine.attach(distortion)
        engine.attach(varispeed)
    }
    
    func loadAudioLoop(receivedAudio: RecordedAudio) {
        let audioLoopURL = receivedAudio.aacURL
        let audioLoopFile: AVAudioFile
        do {
            audioLoopFile = try AVAudioFile(forReading: audioLoopURL as URL)
            loopBuffer = AVAudioPCMBuffer(pcmFormat: audioLoopFile.processingFormat, frameCapacity: AVAudioFrameCount(audioLoopFile.length))
            try audioLoopFile.read(into: loopBuffer)
        } catch let error as NSError {
            fatalError("Couldn't read audioLoopFile into buffer, \(error.localizedDescription)")
        }
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
        if !engine.isRunning {
            do {
                try engine.start()
            } catch let error as NSError {
                fatalError("Couldn't start engine, \(error.localizedDescription)")
            }
        }
    }
    
    func audioFileURL(fileExtension: String) -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.string(from: currentDateTime as Date) + fileExtension
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)!
        return filePath as NSURL
    }
    
    // MARK: Record functions
    func startRecordingMixerOutput() {
        // install a tap on the main mixer output bus and write output buffers to file
        if mixerOutputFileURL == nil {
            mixerOutputFileURL = audioFileURL(fileExtension: ".aac")
        }
        
        let mainMixer = engine.mainMixerNode
        let mixerOutputFile: AVAudioFile
        
        // Recording settings
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 320000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        do {
            mixerOutputFile = try AVAudioFile(forWriting: mixerOutputFileURL! as URL, settings: recordSettings)
        } catch let error as NSError {
            fatalError("mixerOutputFile is nil, \(error.localizedDescription)")
        }
        
        self.startEngine()
        mainMixer.installTap(onBus: 0, bufferSize: 4096, format: mainMixer.outputFormat(forBus: 0)) {buffer, when in
            do {
                try mixerOutputFile.write(from: buffer)
            } catch let error as NSError {
                fatalError("error writing buffer data to file, \(error.localizedDescription)")
            } catch _ {
                fatalError()
            }
        }
        isRecording = true
    }
    
    func stopRecordingMixerOutput() {
        if isRecording {
            engine.mainMixerNode.removeTap(onBus: 0)
            isRecording = false
        }
    }
    
    // MARK: Playback functions
    func playbackPitch(pitchLevel: Float) {
        stopActivePlayer()
        activePlayer = .PitchPlayer
        pitch.pitch = pitchLevel
        self.startEngine()
        pitchPlayer.scheduleBuffer(loopBuffer, at: nil, options: .loops, completionHandler: nil)
        pitchPlayer.play()
        startRecordingMixerOutput()
    }
    
    func playbackDelay(delayLevel: Double) {
        stopActivePlayer()
        activePlayer = .DelayPlayer
        delay.delayTime = delayLevel
        self.startEngine()
        delayPlayer.scheduleBuffer(loopBuffer, at: nil, options: .loops, completionHandler: nil)
        delayPlayer.play()
        startRecordingMixerOutput()
    }
    
    func playbackDistortion(distortionPreset: AVAudioUnitDistortionPreset) {
        stopActivePlayer()
        activePlayer = .DistortionPlayer
        distortion.loadFactoryPreset(distortionPreset)
        self.startEngine()
        distortionPlayer.scheduleBuffer(loopBuffer, at: nil, options: .loops, completionHandler: nil)
        distortionPlayer.play()
        startRecordingMixerOutput()
    }
    
    func playbackVarispeed(varispeedLevel: Float) {
        stopActivePlayer()
        activePlayer = .VarispeedPlayer
        varispeed.rate = varispeedLevel
        self.startEngine()
        varispeedPlayer.scheduleBuffer(loopBuffer, at: nil, options: .loops, completionHandler: nil)
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
    
    // MARK: Save functions
    func saveNewAudio(title: String) {
        let newSavedAudio = RecordedAudio(aacURL: NSURL(fileURLWithPath: ""), title: "", date: "")
        
        newSavedAudio.aacURL = mixerOutputFileURL!
        
        
        newSavedAudio.title = title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy - HH:mm"
        let formattedDate = formatter.string(from: Date())
        newSavedAudio.date = formattedDate
        
        savedAudio.insert(newSavedAudio, at: 0)
        
        NSKeyedArchiver.archiveRootObject(savedAudio, toFile: filePath)
        
    }
}

// MARK: Active player enum
enum ActivePlayer {
    case DelayPlayer, PitchPlayer, DistortionPlayer, VarispeedPlayer, None
}
