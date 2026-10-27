# Draft: slide-by-slide rework

> Draft based on `rework.md`. Each slide has its **content** (what's on screen) and **notes**
> (what I say). `[KEEP]` = existing slide, `[EDIT]` = existing slide reworked, `[NEW]` = to build.
> Shoply is used as the running example throughout (to confirm).

---

## Act 0: Why build tools now

### 1. Title `[KEEP]`

🏮 ハロウィン · Halloween Edition 🏮
**Build devtools for your app** _(title TBD)_
道具を作ろう 👻

**Notes:** When I wrote the description for this talk, I planned to talk about writing DevTool
extensions, like the Riverpod one with time travel.

### 2. I love building tools `[KEEP]`

Images: provider generator, Riverpod projects.

**Notes:** Generators, lints, devtools… I've been building tools for the Flutter ecosystem for years.

### 3. The original plan vs. the AI reality `[KEEP]`

Image: the elephant.

**Notes:** Lots of you now delegate a big part of the programming to AI. Explaining how to
hand-write a devtool extension feels awkward. You probably aren't running tools yourself anymore:
your agent is. So this talk is about building tools in the AI era, and why we need them more than ever.

### 4. Software is mostly maintenance `[NEW]`

- Writing the code: a few days.
- Living with it: years. Reviews, refactors, upgrades, bugs, onboarding.
- **AI made writing cheap. So we write more. So there is more to maintain.**

Visual: two curves, "code written" going up steeply and "review & maintenance cost" following it.

**Notes:** AI didn't remove maintenance, it multiplied it. Every PR an agent opens is a PR
someone has to review, and code someone has to keep working.

### 5. Two kinds of software `[NEW]`

| Shipped to users                    | Internal tools                    |
| ----------------------------------- | --------------------------------- |
| Thousands of users, unknown devices | A handful of devs, known machines |
| Every line reviewed                 | Barely reviewed                   |
| Bugs are costly                     | A bug costs a restart             |
| **Expensive, slow**                 | **Cheap. Let AI write it.**       |

**Notes:** A lint, a CLI or a debug panel doesn't need the care of production code. A prompt and a
quick check is enough. What used to be a week-long side project is now an afternoon.

### 5b. So: build a lot of tools `[NEW]`

Big statement slide:

> **Building custom tools became so cheap with AI that it's worth building a lot of them,
> for the sake of improving maintenance on what you ship to users.**

Visual: a graph of the cost of building a custom tool over the years (illustrative, no real data).
Flat and high for a long time (a lint = an afternoon of analyzer docs, a devtool = weeks), then a
sharp drop when coding agents arrive (~2024–2025), falling below a dashed "worth building" line.

Under the graph, two columns (before / after the drop):

| Before | Now |
|---|---|
| Only specialized engineers working full-time on OSS build devtools | So cheap and simple you can build a devtool in the middle of a rush |

**Notes:** This is the thesis of the talk. The asymmetry from the previous slide means we can be
much less picky about which tools are worth building. Not one big devtool per year, but dozens of
small, throwaway-cheap tools, each removing one bit of maintenance friction. The rest of the talk
is about which ones, and how to make them pay off.

### 6. Turn review comments into tools `[EDIT]` _(moved from the lints section)_ _(\_ReviewToLintSlide)_

**Notes:** When you write the same review comment for the third time, stop. That comment should
become a PR adding a tool (here, a lint). Then nobody has to write, or read, that comment again.

### 7. Prompt or program? `[EDIT]` _(was "Why Create Tools?")_

Example: "Don't hardcode text in widgets."

| Skill / prompt                                            | Lint rule                      |
| --------------------------------------------------------- | ------------------------------ |
| Dead easy to write                                        | Sounds scary (but see slide 5) |
| Non-deterministic. Can skip cases, changes with the model | Deterministic                  |
| Context bloat                                             | Zero context                   |
| Pays tokens on every run                                  | Pays electricity               |

**Notes:** Every tool now competes with "why not just write a skill?". Skills are easy, but
probabilistic. Mistakes slip through and pile up.

### 8. Same prompt, two agents `[EDIT]` _(was "Danger: token spikes")_

Two animated agent transcripts side by side, both answering *"Check this PR for hardcoded strings"*:

- **Figuring it out:** git diff, many file reads, a grep with 412 matches, "23 more reads". Finds 11 strings.
  Counts up to **2m 47s · 214k tokens** over ~6s.
- **Using a lint:** one `dart analyze`. Finds 13 strings. Done in under a second: **6s · 2.1k tokens**.

Callout: **On every PR, forever.** And the one figuring it out missed two.

**Notes:** Same prompt, same model. Multiply by every PR. Even "only scan modified files" is English,
and English is fuzzy: you're not watching what your agent reads.

---

## Act 1: Static tools (package:analyzer)

### 15. Two kinds of devtools `[EDIT]` _(first half of "How to Make Tools")_

| Static (`package:analyzer`)               | Runtime (`package:vm_service`)               |
| ----------------------------------------- | -------------------------------------------- |
| Reads the code                            | Inspects the running app                     |
| Lints, codegen, CI steps, git hooks, docs | Debugger, API client, log viewer, inspectors |

Static is highlighted. Runtime is greyed out ("next").

**Notes:** Don't grep or regex. The analyzer gives you resolved types, every usage of a class,
annotations, docs.

### 17. Generate the lint with AI `[KEEP]`

```
Add a lint rule `avoid_hardcoded_string`, reporting
string literals shown to users.

- Implement it with package:analysis_server_plugin.
- Test it with Dart files in test/lints/, using
  ignore comments where the lint should trigger.
- Run it on the app and generate a baseline file of
  the existing violations, so only new code fails.
```

Be specific: name `analysis_server_plugin`, ask for tests, and ask for a baseline.

**Notes:** Writing a lint used to take an afternoon of reading analyzer docs. Now it's a prompt.
Quick fixes: skip them for in-house rules. The agent fixes the warning anyway, and better.

### 18. Baselines: no big-bang migration `[KEEP]`

```yaml
# lint_baseline.yaml
# generated once: entries may only be removed
avoid_hardcoded_string:
  lib/screens/cart.dart: 4
  lib/screens/checkout.dart: 7
  lib/widgets/promo_banner.dart: 2
```

**Notes:** New code follows the rule right away. Old code is fixed when touched.

### 19. Danger: never grow the baseline `[KEEP]`

Once created, a baseline may only shrink. CI fails when it gains entries.

### 20. Codegen: the value is in the updates `[EDIT]` _(was "Code Generators: Rethinking the Main Value")_

"It reduces boilerplate" → _I couldn't care less, especially with AI._

- No review on generated chunks.
- Uniform behavior.
- **Deterministic updates.** Add a field and `==`, `copyWith` and `toJson` follow.

**Notes:** The real maintenance pain is drift: someone adds a field and forgets `==`. AI may
catch it. Codegen always does.

### 21. Where does drift happen? `[EDIT]` _(was "Codegen Decisions")_

- ✅ Backend schema → models/services (GraphQL / OpenAPI / gRPC)
- ✅ Local DB tables, assets, translations
- 🤔 Routes, widget catalogs, `toString`
- ❌ Saving 2 lines with no error risk (RIP functional_widget)

**Notes:** Most of these already have open-source generators. Shoply example: the backend renames
a field, we regenerate, and the compiler tells us every place to update.

### 22. Keep codegen cheap `[EDIT]` _(merges the two codegen pro tips)_

- Commit generated files. CI regenerates and fails or auto-commits on diff.
- A Dart script reading a JSON file _is_ codegen. You don't always need build_runner.

### 23. Run static tools everywhere `[NEW]`

Same check, many places: **IDE · git hook · CI step · agent loop**

- Because it's just `dart analyze` or `dart run tool/check.dart`.
- Agents run analyze after edits, so they fix lint warnings without being asked.

**Notes:** This is the first glimpse of act 4. A static tool is naturally usable by humans, CI
and agents, because its interface is a command and text output.

---

## Act 2: Runtime tools (package:vm_service)

### 24. Runtime tools `[EDIT]` _(second half of "How to Make Tools")_

Same table as slide 15, with runtime highlighted.

- `evaluate(expression)`: what the debugger's "Evaluate Expression" uses
- Read every live instance and its fields
- Find the VM service URI: first log line, or VS Code → "Copy VM Service URI"

**Notes:** Static tools see what the code _could_ do. Runtime tools see what it _is_ doing.

### 25. Small runtime tools, big wins `[NEW]`

- In-app log & network viewer
- API client logged in as the current user (Postman, but already authenticated)
- Debug-only "list test users" endpoint
- Theme / locale / text-scale switchers

**Notes:** All internal software, all cheap (slide 5). Each one removes a "how do I reproduce
this?" conversation.

### 26–30. Meet Shoply `[KEEP, shortened from 8 to ~5]`

Side panel: browsing → product → add to cart → cart → checkout → order placed.

**Notes:** A small shop app. Real enough that navigating it by hand to review a change gets tedious.

### 31. A site map of Shoply `[KEEP]`

Every page, what can be tapped, and where it leads. Like a Figma prototype, but for the real app.

**Notes:** Plant the question for act 3: how does the tool know every page, and how to fill it with data?

### 32. Site map: real screens `[KEEP]`

### 33. Previewing dark mode `[KEEP]`

### 34. Previewing large text `[KEEP]`

### 35. Reviewing a new page: before / after `[KEEP]`

### 36. Can you spot the change? `[KEEP]`

### 37. Highlighting the change `[KEEP]`

**Notes:** Reviewers see what users will see, not just lines of code.

### 38. In code review `[KEEP]`

On every PR: render the site map, check every page renders and is reachable, post the visual diff.

**Notes:** The runtime tool becomes a CI step. It's the same tool with a different front-end,
which leads into the last act.

---

## Act 3: Architecture ⇄ tools

> The comeback after the demos: "these demos are cool, but to do this, your app needs to be
> architected the right way."

### 11. Architecture and tools are intertwined `[NEW]`

Diagram: a two-way loop.

- **Strict guidelines → tools become possible.**
- **Tools → guidelines are enforced.**

**Notes:** Everything you just saw relied on the app following strict rules. People think of
architecture as something for humans to read. It's also what makes your code machine-understandable.

### 12. Strict shapes make code analysable `[EDIT]` _(was "Static Analyzability")_

Shoply's rules:

- Every page is a route class, with a `fake()` constructor.
- Every model is annotated.
- Every network call goes through one client.

→ A tool can **list every page**, **render it with fake data**, **find every model**,
**log every request**.

**Notes:** None of this is clever. It's consistency. But consistency is what turns "a codebase"
into "data a tool can read". That's the answer to the site map: every page is a route with a
`fake()` constructor, so a tool can list them all and render them.

### 13. Proof: Riverpod `[EDIT]` _(first half of "Case Study: Riverpod")_

`@riverpod` gives a strict, annotated shape →

- riverpod_generator
- riverpod_lint
- the Riverpod devtool

All share `riverpod_analyzer_utils`.

**Notes:** One strict shape, three tools. The parsing logic is written once.

### 14. Strictness used to be expensive. Not anymore. `[NEW]`

- Strict rules used to mean more typing and more friction for devs.
- The agent doesn't mind typing.
- **The stricter the architecture, the more tools you get almost for free.**

**Notes:** The cost of strictness was paid by humans writing code. Now it's mostly paid by agents,
and the benefits (tooling, consistency) remain.

---

## Act 4: Built for humans _and_ AI

### 39. What you see vs. what the agent sees `[NEW]`

| You                       | Your agent (by default) |
| ------------------------- | ----------------------- |
| Logs, network requests    | —                       |
| App state, the screen     | —                       |
| Test accounts             | —                       |
| CI results, crash reports | —                       |
| Source code               | Source code             |

> **Any information you have access to should be exposed to agents too.**

**Notes:** Every gap is a place where the agent guesses or goes hunting. Ask "why is this test
failing?" and it'll find a temp folder of screenshots you never knew existed. It gets the answer,
after spending a ton of time and tokens.

### 40. Every GUI has a machine-readable counterpart `[NEW]`

Diagram: one core package → GUI (humans) · CLI `--json` (scripts, CI) · MCP (agents)
_(Replaces the "DevTools in the AI era" shared-package diagram.)_

**Notes:** Don't build the GUI first and bolt AI on later. Build the core, then add front-ends.
Ideally, the GUI calls the CLI too.

### 41. Shoply, for agents `[NEW]`

> "Open the checkout page as a user with a discounted item in their cart."

The agent: lists test users → logs in → navigates via routes → checks what's on screen.

**Notes:** Same site map, same route list, same test-user endpoint, exposed as MCP tools. The
agent can reproduce a bug report on its own.

### 42. CLI: the cheapest counterpart `[EDIT]` _(merges "CLIs" and "Must-Have CLI Commands")_

`./install` · `./run` · `./test` · `./deploy`

- Install checks Flutter version, Docker, `.env` and codegen, and tells you what's missing.
- Write it in Dart, not bash. Windows users will thank you.

**Notes:** Usable by newcomers, CI and agents alike. Default to a CLI.

### 43. When MCP instead of CLI? `[EDIT]` _(was "Tool: MCP Servers")_

- Long-lived state or expensive startup (a connection to the running app)
- Things only agents should do (tapping the app; `flutter run` has no business offering that)

**Notes:** MCP is just stdin/stdout + JSON. `package:dart_mcp` handles the protocol.

### 44. Real world: Riverpod devtool → MCP `[EDIT]` _(second half of "Case Study: Riverpod")_

Extracting the devtool's inspection logic into a package lets the same core power the devtool
GUI and a Riverpod MCP.

---

## Wrap-up

### 45. Your tools need maintenance too (a little) `[EDIT]` _(merges the 3 testing tips)_

- **Lints:** example files + `// ignore` where it should fire + `unnecessary_ignore`. Then run `dart analyze`.
- **Codegen:** use the generator in `test/integration/*.dart` and test the behavior, not the generated text.
- **CLI:** `Process.run` + `--json`. No mocks.

**Notes:** Internal software, so this is enough. Ask the AI to write these tests along with the tool.

### 46. So, when _do_ we use skills? `[KEEP]`

- Skills are for **discoverability**: "You can inspect app state with the Shoply MCP."
- Don't write manuals in skills. `--help`, MCP descriptions and dartdoc already do that job.

### 47. The flywheel `[NEW]`

```
strict architecture → cheap tools → less maintenance → time for the next tool
```

### 48. Conclusion `[EDIT]`

- **Don't replace tools with prompts.** Use prompts to create your tools.
- **Tools are cheap now. Build a lot of them** to improve maintenance on what you ship.
- **Architecture enables tools; tools enforce architecture.**
- **What you can see, your agent should see.**
- All of it in Dart.

### 49. ありがとう！ Q & A 🍬 `[KEEP]`
