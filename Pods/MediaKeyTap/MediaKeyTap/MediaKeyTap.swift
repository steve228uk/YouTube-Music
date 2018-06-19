//
//  MediaKeyTap.swift
//  Castle
//
//  Created by Nicholas Hurden on 16/02/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Cocoa

public enum MediaKey {
    case playPause
    case previous
    case next
    case rewind
    case fastForward
}

public enum KeyPressMode {
    case keyDown
    case keyUp
    case keyDownAndUp
}

public typealias Keycode = Int32
public typealias KeyFlags = Int32

public struct KeyEvent {
    public let keycode: Keycode
    public let keyFlags: KeyFlags
    public let keyPressed: Bool     // Will be true after a keyDown and false after a keyUp
    public let keyRepeat: Bool
}

public protocol MediaKeyTapDelegate {
    func handle(mediaKey: MediaKey, event: KeyEvent)
}

public class MediaKeyTap {
    let delegate: MediaKeyTapDelegate
    let mediaApplicationWatcher: MediaApplicationWatcher
    let internals: MediaKeyTapInternals
    let keyPressMode: KeyPressMode

    var interceptMediaKeys: Bool {
        didSet {
            if interceptMediaKeys != oldValue {
                self.internals.enableTap(interceptMediaKeys)
            }
        }
    }

    // MARK: - Setup

    public init(delegate: MediaKeyTapDelegate, on mode: KeyPressMode = .keyDown) {
        self.delegate = delegate
        self.interceptMediaKeys = false
        self.mediaApplicationWatcher = MediaApplicationWatcher()
        self.internals = MediaKeyTapInternals()
        self.keyPressMode = mode
    }

    /// Activate the currently running application
    open func activate() {
        mediaApplicationWatcher.activate()
    }

    /// Start the key tap
    open func start() {
        mediaApplicationWatcher.delegate = self
        mediaApplicationWatcher.start()

        internals.delegate = self
        do {
            try internals.startWatchingMediaKeys()
        } catch let error as EventTapError {
            mediaApplicationWatcher.stop()
            print(error.description)
        } catch {}
    }

    private func keycodeToMediaKey(_ keycode: Keycode) -> MediaKey? {
        switch keycode {
        case NX_KEYTYPE_PLAY: return .playPause
        case NX_KEYTYPE_PREVIOUS: return .previous
        case NX_KEYTYPE_NEXT: return .next
        case NX_KEYTYPE_REWIND: return .rewind
        case NX_KEYTYPE_FAST: return .fastForward
        default: return nil
        }
    }

    private func shouldNotifyDelegate(ofEvent event: KeyEvent) -> Bool {
        switch keyPressMode {
        case .keyDown:
            return event.keyPressed
        case .keyUp:
            return !event.keyPressed
        case .keyDownAndUp:
            return true
        }
    }
}

extension MediaKeyTap: MediaApplicationWatcherDelegate {
    func updateIsActiveMediaApp(_ active: Bool) {
        interceptMediaKeys = active
    }

    // When a static whitelisted app starts, we need to restart the tap to ensure that
    // the dynamic whitelist is not overridden by the other app
    func whitelistedAppStarted() {
        do {
            try internals.restartTap()
        } catch let error as EventTapError {
            mediaApplicationWatcher.stop()
            print(error.description)
        } catch {}
    }
}

extension MediaKeyTap: MediaKeyTapInternalsDelegate {
    func updateInterceptMediaKeys(_ intercept: Bool) {
        interceptMediaKeys = intercept
    }

    func handle(keyEvent: KeyEvent) {
        if let key = keycodeToMediaKey(keyEvent.keycode) {
            if shouldNotifyDelegate(ofEvent: keyEvent) {
                delegate.handle(mediaKey: key, event: keyEvent)
            }
        }
    }

    func isInterceptingMediaKeys() -> Bool {
        return interceptMediaKeys
    }
}
