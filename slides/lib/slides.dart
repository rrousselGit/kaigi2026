// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'src/example_1/debug_panel.dart';
import 'src/example_1/models.dart';
import 'src/example_1/shop_app.dart';
import 'src/example_1/state_inspector.dart';
import 'src/site_map/review_comment.dart';
import 'src/site_map/shoply.dart';
import 'src/site_map/site_map.dart';
import 'src/site_map/site_map_view.dart';
import 'theme.dart';
import 'widgets.dart';

class SlideData {
  const SlideData({
    required this.title,
    required this.topic,
    required this.notes,
    required this.child,
    this.example,
    this.group,
    this.steps = 0,
  });

  /// The title shown in the overview grid.
  final String title;
  final Topic topic;
  final String notes;
  final Widget child;

  /// An app shown next to the slide, in a phone frame.
  ///
  /// Consecutive slides with the same type of example share one instance of
  /// it, so the example animates from one slide's state to the next.
  final Widget? example;

  /// Consecutive slides of the same group share one instance of [child]:
  /// moving between them updates it in place instead of cross-fading, so it
  /// can animate between the states that each slide describes.
  final Object? group;

  /// How many times "next" reveals more of [child] before moving to the next
  /// slide. See [Reveal].
  final int steps;
}

const _testingTipLintDont = '''
// test/my_lint_test.dart
@reflectiveTest
class MyLintTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'my_lint';

  Future<void> test_badCase() async {
    await assertDiagnostics(r\'\'\'
class GoodCase {}

class BadCase {}
\'\'\', [lint(25, 7)]);
  }
}''';

const _testingTipLintDo = '''
// test/lint.dart
class GoodCase {}

// ignore: my_lint/code
class BadCase {}''';

const _testingTipLintOptions = '''
# test/analysis_options.yaml
plugins:
  my_lint:
    path: ../
    diagnostics:
      code: true
linter:
  rules:
    - unnecessary_ignore''';

const _lintPrompt = '''
Add a lint rule `avoid_hardcoded_string`, reporting
string literals shown to users.

- Implement it with package:analysis_server_plugin.
- Test it with Dart files in test/lints/, using
  ignore comments where the lint should trigger.
- Run it on the app and generate a baseline file of
  the existing violations, so only new code fails.''';

const _lintBaseline = '''
# lint_baseline.yaml
# generated once: entries may only be removed
avoid_hardcoded_string:
  lib/screens/cart.dart: 4
  lib/screens/checkout.dart: 7
  lib/widgets/promo_banner.dart: 2''';

const _regexLint = '''
// ❌ What AIs write if you let them
RegExp(r"Text\\('[^']*'\\)")

// ✅ Visit the analyzed code instead
class _Visitor extends RecursiveAstVisitor<void> {
  @override
  void visitStringLiteral(StringLiteral node) {...}
}''';

const _testLint = '''
// test/hardcoded_strings_test.dart
test('widgets have no hardcoded strings', () async {
  for (final file in dartFiles('lib/')) {
    final unit = await resolve(file);
    expect(hardcodedStrings(unit), isEmpty);
  }
});''';

const _skillFile = '''
---
name: no-hardcoded-strings
description: Use when editing widgets.
---

Never put user-facing text in widgets.
Use `context.l10n` instead.

Before finishing, check every `Text(...)`
you added or changed.''';

const _lintRule = '''
class AvoidHardcodedString extends AnalysisRule {
  AvoidHardcodedString() : super(
    name: 'avoid_hardcoded_string',
    description: 'Use context.l10n instead.',
  );

  @override
  void registerNodeProcessors(registry, context) {
    registry.addSimpleStringLiteral(this, _Visitor(this));
  }
}''';

const _buttonSource = '''
@Route('/catalog')
class CatalogPage extends StatelessWidget {
  const CatalogPage();

  @override
  Widget build(BuildContext context) {
    return Link(
      route: DetailPageRoute.route,
      params: DetailPageArgs(id: 'headphones'),
      child: ProductTile('headphones'),
    );
  }
}''';

const _mermaidSiteMap = '''
graph LR
  Catalog --> Product
  Catalog --> Cart
  Product --> Cart
  Cart --> Checkout
  Checkout --> OrderPlaced
  OrderPlaced --> Catalog''';

const _constSnippet = '''
final path = '/\${config.catalog}'; // Only known at runtime
const path = '/catalog'; // Readable by the analyzer''';

const _annotationSnippet = '''
@Route('/catalog') // Readable by the analyzer
class CatalogPage extends StatelessWidget {}''';

const _filesSnippet = '''
lib/pages/cart/cart_page.dart
lib/pages/cart/cart_page.fake.dart // Always next to its page
lib/pages/checkout/checkout_page.dart''';

const _fieldsSnippet = '''
l10n.translate('cart.empty') // A string: opaque
l10n.cartEmpty // A field: typed, and searchable''';

const _vmServiceSnippet = '''
final service = await vmServiceConnectUri(uri);

// Run any expression in the running app.
await service.evaluate(
  isolateId,
  libraryId,
  'deck.goTo(42)',
);''';

const _demoCart = [CartItem('headphones'), CartItem('speaker', quantity: 2)];

