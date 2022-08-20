//
//  PreferencesTabViewController.swift
//  YT Music
//
//  Created by Rafael Veronezi on 01/06/22.
//  Copyright © 2022 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(macOS 11.0, *) {
            tabViewItems[0].image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Keyboard Shortcuts")
        } else {
            tabViewItems[0].image = NSImage(named: NSImage.preferencesGeneralName)
        }
    }
    
}
