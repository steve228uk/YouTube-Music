//
//  GeneralPreferences.swift
//  YT Music
//
//  Created by Allan Spreys on 27/11/2022.
//  Copyright © 2022 Cocoon Development Ltd. All rights reserved.
//

import Foundation

public enum GeneralPreferences: CaseIterable {
    case pushNotifications

    private var preferenceKey: String {
        switch self {
        case .pushNotifications: return "isEnablePushNotifications"
        }
    }

    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: preferenceKey, default: true)
        }
    }

    func setEnabled(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: preferenceKey)
    }
}
