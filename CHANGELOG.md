# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Apple Silicon support. [#149](https://github.com/steve228uk/YouTube-Music/pull/149)
* Deeply integrated support for Touch Bar on MacBook Pro. [#146](https://github.com/steve228uk/YouTube-Music/pull/146)
* Alternative global shortcut keys for controlling music playback. [#140](https://github.com/steve228uk/YouTube-Music/pull/140)

## [1.1.1] - 2021-04-27

### Fixes

* Media control keys not responding on newer versions of macOS. [#57](https://github.com/steve228uk/YouTube-Music/pull/57)
* Content not appearing in macOS Big Sur. [#130](https://github.com/steve228uk/YouTube-Music/pull/130)

## [1.1.0] - 2021-04-24

G'day everyone! Tim here! It took a fair few weeks of R&D (including [a PR to fastlane](https://github.com/fastlane/fastlane/pull/18496) itself!), but with Steve's blessing, I've finally managed to remove DevMateKit and replace it with an automated build system around GitHub Actions that will enable creating release updates of YT Music *far* more frequently than before.

This is just a basic release incorporating all of the previous improvements, but now this system in place, hopefully we can start bringing new features and OS support to the app moving forward! Enjoy!

### Added

* A Github Actions automated release pipeline. [#126](https://github.com/steve228uk/YouTube-Music/pull/126)

### Changes

* Set `NSRequiresAquaSystemAppearance` to `false` to enable Dark Mode appearance [#102](https://github.com/steve228uk/YouTube-Music/pull/102)

### Fixes

* Music auto-plays when receiving call. [#58](https://github.com/steve228uk/YouTube-Music/pull/58)
* Enabled media controller commands. [#81](https://github.com/steve228uk/YouTube-Music/pull/81)
* Latest album art being pulled correctly for every new notification. [#84](https://github.com/steve228uk/YouTube-Music/pull/84)
* Too many notifications appearing too often. [#85](https://github.com/steve228uk/YouTube-Music/pull/85)
* App crashes when resizing the window. [#87](https://github.com/steve228uk/YouTube-Music/pull/87)

## [1.0.6] - 2018-07-11

I've changed a few things in this release and it now targets 10.11 for those of you still rocking El Capitan (though you really should think about upgrading at some point 🤭).

### Media Center

This version also adds support for the native media center added in macOS 10.12.2. This means that the Today widget in Notification Center and the media center on Touch Bar devices now fully works!

### Bug Fixes

I've also fixed a bug with the like and dislike shortcuts not always liking the currently playing track.

### Feedback

As always, please leave any feedback or issues on [GitHub](https://github.com/steve228uk/youtube-music) and you can also [follow me on Twitter](https://twitter.com/steve228uk).

## [1.0.5] - 2018-07-06

Hello everyone! This update adds a couple of new features that hopefully make the YT Music experience feel a little more native.

### Keyboard Shortcuts

I've added a number of keyboard shortcuts which can be found in the new "Playback" menu in the Menu Bar. Things like Play/Pause, Next, Previous, Shuffle, Repeat, Like, and Dislike can be found here.

These are also available in the menu on the Dock icon. Right-click or option-click the YT Music icon to find these.

### Notifications

Okay, not everyone will want these and they are on by default. Like any Mac app they can be disabled in System Preferences > Notifications.

For those of you that do want these, you'll get a little banner slide in whenever the track changes. Click the banner to open YT Music or swipe it away with your mouse.

### Feedback

I hope the changes are well received and any feedback or bugs can be reported on Github

## [1.0.4] - 2018-07-02

* Only allows the window to be moved in the toolbar area at the top of the screen.

## [1.0.3] - 2018-06-19

* Added navigation arrows

## [1.0.2] - 2018-06-19

* Fixed issues with windows not displaying correctly

## [1.0.1] - 2018-06-19

* Fixes issue where window wouldn't show on first run
* Added media key support

## [1.0.0] - 2018-06-19

* Initial version of YT Music wrapper

[Unreleased]: https://github.com/steve228uk/YouTube-Music/compare/1.1.1...HEAD
[1.1.1]: https://github.com/steve228uk/YouTube-Music/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/steve228uk/YouTube-Music/compare/1.0.6...1.1.0
[1.0.6]: https://github.com/steve228uk/YouTube-Music/compare/1.0.5...1.0.6
[1.0.5]: https://github.com/steve228uk/YouTube-Music/compare/1.0.4...1.0.5
[1.0.4]: https://github.com/steve228uk/YouTube-Music/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/steve228uk/YouTube-Music/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/steve228uk/YouTube-Music/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/steve228uk/YouTube-Music/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/steve228uk/YouTube-Music/releases/tag/1.0.0
