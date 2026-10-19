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

    
    static let title: LocalizedStringResource = "Stop Player"
    
    static let supportedModes: IntentModes = [.foreground(.immediate)]
    
    static let isDiscoverable: Bool = true
    
    @Dependency
    private var playerManager: MusicQueuePlayer
    
    @MainActor
    func perform() async throws -> some IntentResult {
        playerManager.stop()
        return .result(value: true)
    }
}
