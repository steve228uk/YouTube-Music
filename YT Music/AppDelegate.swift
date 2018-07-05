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
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Play/Pause", action: #selector(ViewController.playPause), keyEquivalent: "Space"))
        menu.addItem(NSMenuItem(title: "Next", action: #selector(ViewController.nextTrack), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Previous", action: #selector(ViewController.previousTrack), keyEquivalent: ""))
        return menu
    }
    
}

