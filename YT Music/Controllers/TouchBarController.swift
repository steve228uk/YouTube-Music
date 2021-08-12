//
//  TouchBarController.swift
//  YT Music
//
//  Created by Paolo Polidori on 08/07/21.
//  Copyright © 2021 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

extension NSTouchBarItem.Identifier {
    static let controlStripItem = NSTouchBarItem.Identifier("uk.co.wearecocoon.YT-Music")
    static let playPauseItem = NSTouchBarItem.Identifier("uk.co.wearecocoon.YT-Music.play-pause")
    static let prevItem = NSTouchBarItem.Identifier("uk.co.wearecocoon.YT-Music.prev")
    static let nextItem = NSTouchBarItem.Identifier("uk.co.wearecocoon.YT-Music.next")
    static let likeItem = NSTouchBarItem.Identifier("uk.co.wearecocoon.YT-Music.like")
    static let dislikeItem = NSTouchBarItem.Identifier("uk.co.wearecocoon.YT-Music.dislike")
}

class TouchBarController: NSObject, NSTouchBarDelegate {
    static let shared = TouchBarController()

    var touchBar: NSTouchBar!
    
    lazy var mainWindowController: NSWindowController? = {
        let delegate = NSApplication.shared.delegate as? AppDelegate
        return delegate?.mainWindowController
    }()
    
    var frontmostApplicationIdentifier: String? {
        return NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    private override init() {
        super.init()
        
        self.touchBar = NSTouchBar()
        self.touchBar.delegate = self
        self.touchBar.defaultItemIdentifiers = [.playPauseItem,
                                                .prevItem,
                                                .nextItem,
                                                .likeItem,
                                                .dislikeItem,
                                                .otherItemsProxy]
        
        

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }
    
    func makeTouchBar() -> NSTouchBar {
        return self.touchBar
    }
    
    private static func makeTouchBarButton(identifier: NSTouchBarItem.Identifier, image: NSImage, target: Any?, action: Selector?) -> NSTouchBarItem {
        if #available(macOS 10.15, *) {
            let item = NSButtonTouchBarItem(identifier: identifier, image: image, target: target, action: action)
            return item
        } else {
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = NSButton(image: image, target: target, action: action)
            return item
        }
    }
    
    private func makeFAButton(faString: String, altString: String, action: Selector) -> NSButton {
        let button = NSButton(title: altString, target: self, action: action)
        guard let font = NSFont(name: "FontAwesome", size: 22.0) else {
            return button
        }
        var displayScale: CGFloat = 1.0
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center;
        let aStr = NSAttributedString(string: faString, attributes: [NSAttributedString.Key.paragraphStyle: pstyle, NSAttributedString.Key.font: font])
        if let main = NSScreen.main {
            displayScale = main.backingScaleFactor
            if displayScale <= 0.0 {
                displayScale = 1.0
            }
        }
        let textHeight = aStr.size().height
        let title = NSAttributedString(string: faString, attributes: [
                                        NSAttributedString.Key.paragraphStyle: pstyle,
                                        NSAttributedString.Key.baselineOffset: ((font.ascender - font.descender) - textHeight) / (2 * displayScale),
                                        NSAttributedString.Key.font: font])
        button.attributedTitle = title
        return button
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .controlStripItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = NSButton(image: NSApplication.shared.applicationIconImage, target: self, action: #selector(presentTouchBar))
            return item
        case .playPauseItem:
            return TouchBarController.makeTouchBarButton(identifier: identifier, image: NSImage(named: NSImage.touchBarPlayPauseTemplateName)!, target: self, action: #selector(playPause))
        case .prevItem:
            return TouchBarController.makeTouchBarButton(identifier: identifier, image: NSImage(named: NSImage.touchBarSkipBackTemplateName)!, target: self, action: #selector(prev))
        case .nextItem:
            return TouchBarController.makeTouchBarButton(identifier: identifier, image: NSImage(named: NSImage.touchBarSkipAheadTemplateName)!, target: self, action: #selector(next))
        case .likeItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = makeFAButton(faString: "\u{f164}", altString: "Like", action: #selector(like))
            return item
        case .dislikeItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = makeFAButton(faString: "\u{f165}", altString: "Dislike", action: #selector(dislike))
            return item
        default:
            return nil
        }
    }
    
    @objc func activeApplicationChanged(_: Notification?) {
        if frontmostApplicationIdentifier != nil &&
                frontmostApplicationIdentifier == Bundle.main.bundleIdentifier {
            presentTouchBar()
        } else {
            dismissTouchBar()
        }
    }
    
    @objc func setupControlStripPresence() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        let item = NSCustomTouchBarItem(identifier: .controlStripItem)
        item.view = NSButton(image: NSApplication.shared.applicationIconImage, target: self, action: #selector(presentTouchBar))
        NSTouchBarItem.addSystemTrayItem(item)
    }
    
    @objc private func presentTouchBar() {
        DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, false)
        presentSystemModal(touchBar, systemTrayItemIdentifier: .controlStripItem)
    }

    @objc private func dismissTouchBar() {
        minimizeSystemModal(touchBar)
        DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, true)
    }
    
    @objc private func playPause() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.playPause), with: nil, waitUntilDone: true)
    }
    
    @objc private func prev() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.previousTrack), with: nil, waitUntilDone: true)
    }
    
    @objc private func next() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.nextTrack), with: nil, waitUntilDone: true)
    }
    
    @objc private func like() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.likeTrack), with: nil, waitUntilDone: true)
    }
    
    @objc private func dislike() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.dislikeTrack), with: nil, waitUntilDone: true)
    }
}
