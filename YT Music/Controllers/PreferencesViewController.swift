//
//  PreferencesViewController.swift
//  YT Music
//
//  Created by Rafael Veronezi on 01/06/22.
//  Copyright © 2022 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var globalPlayPauseCheckbox: NSButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let globalPlayPauseRaw = UserDefaults.standard.integer(forKey: "globalPlayShortcut")
        globalPlayPauseCheckbox.state = NSControl.StateValue(globalPlayPauseRaw)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: self.view.frame.width, height: 200)
    }
    
    // MARK: - Action Methods
    
    @IBAction func globalPlayShortcutToggled(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state.rawValue, forKey: "globalPlayShortcut")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name.PreferencesChanged, object: self)
    }
}

extension NSNotification.Name {
    static let PreferencesChanged = NSNotification.Name(rawValue: "preferencesChanged")
}
