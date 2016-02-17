//
//  Recorded Audio.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathString: String
    var title: String
    
    init(filePathString: String, title: String) {
        self.filePathString = filePathString
        self.title = title
    }
}