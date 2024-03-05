//
//  ContentView.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/2/24.
//

import RealityKit
import RealityKitContent
import SwiftUI
import WebKit

struct SpotifyState: Codable {
  var albumImage: String = ""
  var albumName: String = ""
  var artistName: String = ""
  var device: String = ""
  var heart: Bool = false
  var lyrics: Bool = false
  var playing: Bool = false
  var queue: Bool = false
  var repeatMode: RepeatMode = RepeatMode.none
  var shuffle: Bool = false
  var songLength: Double = 0
  var songName: String = ""
  var songPercent: Double = 0
  var songPosition: Double = 0

  enum CodingKeys: String, CodingKey {
    case playing, songLength, songPercent, songPosition, heart, shuffle, device, songName,
      artistName, albumName, albumImage, queue, lyrics
    case repeatMode = "repeat"
  }

  enum RepeatMode: String, Codable {
    case none = "none"
    case one = "one"
    case all = "all"
  }
}

class WebViewModel: ObservableObject {
  var webView: WKWebView = WKWebView()
  @Published var currentPlaybackTime: Double = 0
  @Published var spotifyState: SpotifyState

  init() {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.1.15"

    webView = WKWebView(frame: .zero, configuration: configuration)
    self.spotifyState = SpotifyState()
  }

  private func log(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n"
  ) {
    let prefix = "SpotifyWebViewModel"
    let message = items.map { "\($0)" }.joined(separator: separator)
    print("\(prefix):\n \(message)", terminator: terminator)
  }

  func update(with data: SpotifyState) {
    self.spotifyState = data
  }

  func songPositionChanged(to newValue: Double) {
    self.spotifyState.songPosition = newValue
  }

  func goHome() {
    touchAriaLabel(label: String("Home"))
  }

  func goSearch() {
    touchAriaLabel(label: String("Search"))
  }

  func goArtist() {
    touchTestID(id: String("context-item-info-artist"))
  }

  func goAlbum() {
    touchTestID(id: String("context-item-link"))
  }

  func goSongInfo() {
    touchAriaLabel(label: "Now playing view")
  }

  func mediaPlayPause() {
    touchTestID(id: String("control-button-playpause"))
  }

  func mediaNext() {
    touchAriaLabel(label: String("Next"))
  }

  func mediaPrevious() {
    touchAriaLabel(label: String("Previous"))
  }

  func mediaShuffle() {
    touchTestID(id: String("control-button-shuffle"))
  }

  func mediaRepeat() {
    touchTestID(id: String("control-button-repeat"))
  }

  func mediaHeart() {
    touchTestID(id: String("add-button"))
  }

  func mediaRemove() {
    touchAriaLabel(label: String("Remove"))
  }

  func mediaLyrics() {
    touchTestID(id: String("lyrics-button"))
  }

  func mediaQueue() {
    touchTestID(id: String("control-button-queue"))
  }

  private func touchAriaLabel(label: String) {
    queryAndClick(query: String("[aria-label=\"\(label)\"]"))
  }

  private func touchTestID(id: String) {
    queryAndClick(query: String("[data-testid=\"\(id)\"]"))
  }

  private func queryAndClick(query: String) {
    let script = """
      (function() {
        const targetedButton = document.querySelector('\(query)');
        if (targetedButton) {
            targetedButton.click();
            console.log('found the button, clicked on it');
        } else {
            console.log('\(query) not found');
        }
        setTimeout(()=>{
          window.getState && window.getState();
        }, 500)
      })()
      """
    runJavascript(script: script)
  }

  private func runJavascript(script: String) {
    self.log("Reunning script:\n \(script)")
    webView.evaluateJavaScript(script) { result, error in
      if let error = error {
        self.log("Error during JS execution: \(error)")
      }
      if let result = result {
        self.log("Result of JS execution: \(result)")
      }
    }
  }
}

struct ContentView: View {
  @ObservedObject var viewModel = WebViewModel()
  @State private var selectedTab = 0

  var body: some View {
    VStack {

      TabView(selection: $selectedTab) {
        Text("").tabItem {
          Label("Home", systemImage: "house")
        }
        .tag(0).onAppear {
          viewModel.goHome()
        }

        Text("").tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
        .tag(1).onAppear {
          viewModel.goSearch()
        }

        Text("").tabItem {
          Label("Reload Player", systemImage: "arrow.clockwise")
        }
        .tag(2).onAppear {
          viewModel.webView.reload()
          selectedTab = 0
        }

      }
      .toolbar {
        ToolbarItemGroup(placement: .bottomOrnament) {
          PlayerBar(viewModel: viewModel)
        }
      }
    }
    .overlay(
      SpotifyWebView(webView: viewModel.webView, viewModel: viewModel)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    )
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
