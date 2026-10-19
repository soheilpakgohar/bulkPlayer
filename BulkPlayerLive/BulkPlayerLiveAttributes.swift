//
//  BulkPlayerLiveAttributes.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//


import ActivityKit
import Foundation

nonisolated
struct BulkPlayerLiveAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        let duration: TimeInterval
        let currentTime: TimeInterval
        let isPlaying: Bool
    }
}
