//
//  FaceBoardApp.swift
//  FaceBoard
//
//  Created by amos.gyamfi@getstream.io on 22.1.2024.
//

import SwiftUI

@main
struct FaceBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                FreeFormDrawingView()
            }
        }
    }
}
