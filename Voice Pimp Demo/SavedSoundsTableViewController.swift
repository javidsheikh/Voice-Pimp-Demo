//
//  SavedSoundsTableViewController.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 19/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit

class SavedSoundsTableViewController: UITableViewController, UIDocumentInteractionControllerDelegate {
    
    var savedAudio: [RecordedAudio]!
    
    var documentInteractionController: UIDocumentInteractionController!
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedAudioArray").path!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let popToRecordVCButton = UIBarButtonItem(title: "Record", style: .Plain, target: self, action: Selector("popToRecordVC"))
        self.navigationItem.rightBarButtonItem = popToRecordVCButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func popToRecordVC() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return savedAudio.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        cell.cellImage.image = UIImage(named: "megaphone-clip-art.png")
        let audioInstance = savedAudio[indexPath.row]
        cell.cellTitle.text = audioInstance.title
        cell.cellDate.text = audioInstance.date

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioInstance = savedAudio[indexPath.row]
        self.documentInteractionController = UIDocumentInteractionController(URL: audioInstance.filePathURL)
        self.documentInteractionController.delegate = self
//        self.documentInteractionController.presentPreviewAnimated(true)
        self.documentInteractionController.presentOpenInMenuFromRect(CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2, width: 300, height: 300), inView: self.view, animated: true)
        print(audioInstance.filePathURL)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
