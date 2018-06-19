# MediaKeyTap

`MediaKeyTap` provides an API for accessing the Mac's media keys (play/pause, next and previous) in your Swift application.
`MediaKeyTap` will only capture key events when it is the most recently activated media application, matching the behaviour of
existing applications, such as those using `SPMediaKeyTap`.

`MediaKeyTap` builds its whitelist by combining the static whitelist from `SPMediaKeyTap` with a dynamic whitelist built
at runtime using `NSDistributedNotificationCenter`. If you create a new application using this library, you should not
need to add your bundle identifier to the whitelist.

## Usage

Create a `MediaKeyTap`:
```swift
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    ⋮

    var mediaKeyTap: MediaKeyTap?

    func applicationDidFinishLaunching(aNotification: Notification) {
        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()
    }

    ⋮
}
```

and implement `MediaKeyTapDelegate`'s 1 method:
```swift
func handle(mediaKey: MediaKey, event: KeyEvent) {
    switch mediaKey {
    case .playPause:
        print("Play/pause pressed")
    case .previous, .rewind:
        print("Previous pressed")
    case .next, .fastForward:
        print("Next pressed")
    }
}
```

You can also access the `KeyEvent` to access the event's underlying `keycode`, `keyFlags` and `keyRepeat` values.

The MediaKeyTap initialiser allows the keypress behaviour to be specified:
```swift
    MediaKeyTap(delegate: self, on: .keyDown) // Default
    MediaKeyTap(delegate: self, on: .keyUp)
    MediaKeyTap(delegate: self, on: .keyDownAndUp)
```

## Requirements

* In order to capture key events globally, your application cannot be sandboxed or you will not receive any events.

## Installation

### CocoaPods

Add `pod 'MediaKeyTap'` to your `Podfile` and run `pod install`.

Then `import MediaKeyTap`.

### Carthage

Add `github "nhurden/MediaKeyTap"` to your `Cartfile` and run `carthage update`.
