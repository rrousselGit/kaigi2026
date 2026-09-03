-----





- More reliable / fewer error
  > 'Don't deploy by hand, automate it' away kind of thing
  > Similarly, 
- Increase speed / reduce cost
  > If you to a task a lot, a time gain or token usage gain can be substantial
  > For example, using lint rules instead of enforcing guidelines with AI is generally both faster, cheaper and more reliable
- Unlock more possibilities


Cost of tool:


---

I don't think I need to explain why we might want to write tools, right?

- Minimize errors
- Reduce time
- Unlocking new options
  That's about it.

But let's adress the elephant in the room:

Why write a tool if you can instead write an AI skill. Same result right?

Here's the thing: just because an AI _can_ do something does not mean it does it well:

- Efficiency. AI may not need tools to do something on its own, but it may need way more time and tokens
  Ai is good at _finding_ information. But not necesserily at doing it fast.
  You can ast a broad 'Why is this test failing?' and it'll somehow find a temporary folder you never knew existed
  and find screenshots about the app that helps it answer the question. But it spent a ton of time and tokens for that.
- Consistency. AI is probabilistic. It will not always do the same thing. But a tool is deterministic
- Reliability. Although it's getting better, AI can hallucinate. Tools generally do not 'invent' info, but rather get it from the source.
- Context bloat. The more skills you add, the more noise you add to the context, and the less reliable AI becomes.
  It becomes costlier (due to more tokens to process), takes more time (having to process skills that are useless just in case), and increases the likelyhood that it'll forget elements.

So there are two main use-cases for writing tools instead of skills:

- Do it better, with a deterministic tool. This ensures the behavior is consistent accross time, models, and shared with all coworkers.
- Unlock more possibilites. Adding log viewers, component libraries, ...

---

If you write a tool, consider a way that is usable by both Humans and AIs alike.
A GUI is great for Humans, but not so much for AI
CLI tools are all purpose, and they're cheap to build. But they are less human friendly.
The best is to start with a CLI or MCP server, then build a GUI on top of it for humans.
