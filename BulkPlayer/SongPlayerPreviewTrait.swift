//
//  SongPlayerPreviewTrait.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import SwiftData

struct SongPlayerPreviewTrait: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(for: SongTrack.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let song1 = SongTrack(path:  "12.%20Taher%20Golgon%20-%20Ba%20To%20%5B128%5D.mp3")
        container.mainContext.insert(song1)
        return container
    }
    
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait<Preview.ViewTraits> {
    @MainActor
    static var previewContainer: Self = .modifier(SongPlayerPreviewTrait())
}