/// A getter rather than a variable, so that hot reload picks up edits to the
/// slides: Dart does not re-run the initializer of global variables.
List<SlideData> get slides => const <SlideData>[
  SlideData(
    title: 'Title Slide',
    topic: Topic.intro,
    notes:
        'When I wrote the description for this talk, originally I planned on '
        'just talking about how to write Flutter DevTool extensions like the '
        'Riverpod extension with time travel. But the more I use AI, the more '
        'I realize: lots of developers are deferring programming to AI now.',
    child: _TitleSlide(),
  ),
  SlideData(
    title: 'Original Plan vs AI Reality',
    topic: Topic.intro,
    notes:
        'Lots of you now delegate a big part of the programming to AI. '
        'Explaining how to hand-write a devtool extension feels awkward: you '
        "probably aren't running tools yourself anymore, your agent is. So this "
        'talk is about building tools in the AI era, and why we need them more '
        'than ever.',
    child: _ImageSlide(
      title: 'The Original Plan vs. The AI Reality',
      child: FramedImage(
        'assets/img/elephant.png',
        aspectRatio: 1280 / 719,
        maxHeight: 480,
      ),
    ),
  ),
  SlideData(
    title: 'Two Kinds of Software',
    steps: 2,
    topic: Topic.intro,
    notes:
        "A lint, a CLI or a debug panel doesn't need the care of production "
        'code. A prompt and a quick check is enough. What used to be a '
        'week-long side project is now an afternoon.',
    child: ContentSlide(
      title: 'Two Kinds of Software',
      children: [
        Grid(
          columns: 2,
          gap: 40,
          children: [
            Reveal(
              1,
              child: _SoftwareKind(
                title: 'Shipped to users',
                verdict: 'Expensive and slow',
                color: Hues.roseLight,
                illustration: _ShippedIllustration(),
                metrics: [
                  ('Users', 'Thousands', 1),
                  ('Devices', 'Unknown', 0.95),
                  ('Review', 'Every line', 1),
                  ('Cost of a bug', 'High', 0.9),
                ],
              ),
            ),
            Reveal(
              2,
              child: _SoftwareKind(
                title: 'Internal tools',
                verdict: 'Cheap. Let AI write it.',
                color: Hues.emeraldLight,
                illustration: _InternalIllustration(),
                metrics: [
                  ('Users', 'A handful of devs', 0.08),
                  ('Devices', 'Known machines', 0.12),
                  ('Review', 'Barely', 0.15),
                  ('Cost of a bug', 'A restart', 0.08),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  SlideData(
    title: 'Vibe Coded Devtools',
    topic: Topic.intro,
    notes:
        'Which is why I am perfectly happy to vibe code devtools, while I would '
        'never ship a vibe coded app to users.',
    child: _ImageSlide(
      child: FramedImage(
        'assets/img/vibe_coded_devtools.png',
        aspectRatio: 1,
        maxHeight: 520,
      ),
    ),
  ),
  SlideData(
    title: 'Worth Building Complex Tools',
    steps: 2,
    topic: Topic.intro,
    notes:
        'This is the thesis of the talk. The asymmetry from the previous slide '
        'means we can be much less picky about which tools are worth building. '
        'Not one big devtool per year, but dozens of small, cheap tools, each '
        'removing one bit of maintenance friction. The rest of the talk is '
        'about which ones, and how to make them pay off.',
    child: _BuildALotSlide(),
  ),
  SlideData(
    title: 'Turn Review Comments into Tools',
    steps: 1,
    topic: Topic.why,
    notes:
        'When you write the same review comment for the third time, stop. '
        'That comment should become a pull request adding a tool. Here a lint, '
        'but the same goes for any repeated friction. Then nobody has to '
        'write, or read, that comment ever again.',
    child: _ReviewToLintSlide(),
  ),
  SlideData(
    title: 'DRY Applies to More Than Code',
    steps: 3,
    topic: Topic.why,
    notes:
        'Each review comment turned into a tool is one less thing to '
        'remember. Over time, the rules of the codebase live in CI, not in the '
        'heads of a few senior engineers.',
    child: _ProgressiveImprovementSlide(),
  ),
  SlideData(
    title: 'Prompt or Program?',
    steps: 9,
    topic: Topic.why,
    notes:
        'Every tool now competes with "why not just write a skill?". Skills '
        'are easy, but probabilistic: mistakes slip through and pile up. A '
        'lint rule sounds scary, but we just saw that tools are cheap now.',
    child: ContentSlide(
      title: 'Prompt or Program?',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  H3('📝 A skill'),
                  CodeBlock(_skillFile, fontSize: 14),
                  SizedBox(height: 16),
                  _ProsCons(
                    firstStep: 1,
                    pros: ['**Dead easy** to write'],
                    cons: [
                      '**Non-deterministic**: skips cases, changes with the '
                          'model',
                      '**Context bloat**',
                      '**Pays tokens** on every run',
                    ],
                  ),
                ],
              ),
            ),
            Reveal(
              5,
              child: DeckCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    H3('⚙️ A specialized devtool'),
                    CodeBlock(_lintRule, fontSize: 14),
                    SizedBox(height: 16),
                    _ProsCons(
                      firstStep: 6,
                      pros: [
                        '**Deterministic**',
                        '**Zero context**',
                        '**Zero cost**',
                      ],
                      cons: ['**Sounds scary to build**, but AI can write it'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  SlideData(
    title: 'Same Prompt, Two Agents',
    steps: 2,
    topic: Topic.why,
    notes:
        'Same prompt, same model. On the left, the agent figures things out '
        'on its own: it reads file after file, greps, reads some more, and '
        'still misses a few. On the right, it runs the lint and reads the '
        'result. Now multiply by every PR, forever. Even "only scan modified '
        "files\" is English, and English is fuzzy: you're not watching what "
        'your agent reads.',
    child: ContentSlide(
      title: 'Same Prompt, Two Agents',
      children: [
        Grid(
          columns: 2,
          gap: 32,
          children: [
            _AgentRun(
              title: 'Figuring it out',
              color: Hues.roseLight,
              revealDuration: Duration(seconds: 6),
              seconds: 167,
              tokens: 214000,
              lines: [
                '• Read(lib/screens/cart.dart)',
                '• Read(lib/screens/checkout.dart)',
                '• Read(lib/widgets/promo_banner.dart)',
                '• Grep("[\'\\"]", lib/)',
                '  -> 412 matches',
                '• Read(lib/l10n/strings.dart)',
                '• Read(lib/screens/product.dart)',
                '  … 23 more reads',
                'Found 11 hardcoded strings.',
              ],
            ),
            _AgentRun(
              title: 'Using a lint',
              color: Hues.emeraldLight,
              revealDuration: Duration(milliseconds: 900),
              seconds: 6,
              tokens: 2100,
              lines: [
                '• Bash(dart analyze)',
                '  -> cart.dart:42 avoid_hardcoded_string',
                '  -> checkout.dart:18 avoid_hardcoded_string',
                '  -> … 11 more',
                'Found 13 hardcoded strings.',
              ],
            ),
          ],
        ),
        Reveal(
          2,
          child: Callout(
            '**On every PR, forever.** And the one figuring it out missed two.',
            top: 24,
          ),
        ),
      ],
    ),
  ),
  SlideData(
    title: 'Two Kinds of Devtools',
    steps: 1,
    topic: Topic.staticTools,
    notes:
        'Most devtools fall into two families. Static tools read the code, '
        'without running it: lints, generators, CI checks. They are built on '
        'package:analyzer, which knows what every identifier refers to. '
        'Runtime tools look at the running app instead, through '
        "package:vm_service. Let's start with static tools.",
    child: _DevtoolKindsSlide(focus: _DevtoolKind.static, highlight: 'Lints'),
  ),
  SlideData(
    title: 'Tool: Custom Lints',
    steps: 8,
    topic: Topic.lints,
    notes:
        'Personal note: I highly recommend every project implement custom '
        'lint rules. You can automate a significant part of your styleguide in '
        'a few hours.',
    child: _CustomLintsSlide(),
  ),
  SlideData(
    title: 'Lints: Things to Note',
    steps: 6,
    topic: Topic.lints,
    notes:
        "Two things. First, don't let your AI parse Dart with regexes: it "
        'will miss multi-line strings, comments, interpolation. Ask it to use '
        'package:analyzer, which knows what is a string and what is a widget. '
        "Second, you don't have to build an actual lint plugin. A plain test "
        'that analyzes the source does the same job in CI and for agents. It '
        "is less readable for humans, since nothing shows in the IDE, but it "
        'has no RAM cost.',
    child: ContentSlide(
      title: 'Things to Note',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  H3("Don't parse Dart with regexes"),
                  CodeBlock(_regexLint, fontSize: 14),
                  SizedBox(height: 16),
                  _ProsCons(
                    firstStep: 1,
                    pros: ['**package:analyzer**: a resolved, typed AST'],
                    cons: [
                      'Regexes miss multi-line strings, comments, '
                          'interpolation…',
                    ],
                  ),
                ],
              ),
            ),
            Reveal(
              3,
              child: DeckCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    H3('A test can be a lint too'),
                    CodeBlock(_testLint, fontSize: 14),
                    SizedBox(height: 16),
                    _ProsCons(
                      firstStep: 4,
                      pros: [
                        '**No RAM cost**: no plugin running in the IDE',
                        'Still runs in **CI and for agents**',
                      ],
                      cons: ['Less human readable: nothing shows in the IDE'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  SlideData(
    title: 'Testing Tip: Custom Lints',
    steps: 1,
    topic: Topic.lints,
    notes: 'Testing tip for custom lints.',
    child: BadgeCardSlide(
      maxWidth: 1000,
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      children: [
        BadgeTitle('Testing Tip: Custom Lints', bottom: 20),
        Grid(
          columns: 2,
          gap: 24,
          children: [
            _DoDontCard(dont: true, code: _testingTipLintDont),
            Reveal(
              1,
              child: _DoDontCard(
                dont: false,
                code: _testingTipLintDo,
                secondCode: _testingTipLintOptions,
                footer:
                    'Then run `dart analyze`. A missing warning makes the '
                    '`ignore` [unnecessary](https://dart.dev/tools/linter-rules/unnecessary_ignore).',
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Md(
          '[Example from riverpod_lint](https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_lint_flutter_test/test/lints/avoid_build_context_in_providers.dart)',
          style: TextStyle(fontSize: 14.4),
        ),
      ],
    ),
  ),
  SlideData(
    title: 'Tool: Quick Fixes',
    steps: 8,
    topic: Topic.lints,
    notes:
        'Quick fixes go along lint rules: an automated fix for the warning. '
        'On the left, a fix you wrote: deterministic and instant. But agents '
        "can't use it, and it isn't context aware: it does one thing, the same "
        'way every time. On the right, '
        'you just tell the agent to fix the warnings, and it adapts to the '
        'situation. So for '
        'in-house lints, skip the fixes. They are worth it when publishing a '
        'package used by thousands of developers.',
    child: _QuickFixSlide(),
  ),
  SlideData(
    title: 'Lints: Baselines',
    steps: 2,
    topic: Topic.lints,
    notes:
        'A new lint on an old codebase reports hundreds of warnings. Instead of '
        'fixing them all before merging, record them in a baseline: the lint '
        'ignores those, and only reports new code.',
    group: #baseline,
    child: _BaselineSlide(),
  ),
  SlideData(
    title: 'Danger: Never Grow the Baseline',
    topic: Topic.lints,
    notes:
        'The one rule of baselines: once created, they only shrink. '
        'Regenerating the baseline to silence a new warning defeats the lint. '
        'Have CI fail if the baseline gains entries.',
    group: #baseline,
    child: _BaselineSlide(showDanger: true),
  ),
  SlideData(
    title: 'Pro Tip: Generate Lints with AI',
    steps: 3,
    topic: Topic.lints,
    notes:
        'Writing a lint used to take an afternoon of reading analyzer docs. '
        'Now it is a prompt. Be specific: name analysis_server_plugin, ask '
        'for tests, and ask for a baseline of existing violations.',
    child: ContentSlide(
      title: 'Generate Lints with AI',
      children: [
        Grid(
          columns: 2,
          children: [
            CodeBlock(_lintPrompt, fontSize: 15),
            DeckCard(
              child: _CardContent(
                title: 'Be specific',
                firstStep: 1,
                items: [
                  'Name **`analysis_server_plugin`**: otherwise AIs often '
                      'reach for other approaches.',
                  'Ask for **tests**, written as code with `// ignore` '
                      'comments.',
                  'Ask for a **baseline file** of the existing violations, '
                      'so that the lint can land today.',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  SlideData(
    title: 'Built for Tools',
    topic: Topic.architecture,
    steps: 3,
    notes:
        'Lints check the code. But design decisions decide what tools can do '
        'at all: a few of them make the code readable by the analyzer. '
        "None of them is about tools. Let's go through them, then see what "
        'they enable on a real app.',
    child: _BuiltForToolsSlide(),
  ),
  SlideData(
    title: 'Example: Shoply',
    topic: Topic.staticTools,
    group: #meetShoply,
    notes: "Here's the app: a small e-commerce app called Shoply. Let's click through it quickly.",
    example: ShopApp(state: ShopState()),
    child: _MeetShoplySlide(page: 'Catalog'),
  ),
  SlideData(
    title: 'Example: Shoply Product',
    topic: Topic.staticTools,
    group: #meetShoply,
    notes: "A product page.",
    example: ShopApp(state: ShopState(productId: 'headphones')),
    child: _MeetShoplySlide(page: 'Product'),
  ),
  SlideData(
    title: 'Example: Shoply Cart',
    topic: Topic.staticTools,
    group: #meetShoply,
    notes: "The cart.",
    example: ShopApp(
      state: ShopState(
        productId: 'headphones',
        cart: _demoCart,
        cartOpen: true,
      ),
    ),
    child: _MeetShoplySlide(page: 'Cart'),
  ),
  SlideData(
    title: 'Example: Shoply Checkout',
    topic: Topic.staticTools,
    group: #meetShoply,
    notes: "Checkout.",
    example: ShopApp(
      state: ShopState(
        productId: 'headphones',
        cart: _demoCart,
        cartOpen: true,
        checkout: CheckoutStep.review,
      ),
    ),
    child: _MeetShoplySlide(page: 'Checkout'),
  ),
  SlideData(
    title: 'Example: Shoply Order Placed',
    topic: Topic.staticTools,
    group: #meetShoply,
    notes: "And the order is placed. Five pages in total.",
    example: ShopApp(
      state: ShopState(
        productId: 'headphones',
        cart: _demoCart,
        cartOpen: true,
        checkout: CheckoutStep.confirmed,
      ),
    ),
    child: _MeetShoplySlide(page: 'Order placed'),
  ),
  SlideData(
    title: 'Example of Custom Architecture to Power Tools',
    topic: Topic.staticTools,
    steps: 2,
    notes:
        'Lints look at one line at a time. But the analyzer can read the whole '
        'app: every page, every button, and which page each button opens. '
        'From that, you can generate anything: an image, a Mermaid graph, a '
        "markdown file. Or something better. Let's see it on Shoply.",
    child: _StaticGoesFurtherSlide(),
  ),
  SlideData(
    title: 'DevTool: Site Map',
    topic: Topic.staticTools,
    group: _SiteMapExample.shoply,
    notes:
        'A first devtool for Shoply: a site map. Every page of the app, what '
        'can be tapped on it, and where each button leads. Like a Figma '
        'prototype, but for the real app. It is static analysis: a form of '
        'codegen. The analyzer reads the routes and the buttons, and the same '
        'graph could just as well be output as an image, a Mermaid graph, or '
        'a markdown file.',
    child: _SiteMapSlide(
      title: 'A Site Map of Shoply',
      example: _SiteMapExample.shoply,
      interactive: false,
    ),
  ),
  SlideData(
    title: 'DevTool: Site Map Screens',
    topic: Topic.staticTools,
    group: _SiteMapExample.shoply,
    notes:
        'The same map, rendering the real pages instead of wireframes. Each '
        'page is filled with fake data, and arrows start from the actual '
        'buttons.',
    child: _SiteMapSlide(
      title: 'A Site Map of Shoply',
      example: _SiteMapExample.shoply,
      previews: true,
      interactive: false,
    ),
  ),
  SlideData(
    title: 'Git Integration',
    topic: Topic.staticTools,
    notes:
        'The site map is generated from the code. And the code lives in git. '
        'So the tool can build the site map of any branch, and compare two of '
        'them: what does this pull request change, for the user?',
    child: _GitIntegrationSlide(),
  ),
  SlideData(
    title: 'DevTool: Review, Before',
    topic: Topic.staticTools,
    group: _SiteMapExample.wishlist,
    notes:
        'Now a pull request adds a wishlist. In the code review, that is four '
        'files of diff. Here is the app before the change...',
    child: _SiteMapSlide(
      title: 'Reviewing a New Page',
      example: _SiteMapExample.wishlist,
      previews: true,
      showBase: true,
    ),
  ),
  SlideData(
    title: 'DevTool: Review, After',
    topic: Topic.staticTools,
    group: _SiteMapExample.wishlist,
    notes:
        '...and after. One new page, and new arrows leading to and from it: '
        'exactly what users will experience differently.',
    child: _SiteMapSlide(
      title: 'Reviewing a New Page',
      example: _SiteMapExample.wishlist,
      previews: true,
    ),
  ),
  SlideData(
    title: 'DevTool: Spot the Change',
    topic: Topic.staticTools,
    group: _SiteMapExample.buyNow,
    notes:
        'Another pull request. This time, no new page: existing pages '
        'changed. Can you spot what changed?',
    child: _SiteMapSlide(
      title: 'Can You Spot the Change?',
      example: _SiteMapExample.buyNow,
      previews: true,
    ),
  ),
  SlideData(
    title: 'DevTool: Highlighted Changes',
    topic: Topic.staticTools,
    group: _SiteMapExample.buyNow,
    notes:
        'With highlighting, the tool answers for you: Product gained a "Buy '
        'now" button straight to Checkout, and Checkout an "Edit cart" button '
        'back to the cart. Users can now skip the cart entirely.',
    child: _SiteMapSlide(
      title: 'Highlighting the Change',
      example: _SiteMapExample.buyNow,
      previews: true,
      highlight: true,
    ),
  ),
  SlideData(
    title: 'DevTool: In Code Review',
    topic: Topic.staticTools,
    notes:
        'Tools like this one belong in CI too. On every pull request, render '
        'the site map, check that every page still renders and can be '
        'reached, and post the visual diff where the review happens. '
        'Reviewers see what users will see, not just lines of code.',
    child: _CodeReviewSlide(),
  ),
  SlideData(
    title: 'Two Kinds of Devtools: Runtime',
    topic: Topic.runtimeTools,
    steps: 1,
    notes:
        "Now the other family: runtime tools. They don't read the code, they "
        'look at the app while it runs. Either from inside the app, like a '
        'debug panel, or from outside, through package:vm_service like the '
        'debugger. Our first example: switching the theme of the running app.',
    child: _DevtoolKindsSlide(
      focus: _DevtoolKind.runtime,
      highlight: 'Theme switcher',
    ),
  ),
  SlideData(
    title: 'DevTool: Site Map Dark Mode',
    topic: Topic.runtimeTools,
    group: _SiteMapExample.shoply,
    notes:
        'The same pages, rendered in dark mode: every screen of the app '
        'checked at once, without clicking through the app on a device.',
    child: _SiteMapSlide(
      title: 'Sandbox: Dark Mode',
      example: _SiteMapExample.shoply,
      previews: true,
      settings: PreviewSettings(brightness: Brightness.dark),
    ),
  ),
  SlideData(
    title: 'DevTool: Site Map Large Text',
    topic: Topic.runtimeTools,
    group: _SiteMapExample.shoply,
    notes:
        'And with a large font, as set by users who need it. Layout issues '
        'show up on every page at once.',
    child: _SiteMapSlide(
      title: 'Sandbox: Large Text',
      example: _SiteMapExample.shoply,
      previews: true,
      settings: PreviewSettings(brightness: Brightness.dark, textScale: 1.6),
    ),
  ),
  SlideData(
    title: 'Debug Panel',
    topic: Topic.runtimeTools,
    notes: "The site map previews are nice, but the running app is where bugs live. So let's put the devtool inside the app.",
    example: ShopApp(state: ShopState(), debug: ShopDebug()),
    child: _RuntimeAppSlide(
      title: 'An In-App Debug Panel',
      points: [
        'Lives **inside the app**: on a real phone, for QA too.',
        'Only in debug builds.',
      ],
    ),
  ),
  SlideData(
    title: 'Debug Panel: Settings',
    topic: Topic.runtimeTools,
    notes: "Open the panel: theme, text size.",
    example: ShopApp(state: ShopState(), debug: ShopDebug(open: true)),
    child: _RuntimeAppSlide(
      title: 'Switch Theme & Text Size',
      points: ['The app on **a real device**.'],
    ),
  ),
  SlideData(
    title: 'Debug Panel: Dark Mode',
    topic: Topic.runtimeTools,
    notes: "Dark mode, in the running app.",
    example: ShopApp(
      state: ShopState(),
      debug: ShopDebug(open: true, brightness: Brightness.dark),
    ),
    child: _RuntimeAppSlide(
      title: 'Switch Theme & Text Size',
      points: ['The app on **a real device**.'],
    ),
  ),
  SlideData(
    title: 'Debug Panel: Large Text',
    topic: Topic.runtimeTools,
    notes: "And large text.",
    example: ShopApp(
      state: ShopState(),
      debug: ShopDebug(open: true, brightness: Brightness.dark, textScale: 1.3),
    ),
    child: _RuntimeAppSlide(
      title: 'Switch Theme & Text Size',
      points: ['The app on **a real device**.'],
    ),
  ),
  SlideData(
    title: 'Debug Panel: Test Users',
    topic: Topic.runtimeTools,
    notes: "Reproducing a bug often starts with: who has this in their account? The panel lists test users, filtered by what they have.",
    example: ShopApp(
      state: ShopState(),
      debug: ShopDebug(open: true, tab: DebugTab.users, userQuery: 'in cart'),
    ),
    child: _RuntimeAppSlide(
      title: 'Find a Test User',
      points: [
        'Search users **by what they have**: a cart, an order, a plan.',
        'No more asking around for a test account.',
      ],
    ),
  ),
  SlideData(
    title: 'Debug Panel: Log In',
    topic: Topic.runtimeTools,
    notes: "One tap, and we're logged in as that user, looking at their cart.",
    example: ShopApp(
      state: ShopState(
        cart: [CartItem('headphones'), CartItem('speaker', quantity: 2)],
        cartOpen: true,
      ),
      debug: ShopDebug(user: 'alice@test.dev'),
    ),
    child: _RuntimeAppSlide(
      title: 'Log In as Them',
      points: ['One tap: the app now shows **their** cart.'],
    ),
  ),
  SlideData(
    title: 'Debug Panel: Network',
    topic: Topic.runtimeTools,
    notes: "And every request the app made. That failing checkout is the bug report.",
    example: ShopApp(
      state: ShopState(),
      debug: ShopDebug(open: true, tab: DebugTab.network),
    ),
    child: _RuntimeAppSlide(
      title: 'See Every Request',
      points: [
        'Every call, its **status** and **timing**.',
        'That 402 is your bug report.',
      ],
    ),
  ),
  SlideData(
    title: 'What vm_service Gives You',
    topic: Topic.runtimeTools,
    steps: 1,
    notes:
        'Everything so far lives inside the app. Tools outside it use '
        'package:vm_service, like the debugger does: evaluate any expression '
        'in the running app, read any live object. Fun fact: this very deck was '
        'edited that way all along. After each change, the agent evaluated an '
        'expression to jump to the slide it had just edited. A runtime tool, '
        'built in minutes, for one talk.',
    child: _VmServiceSlide(),
  ),
  SlideData(
    title: 'State Inspector',
    topic: Topic.runtimeTools,
    notes:
        'A devtool outside the app, reading the state of the running app '
        'through vm_service: who is logged in, what is in the cart, which '
        'page is open. And it can edit it: change a quantity here, and the '
        'app updates. Switch user, and the app shows their account.',
    example: ShopApp(
      state: ShopState(
        cart: [CartItem('headphones'), CartItem('speaker', quantity: 2)],
        cartOpen: true,
      ),
      debug: ShopDebug(user: 'alice@test.dev'),
      inspect: true,
    ),
    child: _StateInspectorSlide(),
  ),
  SlideData(
    title: 'What You See vs. What Your Agent Sees',
    steps: 2,
    topic: Topic.humansAndAi,
    notes:
        'When I debug, I look at the logs, the network tab, the app state, '
        'the screen, I log in as a test user. By default, my agent only has '
        'the source code. Every gap is a place where it guesses, or burns '
        'tokens hunting for something I could have handed it. So: any '
        'information you have access to, your agent should have too.',
    child: _AgentSeesSlide(),
  ),
  SlideData(
    title: 'DevTools in the AI Era',
    topic: Topic.humansAndAi,
    notes:
        'DevTools are the other side of the MCP coin. Expose MCP endpoints so '
        'both human developers and AI agents can query application state '
        'through the exact same underlying Dart package logic.',
    child: BadgeCardSlide(
      maxWidth: 950,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      children: [
        BadgeTitle(
          "Don't write JUST a DevTool! Make it usable by AIs too.",
          bottom: 12,
          fontSize: 30.4,
        ),
        P(
          'Extract state inspection logic into a shared Dart package so both '
          'humans and AI agents benefit!',
          fontSize: 16.8,
          bottom: 20,
        ),
        _SharedPackageDiagram(),
      ],
    ),
  ),
  SlideData(
    title: 'Agents Debug Too',
    steps: 1,
    topic: Topic.humansAndAi,
    notes:
        'The tools we built for ourselves are just as useful to an agent. '
        'Here it finds a premium test user, logs in as them, opens the cart, '
        'reads the crash and evaluates the state, without ever asking me to '
        'reproduce the bug. Only possible because each of those panels has a '
        'machine-readable counterpart.',
    child: _AgentDebugSlide(),
  ),
  SlideData(
    title: 'Start Monday',
    steps: 4,
    topic: Topic.conclusion,
    notes:
        "You don't need a tooling team or a roadmap. Next time something "
        'annoys you twice, that is your next tool. Ask your agent to write '
        'it, in the middle of the rush. Shipped software is expensive, tools '
        "are cheap: spend the cheap kind on the expensive kind. Don't replace "
        'tools with prompts, use prompts to create your tools.',
    child: _StartMondaySlide(),
  ),
  SlideData(
    title: 'Conclusion',
    topic: Topic.conclusion,
    notes:
        'The flywheel: every tool removes some maintenance, which frees time '
        'for the next tool. Thank you, '
        'and happy Halloween!',
    child: _ConclusionSlide(),
  ),
];

// ---------------------------------------------------------------------------
// Slide-specific widgets
// ---------------------------------------------------------------------------

class _TitleSlide extends StatelessWidget {
  const _TitleSlide();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '🏮  ハロウィン · Halloween Edition  🏮',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: palette.accent,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.heading, palette.accent, Hues.wisteria],
              stops: const [0.2, 0.65, 1],
            ).createShader(bounds),
            child: const H1('Build devtools for your app', fontSize: 80),
          ),
        ),
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(
              colors: [
                palette.accent.withValues(alpha: 0),
                palette.accent,
                Hues.wisteria.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '道具を作ろう 👻',
          style: TextStyle(
            fontSize: 22,
            letterSpacing: 6,
            color: palette.textMuted,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 24, 10),
          decoration: BoxDecoration(
            color: palette.textMain.withValues(alpha: 0.05),
            border: Border.all(color: palette.cardBorder),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [palette.accent, Hues.vermilion],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎃', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rémi Rousselet',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.8,
                      color: palette.heading,
                    ),
                  ),
                  Text(
                    'Creator of Riverpod, Freezed, & Flutter DevTools',
                    style: TextStyle(fontSize: 13.6, color: palette.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageSlide extends StatelessWidget {
  const _ImageSlide({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Eyebrow(center: true),
        if (title case final title?)
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: H2(title, textAlign: TextAlign.center),
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: child,
        ),
      ],
    );
  }
}

class _CustomLintsSlide extends StatelessWidget {
  const _CustomLintsSlide();

  @override
  Widget build(BuildContext context) {
    return const ContentSlide(
      title: 'Custom Lints',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LintEditor(),
                  SizedBox(height: 16),
                  Reveal(1, child: _LintTerminal()),
                ],
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Reveal(
                    2,
                    child: _PubPackageCard(
                      name: 'analysis_server_plugin',
                      version: '0.3.25',
                      description:
                          'A framework and support code for building plugins '
                          'for the analysis server.',
                      publisher: 'tools.dart.dev',
                      likes: '23',
                      points: '150',
                      downloads: '1.4M',
                    ),
                  ),
                  SizedBox(height: 24),
                  _ProsCons(
                    firstStep: 3,
                    pros: [
                      '**Cheap to build**, especially with AI',
                      '**Deterministic**',
                      'Seen by **humans, agents and CI**',
                    ],
                    cons: [
                      '**RAM cost** on low-end machines',
                      'Slightly slower `dart analyze`',
                      'Not every rule fits in a lint',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickFixSlide extends StatelessWidget {
  const _QuickFixSlide();

  @override
  Widget build(BuildContext context) {
    return const ContentSlide(
      title: 'Quick Fixes',
      children: [
        Grid(
          columns: 2,
          gap: 32,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QuickFixMenu(),
                SizedBox(height: 20),
                _ProsCons(
                  firstStep: 1,
                  pros: ['**Deterministic** and instant'],
                  cons: [
                    '**AI cannot use them**',
                    '**Not context aware**: a one-trick pony',
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Reveal(4, child: _AgentFix()),
                SizedBox(height: 20),
                _ProsCons(
                  firstStep: 5,
                  pros: ['**Nothing to write**', 'Can adapt to most scenarios'],
                  cons: ['Costs a few tokens'],
                ),
              ],
            ),
          ],
        ),
        Reveal(
          8,
          child: Callout(
            '**Build tools to detect bad code, not to correct it.** Let AI '
            'write the fix. Quick fixes are only worth it for packages used by '
            'thousands of developers.',
            top: 16,
          ),
        ),
      ],
    );
  }
}

/// The IDE's quick fix menu, opened on a lint warning.
class _QuickFixMenu extends StatelessWidget {
  const _QuickFixMenu();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    const code = TextStyle(
      fontFamily: Fonts.code,
      fontSize: 15,
      height: 1.7,
      color: Hues.codeText,
    );

    Widget action(String text, {bool selected = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? palette.accent.withValues(alpha: 0.25) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            selected ? Icons.lightbulb_rounded : Icons.block_rounded,
            size: 16,
            color: selected ? Hues.candyCorn : Hues.slate,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.4,
              color: selected ? Colors.white : Hues.codeText,
            ),
          ),
        ],
      ),
    );

    return _CodeWindow(
      title: 'lib/screens/cart.dart',
      icon: Icons.lightbulb_rounded,
      caption: 'A quick fix you wrote',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              style: code,
              children: [
                TextSpan(
                  text: 'return ',
                  style: TextStyle(color: _LintEditor._keyword),
                ),
                TextSpan(
                  text: 'Text',
                  style: TextStyle(color: _LintEditor._type),
                ),
                TextSpan(text: '('),
                TextSpan(
                  text: "'Your cart is empty'",
                  style: TextStyle(
                    color: _LintEditor._string,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationColor: Hues.candyCorn,
                    decorationThickness: 2,
                  ),
                ),
                TextSpan(text: ');'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60, top: 6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.cardBorder),
                boxShadow: const [
                  BoxShadow(color: Color(0x80000000), blurRadius: 16),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  action('Use a translation', selected: true),
                  action('Ignore for this line'),
                  action('Ignore for this file'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An agent fixing the same lint warning from a one-line prompt.
class _AgentFix extends StatelessWidget {
  const _AgentFix();

  static const _lines = [
    '• Edit(lib/screens/cart.dart)',
    "  - Text('Your cart is empty')",
    '  + Text(context.l10n.emptyCart)',
    '• Edit(lib/l10n/app_en.arb)',
    '  + "emptyCart": "Your cart is empty"',
    '• Bash(dart analyze)',
    '  -> No issues found!',
  ];

  @override
  Widget build(BuildContext context) {
    const code = TextStyle(
      fontFamily: Fonts.code,
      fontSize: 14.4,
      height: 1.7,
      color: Hues.codeText,
    );
    return _CodeWindow(
      title: 'Agent',
      icon: Icons.smart_toy_rounded,
      caption: 'Just ask the agent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '> Fix the lint warnings',
              style: code.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          for (final line in _lines)
            Text(
              line,
              style: switch (line.trimLeft()[0]) {
                '+' => code.copyWith(color: Hues.emeraldLight),
                '-' when !line.contains('->') => code.copyWith(
                  color: Hues.roseLight,
                ),
                '-' => code.copyWith(color: Hues.slate),
                _ => code,
              },
            ),
        ],
      ),
    );
  }
}

/// A file open in an IDE, with a custom lint warning on a hardcoded string.
class _LintEditor extends StatelessWidget {
  const _LintEditor();

  static const _keyword = Color(0xFFC792EA);
  static const _type = Color(0xFF82AAFF);
  static const _string = Color(0xFFC3E88D);

  @override
  Widget build(BuildContext context) {
    const code = TextStyle(
      fontFamily: Fonts.code,
      fontSize: 15,
      height: 1.7,
      color: Hues.codeText,
    );
    const keyword = TextStyle(color: _keyword);
    const type = TextStyle(color: _type);

    return _CodeWindow(
      title: 'lib/screens/cart.dart',
      icon: Icons.person_rounded,
      caption: 'Humans, in the IDE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              style: code,
              children: [
                TextSpan(text: 'class ', style: keyword),
                TextSpan(text: 'EmptyCart ', style: type),
                TextSpan(text: 'extends ', style: keyword),
                TextSpan(text: 'StatelessWidget', style: type),
                TextSpan(text: ' {\n  '),
                TextSpan(text: 'Widget ', style: type),
                TextSpan(text: 'build('),
                TextSpan(text: 'BuildContext ', style: type),
                TextSpan(text: 'context) {\n    '),
                TextSpan(text: 'return ', style: keyword),
                TextSpan(text: 'Text', style: type),
                TextSpan(text: '('),
                TextSpan(
                  text: "'Your cart is empty'",
                  style: TextStyle(
                    color: _string,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationColor: Hues.candyCorn,
                    decorationThickness: 2,
                  ),
                ),
                TextSpan(text: ');'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100, top: 4, bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Hues.candyCorn.withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 17,
                    color: Hues.candyCorn,
                  ),
                  Text(
                    'Strings shown to users must be translated.',
                    style: TextStyle(fontSize: 13.6, color: Colors.white),
                  ),
                  Text(
                    'avoid_hardcoded_string',
                    style: TextStyle(fontSize: 13.6, color: Hues.slate),
                  ),
                ],
              ),
            ),
          ),
          const Text('  }\n}', style: code),
        ],
      ),
    );
  }
}

/// The same lint warning, as `dart analyze` prints it for CI and agents.
class _LintTerminal extends StatelessWidget {
  const _LintTerminal();

  @override
  Widget build(BuildContext context) {
    const code = TextStyle(
      fontFamily: Fonts.code,
      fontSize: 14,
      height: 1.7,
      color: Hues.codeText,
    );
    return _CodeWindow(
      title: 'Terminal',
      icon: Icons.smart_toy_rounded,
      caption: 'Agents and CI, with dart analyze',
      child: const Text.rich(
        TextSpan(
          style: code,
          children: [
            TextSpan(text: '\$ dart analyze\n'),
            TextSpan(
              text: 'warning',
              style: TextStyle(color: Hues.candyCorn),
            ),
            TextSpan(
              text: ' • lib/screens/cart.dart:3:17 • avoid_hardcoded_string',
            ),
          ],
        ),
      ),
    );
  }
}

/// A dark window with a title bar, and who looks at it on the right.
class _CodeWindow extends StatelessWidget {
  const _CodeWindow({
    required this.title,
    required this.icon,
    required this.caption,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Hues.codeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF111827),
            child: Row(
              spacing: 6,
              children: [
                for (final color in const [
                  Hues.rose,
                  Hues.candyCorn,
                  Hues.emerald,
                ])
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: Fonts.code,
                    fontSize: 12.8,
                    color: Hues.slate,
                  ),
                ),
                const Spacer(),
                Icon(icon, size: 16, color: palette.accent),
                Text(
                  caption,
                  style: TextStyle(
                    fontSize: 13.6,
                    fontWeight: FontWeight.w600,
                    color: palette.accent,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _ProsCons extends StatelessWidget {
  const _ProsCons({required this.pros, required this.cons, this.firstStep});

  final List<String> pros;
  final List<String> cons;

  /// When set, rows are revealed one at a time, starting at this step.
  final int? firstStep;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    Widget row(String text, {required bool pro}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(
            pro ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20,
            color: pro ? Hues.emeraldLight : Hues.roseLight,
          ),
          Expanded(
            child: Md(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                color: palette.textMain,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, pro) in pros.indexed)
          _reveal(index, row(pro, pro: true)),
        const SizedBox(height: 8),
        for (final (index, con) in cons.indexed)
          _reveal(pros.length + index, row(con, pro: false)),
      ],
    );
  }

  Widget _reveal(int index, Widget row) => switch (firstStep) {
    final firstStep? => Reveal(firstStep + index, child: row),
    null => row,
  };
}

/// A package as listed on pub.dev, with its numbers at the time of writing.
class _PubPackageCard extends StatelessWidget {
  const _PubPackageCard({
    required this.name,
    required this.version,
    required this.description,
    required this.publisher,
    required this.likes,
    required this.points,
    required this.downloads,
  });

  static const _blue = Color(0xFF0175C2);
  static const _grey = Color(0xFF6B7280);

  final String name;
  final String version;
  final String description;
  final String publisher;
  final String likes;
  final String points;
  final String downloads;

  @override
  Widget build(BuildContext context) {
    Widget metric(String value, String label) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.4,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: _grey,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'pub.dev',
            style: TextStyle(
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: _grey,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
              Text(version, style: const TextStyle(fontSize: 14, color: _grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.6,
              height: 1.45,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 4,
            children: [
              const Icon(Icons.verified_rounded, size: 15, color: _blue),
              Text(
                publisher,
                style: const TextStyle(fontSize: 13.6, color: _blue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            spacing: 28,
            children: [
              metric(likes, 'LIKES'),
              metric(points, 'POINTS'),
              metric(downloads, 'DOWNLOADS'),
            ],
          ),
        ],
      ),
    );
  }
}

enum _SiteMapExample {
  shoply,

  /// The pull request adding a wishlist page to the app.
  wishlist,

  /// The pull request adding a "Buy now" button to existing pages.
  buyNow,
}

/// The site map of the example app, as a devtool would draw it.
///
/// Consecutive slides of an [example] share one site map, which animates to
/// the [previews], [showBase] and [highlight] of each slide.
class _SiteMapSlide extends StatelessWidget {
  const _SiteMapSlide({
    required this.title,
    required this.example,
    this.previews = false,
    this.settings = const PreviewSettings(),
    this.showBase = false,
    this.highlight = false,
    this.interactive = true,
  });

  final String title;
  final _SiteMapExample example;
  final bool previews;

  /// See [SiteMapView.interactive].
  final bool interactive;

  /// The theme and text size of the screens, shown in the preview panel when
  /// changed.
  final PreviewSettings settings;
  final bool showBase;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow(),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: H2(title, key: ValueKey(title)),
          ),
        ),
        Expanded(
          child: switch (example) {
            _SiteMapExample.shoply => SiteMapView(
              siteMap: shoplySiteMap,
              previews: previews,
              settings: settings,
              showSettings: settings != const PreviewSettings(),
              interactive: interactive,
            ),
            _SiteMapExample.wishlist => SiteMapView.diff(
              shoplyWishlistDiff,
              previews: previews,
              showBase: showBase,
              highlight: highlight,
            ),
            _SiteMapExample.buyNow => SiteMapView.diff(
              shoplyBuyNowDiff,
              previews: previews,
              showBase: showBase,
              highlight: highlight,
            ),
          },
        ),
      ],
    );
  }
}

/// A pull request, where CI rendered the site map and a bot commented the
/// pages it changes.
class _CodeReviewSlide extends StatelessWidget {
  const _CodeReviewSlide();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow(),
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: H2('Site Maps in Code Review'),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              const SizedBox(
                width: 400,
                child: DeckCard(child: _PullRequest()),
              ),
              Expanded(
                child: DeckCard(
                  child: SiteMapReviewComment(
                    diff: shoplyBuyNowDiff,
                    screenWidth: 168,
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

class _PullRequest extends StatelessWidget {
  const _PullRequest();

  static const _passed = Color(0xFF22C55E);
  static const _pending = Color(0xFFF59E0B);

  static const _checks = [
    (true, 'analyze & test', 'Passed in 1m 12s'),
    (true, 'site-map / render', '5 pages × 18 environments, no overflow'),
    (true, 'site-map / links', 'Every page can still be reached'),
    (false, 'site-map / review', '2 pages changed: needs an approval'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _passed.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Icon(Icons.call_split_rounded, size: 14, color: _passed),
                  Text(
                    'Open',
                    style: TextStyle(
                      color: _passed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '#128',
              style: TextStyle(color: palette.textMuted, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Add a "Buy now" button',
          style: TextStyle(
            color: palette.heading,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'feature/buy-now → main',
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 13,
            fontFamily: Fonts.code,
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: palette.cardBorder, height: 1),
        const SizedBox(height: 16),
        Text(
          'CHECKS',
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        for (final (passed, name, detail) in _checks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(
                  passed ? Icons.check_circle_rounded : Icons.pending_rounded,
                  size: 20,
                  color: passed ? _passed : _pending,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: palette.textMain,
                          fontSize: 14,
                          fontFamily: Fonts.code,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        detail,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'Merging is blocked until the visual changes are approved.',
          style: TextStyle(color: palette.textMuted, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

/// From a review comment to a lint enforced by CI, as a code review thread
/// and the pull request that follows it.
class _ReviewToLintSlide extends StatelessWidget {
  const _ReviewToLintSlide();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow(),
        const Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: H2('Turn Review Comments into Tools'),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: DeckCard(
                  accentBar: false,
                  padding: EdgeInsets.all(28),
                  child: _ReviewThread(),
                ),
              ),
              Reveal(
                1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 40,
                    color: palette.accent,
                  ),
                ),
              ),
              const Expanded(
                child: Reveal(
                  1,
                  child: DeckCard(
                    accentBar: false,
                    padding: EdgeInsets.all(28),
                    child: _LintPullRequest(),
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

abstract final class _Review {
  static const added = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
}

/// A code review comment, on a diff, and its answer.
class _ReviewThread extends StatelessWidget {
  const _ReviewThread();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrHeader(number: 87, title: 'Add a summer sale banner'),
        const SizedBox(height: 30),
        _CodeSnippet(
          file: 'lib/widgets/promo_banner.dart',
          lines: const [
            (' ', 'Column('),
            ('+', "  Text('SUMMER SALE'),"),
            ('+', "  Text('Up to 30% off audio gear'),"),
          ],
        ),
        const SizedBox(height: 30),
        const _Comment(
          author: 'alex',
          color: Hues.sky,
          text:
              'Strings shown to users must go through l10n.\n'
              'That is the third time this month 😅',
        ),
        const SizedBox(height: 20),
        _Comment(
          author: 'sam',
          color: palette.accent,
          text: 'Good catch! I\'ll make it a lint instead.',
        ),
        const SizedBox(height: 30),
        const _TimelineEvent(
          icon: Icons.link_rounded,
          color: Hues.purpleLight,
          text: 'sam linked a pull request: ',
          detail: '#88 Add avoid_hardcoded_string lint',
        ),
      ],
    );
  }
}

/// The pull request adding a lint, after the review comment.
class _LintPullRequest extends StatelessWidget {
  const _LintPullRequest();

  static const _files = [
    ('A', 'lints/avoid_hardcoded_string.dart', '+64'),
    ('A', 'test/lints/avoid_hardcoded_string.dart', '+31'),
    ('A', 'lint_baseline.yaml', '+13'),
    ('M', 'analysis_options.yaml', '+3'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final mono = TextStyle(fontFamily: Fonts.code, fontSize: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrHeader(
          number: 88,
          title: 'Add avoid_hardcoded_string lint',
          merged: true,
        ),
        const SizedBox(height: 30),
        for (final (status, path, lines) in _files)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              spacing: 12,
              children: [
                Text(
                  status,
                  style: mono.copyWith(
                    color: status == 'A' ? _Review.added : _Review.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: Text(
                    path,
                    style: mono.copyWith(color: palette.textMain),
                  ),
                ),
                Text(lines, style: mono.copyWith(color: _Review.added)),
              ],
            ),
          ),
        const SizedBox(height: 18),
        Row(
          spacing: 10,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: _Review.added,
            ),
            Text(
              'dart analyze',
              style: mono.copyWith(
                color: palette.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '0 new issues · 13 baselined',
              style: TextStyle(color: palette.textMuted, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(
          'NEXT TIME, BEFORE ANY REVIEWER',
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _CodeSnippet(
          file: 'lib/widgets/shipping_info.dart',
          lines: const [('+', "  Text('Free shipping'),")],
          warning: 'avoid_hardcoded_string: use l10n instead.',
        ),
        const SizedBox(height: 36),
        const _TimelineEvent(
          icon: Icons.merge_rounded,
          color: Hues.purpleLight,
          text: 'Merged ',
          detail: '· approved by alex',
        ),
      ],
    );
  }
}

class _PrHeader extends StatelessWidget {
  const _PrHeader({
    required this.number,
    required this.title,
    this.merged = false,
  });

  final int number;
  final String title;
  final bool merged;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final color = merged ? Hues.purpleLight : _Review.added;
    return Row(
      spacing: 10,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(
                merged ? Icons.merge_rounded : Icons.call_split_rounded,
                size: 16,
                color: color,
              ),
              Text(
                merged ? 'Merged' : 'Open',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Text.rich(
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: palette.heading,
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                  ),
                ),
                TextSpan(
                  text: '  #$number',
                  style: TextStyle(color: palette.textMuted, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Lines of a diff, optionally with an analyzer warning on the last one.
class _CodeSnippet extends StatelessWidget {
  const _CodeSnippet({required this.file, required this.lines, this.warning});

  final String file;
  final List<(String, String)> lines;
  final String? warning;

  static int _indentOf(String code) => code.length - code.trimLeft().length;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    const mono = TextStyle(fontFamily: Fonts.code, fontSize: 17, height: 1.7);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Hues.codeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0x14FFFFFF),
            child: Text(
              file,
              style: mono.copyWith(fontSize: 14, color: Hues.slate),
            ),
          ),
          for (final (index, (sign, code)) in lines.indexed)
            Container(
              color: sign == '+' ? _Review.added.withValues(alpha: 0.12) : null,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text.rich(
                TextSpan(
                  style: mono.copyWith(color: Hues.codeText),
                  children: [
                    TextSpan(
                      text: '$sign ',
                      style: TextStyle(
                        color: sign == '+' ? _Review.added : Hues.slate,
                      ),
                    ),
                    // The warning underlines the code, not its indentation.
                    TextSpan(text: code.substring(0, _indentOf(code))),
                    TextSpan(
                      text: code.substring(_indentOf(code)),
                      style: warning != null && index == lines.length - 1
                          ? const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.wavy,
                              decorationColor: _Review.warning,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          if (warning case final warning?)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                spacing: 8,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: _Review.warning,
                  ),
                  Expanded(
                    child: Text(
                      warning,
                      style: mono.copyWith(
                        fontSize: 15,
                        color: _Review.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// An event in the timeline of a pull request.
class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.icon,
    required this.color,
    required this.text,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Row(
      spacing: 14,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: text,
                  style: TextStyle(color: palette.textMuted, fontSize: 16),
                ),
                TextSpan(
                  text: detail,
                  style: TextStyle(
                    color: palette.heading,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A comment in a code review thread.
class _Comment extends StatelessWidget {
  const _Comment({
    required this.author,
    required this.color,
    required this.text,
  });

  final String author;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            author[0].toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              border: Border.all(color: palette.cardBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  author,
                  style: TextStyle(
                    color: palette.heading,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: palette.textMain,
                    fontSize: 18,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Why turning rules into tools pays off over time.
/// How baselines work, with the one rule of baselines fading in below.
///
/// Both slides share one instance (see [SlideData.group]), so the rule fades
/// in instead of the whole slide changing.
class _BaselineSlide extends StatelessWidget {
  const _BaselineSlide({this.showDanger = false});

  final bool showDanger;

  @override
  Widget build(BuildContext context) {
    return ContentSlide(
      title: 'Baselines: No Big-Bang Migration',
      children: [
        Grid(
          columns: 2,
          children: [
            const CodeBlock(_lintBaseline, fontSize: 15),
            DeckCard(
              child: _CardContent(
                title: 'How it works',
                // The next slide shares this one, and shows everything.
                firstStep: showDanger ? null : 0,
                items: [
                  'The lint **ignores** what the baseline lists.',
                  '**New code** must follow the rule right away.',
                  'Old code is **fixed over time**, when touching a file: '
                      'its entry shrinks, then disappears.',
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Always laid out, so that the content above does not move.
        AnimatedOpacity(
          opacity: showDanger ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: AnimatedSlide(
            offset: showDanger ? Offset.zero : const Offset(0, 0.15),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            child: const BadgeCardSlide(
              danger: true,
              maxWidth: double.infinity,
              padding: EdgeInsets.fromLTRB(40, 32, 40, 24),
              children: [
                BadgeTitle(
                  'Once created, a baseline may only shrink.',
                  fontSize: 26,
                  bottom: 8,
                ),
                BadgeSubtitle(
                  'Regenerating it to silence a new warning defeats the lint. '
                  'Make CI fail when the baseline gains entries.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _DevtoolKind { static, runtime }

/// Static vs. runtime devtools, with the family about to be covered
/// highlighted.
class _DevtoolKindsSlide extends StatelessWidget {
  const _DevtoolKindsSlide({required this.focus, required this.highlight});

  final _DevtoolKind focus;

  /// The example of the focused family that the next step highlights: the
  /// one the following slides are about.
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return ContentSlide(
      title: 'Two Kinds of Devtools',
      children: [
        Grid(
          columns: 2,
          gap: 32,
          children: [
            _DevtoolKindCard(
              focused: focus == _DevtoolKind.static,
              // Static tools come first, so they are never "later".
              later: false,
              icon: Icons.description_rounded,
              title: 'Static tools',
              package: 'package:analyzer',
              tagline: 'Read the code, without running it.',
              abilities: const [
                'List every class, and **everywhere** it is used',
                'Read **types**, annotations and doc comments',
              ],
              examples: const ['Lints', 'Code generators', 'Site maps'],
              highlight: focus == _DevtoolKind.static ? highlight : null,
              color: Hues.matcha,
            ),
            _DevtoolKindCard(
              focused: focus == _DevtoolKind.runtime,
              later: focus == _DevtoolKind.static,
              icon: Icons.play_circle_rounded,
              title: 'Runtime tools',
              package: 'in-app, or package:vm_service',
              tagline: 'Inspect the app while it runs.',
              abilities: const [
                '**In-app** panels: theme, test users, requests',
                '**From outside**, with vm_service: the debugger',
              ],
              examples: const ['Theme switcher', 'Log viewer', 'Debugger'],
              highlight: focus == _DevtoolKind.runtime ? highlight : null,
              color: Hues.onibi,
            ),
          ],
        ),
      ],
    );
  }
}

class _DevtoolKindCard extends StatelessWidget {
  const _DevtoolKindCard({
    required this.focused,
    required this.later,
    required this.icon,
    required this.title,
    required this.package,
    required this.tagline,
    required this.abilities,
    required this.examples,
    required this.highlight,
    required this.color,
  });

  final bool focused;

  /// Whether the slides cover this family of tools later on.
  final bool later;

  /// Which of [examples] to highlight from step 1 onwards.
  final String? highlight;
  final IconData icon;
  final String title;
  final String package;
  final String tagline;
  final List<String> abilities;
  final List<String> examples;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return AnimatedOpacity(
      opacity: focused ? 1 : 0.35,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: palette.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused ? color.withValues(alpha: 0.7) : palette.cardBorder,
            width: focused ? 2 : 1,
          ),
          boxShadow: [
            if (focused)
              BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 32),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 14,
              children: [
                Icon(icon, size: 40, color: color),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: Fonts.heading,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: palette.heading,
                  ),
                ),
                const Spacer(),
                if (later)
                  Text(
                    'LATER',
                    style: TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: palette.textDim,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            InlineCode(package, fontSize: 16, color: color),
            const SizedBox(height: 16),
            Text(
              tagline,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: palette.textMain,
              ),
            ),
            FeatureList(abilities, fontSize: 17.6, top: 14),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                for (final example in examples)
                  _ExampleChip(
                    example,
                    color: color,
                    highlighted: highlight == example,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A pill naming a kind of devtool. When [highlighted], it lights up with a
/// pulsing glow once the slide reaches step 1, and the other pills fade.
class _ExampleChip extends StatefulWidget {
  const _ExampleChip(
    this.label, {
    required this.color,
    required this.highlighted,
  });

  final String label;
  final Color color;
  final bool highlighted;

  @override
  State<_ExampleChip> createState() => _ExampleChipState();
}

class _ExampleChipState extends State<_ExampleChip>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  var _lit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final step = SlideStep.of(context);
    // Outside of a slide (e.g. the overview), every step is revealed: keep
    // the pills as they are.
    final lit = widget.highlighted && step >= 1 && step < 1 << 20;
    if (lit && !_lit) {
      // A few pulses, then a steady glow: an endless animation would keep
      // the slide from ever settling.
      _pulse.repeat(reverse: true, count: 6);
    } else if (!lit) {
      _pulse.value = 0;
    }
    _lit = lit;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = SlideStep.of(context);
    final dimmed = !widget.highlighted && step >= 1 && step < 1 << 20;
    final color = widget.color;
    const duration = Duration(milliseconds: 350);

    return AnimatedOpacity(
      opacity: dimmed ? 0.35 : 1,
      duration: duration,
      child: AnimatedScale(
        scale: _lit ? 1.1 : 1,
        duration: duration,
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final pulse = Curves.easeInOut.transform(_pulse.value);
            return AnimatedContainer(
              duration: duration,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _lit ? color : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: color.withValues(alpha: _lit ? 1 : 0.4),
                ),
                boxShadow: [
                  if (_lit)
                    BoxShadow(
                      color: color.withValues(alpha: 0.45 + 0.4 * pulse),
                      blurRadius: 14 + 22 * pulse,
                      spreadRadius: 1 + 5 * pulse,
                    ),
                ],
              ),
              child: child,
            );
          },
          child: AnimatedDefaultTextStyle(
            duration: duration,
            style: TextStyle(
              fontFamily: Fonts.body,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _lit ? Hues.codeBg : color,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

/// From one button in the code, to a graph of the whole app.
class _StaticGoesFurtherSlide extends StatelessWidget {
  const _StaticGoesFurtherSlide();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    Widget arrow(int step) => Reveal(
      step,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 36,
          color: palette.accent,
        ),
      ),
    );

    return ContentSlide(
      title: 'Example of Custom Architecture to Power Tools',
      children: [
        const P(
          'Lints check one line at a time. The analyzer can read **the whole '
          'app**.',
          fontSize: 20,
          bottom: 24,
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    H3('The code'),
                    CodeBlock(_buttonSource, fontSize: 13),
                  ],
                ),
              ),
              Center(child: arrow(1)),
              const Expanded(
                flex: 5,
                child: Reveal(
                  1,
                  child: DeckCard(
                    child: _CardContent(
                      title: 'What the analyzer sees',
                      fontSize: 17.6,
                      items: [
                        'All `@Route` classes',
                        'All references to `Link` within a route',
                      ],
                    ),
                  ),
                ),
              ),
              Center(child: arrow(2)),
              const Expanded(
                flex: 5,
                child: Reveal(
                  2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      H3('Generate a graph of routes → links'),
                      CodeBlock(_mermaidSiteMap, fontSize: 14.4),
                      SizedBox(height: 12),
                      P(
                        'A Mermaid graph. Or an image, a markdown file, or…',
                        fontSize: 15.2,
                        bottom: 0,
                      ),
                    ],
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

/// The title next to the example app, while clicking through its pages.
///
/// Its slides share one instance (see [SlideData.group]), so only the page
/// name changes.
class _MeetShoplySlide extends StatelessWidget {
  const _MeetShoplySlide({required this.page});

  final String page;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow(),
        const H1('Meet Shoply', fontSize: 72),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            page,
            key: ValueKey(page),
            style: TextStyle(
              fontFamily: Fonts.heading,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: palette.accent,
            ),
          ),
        ),
      ],
    );
  }
}

/// Separates the site map from its git integration, around a big git logo.
class _GitIntegrationSlide extends StatelessWidget {
  const _GitIntegrationSlide();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 260,
          child: CustomPaint(painter: _GitLogoPainter()),
        ),
        SizedBox(height: 48),
        H1('Site Map × Git', fontSize: 64),
        SizedBox(height: 16),
        P(
          'The site map of **any branch**, and what a pull request changes.',
          fontSize: 22,
          bottom: 0,
        ),
      ],
    );
  }
}

/// The git logo: a branch drawn on an orange diamond.
class _GitLogoPainter extends CustomPainter {
  const _GitLogoPainter();

  static const _orange = Color(0xFFF05033);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    Offset at(double x, double y) => Offset(x * side, y * side);

    // A rounded square, turned into a diamond.
    canvas
      ..save()
      ..translate(side / 2, side / 2)
      ..rotate(math.pi / 4)
      ..drawShadow(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: side * 0.7,
              height: side * 0.7,
            ),
            Radius.circular(side * 0.07),
          ),
        ),
        _orange,
        24,
        false,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: side * 0.7,
            height: side * 0.7,
          ),
          Radius.circular(side * 0.07),
        ),
        Paint()..color = _orange,
      )
      ..restore();

    final branch = Paint()
      ..color = Colors.white
      ..strokeWidth = side * 0.06
      ..strokeCap = StrokeCap.round;
    final top = at(0.42, 0.36);
    final bottom = at(0.42, 0.68);
    final right = at(0.62, 0.56);
    canvas
      ..drawLine(at(0.27, 0.21), top, branch)
      ..drawLine(top, bottom, branch)
      ..drawLine(top, right, branch);
    for (final node in [top, bottom, right]) {
      canvas.drawCircle(node, side * 0.065, branch);
    }
  }

  @override
  bool shouldRepaint(_GitLogoPainter oldDelegate) => false;
}

/// The architecture decisions the demos rely on, revealed one at a time.
class _BuiltForToolsSlide extends StatelessWidget {
  const _BuiltForToolsSlide();

  /// Each decision, with a snippet shown while it is the latest one revealed.
  static const _decisions = [
    (
      '🔒',
      'Constants',
      'Values the analyzer can read',
      Hues.sky,
      _constSnippet,
    ),
    (
      '🏷️',
      'Annotations',
      'Find every page in one query',
      Hues.teal,
      _annotationSnippet,
    ),
    (
      '📁',
      'File conventions',
      'Know where everything lives',
      Hues.candyCorn,
      _filesSnippet,
    ),
    (
      '🧩',
      'Fields, not strings',
      'Typed, instead of dynamic',
      Hues.purpleLight,
      _fieldsSnippet,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = SlideStep.of(context).clamp(0, _decisions.length - 1);
    return ContentSlide(
      title: 'Built for Tools',
      children: [
        const P(
          'Design decisions impact **what tools can do**.',
          fontSize: 22,
          bottom: 32,
        ),
        Grid(
          columns: 4,
          gap: 20,
          children: [
            for (final (index, (emoji, title, caption, color, _))
                in _decisions.indexed)
              Reveal(
                index,
                // Earlier decisions fade back, to follow the current one.
                child: AnimatedOpacity(
                  opacity: index < current ? 0.4 : 1,
                  duration: const Duration(milliseconds: 350),
                  child: DiagramNode(
                    emoji: emoji,
                    title: title,
                    caption: caption,
                    color: color,
                    tint: color,
                    emojiSize: 36,
                    titleSize: 20,
                    captionSize: 14.4,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 36),
        // Fixed height, so that swapping snippets does not move the slide.
        SizedBox(
          height: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: Center(
              key: ValueKey(current),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: IntrinsicHeight(
                  child: CodeBlock(_decisions[current].$5, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What package:vm_service can do, with the call that drove this deck.
class _VmServiceSlide extends StatelessWidget {
  const _VmServiceSlide();

  @override
  Widget build(BuildContext context) {
    return const ContentSlide(
      title: 'What vm_service Gives You',
      children: [
        Grid(
          columns: 2,
          gap: 40,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FeatureList(fontSize: 20.8, gap: 18, top: 0, [
                  '**Evaluate** any expression, like the debugger.',
                  'Read every **live object**, and its fields.',
                  '**Hot reload**, hot restart, and more.',
                ]),
              ],
            ),
            CodeBlock(_vmServiceSnippet, fontSize: 16),
          ],
        ),
        Reveal(
          1,
          child: Callout(
            '**This deck was edited this way.** After each change, the agent '
            'evaluated an expression to jump to the slide it had edited.',
            fontSize: 19.2,
            top: 32,
          ),
        ),
      ],
    );
  }
}

/// A short title and a few points, next to the example app.
class _RuntimeAppSlide extends StatelessWidget {
  const _RuntimeAppSlide({required this.title, required this.points});

  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow(),
        Padding(padding: const EdgeInsets.only(bottom: 28), child: H2(title)),
        FeatureList(points, fontSize: 22, gap: 16, top: 0),
      ],
    );
  }
}

/// An editable view of the example app's state, next to the app.
class _StateInspectorSlide extends StatelessWidget {
  const _StateInspectorSlide();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Eyebrow(),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: H2('State Inspector'),
        ),
        StateInspector(),
        SizedBox(height: 12),
        _PubPackageCard(
          name: 'vm_service',
          version: '15.4.0',
          description:
              'A library to communicate with a service implementing the Dart '
              'VM service protocol.',
          publisher: 'tools.dart.dev',
          likes: '62',
          points: '150',
          downloads: '22.1M',
        ),
      ],
    );
  }
}

class _AgentDebugSlide extends StatelessWidget {
  const _AgentDebugSlide();

  static const _tools = [
    ('👥', 'Find test users'),
    ('🔑', 'Log in as anyone'),
    ('🧭', 'Open any page'),
    ('💥', 'Read runtime errors'),
    ('🔍', 'Inspect app state'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final accent = palette.topicAccent(Topic.runtimeTools);
    return ContentSlide(
      title: 'Agents Debug Too',
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 32,
            children: [
              const Expanded(
                flex: 3,
                child: _AgentRun(
                  prompt:
                      'Use available MCPs to find why the cart page crashes '
                      'for premium users',
                  title: 'Using runtime tools',
                  color: Hues.emeraldLight,
                  revealDuration: Duration(seconds: 3),
                  seconds: 48,
                  tokens: 9400,
                  lines: [
                    "• shoply.find_users(query: 'premium')",
                    '  -> alice@test.dev (3 items), dan@test.dev (empty cart)',
                    "• shoply.login('dan@test.dev')",
                    "• shoply.open('/cart')",
                    '• dart.get_runtime_errors()',
                    '  -> Null check operator used on a null value',
                    '  -> cart_page.dart:58 PremiumDiscount.build',
                    "• dart.evaluate('cart.premiumDiscount')",
                    '  -> null',
                    'Crashes when a premium cart is empty.',
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    H3('Tools you already built', color: accent),
                    for (final (emoji, label) in _tools)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '$emoji   $label',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: palette.textMain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Reveal(
          1,
          child: Callout(
            '**No "can you reproduce it?"** The agent uses the same tools you '
            'do, as long as they have a machine-readable side.',
            top: 24,
          ),
        ),
      ],
    );
  }
}

class _ProgressiveImprovementSlide extends StatelessWidget {
  const _ProgressiveImprovementSlide();

  @override
  Widget build(BuildContext context) {
    return const BadgeCardSlide(
      maxWidth: 1000,
      children: [
        BadgeTitle('DRY Applies to More Than Just Code', bottom: 12),
        BadgeSubtitle(
          'Write a rule once, as a tool, instead of repeating it in every '
          'review.',
        ),
        SizedBox(height: 28),
        Grid(
          columns: 3,
          gap: 16,
          children: [
            Reveal(
              1,
              child: DiagramNode(
                emoji: '🎯',
                title: 'Consistency',
                caption: 'The same rules, everywhere',
                color: Hues.sky,
                tint: Hues.sky,
              ),
            ),
            Reveal(
              2,
              child: DiagramNode(
                emoji: '🧭',
                title: 'Onboarding',
                caption: 'Newcomers learn the rules from warnings',
                color: Hues.teal,
                tint: Hues.teal,
              ),
            ),
            Reveal(
              3,
              child: DiagramNode(
                emoji: '🤖',
                title: 'Better AI output',
                caption: 'Agents run the tools too, and fix what they report',
                color: Hues.purpleLight,
                tint: Hues.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AgentSeesSlide extends StatelessWidget {
  const _AgentSeesSlide();

  /// What a developer looks at while working, and whether the agent sees it
  /// by default.
  static const _sources = [
    ('📄', 'Source code', true),
    ('📜', 'Logs', false),
    ('🌐', 'Network requests', false),
    ('🧠', 'App state', false),
    ('📱', 'The screen', false),
    ('👥', 'Test accounts', false),
    ('🚨', 'CI & crash reports', false),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final step = SlideStep.of(context);
    return ContentSlide(
      title: 'What You See vs. What Your Agent Sees',
      children: [
        Grid(
          columns: 2,
          gap: 32,
          children: [
            _SourcesCard(
              title: '🧑‍💻  You',
              color: Hues.emeraldLight,
              sources: [
                for (final (emoji, label, _) in _sources) (emoji, label, true),
              ],
            ),
            _SourcesCard(
              title: '🤖  Your agent',
              color: palette.topicAccent(Topic.humansAndAi),
              // Once the rule is applied, the agent sees everything too.
              sources: [
                for (final (emoji, label, seen) in _sources)
                  (emoji, label, seen || step >= 2),
              ],
            ),
          ],
        ),
        const Reveal(
          1,
          child: Callout(
            '**Any information you have access to, your agent should have '
            'too.** Every gap is a place where it guesses.',
            fontSize: 19.2,
            top: 24,
          ),
        ),
      ],
    );
  }
}

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({
    required this.title,
    required this.color,
    required this.sources,
  });

  final String title;
  final Color color;

  /// Each source as (emoji, label, whether it is visible).
  final List<(String, String, bool)> sources;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return DeckCard(
      accentBar: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          H3(title, color: color, fontSize: 24),
          for (final (emoji, label, visible) in sources)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: visible ? 1 : 0.25,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: visible ? 0.1 : 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withValues(alpha: visible ? 0.4 : 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$emoji   $label',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: palette.textMain,
                        ),
                      ),
                    ),
                    if (!visible)
                      Text(
                        '?',
                        style: TextStyle(
                          fontFamily: Fonts.heading,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: palette.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StartMondaySlide extends StatelessWidget {
  const _StartMondaySlide();

  /// Each habit as (the pain, what to do about it).
  static const _habits = [
    ('You write the same review comment twice', 'Make it a lint'),
    (
      'A tool cannot understand your code',
      'Architect your app to be tool compatible',
    ),
    ('Your agent is guessing', 'Give AI access to everything you have'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final accent = palette.topicAccent(Topic.conclusion);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow(),
            const Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: H2('Start Monday'),
            ),
            for (final (index, (trigger, tool)) in _habits.indexed)
              Reveal(
                index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DeckCard(
                    accentBar: false,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            trigger,
                            style: TextStyle(
                              fontSize: 22,
                              color: palette.textMuted,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 32,
                            color: accent,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            tool,
                            style: TextStyle(
                              fontFamily: Fonts.heading,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const Reveal(
              3,
              child: Callout(
                '**Shipped software is expensive, tools are cheap.** Spend '
                'the cheap kind on the expensive kind.',
                fontSize: 21,
                top: 8,
              ),
            ),
            Reveal(
              4,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Don't replace tools with prompts. Use prompts to create "
                  'your tools.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.heading,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: palette.heading,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConclusionSlide extends StatelessWidget {
  const _ConclusionSlide();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎃', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Hues.candyCorn, Hues.pumpkin, Hues.vermilion],
              ).createShader(bounds),
              child: const H1('Conclusion', fontSize: 44),
            ),
            const SizedBox(width: 20),
            const Text('👻', style: TextStyle(fontSize: 40)),
          ],
        ),
        const SizedBox(height: 24),
        const SizedBox.square(dimension: 460, child: _Flywheel()),
        const SizedBox(height: 24),
        Text(
          'ありがとう！ Trick or treat? Q & A 🍬',
          style: TextStyle(
            fontSize: 20,
            color: palette.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

/// The loop of the talk: each tool frees time for the next one.
class _Flywheel extends StatelessWidget {
  const _Flywheel();

  static const _stages = [
    ('😤', 'Notice friction'),
    ('🤖', 'AI builds a tool'),
    ('🧹', 'Less maintenance'),
    ('⏳', 'Time for the next tool'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (context, progress, _) {
        return CustomPaint(
          painter: _FlywheelPainter(color: Hues.pumpkin, progress: progress),
          child: Stack(
            children: [
              for (final (index, (emoji, label)) in _stages.indexed)
                Align(
                  // Top, right, bottom, left.
                  alignment: switch (index) {
                    0 => Alignment.topCenter,
                    1 => Alignment.centerRight,
                    2 => Alignment.bottomCenter,
                    _ => Alignment.centerLeft,
                  },
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.isLight
                          ? palette.cardBg
                          : const Color.fromRGBO(22, 12, 10, 0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Hues.pumpkin.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: palette.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FlywheelPainter extends CustomPainter {
  _FlywheelPainter({required this.color, required this.progress});

  final Color color;

  /// How much of the loop is drawn, from 0 to 1.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 40;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // One clockwise arc per stage, from one node to the next.
    for (var i = 0; i < 4; i++) {
      final drawn = (progress * 4 - i).clamp(0.0, 1.0);
      if (drawn == 0) continue;
      final start = -math.pi / 2 + i * math.pi / 2;
      canvas.drawArc(rect, start, math.pi / 2 * drawn, false, paint);
      if (drawn < 1) continue;

      // An arrowhead just before the next node, pointing clockwise.
      final angle = start + math.pi / 2 - 0.42;
      final tip = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final direction = Offset(-math.sin(angle), math.cos(angle));
      final normal = Offset(math.cos(angle), math.sin(angle));
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(
            (tip - direction * 14 + normal * 8).dx,
            (tip - direction * 14 + normal * 8).dy,
          )
          ..lineTo(
            (tip - direction * 14 - normal * 8).dx,
            (tip - direction * 14 - normal * 8).dy,
          )
          ..close(),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_FlywheelPainter oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;
}

/// The usual card body: a heading and a bullet list.
class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.title,
    required this.items,
    this.fontSize = 16.8,
    this.firstStep,
  });

  final String title;
  final List<String> items;
  final double fontSize;

  /// See [FeatureList.firstStep].
  final int? firstStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        H3(title),
        FeatureList(items, fontSize: fontSize, firstStep: firstStep),
      ],
    );
  }
}

class _BuildALotSlide extends StatelessWidget {
  const _BuildALotSlide();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow(center: true),
            Md(
              "It's finally worth building **complex tools** for your app.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.heading,
                fontSize: 32,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: 28),
            const _TrendChart(
              yLabel: 'Cost of a custom tool',
              height: 240,
              threshold: (0.4, 'Worth building'),
              series: [
                _Series('', Hues.pumpkin, [
                  Offset(0, 0.85),
                  Offset(0.45, 0.82),
                  Offset(0.66, 0.76),
                  Offset(0.82, 0.24),
                  Offset(1, 0.12),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            const Grid(
              columns: 2,
              gap: 24,
              children: [
                Reveal(
                  1,
                  child: DeckCard(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: _CardContent(
                      title: 'Before',
                      items: [
                        'Only specialized engineers working full-time on OSS '
                            'build devtools.',
                      ],
                    ),
                  ),
                ),
                Reveal(
                  2,
                  child: DeckCard(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: _CardContent(
                      title: 'Now',
                      items: [
                        'So cheap and simple you can build a devtool in the '
                            'middle of a rush.',
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A fake agent transcript answering the same prompt, revealed over
/// [revealDuration] to show how long it takes.
class _AgentRun extends StatelessWidget {
  const _AgentRun({
    this.prompt = 'Check this PR for hardcoded strings',
    required this.title,
    required this.color,
    required this.revealDuration,
    required this.seconds,
    required this.tokens,
    required this.lines,
  });

  final String prompt;
  final String title;
  final Color color;
  final Duration revealDuration;

  /// How long the run takes, in the story told by the slide.
  final int seconds;
  final int tokens;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final code = TextStyle(
      fontFamily: Fonts.code,
      fontSize: 14.4,
      height: 1.7,
      color: Hues.codeText,
    );

    // The agent starts running on the first step. Before it, only the prompt
    // shows.
    final started = SlideStep.of(context) >= 1;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: started ? 1 : 0),
      // Going back to before the start resets the run at once.
      duration: started ? revealDuration : Duration.zero,
      builder: (context, progress, _) {
        final visibleLines = (progress * lines.length).ceil();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Hues.codeBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 30),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              H3(title, color: color),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: palette.heading.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '> $prompt',
                  style: code.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              for (final (index, line) in lines.indexed)
                // Hidden lines still take space, so the card does not grow.
                Opacity(
                  opacity: index < visibleLines ? 1 : 0,
                  child: Text(
                    line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: line.startsWith('•')
                        ? code
                        : line.startsWith(' ')
                        ? code.copyWith(color: Hues.slate)
                        : code.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
              const Spacer(),
              const SizedBox(height: 16),
              Row(
                children: [
                  _AgentStat(
                    label: 'Time',
                    value: _duration((seconds * progress).round()),
                    color: color,
                  ),
                  const SizedBox(width: 32),
                  _AgentStat(
                    label: 'Tokens',
                    value: _tokens((tokens * progress).round()),
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _duration(int seconds) => seconds < 60
      ? '${seconds}s'
      : '${seconds ~/ 60}m ${'${seconds % 60}'.padLeft(2, '0')}s';

  static String _tokens(int tokens) => tokens < 10000
      ? '${(tokens / 1000).toStringAsFixed(1)}k'
      : '${tokens ~/ 1000}k';
}

class _AgentStat extends StatelessWidget {
  const _AgentStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: Hues.slate,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: Fonts.heading,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// One side of the "Two Kinds of Software" comparison.
class _SoftwareKind extends StatelessWidget {
  const _SoftwareKind({
    required this.title,
    required this.verdict,
    required this.color,
    required this.illustration,
    required this.metrics,
  });

  final String title;
  final String verdict;
  final Color color;
  final Widget illustration;

  /// Each metric as (label, value, how much of the bar it fills).
  final List<(String, String, double)> metrics;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return DeckCard(
      accentBar: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 190, child: illustration),
          const SizedBox(height: 16),
          H3(title, color: color, fontSize: 24),
          for (final (label, value, fill) in metrics)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 15, color: palette.textMuted),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 10,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: palette.textMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: fill,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              verdict,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.heading,
                fontSize: 19.2,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A phone surrounded by a crowd of users.
class _ShippedIllustration extends StatelessWidget {
  const _ShippedIllustration();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    Widget bar(double width, double height, {double alpha = 0.18}) => Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: palette.heading.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(3),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(
          painter: _CrowdPainter(
            count: 40,
            color: Hues.roseLight,
            clear: Size(130, 190),
          ),
        ),
        Center(
          child: Container(
            width: 96,
            height: 180,
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
            decoration: BoxDecoration(
              color: Hues.codeBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: palette.heading.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Hues.roseLight.withValues(alpha: 0.25),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(40, 6, alpha: 0.35),
                bar(72, 44, alpha: 0.12),
                bar(72, 6),
                bar(56, 6),
                bar(72, 44, alpha: 0.12),
                bar(48, 6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A terminal next to the few developers using it.
class _InternalIllustration extends StatelessWidget {
  const _InternalIllustration();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final style = TextStyle(
      fontFamily: Fonts.code,
      fontSize: 13,
      height: 1.6,
      color: Hues.codeText,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(
          painter: _CrowdPainter(
            count: 3,
            color: Hues.emeraldLight,
            clear: Size(280, 150),
            spots: [Offset(-175, -5), Offset(-197, 35), Offset(-153, 35)],
          ),
        ),
        Center(
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Hues.codeBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Hues.emeraldLight.withValues(alpha: 0.2),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    for (final color in const [
                      Hues.rose,
                      Hues.candyCorn,
                      Hues.emerald,
                    ])
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(r'$ dart run tool/seed', style: style),
                Text(
                  'Seeded 12 test users',
                  style: style.copyWith(color: Hues.emeraldLight),
                ),
                Text(r'$ _', style: style),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Little people scattered around a [clear] area in the middle.
class _CrowdPainter extends CustomPainter {
  const _CrowdPainter({
    required this.count,
    required this.color,
    required this.clear,
    this.spots,
  });

  final int count;
  final Color color;
  final Size clear;

  /// Where to draw people, relative to the center, instead of scattering them.
  final List<Offset>? spots;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(count);
    final center = size.center(Offset.zero);
    final avoid = Rect.fromCenter(
      center: center,
      width: clear.width + 24,
      height: clear.height,
    );
    final people = [for (final spot in spots ?? const []) center + spot];
    for (var attempt = 0; attempt < 5000 && people.length < count; attempt++) {
      final person = Offset(
        12 + random.nextDouble() * (size.width - 24),
        14 + random.nextDouble() * (size.height - 30),
      );
      if (avoid.inflate(10).contains(person)) continue;
      if (people.any((other) => (other - person).distance < 30)) continue;
      people.add(person);
    }

    final paint = Paint()..color = color.withValues(alpha: 0.75);
    for (final person in people) {
      canvas
        ..drawCircle(person.translate(0, -7), 6, paint)
        ..drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(person.dx - 9, person.dy, 18, 11),
            topLeft: const Radius.circular(9),
            topRight: const Radius.circular(9),
          ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_CrowdPainter oldDelegate) =>
      oldDelegate.count != count ||
      oldDelegate.color != color ||
      oldDelegate.clear != clear;
}

/// A line of a [_TrendChart], with [points] from (0, 0) at the bottom left
/// to (1, 1) at the top right.
class _Series {
  const _Series(this.label, this.color, this.points);

  final String label;
  final Color color;
  final List<Offset> points;
}

/// An illustrative chart (no real data) of [series] over the last years, with
/// a marker where coding agents arrived.
class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.yLabel,
    required this.series,
    this.threshold,
    this.height = 320,
  });

  final String yLabel;
  final List<_Series> series;

  /// A dashed horizontal line, as (y, label).
  final (double, String)? threshold;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _TrendChartPainter(
          yLabel: yLabel,
          series: series,
          threshold: threshold,
          axisColor: palette.textMuted,
          accent: palette.accent,
          textStyle: DefaultTextStyle.of(context).style
              .copyWith(fontSize: 14.4, color: palette.textMuted),
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.yLabel,
    required this.series,
    required this.threshold,
    required this.axisColor,
    required this.accent,
    required this.textStyle,
  });

  /// Where coding agents arrived, on the x axis.
  static const _agentsX = 0.7;

  final String yLabel;
  final List<_Series> series;
  final (double, String)? threshold;
  final Color axisColor;
  final Color accent;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(32, 28, size.width - 8, size.height - 28);
    Offset toCanvas(Offset point) => Offset(
      chart.left + point.dx * chart.width,
      chart.bottom - point.dy * chart.height,
    );

    final axis = Paint()
      ..color = axisColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    canvas
      ..drawLine(chart.topLeft, chart.bottomLeft, axis)
      ..drawLine(chart.bottomLeft, chart.bottomRight, axis);

    canvas
      ..save()
      ..translate(8, chart.center.dy)
      ..rotate(-math.pi / 2);
    _text(yLabel).paint(canvas, Offset(-_text(yLabel).width / 2, -2));
    canvas.restore();

    _text('2020').paint(canvas, Offset(chart.left, chart.bottom + 6));
    final today = _text('Today');
    today.paint(canvas, Offset(chart.right - today.width, chart.bottom + 6));

    if (threshold case (final y, final label)) {
      final lineY = toCanvas(Offset(0, y)).dy;
      _dashedLine(
        canvas,
        Offset(chart.left, lineY),
        Offset(chart.right, lineY),
        Hues.emeraldLight.withValues(alpha: 0.8),
      );
      final text = _text(label, color: Hues.emeraldLight);
      text.paint(canvas, Offset(chart.left + 12, lineY - text.height - 4));
    }

    _paintLines(canvas, chart, toCanvas);

    final agentsX = toCanvas(const Offset(_agentsX, 0)).dx;
    _dashedLine(
      canvas,
      Offset(agentsX, chart.top),
      Offset(agentsX, chart.bottom),
      accent.withValues(alpha: 0.7),
    );
    final agents = _text('🤖 Coding agents', color: accent);
    agents.paint(canvas, Offset(agentsX - agents.width / 2, 0));
  }

  void _paintLines(
    Canvas canvas,
    Rect chart,
    Offset Function(Offset) toCanvas,
  ) {
    for (final (index, line) in series.indexed) {
      if (line.label.isNotEmpty) {
        final legendY = chart.top + 12 + index * 26;
        canvas.drawLine(
          Offset(chart.left + 16, legendY),
          Offset(chart.left + 36, legendY),
          Paint()
            ..color = line.color
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
        final text = _text(line.label, color: line.color, bold: true);
        text.paint(canvas, Offset(chart.left + 46, legendY - text.height / 2));
      }

      final points = line.points.map(toCanvas).toList();
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      _curveThrough(path, points);
      canvas
        ..drawPath(
          path,
          Paint()
            ..color = line.color.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        )
        ..drawPath(
          path,
          Paint()
            ..color = line.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  /// Extends [path], which is at the first of [points], through the others.
  void _curveThrough(Path path, List<Offset> points) {
    for (final (index, to) in points.indexed.skip(1)) {
      // Horizontal tangents at each point, for smooth S-shaped segments.
      final from = points[index - 1];
      final midX = (from.dx + to.dx) / 2;
      path.cubicTo(midX, from.dy, midX, to.dy, to.dx, to.dy);
    }
  }

  TextPainter _text(String text, {Color? color, bool bold = false}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          color: color,
          fontWeight: bold ? FontWeight.w700 : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _dashedLine(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final length = (to - from).distance;
    final direction = (to - from) / length;
    for (var start = 0.0; start < length; start += 10) {
      canvas.drawLine(
        from + direction * start,
        from + direction * math.min(start + 5, length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrendChartPainter oldDelegate) =>
      oldDelegate.axisColor != axisColor ||
      oldDelegate.accent != accent ||
      oldDelegate.textStyle != textStyle;
}

class _DoDontCard extends StatelessWidget {
  const _DoDontCard({
    required this.dont,
    required this.code,
    this.secondCode,
    this.footer,
  });

  final bool dont;
  final String code;

  /// Another file, shown below [code].
  final String? secondCode;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          H3(
            dont ? "❌ DON'T" : '✅ DO',
            fontSize: 17.6,
            color: dont ? Hues.roseLight : Hues.emeraldLight,
            textAlign: TextAlign.left,
          ),
          CodeBlock(code),
          if (secondCode case final secondCode?) ...[
            const SizedBox(height: 12),
            CodeBlock(secondCode),
          ],
          if (footer case final footer?)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Md(
                footer,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14.4,
                  height: 1.5,
                  color: Palette.of(context).textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SharedPackageDiagram extends StatelessWidget {
  const _SharedPackageDiagram();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);

    Widget chip(String label, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: palette.isLight ? Hues.codeBg : const Color(0x66000000),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(6.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: Fonts.code,
            fontSize: 12.8,
            color: color,
          ),
        ),
      );
    }

    Widget output(String emoji, String title, Color color, String body) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: palette.isLight
              ? palette.cardBg
              : const Color.fromRGBO(15, 23, 42, 0.85),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22.4)),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Md(
              body,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13.6,
                height: 1.45,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: palette.isLight
            ? palette.surface
            : const Color.fromRGBO(9, 13, 22, 0.7),
        border: Border.all(color: Hues.sky.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(13.6),
      ),
      child: Column(
        spacing: 12,
        children: [
          DiagramBox(
            highlight: true,
            gradient: const [Hues.sky, Hues.purple],
            maxWidth: 750,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Column(
              children: [
                Text(
                  '📦 Shared Core Dart Package',
                  style: TextStyle(
                    fontFamily: Fonts.heading,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.4,
                    color: palette.heading,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    chip('package:vm_service', Hues.sky),
                    chip('package:analyzer', Hues.purpleLight),
                    chip('shared state logic', Hues.emeraldLight),
                  ],
                ),
              ],
            ),
          ),
          const Arrows(['↙', '↘'], maxWidth: 750),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Grid(
              columns: 2,
              gap: 20,
              children: [
                output(
                  '🖥️',
                  'DevTools Extension (GUI)',
                  Hues.sky,
                  'Visual inspector, state timelines, & interactive controls '
                      'for **Human Developers 👨‍💻**',
                ),
                output(
                  '🤖',
                  'MCP Server (JSON-RPC)',
                  Hues.purpleLight,
                  'Exposes tool schemas & state query endpoints for '
                      '**AI Agents 🧠**',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
