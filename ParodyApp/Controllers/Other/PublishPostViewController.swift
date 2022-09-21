//
//  PublishPostViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseFirestore
import Photos

class PublishPostViewController: UIViewController, UITextViewDelegate {
    
    var parody: Parody?
    
    let storageRef = Storage.storage().reference()
    let db = Firestore.firestore()

    var localVideoURL: URL?

    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var youtubeShareBtn: UIButton!
    @IBOutlet weak var youtubeShortsShareBtn: UIButton!
    @IBOutlet weak var instagramReelsShareBtn: UIButton!
    @IBOutlet weak var tiktokShareBtn: UIButton!
    @IBOutlet weak var saveToPhotosBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextView.delegate = self
        
        captionTextView.layer.borderWidth = 0.1
        loadCaption()
        loadPreviewImage()
    }
    
    func loadCaption() {
        captionTextView.text = "Add a caption"
        captionTextView.textColor = UIColor.placeholderText
    }
    
    func loadPreviewImage() {
        if localVideoURL == nil {
            print("No localVideoURL")
            return
        }
        let asset = AVURLAsset(url: localVideoURL!, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        var cgImage: CGImage? = nil
        do {
            cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        } catch {
            print("Error generating preview image", error)
        }
        if let cgImage = cgImage {
            let uiImage = UIImage(cgImage: cgImage)
            previewImageView.image = uiImage
        } else {
            print("cgImage is nil")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("TextViewDidBeginEditing")
        if captionTextView.text == "Add a caption" {
            captionTextView.text = ""
            captionTextView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("TextViewDidEndEditing")
        self.parody?.caption = textView.text
    }
    
    func uploadVideoToDatabase() {
        print("inside UploadVideoToDatabase")
        if let localVideoURL = localVideoURL {
            let uploadedFileName = "\(parody!.id ?? "unknownID")-\(parody!.creator ?? "unknownCreator").m4a"
            print("Uploaded \(uploadedFileName)")
            let thisParodyRef = storageRef.child("videos/\(uploadedFileName)")
            
            let uploadTask = thisParodyRef.putFile(from: localVideoURL, metadata: nil) { metadata, error in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.Segues.postToProfile, sender: self)
                }
            }
        }
    }
    
    func updateParodyObject() {
        print("Inside updateParodyObject")
        if let thisParody = parody {
            print("OK thisParody exists, inside updateParodyObject.")
            let reference = self.db.collection(K.ComposePage.FStore.parodyCollectionName).document(thisParody.id!)
            reference.updateData([
                K.ComposePage.FStore.parodyCaptionField: thisParody.caption ?? ""
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated with caption: \(thisParody.caption ?? "")")
                }
            }
        }
    }
    
    //MARK: - Save and Share Actions
    
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        updateParodyObject()
        uploadVideoToDatabase()
    }
    
    @IBAction func saveToPhotosPressed(_ sender: UIButton) {
        if let localVideoURL = localVideoURL {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localVideoURL)
            }) { saved, error in
                if saved {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
}
