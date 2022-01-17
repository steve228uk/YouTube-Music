//
//  WindowMovableView.swift
//  YT Music
//
//  Created by Stephen Radford on 01/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class WindowMovableView: NSView {
    
    weak var parent: NSView?
    
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
        
        guard let window = window else {
            return
        }
        
        switch event.clickCount {
        case 1:
            parent?.mouseUp(with: event)
        case 2:
            window.setIsZoomed(!window.isZoomed)
        default:
            break
        }
    }
    
}
