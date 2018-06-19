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
    var mediaKeyTap: MediaKeyTap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()
        
        view.alphaValue = 0

        let url = URL(string: "https://music.youtube.com")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = CustomWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15"
        view = webView
    }
    
    override func viewDidLayout() {
        
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
        
        super.viewDidLayout()
        
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

}

// MARK: - Delegates

extension ViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("started", navigation)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
        print(navigation)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("finished", navigation)
        
        injectCustomCSS()
        view.animator().alphaValue = 1
    }
    
}

// MARK: - Media Keys

extension ViewController: MediaKeyTapDelegate {
    
    func handle(mediaKey: MediaKey, event: KeyEvent) {
        print(mediaKey)
    }
    
}
