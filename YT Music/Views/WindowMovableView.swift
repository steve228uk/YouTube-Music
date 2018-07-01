//
//  WindowMovableView.swift
//  YT Music
//
//  Created by Stephen Radford on 01/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class WindowMovableView: NSView {
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    override var isOpaque: Bool {
        return false
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override func mouseDragged(with event: NSEvent) {
        window?.performDrag(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        guard event.clickCount == 2, let window = window else { return }
        window.setIsZoomed(!window.isZoomed)
    }
    
}
