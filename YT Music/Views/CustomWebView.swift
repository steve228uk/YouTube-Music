//
//  CustomWebView.swift
//  YT Music
//
//  Created by Stephen Radford on 19/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import WebKit

class CustomWebView: WKWebView {

    override var isOpaque: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        
        // Check if the enter key is being pressed else let the super handle the event.
        guard let value = event.charactersIgnoringModifiers, value == "\r" else {
            super.keyDown(with: event)
            return
        }
        
        // If enter is being pressed then we manually handle it in JS.
        // There's a condition in here to select the .selected-suggestion if there is one else we dispatch the event on activeElement.
        
        let js = "var elem = document.querySelector('.selected-suggestion'); if(!elem) { elem = document.activeElement; } elem.dispatchEvent(new KeyboardEvent('keydown', { view: window, keyCode: 13, bubbles: true, cancelable: true }));"
        
        evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
        
        
    }
    
}
