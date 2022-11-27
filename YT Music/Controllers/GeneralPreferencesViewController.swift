//
//  GeneralPreferencesViewController.swift
//  YT Music
//
//  Created by Allan Spreys on 27/11/2022.
//  Copyright © 2022 Cocoon Development Ltd. All rights reserved.
//

import Foundation

class GeneralPreferencesViewController: NSViewController {
    // MARK: - Outlets
    @IBOutlet weak var pushNotificationsCheckbox: NSButton!

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        pushNotificationsCheckbox.state = GeneralPreferences.pushNotifications.isEnabled.asControlState
    }

    // MARK: - actions
    @IBAction func pushNotificationsCheckboxToggled(_ sender: NSButton) {
        GeneralPreferences.pushNotifications.setEnabled(sender.state.rawValue != 0)
    }
}
