//
//  MusicQueuePlayer.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import AVFoundation
import Foundation
import ActivityKit
import SwiftUI

enum MusicQueueError: LocalizedError {
    case emptyQueue
    case resourceNotFound(String)

    var errorDescription: String? {
        switch self {
        case .emptyQueue:
            return "The playlist is empty."
        case .resourceNotFound(let name):
            return "Audio resource not found: \(name)"
        }
    }
}

@Observable
@MainActor
final class MusicQueuePlayer {

    static let shared = MusicQueuePlayer()

    private let player = AVQueuePlayer()
    
    private var activity: Activity<BulkPlayerLiveAttributes>? = nil
    
    @ObservationIgnored
    private var timeObserver: Any?

    private init() {}

    // MARK: - Playback

    /// Replace the current queue and begin playing the tracks.
    func play(urls: [URL]) throws {
        guard !urls.isEmpty else {
            throw MusicQueueError.emptyQueue
        }
        
        let _ = Task {
            try await implementSession()
        }

        player.pause()
        player.removeAllItems()

        for url in urls {
            let item = AVPlayerItem(url: url)
            player.insert(item, after: nil)
        }

        player.play()
        withAnimation {
            isPlaying = true
        }
        try implementActivity()
    }
    
    @concurrent
    private func implementSession() async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try await session.activate()
    }
    
    private func implementActivity() throws {
        if let activity {
            endLiveActivity(activity)
        }
        
        try launchLiveActivity(duration: 0.1, currentTime: 0.0)
        
    }

    func pause() {
        withAnimation {
            isPlaying = false
        }
        player.pause()
    }

    func resume() {
        withAnimation {
            isPlaying = false
        }
        player.play()
    }

    /// Skip the current track.
    func next() {
        player.advanceToNextItem()
    }

    func stop() {
        withAnimation {
            isPlaying = false
        }
        player.pause()
        player.removeAllItems()
    }

    // MARK: - State

    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                addPeriodicTimeObserver()
            } else {
                removePeriodicTimeObserver()
            }
        }
    }

    var currentTitle: String = ""

    var queuedItemCount: Int {
        player.items().count
    }

    var currentTime: TimeInterval = 0.0
    
    var duration: TimeInterval = 0.0

    var volume: Float {
        get { player.volume }
        set { player.volume = min(max(newValue, 0), 1) }
    }

    func goTo(_ seconds: TimeInterval) {
        guard player.currentItem != nil else { return }

        let time = CMTime(
            seconds: max(0, seconds),
            preferredTimescale: 600
        )

        player.seek(to: time)
    }
    
    private func launchLiveActivity(duration: TimeInterval, currentTime: TimeInterval) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {return}
        let attributes = BulkPlayerLiveAttributes()
        let contentState = BulkPlayerLiveAttributes.ContentState(duration: duration, currentTime: currentTime, isPlaying: isPlaying)
        let activityContect = ActivityContent(state: contentState, staleDate: nil)
        activity = try Activity.request(attributes: attributes, content: activityContect)
    }
    
    private func endLiveActivity(_ activity: Activity<BulkPlayerLiveAttributes>) {
        let contentState = BulkPlayerLiveAttributes.ContentState(duration: duration, currentTime: currentTime, isPlaying: false)
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        Task {
            await activity.end(activityContent, dismissalPolicy: .immediate)
        }
    }
    
    private func addPeriodicTimeObserver() {
        // Create a 0.5 second interval time.
        let interval = CMTime(value: 1, timescale: 2)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            Task { @MainActor in
                // Update the published currentTime and duration values.
                self.currentTime = time.seconds
                if let duration = self.player.currentItem?.duration.seconds, duration.isFinite {
                    self.duration = duration
                }
                if let url = (self.player.currentItem?.asset as? AVURLAsset)?.url {
                    self.currentTitle = url.lastPathComponent
                }
                guard let activity = self.activity else {return}
                let ac = ActivityContent(state: BulkPlayerLiveAttributes.ContentState(duration: self.duration, currentTime: self.currentTime, isPlaying: self.isPlaying), staleDate: nil)
            
                await activity.update(ac)
            }
            
        }
    }
    
    /// Removes the time observer from the player.
    private func removePeriodicTimeObserver() {
        guard let timeObserver else { return }
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
        guard let activity else {return}
        endLiveActivity(activity)
    }
    
    enum PlayerError: LocalizedError {
        case permision
        
        
        var errorDescription: String? {
            switch self {
            case .permision:
                "Permision error on playing"
            }
        }
    }
}
