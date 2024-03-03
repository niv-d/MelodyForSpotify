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

struct WebView: UIViewRepresentable {
  let webView: WKWebView
  let initialURL: URL

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.1.15"
    let userContentController = WKUserContentController()
    let script = """

      """
    let userScript = WKUserScript(
      source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    userContentController.addUserScript(userScript)
    configuration.userContentController = userContentController

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.load(URLRequest(url: initialURL))
    webView.scrollView.zoomScale = 0.5
    webView.scrollView.setZoomScale(0.5, animated: true)
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
  }

  func injectCSS(webView: WKWebView, cssFileName: String) {
    guard let cssURL = Bundle.main.url(forResource: cssFileName, withExtension: "css"),
      let cssString = try? String(contentsOf: cssURL)
    else {
      print("Failed to load CSS file")
      return
    }

    let js = """
      var style = document.createElement('style');
      style.innerHTML = '\(cssString)';
      document.head.appendChild(style);
      """

    webView.evaluateJavaScript(js) { (_, error) in
      if let error = error {
        print("Error injecting CSS: \(error)")
      }
    }
  }
}

struct ContentView: View {
  let initialURL = URL(string: "https://open.spotify.com")!
  let webView: WKWebView = WKWebView()

  var body: some View {
    VStack {
      WebView(webView: webView, initialURL: initialURL)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
