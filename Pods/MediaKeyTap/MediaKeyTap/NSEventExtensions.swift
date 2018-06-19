//
//  NSEventExtensions.swift
//  MediaKeyTap
//
//  Created by Nicholas Hurden on 28/09/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Foundation

extension NSEvent {
    var isKeyEvent: Bool {
        return subtype.rawValue == 8
    }

    var keycode: Keycode {
        return Keycode((data1 & 0xffff0000) >> 16)
    }

    var keyEvent: KeyEvent {
        let keyFlags = KeyFlags(data1 & 0x0000ffff)
        let keyPressed = ((keyFlags & 0xff00) >> 8) == 0xa
        let keyRepeat = (keyFlags & 0x1) == 0x1

        return KeyEvent(keycode: keycode, keyFlags: keyFlags, keyPressed: keyPressed, keyRepeat: keyRepeat)
    }

    var isMediaKeyEvent: Bool {
        let mediaKeys = [NX_KEYTYPE_PLAY, NX_KEYTYPE_PREVIOUS, NX_KEYTYPE_NEXT, NX_KEYTYPE_FAST, NX_KEYTYPE_REWIND]
        return isKeyEvent && mediaKeys.contains(keycode)
    }
}
