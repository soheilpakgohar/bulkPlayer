//
//  SongTrack.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftData
import AVFoundation
import SwiftUI

@Model
class SongTrack: Identifiable {
    
    
    var id = UUID()
    
    @Attribute(.unique)
    var path: String
    
    var addedToPlaylist = false
    
    init(path: String) {
        self.path = path
    }
    
    @Transient
    var url: URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentURL.appendingPathComponent(path)
    }
    
    func thumbnail() async throws -> Data? {
        let asset = AVURLAsset(url: url)
        let metaData = try await asset.load(.metadata)
        for item in metaData where item.commonKey == .commonKeyArtwork {
            let data = try await item.load(.dataValue)
            return data
        }
        
        return nil
    }
}

extension SongTrack: Equatable {
    static func == (lhs: SongTrack, rhs: SongTrack) -> Bool {
        lhs.url == rhs.url
    }
}
