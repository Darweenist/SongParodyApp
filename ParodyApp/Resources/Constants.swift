//
//  Constants.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import Foundation

struct K {
    struct Segues {
        static let loginToRegister = "LoginToRegister"
        static let registerToHome = "RegisterToHome"
        static let loginToHome = "LoginToHome"
        static let composeToRecord = "ComposeToRecord"
        static let recordToFilm = "RecordToFilm"
        static let filmToPlayer = "FilmToPlayer"
        static let editToPost = "EditToPost"
        static let composeToHome = "ComposeToHome"
        static let postToProfile = "PostToProfile"
        static let loginToSimpleHome = "LoginToSimpleHome"
        static let registerToSimpleHome = "RegisterToSimpleHome"
        static let simpleHomeToCompose = "SimpleHomeToCompose"
    }
    struct ComposePage {
        static let charactersPerLine = 15.0
        static let lyricCellIdentifier = "LyricCell"
        static let lyricCellNibName = "LyricCell"
        struct FStore {
            static let originalSongCollectionName = "originalSongs"
            static let parodyCollectionName = "parodies"
            static let parodyTitleField = "title"
            static let songTitleField = "title"
            static let parodyCreatorField = "creator"
            static let songArtistField = "artist"
            static let parodyLinesField = "lines"
            static let songLinesField = "lines"
            static let parodyOriginalSongIdField = "originalSong"
            static let songTrackNameField = "trackName"
            static let parodyCaptionField = "caption"
        }
    }
}
