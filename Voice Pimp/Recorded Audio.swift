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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(aacURL, forKey: "aacURL")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
    }
    
    required init(coder unarchiver: NSCoder) {
        aacURL = unarchiver.decodeObject(forKey: "aacURL") as! NSURL
        title = unarchiver.decodeObject(forKey: "title") as! String
        date = unarchiver.decodeObject(forKey: "date") as! String
    }
}
