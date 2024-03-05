//
//  MelodyApp.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/2/24.
//

import SwiftUI

@main
struct MelodyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView().frame(
        minWidth: 1000,
        minHeight: 700)
    }.windowResizability(.contentSize)
  }
}
