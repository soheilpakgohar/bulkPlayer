//
//  SongTrack.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftData
import AVFoundation

@Model
class SongTrack: Identifiable {
    
    
    var id = UUID()
    var url: URL
    var addedToPlaylist = false
    
    init(url: URL) {
        self.url = url
    }
    
    func thumbnail() async throws -> Data? {
        let asset = AVURLAsset(url: url)
        do {
            let metaData = try await asset.load(.metadata)
            for item in metaData {
                guard item.commonKey == .commonKeyArtwork else {continue}
                let data = try await item.load(.dataValue)
                guard let data else {continue}
                return data
            }
        } catch {
            throw error
        }
        
        return nil
    }
}
