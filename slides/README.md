# slides

Flutter slides for the "Build devtools for your app" talk.

```sh
flutter run -d macos   # or -d chrome
```

Platform folders are gitignored by the repo; regenerate them with
`flutter create --platforms=macos,web .` if missing.

Shortcuts: `←`/`→`/`Space`/`PageUp`/`PageDown` navigate, `Home`/`End` jump,
`N` speaker notes, `M` overview grid, `T` cycle theme.

## Side-panel examples

A slide can show an app next to it by setting `SlideData.example` (see
`lib/example_panel.dart`). The screen then splits horizontally, with the slide
laid out on a narrower canvas and the app rendered in a phone frame.

Examples are not clickable: each slide describes the app's state (e.g.
`ShopApp(state: ShopState(...))`), and consecutive example slides update the
same app in place, so moving forward or backward animates between states.
Scrolling (wheel, trackpad, or mouse drag) still works inside the example.

`lib/src/example_1/` is a small e-commerce app built this way.
