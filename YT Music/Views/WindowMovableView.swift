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
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return isMovable()
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isMovable() else { return super.mouseDragged(with: event) }
        window?.performDrag(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        guard isMovable() else { return super.mouseUp(with: event) }
        
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
    
    private func isMovable() -> Bool {
        NSCursor.current == NSCursor.arrow
    }
}

