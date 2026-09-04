When I wrote the description for this talk, originally I planned on just talking things such as how to write Flutter Devtool extensions.
I wanted to talk about how I made the tools for Riverpod. Like the devtool extension, with time travel and etc.
And I wanted to broaden in onto how you could do the same thing tailored to your specific apps, and write shell scripts, lints, devtools, etc

But the more I use AI, the more I realise: Lots of you are deffering a large part of the programming to AI now.
So... It feels a bit awkward to explain how to code a devtool extension by hand:

- If you're coding through AI, you're probably not running tools yourself anymore. Ai does.
- Even if you do want a devtool extension, you'd probably ask AI to write it.

So we'll still talk about tooling for your own personal apps. But I'll contextualize it in the modern AI era.

Why create tool
When to/no to
Which tool
How to create

> Make them machine readable
> Human operatable too
> How to test

---

# Why create tools

Especially in the world of AI, all tool creation is put against 'why not write a skill instead?'

Consider wanting to enforce programming styleguides, like say 'Do not hardcode text in widgets'.
We could write a skill. Or we could write a lint rule plugin.

Skill:

- Dead easy
- Non-deterministic.
  AI can ignore cases sometimes. Mistakes can slip by, and start to accumulate.
  Similarly a model change can impact the efficiency of your skill
- Context bloat
  The more skills you add, the more you overwhelm the agent with unrelated context, the costlier it becomes and the more likely it is to miss a step
- Pricy on the long run. Agents aren't free

Custom lint rule:

- Sound scary to do. Not the kind of thing you normally do in day-to-day work, so probably no previous experience
- Deterministic. It will always do the same thing. There can be bugs in your lint, but as a whole, the behavior is predictable

> [!NOTE] Instead of using AI to do a task, use AI to write a tool that will do said task.
> 'Hey gemini, create a new lint rule using dart_analysis_server_plugin. This lint rule should disallow using ' and " inside Widgets'.
> Initial cost slightly higher than skill, long term economy and reliability win (within reasons)

> [!DANGER]
> AI price can ramp up with bad skills.
> A skill that runs on every PR saying 'Scan the codebase for hardcoded text' will cost a lot of money over time, due to doing tons of file reads on every PR.
> You could reduce the cost by saying 'scan only the files modified in the PR', but english is subtle. AIs may still read way more files than you intended. And you're probably not checking exactly what your AI is doing at all times.

INSERT video about prompt with and without skill next to each other, to show the difference in speed

# When to/not to

Don't spend 10 days and millions of tokens to create a tool that'll be ran once and saves 30 minutes.

You can usually do maths to calculate an estimate of costs and benefits. Calculate the estimate time gained.

- Consider a task that takes 10 minutes for a developper to do it by hand in a team of 10, where all developpers do said task weekly

  > That's 10 _ 10 _ 56 = 5600 minutes a year = 93 hours a year

- Now consider that with a tool, said task now takes 1mn. That's 9*10*56 = 5040 minutes a year = 84 hours a year possibly saved.
- Compare that save with the creation cost of the tool. If it takes one developer 10 days (40hours) you are dollar positive after
  about a year ; which is probably not worth it.
  If it takes you half a day instead, it takes 3 weeks to break even. Definitely more reasonable

Of course, this ignores lots of factors, like maintenance cost, or reducing bug probability. This is just an estimate
There's also opportunity cost lost working on other features.
But on its own that should help detect cases where the gain is too small compared to the investment.

Note:
You can use this to compare it with 'How much times and how much benefits we'd get from using AI Skills instead'.
Make sure to account for token expanditure too. Running a tool for 30 seconds 1000 times a year is just costing electricity. Running an agent for a similar amount is spending probably thousands of dollars on tokens.

# Which tool to create?

There are many different kinds of tool:

> Lint
> Code Generator
> CLI
> MCP Server
> Devtool
> codemods
> templates
> assists/refactors
> Automated docs (think architecture graphs, API docs...)

### Lint

