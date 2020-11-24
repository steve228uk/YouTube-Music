//
//  CustomWindow.swift
//  YT Music
//
//  Created by Stephen Radford on 19/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class CustomWindow: NSWindow {

    var buttons: [NSView] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
        
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
//        styleMask.insert(.fullSizeContentView)

        identifier = NSUserInterfaceItemIdentifier(rawValue: "main")
        backgroundColor = NSColor(hue:0.00, saturation:0.00, brightness:0.07, alpha:1.00)
        contentMinSize = NSSize(width: 800, height: 500)
        setFrameAutosaveName(NSWindow.FrameAutosaveName(rawValue: "uk.co.wearecocoon.ytmusic.main"))

        isMovableByWindowBackground = true

        configureButtons()
    }

    // https://zhenchao.li/2018-07-04-positioning-traffic-lights-of-your-cocoa-app/
    private func configureButtons() {
        if styleMask.contains(.fullScreen) { return }

        let close = standardWindowButton(NSWindow.ButtonType.closeButton)
        let minimize = standardWindowButton(NSWindow.ButtonType.miniaturizeButton)
        let maximize = standardWindowButton(NSWindow.ButtonType.zoomButton)

        buttons.append(close!)
        buttons.append(minimize!)
        buttons.append(maximize!)

        buttons.forEach { (btn) in
            btn.superview?.willRemoveSubview(btn)
            btn.removeFromSuperview()

            btn.viewWillMove(toSuperview: contentView)
            contentView!.addSubview(btn)
            btn.viewDidMoveToSuperview()
        }

        var offsetX: CGFloat = 20
        buttons.forEach { (btn) in
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.removeConstraints(btn.constraints)

            btn.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 23).isActive = true
            btn.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor, constant: offsetX).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 14).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 14).isActive = true
            offsetX += 22
        }
        contentView!.layoutSubtreeIfNeeded()

        contentView?.superview!.viewDidEndLiveResize()
    }
}
