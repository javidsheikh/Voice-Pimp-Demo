//
//  Recorded Audio.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject, NSCoding {
    
    var mp4URL: NSURL
    var title: String
    var date: String

    init(mp4URL: NSURL, title: String, date: String) {
        self.mp4URL = NSURL(fileURLWithPath: "")
        self.title = title
        self.date = "dd/mm/yyyy"
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        archiver.encodeObject(mp4URL, forKey: "mp4URL")
        archiver.encodeObject(title, forKey: "title")
        archiver.encodeObject(date, forKey: "date")
    }
    
    required init(coder unarchiver: NSCoder) {
        mp4URL = unarchiver.decodeObjectForKey("mp4URL") as! NSURL
        title = unarchiver.decodeObjectForKey("title") as! String
        date = unarchiver.decodeObjectForKey("date") as! String
    }
}