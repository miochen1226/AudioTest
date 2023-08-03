//
//  AudioTestApp.swift
//  AudioTest
//
//  Created by mio on 2023/7/30.
//

import SwiftUI

@main
struct AudioTestApp: App {
    var audioDriver = AudioDriverEx()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
