//
//  FilmViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import UIKit
import AVFoundation
import AVKit
import CameraManager

class FilmViewController: UIViewController, AVAudioPlayerDelegate {
    
    let cameraManager = CameraManager()
    var audioPlayer: AVAudioPlayer!
    var cameraDoneConfiguring = false
    var videoFilePath: URL?
    var audioFilePath: URL?
    var combinedFilePath: URL?
    
    var parody: Parody?
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var previewView: PreviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("FilmViewController did load.")
        configureCamera()
        recordButton.setTitle("Start Filming", for: .normal)
    }
    
    func configureCamera() {
        cameraManager.addPreviewLayerToView(self.previewView)
        cameraManager.shouldRespondToOrientationChanges = false
        cameraManager.shouldKeepViewAtOrientationChanges = true
        DispatchQueue.main.async {
//            self.cameraManager.resetOrientation()
        }
        print(self.cameraManager.deviceOrientationMatchesInterfaceOrientation())
    }
    
    @IBAction func flipCameraPressed(_ sender: UIBarButtonItem) {
        print("UIBarButtonItem pressed.")
        if cameraManager.cameraDevice == .front {
            cameraManager.cameraDevice = .back
        } else {
            cameraManager.cameraDevice = .front
        }
    }
    
    @IBAction func recordPressed(_ sender: UIButton) {
        if cameraDoneConfiguring == false {
            cameraManager.cameraOutputMode = .videoOnly
            cameraManager.writeFilesToPhoneLibrary = false
            cameraDoneConfiguring = true
        }
        if recordButton.currentTitle == "Start Filming" {
            recordButton.setTitle("Stop Filming", for: .normal)
            cameraManager.startRecordingVideo()
            if let audioFilePath = audioFilePath {
                self.playSound(soundURL: audioFilePath, button: sender)
            } else {
                print("No audio file path to play.")
            }
        } else {
            recordButton.setTitle("Start Filming", for: .normal)
            print("Before stopRecording call.")
            if audioPlayer != nil && audioPlayer.isPlaying {
                audioPlayer.stop()
            }
            cameraManager.stopVideoRecording({ [self] (videoURL, recordError) -> Void in
                print("In callback for stopVideoRecording.")
                
                guard let videoURL = videoURL else {
                    //Handle error of no recorded video URL
                    print("No recorded video URL", recordError!)
                    return
                }
                do {
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    self.videoFilePath = paths[0].appendingPathComponent("videoOnly\(Date.now.timeIntervalSince1970).mp4")
                    try FileManager.default.copyItem(at: videoURL, to: self.videoFilePath!)
                    
                } catch {
                    print("Could not copyItem properly.")
                }
                print("Temp Video saved at \(videoURL).")
                if let videoFilePath = self.videoFilePath {
                    print("Video copied to \(videoFilePath)")
                    if let audioFilePath = audioFilePath {
                        mergeFilesWithUrl(videoUrl: videoFilePath, audioUrl: audioFilePath)
                    } else {
                        print("No audio file to merge with recorded video.")
                        combinedFilePath = videoFilePath
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: K.Segues.filmToPlayer, sender: self)
                        }
                    }
                }
            })
            print("After stopRecording call.")
        }
    }
    
    func playSound(soundURL: URL, button: UIButton) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Error creating an AVAudioPlayer", error)
        }
        audioPlayer.delegate = self
        audioPlayer.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.filmToPlayer {
            let destinationVC = segue.destination as! EditVideoViewController
            // if there is no video file path, meaning no video was filmed, the segue should not be called, and the trigger button should just be greyed out
            destinationVC.videoUrl = combinedFilePath
            destinationVC.parody = parody
        }
    }
    
    func mergeFilesWithUrl(videoUrl: URL, audioUrl: URL)
    {
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

        //start merge

        let aVideoAsset : AVAsset = AVAsset(url: videoUrl)
        
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl)

        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]

        
        compositionAddVideo.preferredTransform = aVideoAssetTrack.preferredTransform
        
        var transforms = aVideoAssetTrack.preferredTransform
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            transforms = transforms.concatenating(CGAffineTransform(rotationAngle: CGFloat(-90.0 * .pi / 180)))
            transforms = transforms.concatenating(CGAffineTransform(translationX: 1280, y: 0))
        }
        else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            transforms = transforms.concatenating(CGAffineTransform(rotationAngle: CGFloat(90.0 * .pi / 180)))
            transforms = transforms.concatenating(CGAffineTransform(translationX: 1280, y: 0))
        }
        else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            transforms = transforms.concatenating(CGAffineTransform(rotationAngle: CGFloat(180.0 * .pi / 180)))
            transforms = transforms.concatenating(CGAffineTransform(translationX: 0, y: 720))
        }
        
        print("Transforming with transform: [[[\(transforms)]]]")
        compositionAddVideo.preferredTransform = transforms
        
        mutableCompositionVideoTrack.append(compositionAddVideo)
        mutableCompositionAudioTrack.append(compositionAddAudio)
        
        
        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

            // Audio file is longer then video file so take videoAsset duration instead of audioAsset duration

            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)

        } catch {
            print("Error creating mutableCompositionTracks", error)
        }

        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)

        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.combinedFilePath = paths[0].appendingPathComponent("combinedVideo\(Date.now.timeIntervalSince1970).mp4")
        
        assetExport.outputURL = combinedFilePath
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                print("Successfully merged and exported combined file.")
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.Segues.filmToPlayer, sender: self)
                }
            case AVAssetExportSession.Status.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("complete")
            }
        }
    }
    
}
