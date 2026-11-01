//
//  StopPlayeIntent.swift
//  BulkPlayerLiveExtension
//
//  Created by soheil pakgohar on 10/19/26.
//


import ActivityKit
import AppIntents
import SwiftUI


struct StopPlayIntent: LiveActivityIntent {

    
    static var title: LocalizedStringResource {"Stop Bulk Player"}
    
    static var supportedModes: IntentModes {[.foreground, .background]}
    
    static let isDiscoverable: Bool = true
    
    @Dependency
    private var player: MusicQueuePlayer
    
    @MainActor
    func perform() async throws -> some IntentResult {
        player.stop()
        return .result()
    }
}
