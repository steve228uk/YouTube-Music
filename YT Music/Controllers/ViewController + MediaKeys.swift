//
//  ViewController + MediaKeys.swift
//  YT Music
//
//  Created by Stephen Radford on 05/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import MediaKeyTap

#if canImport(MediaPlayer)
import MediaPlayer
#endif

extension ViewController: MediaKeyTapDelegate {
    
    func registerRemoteCommands() {
        if #available(OSX 10.12.2, *) {
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.playCommand.addTarget(self, action: #selector(play))
            commandCenter.pauseCommand.addTarget(self, action: #selector(pause))
            commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(playPause))
            commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrack))
            commandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrack))
            commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(seek(_:)))
        } else {
            mediaKeyTap = MediaKeyTap(delegate: self)
            mediaKeyTap?.start()
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
        case.previous, .rewind:
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
