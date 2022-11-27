//
//  HotkeyPreferencesViewController.swift
//  YT Music
//
//  Created by Rafael Veronezi on 01/06/22.
//  Copyright © 2022 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class HotkeyPreferencesViewController: NSViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var globalPlayPauseCheckbox: NSButton!
    @IBOutlet weak var globalNextTrackCheckbox: NSButton!
    @IBOutlet weak var globalPreviousTrackCheckbox: NSButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalPlayPauseCheckbox.state = KeyboardShortcut.playPause.isEnabled.asControlState
        globalNextTrackCheckbox.state = KeyboardShortcut.next.isEnabled.asControlState
        globalPreviousTrackCheckbox.state = KeyboardShortcut.previous.isEnabled.asControlState
    }
    
    // MARK: - Action Methods
    
    @IBAction func globalPlayPauseCheckboxToggled(_ sender: NSButton) {
        KeyboardShortcut.playPause.setEnabled(sender.state.rawValue != 0)
    }
    
    @IBAction func globalNextTrackCheckboxToggled(_ sender: NSButton) {
        KeyboardShortcut.next.setEnabled(sender.state.rawValue != 0)
    }
    
    @IBAction func globalPreviousTrackCheckboxToggled(_ sender: NSButton) {
        KeyboardShortcut.previous.setEnabled(sender.state.rawValue != 0)
    }
    
}

extension Bool {
    
    var asControlState: NSControl.StateValue {
        self ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
}
