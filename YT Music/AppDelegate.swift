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
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("main")) as? NSWindowController
    }()
    
    lazy var dockMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Play", action: #selector(playPause), keyEquivalent: "Space"))
        menu.addItem(NSMenuItem(title: "Next", action: #selector(nextTrack), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Previous", action: #selector(previousTrack), keyEquivalent: ""))
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
    
    @objc func playPause() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.playPause), with: nil, waitUntilDone: true)
    }
    
    @objc func nextTrack() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.nextTrack), with: nil, waitUntilDone: true)
    }
    
    @objc func previousTrack() {
        mainWindowController?.window?.contentViewController?
            .performSelector(onMainThread: #selector(ViewController.previousTrack), with: nil, waitUntilDone: true)
    }
    
}

