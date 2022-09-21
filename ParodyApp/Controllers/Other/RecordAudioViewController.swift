//
//  PostViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import UIKit
import AVFoundation
import FirebaseStorage
import SwiftyRecordButtons

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var parody: Parody?
    var karaokeLines: [String]?
    
    let storageRef = Storage.storage().reference()
    var parodyReference: StorageReference {
        return storageRef.child("parodies")
    }
    var karaokeReference: StorageReference {
        return storageRef.child("karaokes")
    }
    var localKaraokeURL: URL?
    var localParodyURL: URL?
    var localMixedURL: URL?
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var recordButton: UIButton!
    
    let recordBtn = RecordButton()
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(recordBtn)
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
//        tableView.delegate = self
        tableView.dataSource = self
        
        AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
            if hasPermission {
                print("Audio permission enabled.")
            }
        }
        if (parody?.originalSong) != nil {
            karaokeLines = parody?.lines
            downloadKaraokeTrack()
        } else {
            print("Just testing.")
        }
        
        tableView.register(UINib(nibName: K.ComposePage.lyricCellNibName, bundle: nil), forCellReuseIdentifier: K.ComposePage.lyricCellIdentifier)
    }
    
    func downloadKaraokeTrack() {
        let thisKaraokeRef = karaokeReference.child("\(parody!.originalSong.title!) by \(parody!.originalSong.artist!).mp3")
        let localURL = getDirectory().appendingPathComponent("\(parody!.originalSong.title!) by \(parody!.originalSong.artist!).mp3")
        print("Attempting to download \(thisKaraokeRef) to \(localURL)")
        // Download to the local filesystem
        let downloadTask = thisKaraokeRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("Error downloading karaoke file.", error)
            } else {
                // Local file URL for "images/island.jpg" is returned
                self.localKaraokeURL = url
                print("downloaded karaoke file to this url: \(url?.path ?? "unknownURL")")
            }
        }
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        print("playing back")
        if let localMixedURL = localMixedURL {
            print("Attempting to playback file at \(localMixedURL.path)")
            playSound(soundURL: localMixedURL, button: sender)
        }
    }
    
    func playSound(soundURL: URL, button: UIButton) {
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Error creating an AVAudioPlayer", error)
        }
        player.delegate = self
        player.play()
    }
    
    @IBAction func recordPressed(_ sender: UIButton) {
        //Check if we have an active recording
        if audioRecorder == nil {
            do {
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            } catch {
                print("Error setting category of recording session to playAndRecord...", error)
            }
            // play karaoke
            if let localKaraokeURL = localKaraokeURL {
                print("Playing sound at \(localKaraokeURL.path)")
                playSound(soundURL: localKaraokeURL, button: sender)
            } else {
                print("No url to local karaoke file")
            }
            //prepare to start recording
            localParodyURL = getDirectory().appendingPathComponent("\(parody!.title!).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //start recording
            do {
                audioRecorder = try AVAudioRecorder(url: localParodyURL!, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
//                recordButton.setTitle("Stop", for: .normal)
            } catch {
                displayAlert(title: "Oops!", message: "Something went wrong. Recording failed.")
            }
        } else { //means we are already recording
            //stop audio recording
            do {
                try recordingSession.setCategory(AVAudioSession.Category.playback)
            } catch {
                print("Error setting category of recording session...", error)
            }
            audioRecorder.stop()
            audioRecorder = nil
            if let player = player {
                player.stop()
            }
            if let localParodyURL = localParodyURL, let localKaraokeURL = localKaraokeURL {
                let urls: [URL] = [localParodyURL, localKaraokeURL]
                print("Combining audios.")
                combineAudios(tracks: urls)
            }
//            recordButton.setTitle("Record", for: .normal) // present an alert saying your progress will be reset
        }
    
    }
    
    func combineAudios(tracks: [URL]) {
        let composition = AVMutableComposition()
        for trackPath: URL in tracks {
            let audioAsset = AVURLAsset(url: trackPath, options: nil)
            let audioTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAsset.tracks(withMediaType: AVMediaType.audio)[0], at: CMTime.zero)
                } catch {
                    print("Error merging audio track at \(trackPath.path)")
                    return
                }
        }
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        let mixedAudio: String = "\(parody!.id ?? "unknownID")-\(parody!.creator ?? "unknownCreator").m4a"
        let exportPath: String = NSTemporaryDirectory() + (mixedAudio)
        localMixedURL = URL(fileURLWithPath: exportPath)
        if FileManager.default.fileExists(atPath: exportPath) {
            try? FileManager.default.removeItem(atPath: exportPath)
        }
        assetExport!.outputFileType = AVFileType.m4a
        assetExport!.outputURL = localMixedURL
        assetExport!.shouldOptimizeForNetworkUse = true
        assetExport!.exportAsynchronously(completionHandler: {() -> Void in
            print("Sucessfully exported mixed audio to \(self.localMixedURL!.path)")
        })
    }
    
    //searching for path to directory in which audio recording will be saved
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //displays an alert
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // save recorded audio to Firebase Storage
    // grey this button out before people have stopped recording maybe
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        if player != nil && player.isPlaying {
            player.stop()
        }
        if let localMixedURL = localMixedURL {
            let uploadedFileName = "\(parody!.id ?? "unknownID")-\(parody!.creator ?? "unknownCreator").m4a"
            print("Uploaded \(uploadedFileName)")
            let thisParodyRef = storageRef.child("parodies/\(uploadedFileName)")
            
            thisParodyRef.putFile(from: localMixedURL, metadata: nil) { metadata, error in
                self.parody?.hasAudio = true
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.Segues.recordToFilm, sender: sender)
                }
            }
        }
//        performSegue(withIdentifier: K.Segues.recordToFilm, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.recordToFilm {
            let destinationVC = segue.destination as! FilmViewController
            destinationVC.audioFilePath = localMixedURL
            destinationVC.parody = self.parody
        }
    }
}

//MARK: - TableView Data Source Methods

extension RecordAudioViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let writtenParody = parody {
            return writtenParody.lines.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ComposePage.lyricCellIdentifier, for: indexPath) as! LyricCell
        cell.textField.isHidden = true
        cell.label.isHidden = false
        cell.label.text = parody?.lines[indexPath.row]
        return cell
    }
}

//MARK: - TableView Delegate Methods

extension RecordAudioViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath,
                                   at: UITableView.ScrollPosition.middle, animated: true)
    }
}

