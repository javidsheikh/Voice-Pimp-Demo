//
//  Recorded Audio.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 17/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject, NSCoding {
    
    var aacURL: NSURL
    var title: String
    var date: String

    init(aacURL: NSURL, title: String, date: String) {
        self.aacURL = NSURL(fileURLWithPath: "")
        self.title = title
        self.date = "dd/mm/yyyy"
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        archiver.encodeObject(aacURL, forKey: "aacURL")
        archiver.encodeObject(title, forKey: "title")
        archiver.encodeObject(date, forKey: "date")
    }
    
    required init(coder unarchiver: NSCoder) {
        aacURL = unarchiver.decodeObjectForKey("aacURL") as! NSURL
        title = unarchiver.decodeObjectForKey("title") as! String
        date = unarchiver.decodeObjectForKey("date") as! String
    }
}