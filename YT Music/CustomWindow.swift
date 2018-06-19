//
//  CustomWindow.swift
//  YT Music
//
//  Created by Stephen Radford on 19/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class CustomWindow: NSWindow {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
        identifier = NSUserInterfaceItemIdentifier(rawValue: "main")
        backgroundColor = NSColor(hue:0.00, saturation:0.00, brightness:0.07, alpha:1.00)
        setFrameAutosaveName(NSWindow.FrameAutosaveName(rawValue: "uk.co.wearecocoon.ytmusic.main"))
        
    }
    
}
