//
//  SavedSoundsTableViewController.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 19/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit

// MARK: Saved Sounds Table VC
class SavedSoundsTableViewController: UITableViewController {
        
    var savedAudio: [RecordedAudio]!
    
    var documentInteractionController: UIDocumentInteractionController!
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedAudioArray").path!
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [RecordedAudio] {
            savedAudio = array
        }

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func presentPlayController(sender: UIButton) {
        let audioInstance = self.savedAudio[sender.tag] as RecordedAudio
        self.documentInteractionController = UIDocumentInteractionController(URL: audioInstance.aacURL)
        self.documentInteractionController.delegate = self
        self.documentInteractionController.name = audioInstance.title
        self.documentInteractionController.presentPreviewAnimated(true)
    }
    
    @IBAction func presentShareController(sender: UIButton) {
        let audioInstance = self.savedAudio[sender.tag] as RecordedAudio
        self.documentInteractionController = UIDocumentInteractionController(URL: audioInstance.aacURL)
        self.documentInteractionController.delegate = self
        self.documentInteractionController.presentOpenInMenuFromRect(CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2, width: 300, height: 300), inView: self.view, animated: true)
    }

    // MARK: - Table view delegate methods
    // Sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedAudio.count
    }
    
    // Rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        let audioInstance = savedAudio[indexPath.row]
        cell.cellTitle.text = audioInstance.title
        cell.cellDate.text = audioInstance.date
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: "presentPlayController:", forControlEvents: .TouchUpInside)
        
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: "presentShareController:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    // Populate cells
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.savedAudio.removeAtIndex(indexPath.row)
            NSKeyedArchiver.archiveRootObject(savedAudio, toFile: filePath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }
    }
    
    // MARK: Helper functions
    @IBAction func popToRecordVC(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}

// MARK: UIDocumentInteractionController delegate
extension SavedSoundsTableViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        if let navigationController = self.navigationController {
            return navigationController
        } else {
            return self
        }
    }

}

