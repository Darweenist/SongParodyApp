//
//  Parody.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/19/22.
//

import Foundation

struct Parody {
    var creator: String?
    var title: String?
    var lines: [String]
    var id: String?
    var originalSong: OriginalSong
    var originalSongId: String?
    var hasVideo: Bool = false
    var hasAudio: Bool = false
    var caption: String?
}
