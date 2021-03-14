//
//  AppDelegate.swift
//  YT Music
//
//  Created by Stephen Radford on 19/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var mainWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "main") as? NSWindowController
    }()
    
    lazy var dockMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Play", action: #selector(playPause), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Next", action: #selector(nextTrack), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Previous", action: #selector(previousTrack), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Shuffle", action: #selector(shuffleTracks), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Repeat", action: #selector(repeatTracks), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Like", action: #selector(likeTrack), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Dislike", action: #selector(dislikeTrack), keyEquivalent: ""))
        return menu
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        
        mainWindowController?.window?.isExcludedFromWindowsMenu = true
        mainWindowController?.showWindow(self)
        mainWindowController?.window?.makeKeyAndOrderFront(self)

    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            mainWindowController?.showWindow(self)
            mainWindowController?.window?.makeKeyAndOrderFront(self)
        }
        
        return true
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }
    
    // MARK: - Actions
    // These are here because if the window is closed `ViewController` can't be first responder :(
    
    @objc func playPause(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.playPause), with: nil, waitUntilDone: true)
    }
    
    @objc func nextTrack(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.nextTrack), with: nil, waitUntilDone: true)
    }
    
    @objc func previousTrack(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.previousTrack), with: nil, waitUntilDone: true)
    }
    
    @objc func likeTrack(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.likeTrack), with: nil, waitUntilDone: true)
    }
    
    @objc func dislikeTrack(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.dislikeTrack), with: nil, waitUntilDone: true)
    }
    
    @objc func repeatTracks(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.repeatTracks), with: nil, waitUntilDone: true)
    }
    
    @objc func shuffleTracks(_ sender: Any?) {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.shuffleTracks), with: nil, waitUntilDone: true)
    }
    
}

