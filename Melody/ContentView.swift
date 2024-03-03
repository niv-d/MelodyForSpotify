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

struct SpotifyWebView: UIViewRepresentable {
  let webView: WKWebView

  private func log(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n"
  ) {
    let prefix = "SpotifyWebView"
    let message = items.map { "\($0)" }.joined(separator: separator)
    print("\(prefix):\n \(message)", terminator: terminator)
  }

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.1.15"
    configuration.userContentController.add(
      context.coordinator as WKScriptMessageHandler, name: "consoleLog")

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    webView.load(URLRequest(url: URL(string: "https://accounts.spotify.com/en/login")!))
    // webView.load(URLRequest(url: URL(string: "https://open.spotify.com")!))
    webView.isOpaque = false
    webView.backgroundColor = UIColor.clear

    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
  }

  func goHome() {
    touchAriaLabel(label: String("Home"))
  }

  func goSearch() {
    touchAriaLabel(label: String("Search"))
  }

  func mediaPlay() {
    touchAriaLabel(label: String("Play"))
  }

  func mediaPause() {
    touchAriaLabel(label: String("Pause"))
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
    let script = """
        const button = document.querySelector('[aria-label="\(label)"]');
        if (button) {
            button.click();
        } else {
            console.log('[aria-label="\(label)"] not found');
        }
      """
    runJavascript(script: script)
  }

  private func touchTestID(id: String) {
    let script = """
        const button = document.querySelector('[data-testid="\(id)"]');
        if (button) {
            button.click();
        } else {
            console.log('[data-testid="\(id)"] not found');
        }
      """
    runJavascript(script: script)
  }

  private func runJavascript(script: String) {
    webView.evaluateJavaScript(script) { result, error in
      if let error = error {
        self.log("Error during JS execution: \(error)")
      }
      if let result = result {
        self.log("Result of JS execution: \(result)")
      }
    }
  }

  func readPageContent(completion: @escaping (String?, Error?) -> Void) {
    let js = "document.body.innerText"  // JavaScript to get all text content from the body
    webView.evaluateJavaScript(js) { result, error in
      if let error = error {
        completion(nil, error)
        return
      }
      if let content = result as? String {
        completion(content, nil)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var parent: SpotifyWebView

    init(_ parent: SpotifyWebView) {
      self.parent = parent
    }

    enum FileError: Error {
      case fileNotFound
      case unreadableContent
    }
    private func readFileBy(name: String, type: String) throws -> String {
      guard let path = Bundle.main.path(forResource: name, ofType: type) else {
        throw FileError.fileNotFound
      }
      do {
        return try String(contentsOfFile: path, encoding: .utf8)
      } catch {
        throw FileError.unreadableContent
      }
    }

    // Why?? This fixes an issue with "EOF" when loading the CSS, I couldn't figure out why, but
    // **magic**
    private func encodeStringTo64(fromString: String) -> String? {
      let plainData = fromString.data(using: .utf8)
      return plainData?.base64EncodedString(options: [])
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      do {
        let cssFile = try readFileBy(name: "theme", type: "css")
        let jsFile = try readFileBy(name: "script", type: "js")
        let injectedScripts = """
          (function() {
            //Allow logging into XCode console
            var originalLog = console.log;
            console.log = function(message) {
              window.webkit.messageHandlers.consoleLog.postMessage(message);
              originalLog.apply(console, arguments);
            };
            //Inject CSS
            var parent = document.getElementsByTagName('head').item(0);
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = window.atob('\(encodeStringTo64(fromString: cssFile)!)'); //**magic**
            parent.appendChild(style);

            //Inject JS
            \(jsFile)
          })()
          """
        webView.evaluateJavaScript(injectedScripts) { _, error in
          if let error = error {
            self.parent.log("Error during JS injections: \(error)")
          }
        }
      } catch {
        parent.log("Error during loading files to inject: \(error)")
      }

    }
    func userContentController(
      _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
      if message.name == "consoleLog", let log = message.body as? String {
        parent.log("Message from console.log: \(log)")
      }
    }
  }
}

struct ContentView: View {
  let webView: WKWebView = WKWebView()

  var body: some View {
    VStack {
      SpotifyWebView(webView: webView)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
