//
//  SpotifyWebView.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/3/24.
//

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
    webView.configuration.userContentController.add(
      context.coordinator as WKScriptMessageHandler, name: "consoleLog")
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
          
            console.log("Injected into spotify");
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