Custom lint rules are a thing you can do officially since not that long ago.
You can use analysis_server_plugin to build your own lint rules.

Pros:

- Cheap to build. Once you have the linter project created, adding new lint rules often takes half an hour, including tests.
  It varies depending on the specific rule of course.
- Naturally visible to both Humans, AIs and your CI. Since it just relies on 'dart analyze', it can be integrated in pretty much any workflow.

Cons:

- Low end machines can struggle with the added RAM cost of running analyzer plugins
- It slows down 'dart analyze' having to spawn plugins
- Not everything in your styleguide can be implemented as a lint rule.

Personal note:
I would highly recommand every project to implement custom lint rules.

You can automate a significant part of your styleguide in a few hours.

Since the output is deterministic, it does not matter if your AI sometimes ignores your stylguide. Lints will catch it and the agent will keep running until diagnostics are fixed. Often you won't even have to ask anything

#### Testing tip

Lint rules can be tested by enabling the rule in your linter project, and just creating .dart files with various
examples of all the issues.
Then, for all the cases where a warning should be emitted, add an //ignore.
And to cover cases where no ignore should be emitted, enable 'unnecessary_ignore' to highlight ignores that do nothing.
This way, you can test your lints by just writing normal code and testing them with 'dart analyze'.

### Quick fixes

They usually go along lint rules.
They serve as an automated fix to the lint error.

Pros:

- Still quite cheap to build

Cons:

- A lot less useful (requires making a mistake first)
- Similarly to lints, writing an automated fix is not always possible.
- AIs are currently a bit bad at using quick-fixes. They'll often instead edit the code themselves instead of invoking the quick-fix.

Personal note:
For your average styleguide lint rules, I would skip on writing quick-fixes.
Not that they aren't useful. But we don't really care about having a deterministic output for fixes. AI will fix it for you, and they are
better at handling all sorts of cases.
Things become different is you start considering publishing your custom lint rules. Say you maintain an open source package,
a quick fix suddenly can reach an audience of thousands of developpers.

### Code-generators

This one has always been controversial. Some swear by it, others refuse to touch it.
I personally stand in the middle. I think it is a godsent for certain problems. But others gain very little from it.
In any case, when reading discussions about code-gen, I don't agree with the 'arguments for codegen' used.
Often, you'll see 'It reduces boilerplate' as main argument. But I couldn't care less, especially with AI.

For me codegen is about this:

- Codegen removes the need to do code review on chunks of the codebase. If using Freezed for instance, you don't read how copyWith
  is implement everytimes you add a new class.
- It ensures consistency. Generators are deterministics, so two data-classes using Freezed will have a very similar behavior
- More importantly, it makes updates simple.
  Programming is not just about the initial write. When you add or remove fields, you may have to update ==, hashCode, copyWith, toString, etc...
  Mistakes slips by. It's common to add a new field, but forget to update == too.
  Ai can help, but that's not deterministic.
  Codegen is a way to make this update deterministic.

Pros:

- Simpler reviews
- Uniform code
- Easier updates
- Makes code more statically analyzable (due to relying on annotations)
  This can compound with creating other tools.
- Possible bug reduction

Cons:

- Tooling cost

Things I would definitely automate with codegen:

- Data layer with the backend.
  Define a schema (GraphQL/Swagger/gRPC/etc) and use code-generation to generate a Model/Service layer.
- Same goes for your on-device database. Use a schema for tables and such.
- Assets. Instead of a broad `Image.assert('name')`, have a generator generate a wrapper class. Like `FontAwesome.check` instead of `'fa check'`
- Translations. `L10n.of(context).homePageTitle` instead of `L10n.of(context).translate('homePageTitle')`

> Most of these often have an alternative tech that supports codegen. This is not a new problem, so you may not need
> a custom generator for these and can use an Open Source one

What I _maybe_ would use codegen for:

- Routing.
  This enables statlically listing all routes.
  You get type safety on route parameters.
- Widget list. Using build_runner, you can generate a widget browser for your app.
  It avoids having to update it by hand.
