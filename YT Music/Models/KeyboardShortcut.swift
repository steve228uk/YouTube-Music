//
//  KeyboardShortcut.swift
//  YT Music
//
//  Created by Rafael Veronezi on 01/06/22.
//  Copyright © 2022 Cocoon Development Ltd. All rights reserved.
//

import Foundation

public enum KeyboardShortcut: CaseIterable {
    case playPause
    case previous
    case next
    
    private var preferenceKey: String {
        switch self {
        case .playPause: return "isEnableGlobalPlayPauseHotkey"
        case .previous: return "isEnableGlobalNextTrackHotkey"
        case .next: return "isEnableGlobalPreviousTrackHotkey"
        }
    }
    
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: preferenceKey, default: true)
        }
    }
    
    func setEnabled(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: preferenceKey)
        UserDefaults.standard.synchronize()
        NSNotification.notifyPreferencesChanged()
    }
}

extension UserDefaults {
    
    public func bool(forKey key: String, default value: Bool) -> Bool {
        if exists(key: key) {
            return bool(forKey: key)
        }
        return value
    }
    
    public func exists(key: String) -> Bool {
        UserDefaults.standard.object(forKey: key) != nil
    }
    
}

extension NSNotification {
    public static func notifyPreferencesChanged() {
        NotificationCenter.default.post(name: NSNotification.Name.PreferencesChanged, object: self)
    }
}

extension NSNotification.Name {
    static let PreferencesChanged = NSNotification.Name(rawValue: "preferencesChanged")
}
