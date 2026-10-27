# slides

Flutter slides for the "Build devtools for your app" talk.

```sh
flutter run -d macos   # or -d chrome
```

Platform folders are gitignored by the repo; regenerate them with
`flutter create --platforms=macos,web .` if missing.

Shortcuts: `←`/`→`/`Space`/`PageUp`/`PageDown` navigate, `Home`/`End` jump,
`N` speaker notes, `M` overview grid, `T` cycle theme, `P` presentation mode.

## Presentation mode

`P` turns the window into a presenter view: the slide, with the speaker notes,
a timer and what comes next. With Flutter's experimental multi-window support
enabled, it also opens a second window showing only the slides, for the
audience. This requires Flutter's master channel, and enabling the feature
once (then restart the app):

```sh
flutter config --enable-windowing
```

With windowing enabled, the app creates all of its windows itself, so the
macOS runner must start Flutter without a window. After regenerating
`macos/`, replace `macos/Runner/AppDelegate.swift` with:

```swift
import Cocoa
import FlutterMacOS

/// Starts Flutter without any window: the app creates its windows itself,
/// with Flutter's (experimental) multi-window API. See lib/main.dart.
@main
class AppDelegate: FlutterAppDelegate {
  var engine: FlutterEngine?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Works around a crash on hot restart: the engine closes its windows
    // after disposing their view controllers, and a focused window that closes
    // then notifies its delegate, which reads the disposed controller.
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: nil,
      queue: nil
    ) { notification in
      (notification.object as? NSWindow)?.delegate = nil
    }

    let engine = FlutterEngine(name: "slides", project: nil)
    RegisterGeneratedPlugins(registry: engine)
    engine.run(withEntrypoint: nil)
    self.engine = engine
  }

  // Hot restarts close every window before the app opens its main window
  // again. The app quits itself when its main window is closed instead.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
```

and remove the `MainFlutterWindow` window (and its `mainFlutterWindow`
outlet) from `macos/Runner/Base.lproj/MainMenu.xib`. The `willCloseNotification`
observer works around a crash of Flutter's macOS embedder on hot restart.

Both windows show the same deck, and either one can be used to navigate.

## Side-panel examples

A slide can show an app next to it by setting `SlideData.example` (see
`lib/example_panel.dart`). The screen then splits horizontally, with the slide
laid out on a narrower canvas and the app rendered in a phone frame.

Each slide describes the app's state (e.g. `ShopApp(state: ShopState(...))`),
and consecutive example slides update the same app in place, so moving forward
or backward animates between states. Scrolling (wheel, trackpad, or mouse drag)
works inside the example.

The example can also be clicked through (products, cart, checkout, back
buttons...). Clicks change a copy of the slide's state, which is reset when
moving to another slide.

`lib/src/example_1/` is a small e-commerce app built this way.
