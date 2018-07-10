//
//  MediaCenter.swift
//  YT Music
//
//  Created by Stephen Radford on 05/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import WebKit
import MediaPlayer
import AVFoundation

class MediaCenter: NSObject, WKScriptMessageHandler, NSUserNotificationCenterDelegate {
    
    static let `default` = MediaCenter()
    
    override private init() { }
    
    private var titleChanged = false
    
    private var byChanged = false
    
    let fakePlayer = AVPlayer(url: Bundle.main.url(forResource: "silence", withExtension: "mp3")!)

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
    
    var thumbnail: String? {
        didSet {
            guard oldValue != thumbnail else { return }
            
            guard let thumbnail = thumbnail,
            let thumbnailURL = URL(string: thumbnail) else {
                image = nil
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                self.image = NSImage(contentsOf: thumbnailURL)
            }
        }
    }
    
    var image: NSImage?
    
    var length: TimeInterval = 0
    
    var progress: TimeInterval = 0
    
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
        length = dict["length"] as? TimeInterval ?? 0
        progress = dict["progress"] as? TimeInterval ?? 0
        isPlaying = dict["isPlaying"] as? Bool ?? false
        
        
        sendNotificationIfRequired()
        
        if #available(OSX 10.12.2, *) {
            DispatchQueue.main.async {
                self.setNowPlaying()
            }
        }
    }
    
    /// Sends an `NSUserNotification` regarding the song change.
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
    
    /// Sets the information in `MPNowPlayingInfoCenter`
    @available(OSX 10.12.2, *)
    func setNowPlaying() {
        guard let title = title, let by = by else { return }
        
        // This seems to be working.
        // Required to stop WKWebView stealing control.
        fakePlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        fakePlayer.play()
        
        let components = by.components(separatedBy: " • ")
        
        var info: [String:Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: components[0],
            MPMediaItemPropertyMediaType: MPMediaType.music.rawValue,
            MPMediaItemPropertyPlaybackDuration: length,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: progress
        ]
        
        // Add the album title if there's one
        if components.count > 1 {
            info[MPMediaItemPropertyAlbumTitle] = components[1]
        }
        
        if #available(OSX 10.13.2, *) {
            var artwork: MPMediaItemArtwork?
            
            if let image = image {
                artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 500, height: 500)) { (_) -> NSImage in
                    return image
                }
            }
            
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
        
    }
    
}
