// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'src/example_1/models.dart';
import 'src/example_1/shop_app.dart';
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

const _testingTipCodegenDont = '''
// test/generator_test.dart
test('test generator string output', () {
  final output = generate('class Foo {}');
  expect(
    output,
    contains('void foo() {}'),
  );
});''';

const _testingTipCodegenDo = '''
// test/integration/foo_test.dart
// Write target code, run generator & test runtime:
@data
class Foo {}

test('test runtime behavior', () {
  expect(Foo().toString(), 'Foo()');
});''';

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

const _demoCart = [CartItem('headphones'), CartItem('speaker', quantity: 2)];

final slides = <SlideData>[
  const SlideData(
    title: 'Title Slide',
    topic: Topic.intro,
    notes:
        'When I wrote the description for this talk, originally I planned on '
        'just talking about how to write Flutter DevTool extensions like the '
        'Riverpod extension with time travel. But the more I use AI, the more '
        'I realize: lots of developers are deferring programming to AI now.',
    child: _TitleSlide(),
  ),
  const SlideData(
    title: 'I Love Building Tools',
    steps: 2,
    topic: Topic.intro,
    notes:
        "I've always been passionate about building tools that empower "
        'developers, from code generators to ecosystem tooling across Riverpod '
        'and Provider projects.',
    child: _ImageSlide(
      title: 'I Love Building Tools',
      maxWidth: 1100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FramedImage(
            'assets/img/provider_generator.png',
            aspectRatio: 678 / 1096,
            maxHeight: 440,
          ),
          SizedBox(width: 16),
          FramedImage(
            'assets/img/riverpod_projects.png',
            aspectRatio: 924 / 1302,
            maxHeight: 440,
          ),
          SizedBox(width: 24),
          SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Reveal(
                  1,
                  child: _PubPackageCard(
                    name: 'custom_lint',
                    version: '0.8.1',
                    description:
                        'Lint rules are a powerful way to improve the '
                        'maintainability of a project. Custom Lint allows '
                        'package authors and developers to easily write '
                        'custom lint rules.',
                    publisher: 'invertase.io',
                    likes: '264',
                    points: '130',
                    downloads: '749k',
                  ),
                ),
                SizedBox(height: 16),
                Reveal(
                  2,
                  child: _PubPackageCard(
                    name: 'expect_error',
                    version: '1.0.16',
                    description:
                        'A testing utility for checking compilation errors',
                    publisher: 'dash-overflow.net',
                    likes: '6',
                    points: '110',
                    downloads: '5.9k',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
  const SlideData(
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
  const SlideData(
    title: 'Software Is Mostly Maintenance',
    steps: 2,
    topic: Topic.intro,
    notes:
        "AI didn't remove maintenance, it multiplied it. Every PR an agent "
        'opens is a PR someone has to review, and code someone has to keep '
        'working.',
    child: ContentSlide(
      title: 'Software Is Mostly Maintenance',
      children: [
        Grid(
          columns: 2,
          gap: 48,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FeatureList(fontSize: 20.8, gap: 18, top: 0, firstStep: 0, [
                  '**Writing the code:** a few days.',
                  '**Living with it:** years. Reviews, refactors, upgrades, '
                      'bugs, onboarding.',
                ]),
                SizedBox(height: 16),
                Reveal(
                  2,
                  child: Callout(
                    '**AI made writing cheap.** So we write more. So there is '
                    'more to maintain.',
                    fontSize: 19.2,
                  ),
                ),
              ],
            ),
            _TrendChart(
              yLabel: 'Time to implement a feature',
              stacked: true,
              series: [
                _Series('Coding', Hues.pumpkin, [
                  Offset(0, 0.6),
                  Offset(0.45, 0.58),
                  Offset(0.68, 0.54),
                  Offset(0.85, 0.16),
                  Offset(1, 0.1),
                ]),
                _Series('Review', Hues.wisteria, [
                  Offset(0, 0.22),
                  Offset(0.45, 0.22),
                  Offset(0.68, 0.23),
                  Offset(0.85, 0.3),
                  Offset(1, 0.33),
                ]),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Two Kinds of Software',
    steps: 1,
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
            _SoftwareKind(
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
            Reveal(
              1,
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
  const SlideData(
    title: 'Build a Lot of Tools',
    steps: 3,
    topic: Topic.intro,
    notes:
        'This is the thesis of the talk. The asymmetry from the previous slide '
        'means we can be much less picky about which tools are worth building. '
        'Not one big devtool per year, but dozens of small, cheap tools, each '
        'removing one bit of maintenance friction. The rest of the talk is '
        'about which ones, and how to make them pay off.',
    child: _BuildALotSlide(),
  ),
  const SlideData(
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
  const SlideData(
    title: 'Progressive Improvement',
    steps: 3,
    topic: Topic.why,
    notes:
        'Each review comment turned into a tool is one less thing to '
        'remember. Over time, the rules of the codebase live in CI, not in the '
        'heads of a few senior engineers.',
    child: _ProgressiveImprovementSlide(),
  ),
  const SlideData(
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
                        '**Pays electricity**',
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
  const SlideData(
    title: 'Same Prompt, Two Agents',
    steps: 1,
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
                '• Bash(git diff --name-only main)',
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
          1,
          child: Callout(
            '**On every PR, forever.** And the one figuring it out missed two.',
            top: 24,
          ),
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Tool: Custom Lints',
    steps: 8,
    topic: Topic.lints,
    notes:
        'Personal note: I highly recommend every project implement custom '
        'lint rules. You can automate a significant part of your styleguide in '
        'a few hours.',
    child: _CustomLintsSlide(),
  ),
  const SlideData(
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
  const SlideData(
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
  const SlideData(
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
  const SlideData(
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
  const SlideData(
    title: 'Danger: Never Grow the Baseline',
    topic: Topic.lints,
    notes:
        'The one rule of baselines: once created, they only shrink. '
        'Regenerating the baseline to silence a new warning defeats the lint. '
        'Have CI fail if the baseline gains entries.',
    group: #baseline,
    child: _BaselineSlide(showDanger: true),
  ),
  const SlideData(
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
  const SlideData(
    title: 'Tool: Code Generators',
    topic: Topic.codegen,
    notes:
        'Codegen is about zero PR review on boilerplate, uniform behavior, and '
        'deterministic updates when fields change.',
    child: ContentSlide(
      title: 'Code Generators: Rethinking the Main Value',
      children: [
        P(
          'Common Argument: *"Codegen reduces boilerplate."* → '
          "**I couldn't care less, especially with AI!**",
        ),
        SizedBox(height: 16),
        DeckCard(
          child: _CardContent(
            title: 'What Codegen is ACTUALLY About',
            items: [
              '**Reduce code to Review**',
              '**Ensures Consistency**',
              '**Update generated code is simple**',
            ],
          ),
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Pro Tip: Static Analyzability',
    topic: Topic.codegen,
    notes:
        'Annotations make code statically analyzable, compounding the power '
        'of downstream custom tools.',
    child: BadgeCardSlide(
      children: [
        BadgeTitle('Codegen makes code statically analyzable.'),
        BadgeSubtitle(
          "It's hard to know if `Translation.of().translate('settings_title')` "
          'is unused.\n'
          "It's easy to know if `Translation.of().settingsTitle` is unused.\n\n"
          "Delete the translation and you'll get a compilation error, ha!",
          height: 1.7,
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Codegen Decisions',
    topic: Topic.codegen,
    notes:
        'Many data layer codegen tools have existing open source packages. '
        'Simple Dart scripts that read JSON and output files count as codegen '
        'too!',
    child: ContentSlide(
      title: 'What to Automate with Codegen (and What to Avoid)',
      children: [
        Grid(
          columns: 3,
          gap: 20,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'Definitely Automate',
                fontSize: 14.4,
                items: [
                  '**Backend Data Layer**: GraphQL / Swagger / gRPC schemas to '
                      'Dart models.',
                  '**On-Device DB**: Table schemas.',
                  "**Assets**: `FontAwesome.check` instead of `'fa check'`.",
                  '**Translations**: `L10n.of(context).homePageTitle`.',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Maybe Automate',
                fontSize: 14.4,
                items: [
                  '**Routing**: Type safety on route parameters & static '
                      'route list.',
                  '**Design system browser**: Auto-generated widget browser '
                      'via `build_runner`.',
                  '**Error-Prone Tasks**: Auto-generated `toString` to '
                      'prevent stale fields.',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Do NOT Automate',
                fontSize: 14.4,
                items: [
                  "**Minor Boilerplate Gains** that aren't error prone (e.g. "
                      'my old `functional_widget` saving 2-3 lines on '
                      'StatelessWidgets).',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Pro Tip: Commit Generated Files',
    topic: Topic.codegen,
    notes: 'Commit generated files and let CI auto-commit codegen updates.',
    child: BadgeCardSlide(
      children: [
        BadgeTitle('Commit generated files & let CI auto-update them'),
        BadgeSubtitle(
          'Always commit generated files into source control.\n'
          'Configure your CI pipeline to auto-run codegen and commit updates '
          'when schemas change!',
          height: 1.7,
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Pro Tip: Simple Scripts over build_runner',
    topic: Topic.codegen,
    notes:
        'Simple Dart scripts that read JSON and output files count as codegen '
        'too!',
    child: BadgeCardSlide(
      children: [
        BadgeTitle('Codegen can be a basic Dart script'),
        BadgeSubtitle(
          'Codegen can be a basic Dart script reading JSON and outputting a '
          "file.\nIt doesn't have to be complex `build_runner` logic!",
          height: 1.7,
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Testing Tip: Code Generators',
    topic: Topic.codegen,
    notes:
        'Testing tip for code generators: avoid brittle string checks, test '
        'runtime behavior of generated files instead.',
    child: BadgeCardSlide(
      maxWidth: 1000,
      children: [
        BadgeTitle('Testing Tip: Code Generators', bottom: 32),
        Grid(
          columns: 2,
          gap: 24,
          children: [
            _DoDontCard(dont: true, code: _testingTipCodegenDont),
            _DoDontCard(dont: false, code: _testingTipCodegenDo),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Tool: CLIs',
    topic: Topic.cli,
    notes:
        'Bash can be daunting on Windows. Write Dart scripts instead! CLIs are '
        'universally usable by humans, AIs, and CI pipelines.',
    child: ContentSlide(
      title: 'Command Line Interfaces (CLIs)',
      children: [
        _CliDiagram(),
        Callout(
          '👍 Skip bash. Dart is a scripting language, write Dart scripts!',
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Pro Tip: Must-Have CLI Commands',
    topic: Topic.cli,
    notes:
        'Essential CLI commands to standardize setup, running, testing, and '
        'deploying across projects.',
    child: BadgeCardSlide(
      maxWidth: 950,
      children: [
        BadgeTitle('Must-Have Commands for All Projects', bottom: 16),
        FeatureList(top: 16, gap: 12.8, [
          '`./install`: Check Flutter/Dart versions, missing tools (Docker, '
              'CLIs), set up hidden `.env` & codegen. Link solutions for '
              'missing tools!',
          '`./run`: Start emulators, Docker, local servers.',
          '`./test`: Unit & integration tests on browser/simulators.',
          '`./deploy`: Update changelogs, bump versions, release flags, '
              'publish to stores.',
        ]),
      ],
    ),
  ),
  const SlideData(
    title: 'Danger: Avoid Module Templates',
    topic: Topic.cli,
    notes:
        'Avoid writing CLI module templates. AI handles module creation '
        'easily, and keeping templates updated is costly.',
    child: BadgeCardSlide(
      danger: true,
      children: [
        BadgeTitle('Skip Templates (Mason, etc)'),
        BadgeSubtitle(
          'High maintenance cost. Low usage rate. And AI is really good at '
          'this sort of task.',
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Testing Tip: CLI Tools',
    topic: Topic.cli,
    notes: 'Testing tip for CLI tools.',
    child: BadgeCardSlide(
      children: [
        BadgeTitle('Testing Tip: CLI Tools'),
        BadgeSubtitle('Integration tests are super easy with Process.run!'),
        SizedBox(height: 32),
        Center(
          child: CodeBlock(
            "Process.run('dart', ['path/to/bin.dart', '--machine']);",
            fontSize: 15.2,
          ),
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Tool: MCP Servers',
    topic: Topic.mcp,
    notes:
        'MCPs are the perfect abstraction when allowing LLMs to perform tasks '
        'that humans would generally do in a GUI.',
    child: ContentSlide(
      title: 'MCP Servers (Model Context Protocol)',
      children: [
        _McpDiagram(),
        Callout(
          '💡 **When to use MCP over CLI:** Long-lived servers save startup '
          "costs & persist state when human/CI CLI interaction isn't required.",
          fontSize: 15.2,
          top: 10,
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Tool: DevTools',
    topic: Topic.devtools,
    notes:
        'DevTools are built primarily for human developers, splitting into '
        'in-app inspectors for QA and external DevTools extensions for IDE '
        'debugging.',
    child: ContentSlide(
      title: 'DevTools Extensions: For Humans Only',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: '📱 In-App DevTools',
                items: [
                  '**On-Device Inspection**: Embedded directly inside the app '
                      'build for QA and devs.',
                  '**No Debugger Required**: Test feature flags, inspect '
                      'logs, & trigger state overrides on real hardware.',
                  '**Ideal For**: Manual QA testing, quick runtime tweaks, & '
                      'staging builds.',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: '🖥️ External DevTools Extensions',
                items: [
                  '**Flutter DevTools Suite Integration**: Embedded extension '
                      'tab inside standard DevTools.',
                  '**Debugger API & Analyzer**: Powered by `vm_service` & '
                      'static AST analysis.',
                  '**Ideal For**: Rich state tree inspectors, visual '
                      'debuggers, & time-travel state tracking.',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Example: Shoply',
    topic: Topic.devtools,
    notes:
        "Here's the app we'll build tools for: a small e-commerce app. "
        'Everything you see on the phone is derived from a single state object.',
    example: ShopApp(state: ShopState()),
    child: _ExampleSlide(
      title: 'Meet Shoply',
      points: [
        'A tiny e-commerce app: **catalog**, **product pages**, **cart** and '
            '**checkout**.',
        'Everything on screen is derived from **one state object**.',
      ],
      code: 'ShopState()',
    ),
  ),
  const SlideData(
    title: 'Example: Browsing',
    topic: Topic.devtools,
    notes: 'Users scroll through the catalog.',
    example: ShopApp(state: ShopState(catalogScroll: 480)),
    child: _ExampleSlide(
      title: 'Browsing the Catalog',
      points: ['Scroll position is UI state too.'],
      code: 'ShopState(catalogScroll: 480)',
    ),
  ),
  const SlideData(
    title: 'Example: Filtering',
    topic: Topic.devtools,
    notes: 'Users narrow down the catalog with categories.',
    example: ShopApp(state: ShopState(category: 'Audio')),
    child: _ExampleSlide(
      title: 'Filtering by Category',
      points: ['Filters change what the catalog shows.'],
      code: "ShopState(category: 'Audio')",
    ),
  ),
  const SlideData(
    title: 'Example: Product Details',
    topic: Topic.devtools,
    notes: 'Opening a product pushes a new page.',
    example: ShopApp(
      state: ShopState(category: 'Audio', productId: 'headphones'),
    ),
    child: _ExampleSlide(
      title: 'Opening a Product',
      points: ['Navigation is state: the page stack derives from it.'],
      code: '''ShopState(
  category: 'Audio',
  productId: 'headphones',
)''',
    ),
  ),
  const SlideData(
    title: 'Example: Add to Cart',
    topic: Topic.devtools,
    notes: 'Adding to cart updates the badge, the button, and the catalog.',
    example: ShopApp(
      state: ShopState(
        category: 'Audio',
        productId: 'headphones',
        cart: [CartItem('headphones')],
      ),
    ),
    child: _ExampleSlide(
      title: 'Adding to the Cart',
      points: ['One change, many widgets updated: badge, button, catalog.'],
      code: '''ShopState(
  category: 'Audio',
  productId: 'headphones',
  cart: [CartItem('headphones')],
)''',
    ),
  ),
  const SlideData(
    title: 'Example: Cart',
    topic: Topic.devtools,
    notes: 'The cart lists items and computes totals.',
    example: ShopApp(
      state: ShopState(
        category: 'Audio',
        productId: 'headphones',
        cart: _demoCart,
        cartOpen: true,
      ),
    ),
    child: _ExampleSlide(
      title: 'Reviewing the Cart',
      points: ['Totals and shipping are **derived** from the cart.'],
      code: '''ShopState(
  ...,
  cart: [
    CartItem('headphones'),
    CartItem('speaker', quantity: 2),
  ],
  cartOpen: true,
)''',
    ),
  ),
  const SlideData(
    title: 'Example: Checkout',
    topic: Topic.devtools,
    notes: 'Checkout summarizes the order before placing it.',
    example: ShopApp(
      state: ShopState(
        category: 'Audio',
        productId: 'headphones',
        cart: _demoCart,
        cartOpen: true,
        checkout: CheckoutStep.review,
      ),
    ),
    child: _ExampleSlide(
      title: 'Checking Out',
      points: ['Address, delivery & payment: more state to inspect.'],
      code: '''ShopState(
  ...,
  checkout: CheckoutStep.review,
)''',
    ),
  ),
  const SlideData(
    title: 'Example: Order Placed',
    topic: Topic.devtools,
    notes: 'And the order is placed.',
    example: ShopApp(
      state: ShopState(
        category: 'Audio',
        productId: 'headphones',
        cart: _demoCart,
        cartOpen: true,
        checkout: CheckoutStep.confirmed,
      ),
    ),
    child: _ExampleSlide(
      title: 'Order Placed',
      points: [
        'How did we get here? A DevTool could **replay every state change**.',
      ],
      code: '''ShopState(
  ...,
  checkout: CheckoutStep.confirmed,
)''',
    ),
  ),
  const SlideData(
    title: 'DevTool: Site Map',
    topic: Topic.devtools,
    group: _SiteMapExample.shoply,
    notes:
        'A first devtool for Shoply: a site map. Every page of the app, what '
        'can be tapped on it, and where each button leads. Like a Figma '
        'prototype, but for the real app.',
    child: _SiteMapSlide(
      title: 'A Site Map of Shoply',
      example: _SiteMapExample.shoply,
    ),
  ),
  const SlideData(
    title: 'DevTool: Site Map Screens',
    topic: Topic.devtools,
    group: _SiteMapExample.shoply,
    notes:
        'The same map, rendering the real pages instead of wireframes. Each '
        'page is filled with fake data, and arrows start from the actual '
        'buttons.',
    child: _SiteMapSlide(
      title: 'A Site Map of Shoply',
      example: _SiteMapExample.shoply,
      previews: true,
    ),
  ),
  const SlideData(
    title: 'DevTool: Site Map Dark Mode',
    topic: Topic.devtools,
    group: _SiteMapExample.shoply,
    notes:
        'The same pages, rendered in dark mode: every screen of the app '
        'checked at once, without clicking through the app on a device.',
    child: _SiteMapSlide(
      title: 'Previewing Dark Mode',
      example: _SiteMapExample.shoply,
      previews: true,
      settings: PreviewSettings(brightness: Brightness.dark),
    ),
  ),
  const SlideData(
    title: 'DevTool: Site Map Large Text',
    topic: Topic.devtools,
    group: _SiteMapExample.shoply,
    notes:
        'And with a large font, as set by users who need it. Layout issues '
        'show up on every page at once.',
    child: _SiteMapSlide(
      title: 'Previewing Large Text',
      example: _SiteMapExample.shoply,
      previews: true,
      settings: PreviewSettings(brightness: Brightness.dark, textScale: 1.6),
    ),
  ),
  const SlideData(
    title: 'DevTool: Review, Before',
    topic: Topic.devtools,
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
  const SlideData(
    title: 'DevTool: Review, After',
    topic: Topic.devtools,
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
  const SlideData(
    title: 'DevTool: Spot the Change',
    topic: Topic.devtools,
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
  const SlideData(
    title: 'DevTool: Highlighted Changes',
    topic: Topic.devtools,
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
  const SlideData(
    title: 'DevTool: In Code Review',
    topic: Topic.devtools,
    notes:
        'Tools like this one belong in CI too. On every pull request, render '
        'the site map, check that every page still renders and can be '
        'reached, and post the visual diff where the review happens. '
        'Reviewers see what users will see, not just lines of code.',
    child: _CodeReviewSlide(),
  ),
  const SlideData(
    title: 'Pro Tip: DevTools in the AI Era',
    topic: Topic.devtools,
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
  const SlideData(
    title: 'How to Make Tools',
    topic: Topic.creation,
    notes:
        'A large chunk of tools fall into static analysis (analyzer) or '
        'runtime tools (vm_service).',
    child: ContentSlide(
      title: 'How to Make Tools: Static vs. Runtime Analysis',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'Static Analysis (package:analyzer)',
                description:
                    "**Don't rely on greps/regex and string code parsing!** "
                    'Analyzer is a must for precise code views.',
                items: [
                  'List all classes across workspace.',
                  'Find everywhere a class is used.',
                  'Inspect methods, doc comments, annotations, and AST fields.',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Runtime Analysis (package:vm_service)',
                description:
                    'Inspect live application memory via VM Service URI (from '
                    'logs or VS Code clipboard).',
                items: [
                  'Arbitrary code execution (`eval(code)` like VS Code '
                      'Debugger Expression Evaluator).',
                  'Inspect full application memory.',
                  'List all object instances and read field values live.',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Case Study: Riverpod',
    topic: Topic.creation,
    notes:
        'By sharing analyzer utilities and vm_service logic, we can easily '
        'power lints, codegen, devtools, and MCP servers simultaneously.',
    child: ContentSlide(
      title: 'Practical Architecture: The Riverpod Tooling Suite',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'riverpod_lint & riverpod_generator',
                items: [
                  '**Shared Implementation**: All provider metadata parsing '
                      'logic is extracted into `riverpod_analyzer_utils` '
                      'library and used by both tools.',
                  'Technically allows anyone to build custom Riverpod lint '
                      'rules or documentation tools.',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Riverpod DevTool & MCP Refactor',
                items: [
                  'Uses `vm_service` to inspect running app & display all '
                      'providers and their states.',
                  'Supports **time travel** state history & live provider '
                      'modification.',
                  '**Current Refactor**: Extracting logic so a **Riverpod MCP '
                      'Server** can be created for AI agents!',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Role of AI Skills',
    topic: Topic.creation,
    notes:
        'Skills are for discoverability. Let tools document themselves '
        'through --help flags, MCP tool schemas, and Dart docs.',
    child: ContentSlide(
      title: 'So, When DO We Use Skills Then?',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'Skills ARE for Discoverability',
                items: [
                  "Installing a tool doesn't mean the AI knows it exists.",
                  'A simple prompt: *"You can inspect memory of the debugged '
                      'app using MyState MCP"* is enough for AIs to use it.',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: "DON'T Write Tool Manuals in Skills",
                items: [
                  'Tools have natural discovery mechanisms!',
                  'CLIs have `--help` (agents check this natively).',
                  'MCP servers list tools with descriptions.',
                  'Generators have READMEs and Dart doc comments.',
                ],
              ),
            ),
          ],
        ),
        Callout(
          "🚫 **Avoid Context Pollution:** Don't pollute prompt context with "
          'manuals the AI needs once in a blue moon. Using skills to solve '
          'coding problems directly is a last resort!',
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Conclusion',
    topic: Topic.conclusion,
    notes:
        "Thank you, and happy Halloween! Remember: Don't replace tools with prompts, use prompts to "
        'create your tools. Plus, all these tools can be written in Dart, so '
        "they're super easy to get started with!",
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
  const _ImageSlide({
    required this.title,
    required this.child,
    this.maxWidth = 950,
  });

  final String title;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Eyebrow(center: true),
        Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: H2(title, textAlign: TextAlign.center),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
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
            '**Skip quick fixes for in-house lints.** Write them for packages '
            'used by thousands of developers.',
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
  });

  final String title;
  final _SiteMapExample example;
  final bool previews;

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

class _ProgressiveImprovementSlide extends StatelessWidget {
  const _ProgressiveImprovementSlide();

  @override
  Widget build(BuildContext context) {
    return const BadgeCardSlide(
      maxWidth: 1000,
      children: [
        BadgeTitle('Progressive Improvement', bottom: 12),
        BadgeSubtitle(
          'As time passes, codebase rules become enforced by the CI, instead '
          'of living in the heads of engineers.',
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

/// A step of the example app walkthrough, shown next to the app itself.
class _ExampleSlide extends StatelessWidget {
  const _ExampleSlide({
    required this.title,
    required this.points,
    required this.code,
  });

  final String title;
  final List<String> points;

  /// The state the example is in, as Dart code.
  final String code;

  @override
  Widget build(BuildContext context) {
    return ContentSlide(
      title: title,
      children: [
        FeatureList(points, fontSize: 19),
        const SizedBox(height: 32),
        CodeBlock(code, fontSize: 17),
      ],
    );
  }
}

class _ConclusionSlide extends StatelessWidget {
  const _ConclusionSlide();

  static const _points = [
    "**Don't replace tools with prompts.** Use prompts to create your tools.",
    '**Avoid using Skills to solve problems.** Use them to make an agent '
        'discover the tools to solve said problem.',
    '**Building tools has never been easier** thanks to AI.',
    '**Write all tools in Dart:** Custom lints, codegen, CLIs, and MCP '
        'servers can all be written in Dart!',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎃', style: TextStyle(fontSize: 44)),
            const SizedBox(width: 20),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Hues.candyCorn, Hues.pumpkin, Hues.vermilion],
              ).createShader(bounds),
              child: const H1('Conclusion', fontSize: 48),
            ),
            const SizedBox(width: 20),
            const Text('👻', style: TextStyle(fontSize: 44)),
          ],
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.isLight
                  ? palette.cardBg
                  : const Color.fromRGBO(22, 12, 10, 0.88),
              border: Border.all(color: Hues.pumpkin.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Hues.pumpkin.withValues(alpha: 0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Hues.wisteria.withValues(alpha: 0.15),
                  blurRadius: 60,
                ),
              ],
            ),
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: FeatureList(_points, fontSize: 19.2, gap: 16, top: 0),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Hues.pumpkin, Hues.vermilion],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'ありがとう！ Trick or treat? Q & A 🍬',
          style: TextStyle(
            fontSize: 21.6,
            color: palette.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

/// The usual card body: a heading, an optional paragraph and a bullet list.
class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.title,
    required this.items,
    this.description,
    this.fontSize = 16.8,
    this.firstStep,
  });

  final String title;
  final String? description;
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
        if (description case final description?)
          P(description, fontSize: 15.2, bottom: 8),
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
              'Building custom tools became so cheap with AI that it is worth '
              'building **a lot of them**, to improve maintenance on what you '
              'ship to users.',
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
            const Reveal(
              1,
              child: _TrendChart(
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
            ),
            const SizedBox(height: 24),
            const Grid(
              columns: 2,
              gap: 24,
              children: [
                Reveal(
                  2,
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
                  3,
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
    required this.title,
    required this.color,
    required this.revealDuration,
    required this.seconds,
    required this.tokens,
    required this.lines,
  });

  static const _prompt = 'Check this PR for hardcoded strings';

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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: revealDuration,
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
                  '> $_prompt',
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
///
/// In a stacked chart, the y of [points] is the thickness of the band instead.
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
    this.stacked = false,
    this.height = 320,
  });

  final String yLabel;
  final List<_Series> series;

  /// Draws [series] as bands stacked on top of each other, instead of lines.
  /// The points of all series must share the same x.
  final bool stacked;

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
          stacked: stacked,
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
    required this.stacked,
    required this.axisColor,
    required this.accent,
    required this.textStyle,
  });

  /// Where coding agents arrived, on the x axis.
  static const _agentsX = 0.7;

  final String yLabel;
  final List<_Series> series;
  final (double, String)? threshold;
  final bool stacked;
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

    if (stacked) {
      _paintBands(canvas, chart, toCanvas);
    } else {
      _paintLines(canvas, chart, toCanvas);
    }

    final agentsX = toCanvas(const Offset(_agentsX, 0)).dx;
    _dashedLine(
      canvas,
      Offset(agentsX, chart.top),
      Offset(agentsX, chart.bottom),
      // White stands out over the colored bands of stacked charts.
      (stacked ? Colors.white : accent).withValues(alpha: 0.7),
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

  void _paintBands(
    Canvas canvas,
    Rect chart,
    Offset Function(Offset) toCanvas,
  ) {
    var bottom = [for (final point in series.first.points) Offset(point.dx, 0)];
    for (final band in series) {
      final top = [
        for (final (index, point) in band.points.indexed)
          bottom[index].translate(0, point.dy),
      ];
      final upper = top.map(toCanvas).toList();
      final lower = bottom.map(toCanvas).toList().reversed.toList();

      final area = Path()..moveTo(upper.first.dx, upper.first.dy);
      _curveThrough(area, upper);
      area.lineTo(lower.first.dx, lower.first.dy);
      _curveThrough(area, lower);
      area.close();
      final edge = Path()..moveTo(upper.first.dx, upper.first.dy);
      _curveThrough(edge, upper);
      canvas
        ..drawPath(
          area,
          // Opaque, so that bands read as solid blocks over the background.
          Paint()
            ..color = Color.alphaBlend(
              band.color.withValues(alpha: 0.7),
              Hues.codeBg,
            ),
        )
        ..drawPath(
          edge,
          Paint()
            ..color = band.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );

      final label = _text(band.label, color: Colors.white, bold: true);
      final labelY = toCanvas(Offset(0, (bottom.first.dy + top.first.dy) / 2));
      label.paint(
        canvas,
        Offset(chart.left + 12, labelY.dy - label.height / 2),
      );

      bottom = top;
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

class _CliDiagram extends StatelessWidget {
  const _CliDiagram();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return DeckCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const H3(
            'CLI as Universal Interface Layer',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Column(
            spacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const Grid(
                  columns: 3,
                  gap: 16,
                  children: [
                    DiagramNode(
                      emoji: '👨‍💻',
                      title: 'Humans',
                      caption: 'Terminal / Scripts',
                      color: Hues.sky,
                      tint: Hues.sky,
                    ),
                    DiagramNode(
                      emoji: '🤖',
                      title: 'AI Agents',
                      caption: 'Tool Calling / Exec',
                      color: Hues.purpleLight,
                      tint: Hues.purple,
                    ),
                    DiagramNode(
                      emoji: '⚙️',
                      title: 'Tools & GUIs',
                      caption: 'CI Pipelines / IDEs',
                      color: Hues.emeraldLight,
                      tint: Hues.emerald,
                    ),
                  ],
                ),
              ),
              const Arrows(['↓', '↓', '↓']),
              DiagramBox(
                highlight: true,
                gradient: const [Hues.sky, Hues.emerald],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Text.rich(
                  TextSpan(
                    text: '💻 CLI Abstraction Layer ',
                    children: [
                      TextSpan(
                        text: '(Dart Scripts / Executables)',
                        style: TextStyle(
                          color: palette.accent,
                          fontSize: 14.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.code,
                    fontWeight: FontWeight.w700,
                    fontSize: 17.6,
                    color: palette.heading,
                  ),
                ),
              ),
              const Arrows(['↓']),
              DiagramBox(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Text(
                      'Underlying Project Actions',
                      style: TextStyle(
                        fontSize: 15.2,
                        fontWeight: FontWeight.w700,
                        color: palette.calloutText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Environment Setup • Emulators & Docker • Tests • '
                      'Codegen • Deployments',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.6, color: palette.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _McpDiagram extends StatelessWidget {
  const _McpDiagram();

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return DeckCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const H3(
            'MCP Architecture: Connecting AI Agents to App State',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Column(
            spacing: 10,
            children: [
              const DiagramNode(
                emoji: '🤖',
                title:
                    'AI Agent (LLM Client / Cursor / Claude Desktop / Custom '
                    'Agent)',
                caption:
                    'Discovers tool schemas & invokes actions autonomously',
                color: Hues.purpleLight,
                tint: Hues.purple,
                emojiSize: 20.8,
                titleSize: 15.2,
                captionSize: 12.5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  const Arrows(['↓'], maxWidth: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.1),
                      border: Border.all(
                        color: palette.accent.withValues(alpha: 0.25),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'JSON-RPC over Stdio / HTTP',
                      style: TextStyle(
                        fontFamily: Fonts.code,
                        fontSize: 13.6,
                        fontWeight: FontWeight.w600,
                        color: palette.accent,
                      ),
                    ),
                  ),
                  const Arrows(['↓'], maxWidth: 20),
                ],
              ),
              DiagramBox(
                highlight: true,
                gradient: const [Hues.sky, Hues.purple],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text.rich(
                  TextSpan(
                    text: '⚡ MCP Server ',
                    children: [
                      TextSpan(
                        text:
                            '(package:dart_mcp — Stateful / Long-Lived Server)',
                        style: TextStyle(
                          color: palette.accent,
                          fontSize: 13.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.code,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.8,
                    color: palette.heading,
                  ),
                ),
              ),
              const Arrows(['↓', '↓']),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const Grid(
                  columns: 2,
                  gap: 16,
                  children: [
                    DiagramNode(
                      emoji: '🛠️',
                      title: 'Tools',
                      caption:
                          'Executable actions, API probes, app control, & '
                          'state mutation',
                      color: Hues.sky,
                      emojiSize: 20,
                      titleSize: 15.2,
                    ),
                    DiagramNode(
                      emoji: '📁',
                      title: 'Files & Resources',
                      caption:
                          'Workspace files, logs, URIs, test fixtures, & '
                          'documentation',
                      color: Hues.emeraldLight,
                      emojiSize: 20,
                      titleSize: 15.2,
                    ),
                  ],
                ),
              ),
            ],
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
