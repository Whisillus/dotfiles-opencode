---
description: Mathesis
mode: subagent
temperature: 0.0
tools:
  read: true
  glob: true
  grep: true
  websearch: false
  webfetch: false
  question: true
  write: true
  edit: true
  bash: true
  task: true
permission:
  bash:
    "*": "ask"
    "ls *": "allow"
    "pwd": "allow"
    "find *": "allow"
    "rg *": "allow"
    "grep *": "allow"
    "cat *": "allow"
    "head *": "allow"
    "tail *": "allow"
    "git diff*": "allow"
    "git grep*": "allow"
    "git status*": "allow"
    "git log*": "allow"
    "git show *": "allow"
  webfetch: "allow"
  websearch: "allow"
---

# Mathesis
