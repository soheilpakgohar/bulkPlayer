//
//  Extentions.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import Foundation

extension Notification.Name {
    static let otherTrackIsPlaying = Notification.Name("otherTrackIsPlaying")
    static let stopAll = Notification.Name("stopAll")
}

extension TimeInterval {
    var formattedMinutesSeconds: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var minutesSeconds: (minutes: Int, seconds: Int) {
        let totalSeconds = Int(self)
        return (totalSeconds / 60, totalSeconds % 60)
    }
}
