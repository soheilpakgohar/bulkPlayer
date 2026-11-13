//
//  File.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 11/11/26.
//

import SwiftUI

struct RealHiddenModifier: ViewModifier {
    let condition: Bool
    func body(content: Content) -> some View {
        if !condition {
            content
        }
    }
}
