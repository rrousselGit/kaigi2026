# Talk rework plan

## The problem with the current deck

The deck is organised by tool type: Lints → Quick fixes → Codegen → CLIs → MCP → DevTools.
Each section has a Pros/Cons slide plus tips. That makes the talk read like a catalogue.
The Shoply example only shows up in the DevTools section, and the "why" is all in the
intro. After that, the talk never comes back to it.

## New thesis

> Most of the cost of software is maintenance. AI makes writing code cheap, so we write more
> code, and maintenance gets harder. AI also makes writing tools cheap.
> So, every time maintenance hurts, turn that pain into a tool.

Tool kinds stop being the chapters. The talk is built on four ideas instead:

1. **Two kinds of software.** Software deployed to users is expensive and slow to review.
   Internal software (controlled environment, few users) is cheap to build and maintain with AI.
   That asymmetry is *why now*.
2. **Architecture and tools are intertwined.** Strict guidelines make code analysable, which makes
   tools possible. Tools then enforce the guidelines. It's a two-way loop.
3. **Two kinds of devtools.** Static (analyzer) and runtime (vm_service). This is the body of the talk.
4. **Built for humans and AI.** Any information you have access to should be exposed to agents too.
   Every GUI has a machine-readable counterpart.

The loop runs through all of it:

```
notice friction  →  encode it in a tool  →  it never costs time again  →  repeat
```

## Proposed structure

### 0. Intro: why build tools now
- Title, "I love building tools", original plan vs. AI reality (keep).
- Maintenance thesis: code volume up, review/maintenance cost up with it.
- **New: two kinds of software.** Two columns:
  - *Shipped to users:* every line is reviewed, edge cases matter, mistakes are costly. Slow.
  - *Internal tools:* known environment, a handful of users, a bug costs a restart. Let AI write them.
  - Punchline: spend the cheap kind of software to make the expensive kind easier to maintain.
- The loop.
- Filter: skill vs. tool (determinism, cost, context bloat), token danger, ROI math. Compress the
  existing 4 slides to about 3. The ROI math gets cheaper on the "build cost" side because of point 1.

### 1. Architecture ⇄ tools
The bridge between the "why" and the tools themselves.
- **Strict guidelines enable tools.** If every page is a route with a fake-data constructor, a tool can
  list and render every page (this foreshadows the site map). If every model is annotated, a tool can
  find every model. The existing "Static Analyzability" slide moves here.
- **Tools enforce guidelines.** A rule only in a wiki erodes. A rule in a lint holds.
- Riverpod as the proof: the strict `@riverpod` shape is what makes riverpod_lint, the generator and
  the devtool possible.
- Payoff: the stricter the architecture, the more tools you get almost for free. And with AI writing
  the code, strictness costs much less than it used to.

### 2. Static tools (package:analyzer)
They run without the app. They make sure the code respects the architecture.
- **Lints**, the main example. Review comment → lint (existing `_ReviewToLintSlide`), generate
  the lint with AI, baselines + "never grow the baseline", progressive improvement. Quick fixes
  become one line in the notes.
- **Codegen.** The pain is drift, not boilerplate (the existing "rethinking the main value" slide).
  Definitely / maybe / don't automate. Commit generated files + simple scripts as one slide.
- **Where static tools run.** IDE, CI step, git hooks, pre-commit. The same check runs everywhere,
  for humans and agents alike, because it is just `dart analyze` or a script.
- Possibly: architecture graphs and docs generated from the analyzer (from `conf.md`).

### 3. Runtime tools (package:vm_service)
They look at the running app: debugger, API client (Postman-style), log viewer, state inspector.
- What vm_service gives you: evaluate, inspect instances and fields (the existing "How to make" slide, runtime half).
- Small internal tools: an API client pre-authenticated with the current user's token, a debug-only
  "list test users" endpoint, an in-app log/network viewer (from `conf.md`).
- **Climax: the Shoply site map.** It is the walkthrough plus the site map, dark mode, large text,
  review before/after, spot the change, highlighted diff and in-code-review slides. Shorten the
  Shoply walkthrough to 4–5 slides. Tie back to act 1: this only works because pages follow a strict shape.

### 4. Built for humans and AI
**Rule: any information you have access to, the agent should have too.**
- Opening slide: what you see and what the agent sees. You see logs, network requests, app state,
  the screen, test accounts, CI results and crash reports. By default, the agent only sees source code.
  Every gap is a place where the agent guesses, or burns tokens hunting for something
  (the "found screenshots in a temp folder" anecdote from `other.md`).
- Corollary: every GUI has a machine-readable counterpart.
- One core package, several front-ends: GUI/devtool for humans; CLI (`--json`), MCP and CI for machines.
  This replaces the existing "DevTools in the AI era" + shared package diagram.
- Shoply: the site map GUI ↔ an MCP tool "open the detail page of a children's book" ↔ a CI step
  posting the visual diff.
- Where CLIs fit: the cheapest machine-readable front-end. Install / run / test / deploy (keep the
  must-have slide). MCP when you need a long-lived process or something only agents should use.
- Riverpod devtool → MCP refactor as a real-world instance.

### 5. Wrap-up
- **Maintaining your tools:** the three testing tips in one or two slides (lint `// ignore` + `unnecessary_ignore`,
  codegen integration files, CLI `Process.run` + `--json`). Being internal software, they don't need
  more than that.
- Skills are for discoverability (keep).
- Conclusion: the flywheel. Strict architecture → cheap tools → less maintenance → time to build the
  next tool. Keep "don't replace tools with prompts, use prompts to create tools".

## Slide-level changes

| Action | Slides |
|---|---|
| Cut | Tooling Taxonomy (the "list of kinds" slide), Tool: Quick Fixes, Danger: Skip Quick Fixes, Danger: Avoid Module Templates |
| Retitle (problem-first, not "Tool: X") | Tool: Custom Lints, Tool: Code Generators, Tool: CLIs, Tool: MCP Servers, Tool: DevTools |
| Split | "How to Make Tools" (static vs. runtime): becomes the opening slide of acts 2 and 3 |
| Move | Static Analyzability → act 1; Riverpod case study → split between act 1 (architecture) and act 4 (devtool → MCP); CLIs → act 4 |
| Merge | 3 testing tips → "Maintaining your tools"; commit-generated + simple scripts → one slide |
| New | Maintenance thesis, two kinds of software, the loop, architecture ⇄ tools (2–3 slides), where static tools run, small runtime tools, what you see vs. what the agent sees, human/machine front-ends diagram, Shoply MCP slide, flywheel conclusion |
| Code | `Topic` enum: replace per-tool topics with `intro`, `architecture`, `static`, `runtime`, `interfaces`, `conclusion` |

## Open questions

1. **Running example:** should Shoply run through all acts? Act 1 could show Shoply's page shape
   enabling the site map, and act 2 a lint flagging a hardcoded string in Shoply. `examples/books`
   (GraphQL codegen, lints, MCP) could serve as a live-demo backup.
2. **Title:** keep "Build devtools for your app", or something closer to the thesis,
   like "Tools that maintain your app" or "Turn friction into tools"?
3. **Length:** this version adds more than it cuts (about 4 cut, about 10 new). Is there a time budget to hit?
