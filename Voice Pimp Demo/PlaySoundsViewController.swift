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
    
    var engine: AVAudioEngine!
    var receivedAudio: RecordedAudio!
    var audioFile: AVAudioFile!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        engine = AVAudioEngine()
        do {
            audioFile = try AVAudioFile(forReading: receivedAudio.filePathURL)
        } catch {
            print("Could not read recorded audio file")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to set variable pitch
    func setVariablePitch(pitch: Float) {
        engine.stop()
        engine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        engine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        engine.attachNode(changePitchEffect)
        
        engine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        engine.connect(changePitchEffect, to: engine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do {
            try engine.start()
        } catch {
            print("Unable to start audio engine")
        }
        
        audioPlayerNode.play()
    }
    
    // Function to set variable delay
    func setVariableDelay(delay: Double) {
        engine.stop()
        engine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        engine.attachNode(audioPlayerNode)
        
        let changeDelayEffect = AVAudioUnitDelay()
        changeDelayEffect.delayTime = delay
        engine.attachNode(changeDelayEffect)
        
        engine.connect(audioPlayerNode, to: changeDelayEffect, format: nil)
        engine.connect(changeDelayEffect, to: engine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do {
            try engine.start()
        } catch {
            print("Unable to start audio engine")
        }
        
        audioPlayerNode.play()
    }
    
    // Function to set distortion preset
    func setDistortionPreset(preset: AVAudioUnitDistortionPreset) {
        engine.stop()
        engine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        engine.attachNode(audioPlayerNode)
        
        let addDistortionEffect = AVAudioUnitDistortion()
        addDistortionEffect.loadFactoryPreset(preset)
        engine.attachNode(addDistortionEffect)
        
        engine.connect(audioPlayerNode, to: addDistortionEffect, format: nil)
        engine.connect(addDistortionEffect, to: engine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do {
            try engine.start()
        } catch {
            print("Unable to start audio engine")
        }
        
        audioPlayerNode.play()
    }
    
    // IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        setVariablePitch(1000)
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        setVariablePitch(-1000)
    }
    
    @IBAction func playbackEcho(sender: UIButton) {
        setVariableDelay(1.5)
    }
    
    @IBAction func playbackAlien(sender: UIButton) {
        setDistortionPreset(AVAudioUnitDistortionPreset.SpeechAlienChatter)
    }
    
    @IBAction func playbackCosmic(sender: UIButton) {
        setDistortionPreset(AVAudioUnitDistortionPreset.SpeechCosmicInterference)
    }
    
    @IBAction func playbackGoldenPi(sender: UIButton) {
        setDistortionPreset(AVAudioUnitDistortionPreset.SpeechGoldenPi)
    }
    
    @IBAction func playbackRadio(sender: UIButton) {
        setDistortionPreset(AVAudioUnitDistortionPreset.SpeechRadioTower)
    }
    
    @IBAction func playbackWaves(sender: UIButton) {
        setDistortionPreset(AVAudioUnitDistortionPreset.SpeechWaves)
    }
    
    @IBAction func stopPlayback(sender: UIButton) {
        engine.stop()
        engine.reset()
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
