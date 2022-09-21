//
//  EditVideoViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 7/7/22.
//

import UIKit
import AVFoundation

class EditVideoViewController: UIViewController {
    
    var videoUrl: URL?
    var parody: Parody?
    
    @IBOutlet weak var player: VideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EditViewController did load.")
        if let videoUrl = videoUrl {
            player.loopVideoWithURL(url: videoUrl)
        } else {
            print("Bruh why is there no videoURL.")
        }
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        player.stopPlayingLoop()
        print("Performing segue to PublishPostViewController")
        performSegue(withIdentifier: K.Segues.editToPost, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("performing segue: \(String(describing: segue.identifier))")
        if segue.identifier == K.Segues.editToPost {
            let destinationVC = segue.destination as! PublishPostViewController
            destinationVC.localVideoURL = videoUrl
            destinationVC.parody = parody
        }
    }

}
