//
//  MediaApplicationWatcher.swift
//  Castle
//
//  Maintains a list of active media applications.
//
//  Created by Nicholas Hurden on 18/02/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Cocoa

protocol MediaApplicationWatcherDelegate {
    func updateIsActiveMediaApp(_ active: Bool)
    func whitelistedAppStarted()
}

class MediaApplicationWatcher {
    var mediaApps: [NSRunningApplication]
    var delegate: MediaApplicationWatcherDelegate?

    // A set of bundle identifiers that notifications have been received from
    var dynamicWhitelist: Set<String>

    let mediaKeyTapDidStartNotification = "MediaKeyTapDidStart" // Sent on start()
    let mediaKeyTapReplyNotification = "MediaKeyTapReply" // Sent on receipt of a mediaKeyTapDidStartNotification

    init() {
        self.mediaApps = []
        self.dynamicWhitelist = []
    }

    deinit {
        stop()
    }

    /// Activate the currently running application (without an NSNotification)
    func activate() {
        handleApplicationActivation(application: NSRunningApplication.current)
    }

    func start() {
        let notificationCenter = NSWorkspace.shared.notificationCenter

        notificationCenter.addObserver(self,
                                       selector: #selector(applicationLaunched),
                                       name: NSWorkspace.didLaunchApplicationNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(applicationActivated),
                                       name: NSWorkspace.didActivateApplicationNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(applicationTerminated),
                                       name: NSWorkspace.didTerminateApplicationNotification,
                                       object: nil)

        setupDistributedNotifications()
    }

    func stop() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    func setupDistributedNotifications() {
        let distributedNotificationCenter = DistributedNotificationCenter.default()

        // Notify any other apps using this library using a distributed notification
        // deliverImmediately is needed to ensure that backgrounded apps can resign the
        // media tap immediately when new media apps are launched
        let ownBundleIdentifier = Bundle.main.bundleIdentifier

        distributedNotificationCenter.postNotificationName(NSNotification.Name(rawValue: mediaKeyTapDidStartNotification), object: ownBundleIdentifier, userInfo: nil, deliverImmediately: true)

        distributedNotificationCenter.addObserver(forName: NSNotification.Name(rawValue: mediaKeyTapDidStartNotification), object: nil, queue: nil) { notification in
            if let otherBundleIdentifier = notification.object as? String {
                guard otherBundleIdentifier != ownBundleIdentifier else { return }
                self.dynamicWhitelist.insert(otherBundleIdentifier)

                // Send a reply so that the sender knows that this app exists
                distributedNotificationCenter.postNotificationName(NSNotification.Name(rawValue: self.mediaKeyTapReplyNotification), object: ownBundleIdentifier, userInfo: nil, deliverImmediately: true)
            }
        }

        distributedNotificationCenter.addObserver(forName: NSNotification.Name(rawValue: mediaKeyTapReplyNotification), object: nil, queue: nil) { notification in
            if let otherBundleIdentifier = notification.object as? String {
                guard otherBundleIdentifier != ownBundleIdentifier else { return }
                self.dynamicWhitelist.insert(otherBundleIdentifier)
            }
        }
    }

    // MARK: - Notifications

    @objc private func applicationLaunched(_ notification: Notification) {
        if let application = (notification as NSNotification).userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            if inStaticWhitelist(application) && application != NSRunningApplication.current {
                delegate?.whitelistedAppStarted()
            }
        }
    }

    @objc private func applicationActivated(_ notification: Notification) {
        if let application = (notification as NSNotification).userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            guard whitelisted(application) else { return }
            handleApplicationActivation(application: application)
        }
    }

    @objc private func applicationTerminated(_ notification: Notification) {
        if let application = (notification as NSNotification).userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            mediaApps = mediaApps.filter { $0 != application }
            updateKeyInterceptStatus()
        }
    }

    // When activated, move `application` to the front of `mediaApps` and toggle the tap as necessary
    private func handleApplicationActivation(application: NSRunningApplication) {
        mediaApps = mediaApps.filter { $0 != application }
        mediaApps.insert(application, at: 0)
        updateKeyInterceptStatus()
    }

    private func updateKeyInterceptStatus() {
        guard mediaApps.count > 0 else { return }

        let activeApp = mediaApps.first!
        let ownApp = NSRunningApplication.current

        delegate?.updateIsActiveMediaApp(activeApp == ownApp)
    }

    // MARK: - Identifier Whitelist

    // The static SPMediaKeyTap whitelist
    func whitelistedApplicationIdentifiers() -> Set<String> {
        var whitelist: Set<String> = [
            "at.justp.Theremin",
            "co.rackit.mate",
            "com.Timenut.SongKey",
            "com.apple.Aperture",
            "com.apple.QuickTimePlayerX",
            "com.apple.iPhoto",
            "com.apple.iTunes",
            "com.apple.iWork.Keynote",
            "com.apple.quicktimeplayer",
            "com.beardedspice.BeardedSpice",
            "com.beatport.BeatportPro",
            "com.bitcartel.pandorajam",
            "com.ilabs.PandorasHelper",
            "com.jriver.MediaCenter18",
            "com.jriver.MediaCenter19",
            "com.jriver.MediaCenter20",
            "com.macromedia.fireworks", // the tap messes up their mouse input
            "com.mahasoftware.pandabar",
            "com.netease.163music",
            "com.plexsquared.Plex",
            "com.plug.Plug",
            "com.plug.Plug2",
            "com.soundcloud.desktop",
            "com.spotify.client",
            "com.ttitt.b-music",
            "fm.last.Last.fm",
            "fm.last.Scrobbler",
            "org.clementine-player.clementine",
            "org.niltsh.MPlayerX",
            "org.quodlibet.quodlibet",
            "org.videolan.vlc",
            "ru.ya.themblsha.YandexMusic"
        ]

        if let ownIdentifier = Bundle.main.bundleIdentifier {
            whitelist.insert(ownIdentifier)
        }

        return whitelist
    }

    private func inStaticWhitelist(_ application: NSRunningApplication) -> Bool {
        return (whitelistedApplicationIdentifiers().contains <^> application.bundleIdentifier) ?? false
    }

    private func inDynamicWhitelist(_ application: NSRunningApplication) -> Bool {
        return (dynamicWhitelist.contains <^> application.bundleIdentifier) ?? false
    }

    private func whitelisted(_ application: NSRunningApplication) -> Bool {
        return inStaticWhitelist(application) || inDynamicWhitelist(application)
    }
}
