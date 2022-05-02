//
//  SupportNSTouchBar.swift
//  YT Music
//
//  Created by Paolo Polidori on 08/07/21.
//  Copyright © 2021 Cocoon Development Ltd. All rights reserved.
//
import Cocoa

func presentSystemModal(_ touchBar: NSTouchBar!, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
    if #available(OSX 10.14, *) {
        NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: identifier)
    } else {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: identifier)
    }
}

func presentSystemModal(_ touchBar: NSTouchBar!, placement: Int64, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
    if #available(OSX 10.14, *) {
        NSTouchBar.presentSystemModalTouchBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
    } else {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
    }
}

func minimizeSystemModal(_ touchBar: NSTouchBar!) {
    if #available(OSX 10.14, *) {
        NSTouchBar.minimizeSystemModalTouchBar(touchBar)
    } else {
        NSTouchBar.minimizeSystemModalFunctionBar(touchBar)
    }
}
