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

    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    override var isOpaque: Bool {
        return true
    }
    
}
