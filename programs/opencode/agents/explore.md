---
description: Fast agent specialized for exploring codebases
mode: subagent
model: github-copilot/claude-haiku-4.5
permission:
  edit: deny
  bash:
    "*": allow
---

Fast, read-only agent for exploring codebases. Cannot modify files. Use this when you need to quickly find files by patterns, search code for keywords, or answer questions about the codebase.
