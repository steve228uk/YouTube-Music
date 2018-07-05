//
//  MediaCenter.swift
//  YT Music
//
//  Created by Stephen Radford on 05/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import WebKit

class MediaCenter: NSObject, WKScriptMessageHandler, NSUserNotificationCenterDelegate {
    
    static let `default` = MediaCenter()
    
    override private init() { }
    
    private var titleChanged = false
    
    private var byChanged = false
    
    var title: String? {
        didSet {
            titleChanged = title != oldValue
        }
    }
    
    var by: String? {
        didSet {
            byChanged = by != oldValue
        }
    }
    
    var thumbnail: String?
    
    var length: Int = 0
    
    var progress: Int = 0
    
    var isPlaying = false {
        didSet {
            (NSApp.delegate as? AppDelegate)?.dockMenu.item(at: 0)?.title = isPlaying ? "Pause" : "Play"
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String:Any] else { return }
        
        title = dict["title"] as? String
        by = dict["by"] as? String
        thumbnail = dict["thumbnail"] as? String
        length = dict["length"] as? Int ?? 0
        progress = dict["progress"] as? Int ?? 0
        isPlaying = dict["isPlaying"] as? Bool ?? false
        
        sendNotificationIfRequired()
    }
    
    func sendNotificationIfRequired() {
        guard let title = title,
        let by = by,
        let thumbnail = thumbnail,
        let thumbnailURL = URL(string: thumbnail),
        title != "",
        by != "",
        titleChanged || byChanged else {
            return
        }
        
        let notification = NSUserNotification()
        
        notification.title = title
        notification.subtitle = by
        
        notification.contentImage = NSImage(contentsOf: thumbnailURL)
        
        
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
        
        titleChanged = false
        byChanged = false
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        (NSApp.delegate as? AppDelegate)?.mainWindowController?.showWindow(self)
        (NSApp.delegate as? AppDelegate)?.mainWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
}
