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
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        return url.appendingPathComponent("savedAudioArray")!.path
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [RecordedAudio] {
            savedAudio = array
        }

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.backgroundColor = UIColor.init(hexString: "6C7DF5")
        self.tableView.allowsSelection = false
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func presentPlayController(sender: UIButton) {
        let audioInstance = self.savedAudio[sender.tag] as RecordedAudio
        self.documentInteractionController = UIDocumentInteractionController(url: audioInstance.aacURL as URL)
        self.documentInteractionController.delegate = self
        self.documentInteractionController.name = audioInstance.title
        self.documentInteractionController.presentPreview(animated: true)
    }
    
    @IBAction func presentShareController(sender: UIButton) {
        let audioInstance = self.savedAudio[sender.tag] as RecordedAudio
        self.documentInteractionController = UIDocumentInteractionController(url: audioInstance.aacURL as URL)
        self.documentInteractionController.delegate = self
        self.documentInteractionController.presentOpenInMenu(from: CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2, width: 300, height: 300), in: self.view, animated: true)
    }

    // MARK: - Table view delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedAudio.count
    }
    
    // Rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let audioInstance = savedAudio[indexPath.row]
        cell.cellTitle.text = audioInstance.title
        cell.cellDate.text = audioInstance.date
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(SavedSoundsTableViewController.presentPlayController(sender:)), for: .touchUpInside)
        
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(SavedSoundsTableViewController.presentShareController(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    // Populate cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.savedAudio.remove(at: indexPath.row)
            NSKeyedArchiver.archiveRootObject(savedAudio, toFile: filePath)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            tableView.reloadData()
        }

    }
    
    // MARK: IBActions
    @IBAction func popToRecordVC(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}

// MARK: UIDocumentInteractionController delegate
extension SavedSoundsTableViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        if let navigationController = self.navigationController {
            return navigationController
        } else {
            return self
        }
    }

}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

