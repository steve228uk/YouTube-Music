//
//  ViewController + MediaKeys.swift
//  YT Music
//
//  Created by Stephen Radford on 05/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import MediaKeyTap
import Magnet

#if canImport(MediaPlayer)
import MediaPlayer
#endif

extension ViewController: MediaKeyTapDelegate {
    func registerRemoteCommands() {
        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()
        
        if let keyCombo = KeyCombo(key: .space, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "space", keyCombo: keyCombo) { hotKey in
                self.playPause()
            }
            hotKey.register()
        }
        
        if let keyCombo = KeyCombo(key: .pageUp, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "pageup", keyCombo: keyCombo) { hotKey in
                self.nextTrack()
            }
            hotKey.register()
        }
        
        if let keyCombo = KeyCombo(key: .pageDown, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "pagedown", keyCombo: keyCombo) { hotKey in
                self.previousTrack();
            }
            hotKey.register()
        }
        
        if let keyCombo = KeyCombo(key: .f, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "CommandShiftF", keyCombo: keyCombo) { hotKey in
                self.startSearch();
            }
            hotKey.register()
        }
    }
    
    func handle(mediaKey: MediaKey, event: KeyEvent) {
        guard webView.url?.host == "music.youtube.com" else {
            return
        }
        
        switch mediaKey {
        case .playPause:
            playPause()
            break
        case .next, .fastForward:
            nextTrack()
            break
        case .previous, .rewind:
            previousTrack()
            break
        }
    }
    
    @objc func playPause() {
        clickElement(selector: ".play-pause-button")
    }
    
    @objc func pause() {
        if (MediaCenter.default.isPlaying) {
            clickElement(selector: ".play-pause-button")
        }
    }
    
    @objc func play() {
        if (!MediaCenter.default.isPlaying) {
            clickElement(selector: ".play-pause-button")
        }
    }
    
    @objc func nextTrack() {
        clickElement(selector: ".next-button")
    }
    
    @objc func previousTrack() {
        clickElement(selector: ".previous-button")
    }
    
    @objc func likeTrack() {
        clickElement(selector: ".ytmusic-player-bar .like")
    }
    
    @objc func dislikeTrack() {
        clickElement(selector: ".ytmusic-player-bar .dislike")
    }
    
    @objc func shuffleTracks() {
        clickElement(selector: ".shuffle")
    }
    
    @objc func repeatTracks() {
        clickElement(selector: ".repeat")
    }
    
    @objc func startSearch() {
        let js = "var elem = document.getElementsByTagName('ytmusic-search-box')[0]; elem.setAttribute('opened', '');"
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func clickElement(selector: String) {
        let js = "document.querySelector('\(selector)').click();";
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    @available(OSX 10.12.2, *)
    @objc func seek(_ notification: Any) {
        guard let event = notification as? MPChangePlaybackPositionCommandEvent else { return }
        seek(to: event.positionTime)
    }
    
    func seek(to: TimeInterval) {
        let rounded = Int(round(to))
        let js = "document.querySelector('#movie_player video').currentTime = \(rounded);"
        
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
}