- Tasks that are done many times but error prone.
  Think toString. Not much value in doing it by hand, but you don't want toString to get stale because you renamed the class or a field and forgot to update toString

What I would not use codegen for:

- Minor boilerplate gains that aren't error prone. Like my old functional_widget, which slightly reduces the boilerplate of writing StatelessWidgets.
  It saves 2-3 lines, but that's essentially the only gain (whereas there are a bunch of downsides).

TIP:
Consider commiting generated files, and have the CI automatically commit code-generation updates as part of a CI step.

TIP 2:
Code-gen doesn't have to be complex build-runner logic. Nor does it have to be relying on annotation inside Dart code.
A basic Dart script that reads a JSON/schema file and output another file is also a form of codegen.
build_runner is cool though. When you have lots of inputs/outputs; it enables only regenerating what is out of date.

#### Testing tips

Avoid tests that verify 'The generated code contains `void function()`'. This is brittle, as you're testing implemenentation details and this will break very often.
I've done that in functional_widget, but that made working on the project horrible, because any change in how the
generated code is written breaks tons of tests.

Instead prefer:

- Writing plain .dart files in test/integration/\* that use your code-geenrator. For example a `@data class Foo {}`
- Run the generator against your test folder
- Then write normal `test` that use said `Foo()` class to verify the behavior you expect.

# CLI

Think bash scripts.
Although we're in Dart land. And Dart is a very good scripting language. Write Dart scripts if you prefer!

Pros:

- Very versatile
- Easily usable by both humans, AIs, and other tools (CI, etc)
- Often cheap to build

Cons:

- Bash can be dauting, and windows users won't be happy. Use dart!
- Humans often prefer GUIs.

Must have for all projects:

- Install
  > Don't just to a pub get. Setup codegen, hidden .env file etc.
  > Check which version of Flutter/Dart is installed and reject non-conforming ones.
  > Detect early if you're missing some required tools (like Docker, specific CLIs, etc) to save hours of debugging for newcomers
  > If something is missing, link what should be done about it.
  > Make it so that a './install' sets up everything you need
- Run
  > Start emulators, docker, ...
- Test
  > Run both unit and integraction tests
  > Spawn a broswer or Android+iOS simulators
- Deploy
  > Update changelogs/versions
  > Publish to stores
  > Specify all the env variables and build with --release

Good to have:

- Static analysis devtools are good with CLI.
  You can have Dart scripts that use Analyzer and obtain all Models/Controllers/Repisitories in your app, and list their interactions
  You can also automate a graph generation

CLIs are a good abstraction layer for everything that you want both humans and machine to use.
If you create GUIs, it's often useful to have the GUI work by invoking your CLI instead of implementing everything in the GUI directly

Not very valuables

- Templates
  './create_module my_module' => creates packages/my_module/{pubspec.yaml, lib/, test/, } and updates the main package pubspec.yaml
  > AI can often do that too. And keeping them up-to-date is often costly. You also run them quite rarely.

### Testing tip

Integration tests for CLIs are super easy to make for the most part.
Especially since you can double dip by offering a --machine=json flag

Just write tests that do `Process.run('dart', ['path/to/my/bin.dart', '--my-flag'])` and check stdout/stderr/stdin.
No mock needed

## MCP servers

In case some of you are not familiar with the term, MCP stands for Machine Protocol.
It is essentially just a server, running either locally on your machine or on a different device,
that uses a specific protocol designed for AI agents.
This is how AI agents can read files or perform tool calls.

It sounds fancy. but we're using Dart! That's just about opening a websocket
and sending/receiving a JSON object.
Although if you don't want to deal with the transport hassle, there's an official Dart package for
writing MCP ; which takes care of the logic.

---

MCP servers are good for cases where a CLI isn't very beneficial.

- You need a long-lived server, to save on startup costs or to have persisted state
- Humans and other tools have no business interacting with it.

In general, prefer CLI over MCPs if they can also be used by humans or CIs or other command lines.
But I find MCPs good when you want to allow LLMs to do task that you would generally do in a GUI.

