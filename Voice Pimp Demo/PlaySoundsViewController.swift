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
    
    //IBActions
    @IBAction func playbackChipmunk(sender: UIButton) {
        setVariablePitch(1000)
    }
    
    @IBAction func playbackVader(sender: UIButton) {
        setVariablePitch(-1000)
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
