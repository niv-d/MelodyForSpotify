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

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.1.15"

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

  private func encodeStringTo64(fromString: String) -> String? {
    let plainData = fromString.data(using: .utf8)
    return plainData?.base64EncodedString(options: [])
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebView

    init(_ parent: WebView) {
      self.parent = parent
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      do {
        let cssFile = try parent.readFileBy(name: "theme", type: "css")
        let jsFile = try parent.readFileBy(name: "script", type: "js")
        let injectedScripts = """
          (function() {
            var parent = document.getElementsByTagName('head').item(0);
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = window.atob('\(parent.encodeStringTo64(fromString: cssFile)!)');
            parent.appendChild(style)

            \(jsFile)
          })()
          """
        webView.evaluateJavaScript(injectedScripts) { _, error in
          if let error = error {
            print("Error injecting JavaScript: \(error)")
          }
        }
      } catch {
        print("Injecting javascript and css failed...")
      }

    }
    func userContentController(
      _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
      if message.name == "consoleLog", let log = message.body as? String {
        print("JavaScript Console Log: \(log)")
      }
    }
  }
}

struct ContentView: View {
  let webView: WKWebView = WKWebView()

  var body: some View {
    VStack {
      WebView(webView: webView)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
