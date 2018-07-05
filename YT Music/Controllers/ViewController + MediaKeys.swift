//
//  ViewController + MediaKeys.swift
//  YT Music
//
//  Created by Stephen Radford on 05/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import MediaKeyTap

extension ViewController: MediaKeyTapDelegate {
    
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
        case.previous, .rewind:
            previousTrack()
            break
        }
    }
    
    @objc func playPause() {
        clickElement(className: "play-pause-button")
    }
    
    @objc func nextTrack() {
        clickElement(className: "next-button")
    }
    
    @objc func previousTrack() {
        clickElement(className: "previous-button")
    }
    
    @objc func likeTrack() {
        clickElement(className: "like")
    }
    
    @objc func dislikeTrack() {
        clickElement(className: "dislike")
    }
    
    @objc func shuffleTracks() {
        clickElement(className: "shuffle")
    }
    
    @objc func repeatTracks() {
        clickElement(className: "repeat")
    }
    
    func clickElement(className: String) {
        let js = "var elements = document.getElementsByClassName('\(className)'); if(elements.length > 0) { elements[0].click(); }";
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
}
