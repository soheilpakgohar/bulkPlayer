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
        let song1 = SongTrack(url: URL(string: "file:///Users/soheilpakgohar/Library/Developer/CoreSimulator/Devices/AFFAD755-34F6-4380-8554-3DFBBCF74648/data/Containers/Data/Application/A0F6AA8E-5A09-43A8-9EC5-A4F3E383065A/Documents/09.%20Taher%20Golgon%20-%20Tanhat%20Nemizaram%20%5B128%5D.mp3")!)
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
