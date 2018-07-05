//
//  ViewController.swift
//  YT Music
//
//  Created by Stephen Radford on 19/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import WebKit
import MediaKeyTap

class ViewController: NSViewController {

    var webView: CustomWebView!
    var userContentController: WKUserContentController!
    var movableView: WindowMovableView!
    var mediaKeyTap: MediaKeyTap?
    var backButton: NSButton!
    var forwardButton: NSButton!
    var backObservation: NSKeyValueObservation?
    var forwardObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()
        
        view.alphaValue = 0
        
        let url = URL(string: "https://music.youtube.com")!
        let request = URLRequest(url: url)
        webView.load(request)
        
        addObservers()
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        
        userContentController = WKUserContentController()
        userContentController.add(MediaCenter.default, name: "observer")
        webConfiguration.userContentController = userContentController
        
        
        webView = CustomWebView(frame: .zero, configuration: webConfiguration)
        webView.wantsLayer = true
        webView.layerContentsRedrawPolicy = .onSetNeedsDisplay
        webView.frame = NSRect(x: 0, y: 0, width: 1024, height: 768)
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15"
        
        addMovableView()
        addNavigationButtons()
        
        view = webView
    }
    
    override func viewDidLayout() {
        
        super.viewDidLayout()

        if let btn = view.window?.standardWindowButton(.closeButton) {
            btn.removeFromSuperview()
            btn.setFrameOrigin(NSPoint(x: 17, y: 22))
            view.addSubview(btn)
        }
        
        if let btn = view.window?.standardWindowButton(.miniaturizeButton) {
            btn.removeFromSuperview()
            btn.setFrameOrigin(NSPoint(x: 37, y: 22))
            view.addSubview(btn)
        }
        
        if let btn = view.window?.standardWindowButton(.zoomButton) {
            btn.removeFromSuperview()
            btn.setFrameOrigin(NSPoint(x: 57, y: 22))
            view.addSubview(btn)
        }

        movableView.frame = CGRect(x: 0, y: 0, width: webView.frame.width, height: 20)
        
    }
    
    func addObservers() {
        backObservation = webView.observe(\CustomWebView.canGoBack) { (webView, _) in
            self.backButton.isEnabled = webView.canGoBack
            self.backButton.image = webView.canGoBack ? #imageLiteral(resourceName: "Back Arrow Active") : #imageLiteral(resourceName: "Back Arrow Inactive")
        }
        
        forwardObservation = webView.observe(\CustomWebView.canGoForward) { (webView, _) in
            self.forwardButton.isEnabled = webView.canGoForward
            self.forwardButton.image = webView.canGoForward ? #imageLiteral(resourceName: "Forward Arrow Active") : #imageLiteral(resourceName: "Forward Arrow Inactive")
        }
    }
    
    func addNavigationButtons() {
        backButton = NSButton(image: #imageLiteral(resourceName: "Back Arrow Inactive"), target: self, action: #selector(backButtonClicked(_:)))
        backButton.isEnabled = false
        backButton.bezelStyle = .shadowlessSquare
        backButton.isBordered = false
        
        var frame = backButton.frame
        frame.origin = CGPoint(x: 90, y: 15)
        backButton.frame = frame
        
        webView.addSubview(backButton)
        
        forwardButton = NSButton(image: #imageLiteral(resourceName: "Forward Arrow Inactive"), target: self, action: #selector(forwardButtonClicked(_:)))
        forwardButton.isEnabled = false
        forwardButton.bezelStyle = .shadowlessSquare
        forwardButton.isBordered = false
        
        frame = forwardButton.frame
        frame.origin = CGPoint(x: 130, y: 15)
        forwardButton.frame = frame
        
        webView.addSubview(forwardButton)
    }
    
    @objc func backButtonClicked(_ sender: NSButton) {
        webView.goBack()
    }
    
    @objc func forwardButtonClicked(_ sender: NSButton) {
        webView.goForward()
    }

    func addMovableView() {
        movableView = WindowMovableView(frame: .zero)
        movableView.frame = CGRect(x: 0, y: 0, width: webView.frame.width, height: 20)
        webView.addSubview(movableView)
    }
    
}

// MARK: - Delegates

extension ViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
        print(navigation)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.url?.host == "music.youtube.com" else {
            view.animator().alphaValue = 1
            return
        }
        
        injectCustomCSS()
        injectObservers()
        view.animator().alphaValue = 1
    }
    
    func injectCustomCSS() {
        guard let cssURL = Bundle.main.url(forResource: "custom", withExtension: "css"),
        let css = try? String(contentsOf: cssURL) else {
            return
        }
        
        var js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        js = js.replacingOccurrences(of: "\n", with: "")
        js = js.replacingOccurrences(of: "{", with: "\\{")
        js = js.replacingOccurrences(of: "}", with: "\\}")
        
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    /// Injects observers that the WKScriptMessageHandler will hear back from.
    /// These are used to detect when a track is playing etc.
    func injectObservers() {
        guard let jsURL = Bundle.main.url(forResource: "observer", withExtension: "js"),
        let js = try? String(contentsOf: jsURL) else {
            return
        }
        
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }

}
