// Slides are hardcoded text by nature.
// ignore_for_file: lints_plugin/avoid_hardcoded_string

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'src/example_1/models.dart';
import 'src/example_1/shop_app.dart';
import 'theme.dart';
import 'widgets.dart';

class SlideData {
  const SlideData({
    required this.title,
    required this.topic,
    required this.notes,
    required this.child,
    this.example,
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
}

const _testingTipLintDont = '''
// test/lint_test.dart
test(() async {
  final result = analyze(\'\'\'
class GoodCase {}

class BadCase {}
\'\'\');
});''';

const _testingTipLintDo = '''
// test/lint.dart
class GoodCase {}

// ignore: my_lint/code
class BadCase {}''';

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
    topic: Topic.intro,
    notes:
        "I've always been passionate about building tools that empower "
        'developers, from code generators to ecosystem tooling across Riverpod '
        'and Provider projects.',
    child: _ImageSlide(
      title: 'I Love Building Tools',
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
        ],
      ),
    ),
  ),
  const SlideData(
    title: 'Original Plan vs AI Reality',
    topic: Topic.intro,
    notes:
        "So we'll still talk about tooling for your own personal apps. But "
        "I'll contextualize it in the modern AI era: Why create tools, When "
        'to/not to, Which tool to create, and How to create them.',
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
    title: 'Why Create Tools?',
    topic: Topic.why,
    notes:
        'Skills are dead easy but non-deterministic and pricy long-term. Lints '
        'sound scary but are 100% deterministic.',
    child: ContentSlide(
      title: 'Why Create Tools? (Tools vs. Skills)',
      children: [
        Callout(
          'Consider enforcing style guides: *"Do not hardcode text inside '
          'Widgets"*. We could write an AI Skill, or a custom Lint rule plugin.',
          top: 0,
        ),
        SizedBox(height: 8),
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'Approach A: Writing an AI Skill',
                items: [
                  '**Dead easy to write** in markdown.',
                  '**Non-deterministic**',
                  '**Context Bloat**',
                  '**Pricy long term**',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Approach B: Custom Lint Rule Plugin',
                items: [
                  '**Sounds scary to do**',
                  '**Deterministic**',
                  '**Zero runtime token cost**',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Danger: Token Consumption Spikes',
    topic: Topic.why,
    notes:
        'Danger: Broad or poorly scoped skills (like scanning an entire '
        'repository on every PR) cause massive context bloat and token '
        'consumption spikes over time.',
    child: BadgeCardSlide(
      danger: true,
      children: [
        BadgeTitle('Bad skills can cause token consumption spikes.'),
        BadgeSubtitle(
          '*"Scan the codebase for hardcoded text"* vs. '
          '*"Scan only the files modified in the PR"*',
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Pro Tip: Write Tools with AI',
    topic: Topic.why,
    notes:
        'Key takeaway: Shift from using AI to perform repetitive manual tasks '
        'to using AI to generate deterministic tools (lints, scripts, codegen) '
        'that perform those tasks for you.',
    child: BadgeCardSlide(
      children: [
        BadgeTitle(
          'Instead of using AI to do a task, use AI to write a tool that will '
          'do said task.',
        ),
        BadgeSubtitle(
          '*"Hey Gemini, create a new lint rule using '
          "analysis_server_plugin. This lint rule should disallow using ' "
          'and " inside Widgets."*',
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'ROI & Decision Math',
    topic: Topic.why,
    notes:
        'This ignores maintenance cost or bug reduction, but helps detect '
        'cases where gain is too small compared to investment.',
    child: ContentSlide(
      title: 'When to (and NOT to) Build a Tool',
      children: [
        P(
          "Don't spend 10 days and millions of tokens creating a tool that "
          'runs once and saves 30 minutes. Calculate time gained:',
        ),
        SizedBox(height: 8),
        Grid(
          columns: 2,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FeatureList(top: 0, [
                  '**Team Compounding:** Small weekly time savings per dev '
                      'compound into major annual team gains.',
                  '**AI Shifts the Equation:** Building a tool with AI in 4 '
                      'hours instead of 40 hours makes ROI break-even almost '
                      'immediate.',
                ]),
                Callout(
                  '⚠️ **Token Expense:** Running a tool for 30s 1,000 times/yr '
                  'costs electricity. Running an agent for that costs '
                  'thousands of dollars on tokens.',
                  fontSize: 14.4,
                ),
              ],
            ),
            _RoiCalculator(),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Tooling Taxonomy',
    topic: Topic.why,
    notes:
        "Let's look at each tool category in detail: Pros, Cons, Personal "
        'Recommendations, and Testing Tips!',
    child: ContentSlide(
      title: 'Which Tool Should You Create?',
      children: [
        P(
          'There are many different kinds of developer tools available in '
          'Dart/Flutter:',
        ),
        SizedBox(height: 8),
        Grid(
          columns: 3,
          gap: 16,
          children: [
            _TaxonomyCard(
              'Custom Lints',
              'Enforce code conventions & prevent bugs via analyzer plugins.',
            ),
            _TaxonomyCard(
              'Code Generators',
              'Ensure consistency & deterministic updates across data models.',
            ),
            _TaxonomyCard(
              'CLIs & Scripts',
              'Universal scripting interface for Humans, CI, and AI agents.',
            ),
            _TaxonomyCard(
              'MCP Servers',
              'Stateful Model Context Protocol servers for AI agents.',
            ),
            _TaxonomyCard(
              'DevTools Extensions',
              'Visual GUIs & inspectors for human developers and QA.',
            ),
            _TaxonomyCard(
              'Codemods & Docs',
              'Automated API refactoring, architecture graphs, & docs.',
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Tool: Custom Lints',
    topic: Topic.lints,
    notes:
        'Personal note: I highly recommend every project implement custom '
        'lint rules. You can automate a significant part of your styleguide in '
        'a few hours.',
    child: ContentSlide(
      title: 'Custom Lints (analysis_server_plugin)',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'Pros',
                items: [
                  '**Cheap to build**',
                  '**Naturally visible** to Humans, AIs, and CI via '
                      '`dart analyze`.',
                  '**Empowers AI by design**',
                ],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Cons',
                items: [
                  '**RAM cost**',
                  'Slows down `dart analyze` slightly to spawn plugins.',
                  'Not everything in styleguides can be implemented as a lint.',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Testing Tip: Custom Lints',
    topic: Topic.lints,
    notes: 'Testing tip for custom lints.',
    child: BadgeCardSlide(
      maxWidth: 1000,
      children: [
        BadgeTitle('Testing Tip: Custom Lints', bottom: 32),
        Grid(
          columns: 2,
          gap: 24,
          children: [
            _DoDontCard(dont: true, code: _testingTipLintDont),
            _DoDontCard(
              dont: false,
              code: _testingTipLintDo,
              footer:
                  'And enable the lint on your project, alongside '
                  '[`unnecessary_ignore`](https://dart.dev/tools/linter-rules/unnecessary_ignore)',
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
    topic: Topic.lints,
    notes:
        'Quick fixes accompany lint rules, but AI often edits code directly '
        'instead of using quick fixes.',
    child: ContentSlide(
      title: 'Quick Fixes & Automated Refactors',
      children: [
        Grid(
          columns: 2,
          children: [
            DeckCard(
              child: _CardContent(
                title: 'Pros',
                items: ['Cheap to build.', 'Good at scale for batch fixes'],
              ),
            ),
            DeckCard(
              child: _CardContent(
                title: 'Cons',
                items: [
                  '**A lot less useful**: Requires making a mistake first.',
                  'Writing automated fixes is often a lot more complex.',
                  'AIs are currently a bit bad at using quick-fixes',
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SlideData(
    title: 'Danger: Skip Quick Fixes',
    topic: Topic.lints,
    notes:
        'Skip writing quick fixes for internal team lints. AI handles code '
        'fixes reliably.',
    child: BadgeCardSlide(
      danger: true,
      children: [
        BadgeTitle("Don't bother writing fixes. AI takes care of it."),
        BadgeSubtitle(
          "We don't care about deterministic output for fixes — AI handles "
          'them effectively. Save effort unless maintaining open-source '
          'packages for thousands of developers.',
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
        "Thank you! Remember: Don't replace tools with prompts, use prompts to "
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.heading, palette.accent, Hues.violet],
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
                Hues.violet.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
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
                    colors: [palette.accent, Hues.violet],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'RR',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
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
  const _ImageSlide({required this.title, required this.child});

  final String title;
  final Widget child;

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
          constraints: const BoxConstraints(maxWidth: 950),
          child: child,
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
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Hues.sky, Hues.cyan],
          ).createShader(bounds),
          child: const H1('Conclusion', fontSize: 48),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.isLight
                  ? palette.cardBg
                  : const Color.fromRGBO(15, 23, 42, 0.85),
              border: Border.all(color: Hues.sky.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Hues.cyan.withValues(alpha: 0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Hues.sky.withValues(alpha: 0.15),
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
                        colors: [Hues.sky, Hues.cyan],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Thank You! Q & A',
          style: TextStyle(
            fontSize: 21.6,
            color: Hues.sky,
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
  });

  final String title;
  final String? description;
  final List<String> items;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        H3(title),
        if (description case final description?)
          P(description, fontSize: 15.2, bottom: 8),
        FeatureList(items, fontSize: fontSize),
      ],
    );
  }
}

class _TaxonomyCard extends StatelessWidget {
  const _TaxonomyCard(this.title, this.description);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [H3(title), P(description, fontSize: 13.6, bottom: 0)],
      ),
    );
  }
}

class _DoDontCard extends StatelessWidget {
  const _DoDontCard({required this.dont, required this.code, this.footer});

  final bool dont;
  final String code;
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

class _RoiCalculator extends StatefulWidget {
  const _RoiCalculator();

  @override
  State<_RoiCalculator> createState() => _RoiCalculatorState();
}

class _RoiCalculatorState extends State<_RoiCalculator> {
  final _devs = TextEditingController(text: '10');
  final _minutes = TextEditingController(text: '9');
  final _frequency = TextEditingController(text: '1');

  @override
  void dispose() {
    _devs.dispose();
    _minutes.dispose();
    _frequency.dispose();
    super.dispose();
  }

  int get _hoursSaved {
    double read(TextEditingController c) => double.tryParse(c.text) ?? 0;
    return (read(_devs) * read(_minutes) * read(_frequency) * 56 / 60).round();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.isLight
            ? palette.cardBg
            : const Color.fromRGBO(15, 23, 42, 0.85),
        border: Border.all(color: palette.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const H3('Interactive ROI Calculator', fontSize: 17.6),
          _row('Team Size (Devs):', _devs),
          _row('Task Time Saved (mins):', _minutes),
          _row('Frequency (per dev/wk):', _frequency),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.08),
              border: Border.all(color: palette.accent.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMATED ANNUAL TEAM SAVINGS',
                  style: TextStyle(fontSize: 12.8, color: palette.textMuted),
                ),
                Text(
                  '$_hoursSaved Hours',
                  style: TextStyle(
                    fontFamily: Fonts.heading,
                    fontSize: 28.8,
                    fontWeight: FontWeight.w800,
                    color: palette.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, TextEditingController controller) {
    final palette = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.4, color: palette.textMuted),
          ),
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.textMain.withValues(alpha: 0.05),
              border: Border.all(color: palette.cardBorder),
              borderRadius: BorderRadius.circular(6.4),
            ),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: palette.accent,
              style: TextStyle(
                fontFamily: Fonts.code,
                fontSize: 14.4,
                color: palette.heading,
              ),
              decoration: const InputDecoration.collapsed(hintText: null),
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
