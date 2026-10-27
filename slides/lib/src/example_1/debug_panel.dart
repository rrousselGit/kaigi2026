// The example app is hardcoded demo content.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:material_ui/material_ui.dart';

import '../../theme.dart';
import 'models.dart';

enum DebugTab { settings, users, network }

/// The state of the [ShopApp]'s in-app debug panel.
@immutable
class ShopDebug {
  const ShopDebug({
    this.open = false,
    this.tab = DebugTab.settings,
    this.brightness = Brightness.light,
    this.textScale = 1,
    this.userQuery = '',
    this.user,
  });

  final bool open;
  final DebugTab tab;
  final Brightness brightness;
  final double textScale;

  /// What the test users are filtered by.
  final String userQuery;

  /// The email of the test user logged in from the panel, if any.
  final String? user;

  ShopDebug copyWith({
    bool? open,
    DebugTab? tab,
    Brightness? brightness,
    double? textScale,
    String? user,
  }) {
    return ShopDebug(
      open: open ?? this.open,
      tab: tab ?? this.tab,
      brightness: brightness ?? this.brightness,
      textScale: textScale ?? this.textScale,
      userQuery: userQuery,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShopDebug &&
      other.open == open &&
      other.tab == tab &&
      other.brightness == brightness &&
      other.textScale == textScale &&
      other.userQuery == userQuery &&
      other.user == user;

  @override
  int get hashCode =>
      Object.hash(open, tab, brightness, textScale, userQuery, user);
}

/// An account of the test backend, and the app state logging in shows.
class TestUser {
  const TestUser(this.email, this.traits, this.state);

  final String email;
  final List<String> traits;
  final ShopState state;
}

const testUsers = [
  TestUser(
    'alice@test.dev',
    ['3 items in cart', 'Premium'],
    ShopState(
      cart: [CartItem('headphones'), CartItem('speaker', quantity: 2)],
      cartOpen: true,
    ),
  ),
  TestUser('bob@test.dev', ['New user'], ShopState()),
  TestUser('carol@test.dev', [
    '1 item in cart',
    'Order placed',
  ], ShopState(cart: [CartItem('watch')], cartOpen: true)),
  TestUser('dan@test.dev', ['Premium'], ShopState()),
];

/// The requests the app made, as the network tab lists them.
const _requests = [
  ('GET', '/products', 200, 84),
  ('GET', '/products/headphones', 200, 41),
  ('POST', '/cart', 201, 120),
  ('GET', '/cart', 200, 38),
  ('POST', '/checkout', 402, 210),
];

/// Colors of the debug panel, which looks like a devtool rather than the app.
abstract final class _Colors {
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const border = Color(0xFF334155);
  static const text = Color(0xFFF1F5F9);
  static const muted = Color(0xFF94A3B8);
  static const accent = Color(0xFF22D3EE);
  static const success = Color(0xFF4ADE80);
  static const error = Color(0xFFF87171);
}

/// The button opening the debug panel, floating over the app.
class DebugButton extends StatelessWidget {
  const DebugButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _Colors.background,
          shape: BoxShape.circle,
          border: Border.all(color: _Colors.accent, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x5522D3EE), blurRadius: 16),
          ],
        ),
        child: const Text('🐞', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

/// The in-app debug panel: theme and text size, test users, and requests.
class DebugPanel extends StatelessWidget {
  const DebugPanel({
    super.key,
    required this.debug,
    required this.onChanged,
    required this.onLogin,
  });

  final ShopDebug debug;
  final ValueChanged<ShopDebug> onChanged;
  final ValueChanged<TestUser> onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: _Colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: _Colors.accent, width: 2)),
        boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 24)],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: Fonts.body,
          color: _Colors.text,
          fontSize: 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  '🐞 Debug',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onChanged(debug.copyWith(open: false)),
                  child: const Icon(
                    Icons.close_rounded,
                    color: _Colors.muted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Segments(
              value: debug.tab,
              options: const [
                (DebugTab.settings, 'Settings'),
                (DebugTab.users, 'Users'),
                (DebugTab.network, 'Network'),
              ],
              onChanged: (tab) => onChanged(debug.copyWith(tab: tab)),
            ),
            const SizedBox(height: 16),
            switch (debug.tab) {
              DebugTab.settings => _Settings(
                debug: debug,
                onChanged: onChanged,
              ),
              DebugTab.users => _Users(
                query: debug.userQuery,
                onLogin: onLogin,
              ),
              DebugTab.network => const _Network(),
            },
          ],
        ),
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({required this.debug, required this.onChanged});

  final ShopDebug debug;
  final ValueChanged<ShopDebug> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, Widget control) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: _Colors.muted)),
          ),
          Expanded(child: control),
        ],
      ),
    );

    return Column(
      children: [
        row(
          'Theme',
          _Segments(
            value: debug.brightness,
            options: const [
              (Brightness.light, 'Light'),
              (Brightness.dark, 'Dark'),
            ],
            onChanged: (brightness) =>
                onChanged(debug.copyWith(brightness: brightness)),
          ),
        ),
        row(
          'Text size',
          _Segments(
            value: debug.textScale,
            options: const [(1.0, '100%'), (1.3, '130%'), (1.6, '160%')],
            onChanged: (textScale) =>
                onChanged(debug.copyWith(textScale: textScale)),
          ),
        ),
      ],
    );
  }
}

class _Users extends StatelessWidget {
  const _Users({required this.query, required this.onLogin});

  final String query;
  final ValueChanged<TestUser> onLogin;

  @override
  Widget build(BuildContext context) {
    final matches = [
      for (final user in testUsers)
        if (user.traits.any((trait) => trait.contains(query))) user,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _Colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _Colors.border),
          ),
          child: Row(
            spacing: 8,
            children: [
              const Icon(Icons.search_rounded, color: _Colors.muted, size: 18),
              Text(query.isEmpty ? 'Find a test user…' : query),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final user in matches)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _Colors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final trait in user.traits)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _Colors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                trait,
                                style: const TextStyle(
                                  color: _Colors.accent,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onLogin(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _Colors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: _Colors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Network extends StatelessWidget {
  const _Network();

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: Fonts.code, fontSize: 12.5);
    return Column(
      children: [
        for (final (method, path, status, duration) in _requests)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: status >= 400
                  ? _Colors.error.withValues(alpha: 0.12)
                  : _Colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: status >= 400 ? _Colors.error : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    method,
                    style: mono.copyWith(
                      color: _Colors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Text(path, style: mono)),
                Text(
                  '$status',
                  style: mono.copyWith(
                    color: status >= 400 ? _Colors.error : _Colors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${duration}ms',
                    textAlign: TextAlign.right,
                    style: mono.copyWith(color: _Colors.muted),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Mutually exclusive options, like a segmented button.
class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final (option, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: option == value
                        ? _Colors.accent.withValues(alpha: 0.2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: option == value ? _Colors.accent : _Colors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A banner confirming which test user the app is logged in as.
class LoggedInBanner extends StatelessWidget {
  const LoggedInBanner({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _Colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          const Text('🐞'),
          Text(
            'Logged in as $email',
            style: const TextStyle(
              fontFamily: Fonts.body,
              color: _Colors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
