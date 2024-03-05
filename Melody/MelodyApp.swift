//
//  MelodyApp.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/2/24.
//

import SwiftUI
import AVFoundation

@main
struct MelodyApp: App {
  init() {
    configureAudioSession()
  }
  var body: some Scene {
    WindowGroup {
      ContentView().frame(
        minWidth: 1000,
        minHeight: 700)
    }.windowResizability(.contentSize)
  }
  
  func configureAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set audio session category. Error: \(error)")
    }
  }
}
