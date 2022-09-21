//
//  ComposeViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Foundation

class ComposeViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var songSearchBar: UISearchBar!
    @IBOutlet weak var parodyTitle: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var originalSong: OriginalSong?
    var parody: Parody?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.songSearchBar.searchBarStyle = .minimal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        songSearchBar.delegate = self
        parodyTitle.delegate = self
        
        tableView.register(UINib(nibName: K.ComposePage.lyricCellNibName, bundle: nil),forCellReuseIdentifier: K.ComposePage.lyricCellIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.composeToRecord {
            let destinationVC = segue.destination as! RecordAudioViewController
            destinationVC.parody = self.parody
            print("Preparing for segue...id at this point is \(self.parody?.id ?? "no id")")
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        saveNewLyrics(andPerformSegueTo: K.Segues.composeToHome)
    }
    
    @IBAction func recordAudioPressed(_ sender: Any) {
        saveNewLyrics(andPerformSegueTo: K.Segues.composeToRecord)
    }
    
    //MARK: - Model Manupulation Methods
    
    func loadOldLyrics(songTitle: String) {
        // load old lyrics of song from database into controller
        // create a model called old song, with artist, lyrics, length, etc.
        
        db.collection(K.ComposePage.FStore.originalSongCollectionName).whereField(K.ComposePage.FStore.songTitleField, isEqualTo: songTitle)
            .getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an error retrieving data from Firestore.", e)
            } else {
                // successfully fetched data
                if let snapshotDocuments = querySnapshot?.documents {
//                    for doc in snapshotDocuments {
                    //currently just taking the first search result, use result navigator/selector dropdown later
                    let doc = snapshotDocuments.first
                    if doc == nil {
                        print("No search results found.")
                        return
                    }
                    let data = doc!.data()
                    if let title = data[K.ComposePage.FStore.songTitleField] as? String,
                       let artist = data[K.ComposePage.FStore.songArtistField] as? String,
                       let lines = data[K.ComposePage.FStore.songLinesField] as? [String] {
                        
                        let newOriginalSong = OriginalSong(title: title, artist: artist, lines: lines, trackName: data[K.ComposePage.FStore.songTrackNameField] as? String)
                        self.originalSong = newOriginalSong
                        self.parody = Parody(creator: Auth.auth().currentUser?.email, title: self.parodyTitle.text, lines: [String](repeating: "", count: newOriginalSong.lines!.count), originalSong: newOriginalSong, originalSongId: doc?.documentID)
                            
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
//                    }
                }
            }
        }
    }
    
    func loadNewLyrics() {
        // load previously written new lyrics of song from database into controller
    }
    
    func saveNewLyrics(andPerformSegueTo: String) {
        // save newly written lyrics of parody into database
        if let thisParody = self.parody {
            if thisParody.id == nil {
                var ref: DocumentReference? = nil
                ref = self.db.collection(K.ComposePage.FStore.parodyCollectionName).addDocument(data: [
                    K.ComposePage.FStore.parodyCreatorField: thisParody.creator ?? "unknown",
                    K.ComposePage.FStore.parodyLinesField: thisParody.lines,
                    K.ComposePage.FStore.parodyTitleField: thisParody.title ?? "untitled",
                    K.ComposePage.FStore.parodyOriginalSongIdField: thisParody.originalSongId ?? "no original song",
                ]) { (error) in
                    if let e = error {
                        print("Error adding data to Firestore.", e)
                    } else {
                        print("Successfully saved parody to Firestore!")
                        self.parody?.id = ref!.documentID
                        print("Document added with ID: \(self.parody?.id ?? "no id")")
                        if andPerformSegueTo == K.Segues.composeToRecord {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: K.Segues.composeToRecord, sender: self)
                            }
                        } else if andPerformSegueTo == K.Segues.composeToHome {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: K.Segues.composeToHome, sender: self)
                            }
                        }
                    }
                }
            } else {
                let existingParodyRef: DocumentReference? = db.collection(K.ComposePage.FStore.parodyCollectionName).document(self.parody?.id ?? "")
                if let existingParodyRef = existingParodyRef {
                    existingParodyRef.getDocument { document, error in
                        if let document = document, document.exists {
                            // parody with this id already exists, so we are just updating its data fields
                            document.reference.updateData([
                                K.ComposePage.FStore.parodyCreatorField: thisParody.creator ?? "unknown",
                                K.ComposePage.FStore.parodyLinesField: thisParody.lines,
                                K.ComposePage.FStore.parodyTitleField: thisParody.title ?? "untitled",
                                K.ComposePage.FStore.parodyOriginalSongIdField: thisParody.originalSongId ?? "no original song"
                            ])
                            print("Successfully updated existing parody with id: \(self.parody?.id ?? "no id")")
                            if andPerformSegueTo == K.Segues.composeToRecord {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: K.Segues.composeToRecord, sender: self)
                                }
                            } else if andPerformSegueTo == K.Segues.composeToHome {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: K.Segues.composeToHome, sender: self)
                                }
                            }
                        } else {
                            print("Something is wrong. Doc ref doesn't exist.")
                        }
                    }
                }
            }
        }
    }

}

//MARK: - UITableViewDataSource Methods

extension ComposeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let lines = originalSong?.lines {
            return lines.count * 2
        }
        print("Old lyrics aren't loaded into string.")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ComposePage.lyricCellIdentifier, for: indexPath) as! LyricCell
        cell.delegate = self
        if indexPath.row % 2 == 0 {
            // old lyrics
            cell.textLabel?.textColor = UIColor.gray
            if let song = originalSong {
                let lines = song.lines
                let currentLine = lines![indexPath.row / 2]
                cell.label.text = String(currentLine)
                cell.textField.isHidden = true
                cell.label.isHidden = false
            }
            return cell
        } else {
            // new lyrics
            if let thisParody = parody {
                let currentLine = thisParody.lines[indexPath.row / 2]
                cell.textField.text = currentLine
                cell.label.isHidden = true
                cell.textField.isHidden = false
            }
            cell.numLine = indexPath.row / 2
            return cell
        }
    }
}

//MARK: - SearchBar Delegate Methods

extension ComposeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Searching for \(searchBar.text!)")
        //search for text in search bar
        loadOldLyrics(songTitle: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if originalSong != nil {
            originalSong = nil
            parody = nil
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        if searchBar.text?.count == 0 {
            //if text bar character count decreased (changed) down to 0
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

//MARK: - Title Textfield methods

extension ComposeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        parody?.title = parodyTitle.text
    }
}