Consider manipulating an app.
Humans manipulate it by clicking on the scren. Tests do it with an internal protocol (test.tap, etc).
CIs have no business knowing how to clic on the app. And having 'flutter run' allow 'tap' commands would be weird.
An MCP to allow LLMs to manipulate the app is the perfect use-case for MCP servers.

> If you build a custom Routing or state management library, it could be useful to build an MCP to allow LLMs to query is and inspect
> the state of the app at runtime, instead of just looking at the code.

Tool idea:

- A way to do API calls with the current user token, so that agents can poke at the API to debug
- Make a debug-only API endpoint that list various test users and their metadata.
- Teach AI how to login/logout of your app and how to access specific routes
- THis can enable 'Find a user capable of displaying X in page Y', where the agent repeatedly login/logout and navigate until a specific widget appears on screen.

## Devtools

Devtools are the other side of the MCP coin. They are often used for similar purposes, but destined for Humans instead.
If you built a custom state management or routing system, you might want a state inspector or a routing tree viewer, with a pretty GUI

They can be in-app, or can be Flutter Devtool extensions.

- In-app devtools have the benefit of being usable after the app has been built and QA is testing it. Helps debugging :)
- External devtools are often more powerful, thanks to being able to rely on the debugger API or static analysis or reading the source.

In modern age you probably don't want to write _just_ a devtool. You'll want to make it usable by AIs too if possible.

For example, if you build an in-app list of logs, it's best if you can expose an MCP server allows LLMs to access said log list while the debugger is running.

Tool idea:

- A list of all logs and network requests in app
- Theme switchers

# How to make

A large chunks of tools tend to fall in two categories:

- Static analysis. They'll rely on analyzer (lints, generators, generated docs, ...)
- Runtime tools. Depending on vm_service to inspect with the running app.

For static analysis, dont rely in greps/regex and code parsing. Analyzer is a must. It'll give you a much more precise view of the code.

Static Analysis can do things such as:

- List all classes
- Find everywhere a class is used
- inspect all of its methods, docs, annotations, etc.

Runtime analysis on the other hand rely on vm_service. It allows:

- Arbitrary code execution. Think 'eval(code)'. This is how VScode's Debugger 'Evaluate Expression' works.
- Inspecting the full memory of the application.
  Including things like:
  - Listing all object instances
  - Obtain metadata about such objects, including obtaining the value of all fields.

VM_service relies on first finding a 'vm_service URI'. This is one of the first things logged when you start your Flutter app.
You can also do VScode > copy VM Service URI to clipboard

# Practical examples

Riverpod_lint and riverpod_generator

> Shared implementation. All the 'parse provider metadata' logic is shared in a riverpod_analyzer_utils library and used by both tools.
> You could technically use it to build your own Riverpod lint rules or custom docs tools and such

Riverpod devtool

> Use vm_service to inspect a running Flutter app and provide a UI to display all providers, their state.
> Supports going back in time to view the state history
> Supports modifying providers

> It is currently being partly rewritten to extract the logic, so that a Riverpod MCP server could be created

# So, when do use skills then?

Skills are good for discoverability. You may have installed a tool, but that does not mean the AI knows said tool exists.
A simple 'You can inspect the memory of the debugged application using MyState MCP' is generally enough for AIs to use it on their own.

DON'T write docs on how to use said tool in the skill. All AI tools have some form of natural way to get that info.
For example, a CLI should have a --help. Agents will naturally check that --help
An MCP will list its tools with a small description that the agent can use.
A generator will have a readme or an annotation (with Dart documentation on that annotation).

This avoids polluting context with things that the AI needs once in a blue moon.

Using skills to solve problems are a last resort:
U

# The AI Tooling Philosophy (Conclusion / Takeaway)

Don't replace tools with prompts. Use prompts to create your tools.
Avoid using Skills to solve problems. Use them to make an agent discover the tools to solve said problem.
You'll improve code quality thanks to determinism, often reduce time taken, and price paid to OpenAI.
