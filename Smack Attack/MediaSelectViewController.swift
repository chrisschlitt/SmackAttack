//
//  MediaSelectViewController.swift
//  Smack Attack
//
//  Created by Christopher Schlitt on 3/24/17.
//  Copyright © 2017 Smack Innovations. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaSelectViewController: UITableViewController, MPMediaPickerControllerDelegate {

    var chosenSongTitle: String!
    var chosenSongArtist: String!
    var chosenSongURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.chosenSongTitle = "Cancel"
        self.chosenSongArtist = "None"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
        if(indexPath.row == 0){
            let mediaPicker = MPMediaPickerController(mediaTypes: .music)
            mediaPicker.delegate = self
            mediaPicker.allowsPickingMultipleItems = false
            present(mediaPicker, animated: true, completion: {})
        } else if(indexPath.row == 1){
            
                // Create the alert controller.
                let alert = UIAlertController(title: "Enter URL", message: "Enter a URL of a sound file", preferredStyle: .alert)
                
                // Add URL field
                alert.addTextField { (textField) in
                    
                    textField.text = ""
                    
                    let pasteboardString: String? = UIPasteboard.general.string
                    if let pasteText = pasteboardString {
                        if(self.verifyUrl(urlString: pasteText)){
                            textField.text = pasteText
                        }
                    }
                }
                
                // Add close action
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                
                // Add action handler
                alert.addAction(UIAlertAction(title: "Load", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    
                    
                    
                    
                    var url = (textField?.text)!
                    if(!url.hasPrefix("http")){
                        url = "https://" + url
                    }
                    
                    self.chosenSongTitle = "Stream"
                    self.chosenSongArtist = url
                    self.chosenSongURL = URL(string: url)
                    self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                    
                    
                }))
            DispatchQueue.main.async {
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }
            
        } else if(indexPath.row == 5){
            self.chosenSongTitle = "No Song"
            self.chosenSongArtist = " "
            self.chosenSongURL = nil
            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /* Media Picker Delegate Methods */
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print("The user closed the media picker")
        
        dismiss(animated: true, completion: nil)
        
        // User selected a/an item(s).
        if(mediaItemCollection.count > 0){
            print("The user selected \(mediaItemCollection.items.first!.title)")
            
            if((mediaItemCollection.items.first!.value(forProperty: MPMediaItemPropertyIsCloudItem) as! Bool)){
                // Song is stored in the cloud
                let alert = UIAlertController(title: "Not Supported", message: "Songs stored in the cloud are not supported. Open the music app and download the song first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Load sing
                self.chosenSongTitle = mediaItemCollection.items.first!.title
                self.chosenSongArtist = mediaItemCollection.items.first!.artist
                self.chosenSongURL = mediaItemCollection.items.first!.assetURL
                performSegue(withIdentifier: "unwindToMenu", sender: self)
            }
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("User selected Cancel")
        dismiss(animated: true, completion: nil)
    }

    /* Navigation Methods */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "unwindToMenu" && self.chosenSongTitle != nil){
            let vc = segue.destination as! ViewController
            vc.currentSongURL = self.chosenSongURL
            vc.currentSongTitle = self.chosenSongTitle
            vc.currentSongArtist = self.chosenSongArtist
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    
    /* Utinity Methods */
    func verifyUrl(urlString: String?) -> Bool {
        // Check for nil
        if let urlString = urlString {
            // create URL instance
            if let url = URL(string: urlString) {
                // check if your application can open the URL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }

}
