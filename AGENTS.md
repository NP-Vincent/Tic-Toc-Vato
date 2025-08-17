# AGENTS: AI Agent Interaction Guide

This file is intended for AI agents (e.g. GitHub Copilot, ChatGPT / Codex) that will assist in developing and refining this Mini App.

---

## Goals for AI Agents

1. **Understand Farcaster Mini App requirements** by reading:
   - The Farcaster **"Getting Started"** documentation:  
     `https://miniapps.farcaster.xyz/docs/getting-started`
   - The `llms-full.txt` file for full spec context:  
     `https://miniapps.farcaster.xyz/llms-full.txt`

2. **Assist project tasks** such as:
   - Updating `index.html` to match guidance (e.g., manifest embed, meta tags, capabilities)
   - Generating the `/.well-known/farcaster.json` manifest
   - Creating metadata like app icons, OpenGraph tags, `fc:miniapp` embed meta
   - Suggesting improvements for UX, Discoverability, Testing
   - Ensuring `sdk.actions.ready()` is used correctly, and other best practices
   - Maintaining the `contracts/` directory and keeping `index.html` in sync with the deployed contract address
   - The prize pool contract is currently deployed at `0xA82ad49C77160D09F49c6f5fDf35d3000685b624` with proxy `0xDB30fa8787C71Cf725E5b377130Df5fBEB3BbF5E`
   - `index.html` loads its ABI and address from `abi/TicTacVatoPrizePool.json`; update this file if redeploying
   - The public site is hosted at `https://vato.sqmu.io`

3. **Prompt the user with context-based questions**, **only referencing the docs** and not quoting from them verbatim. Example prompts:
   - “Should we create `farcaster.json` now with placeholders, or generate it later once the GH Pages URL is known?”
   - “Would you like to include social meta tags (`og:*`) to improve share/embed experience?”

---

## Agent Instructions (to be referenced by AI)

- **Import the full spec** via `llms-full.txt` into your context. This document is formatted for LLM consumption. ([source](https://miniapps.farcaster.xyz/llms-full.txt))  
- **When providing edits or suggestions**, do **not quote** from the docs. Instead, phrase references like:
  - “According to the Getting Started guide, you must call `sdk.actions.ready()` after your UI loads to avoid infinite loading screens.”
  - “The manifest requires `requiredChains` and `requiredCapabilities` fields so the Farcaster host can properly enable the app.”

- **Only ask follow-up questions** if clarity is needed, and phrase them around the doc:
  - Example: “Should we declare `requiredChains: ["eip155:42161"]` in the manifest as recommended by the Farcaster Publishing guide?”

---

## Summary

This repository is structured for minimal dependencies and Farcaster compliance. AI agents should:

- Reference the Farcaster docs for best practices
- Maintain the prize pool contract in `contracts/` alongside the HTML client
- Assist in filling placeholders (like the contract address) and verifying the app's integration with the Farcaster ecosystem
- Guide without revealing the actual doc text, only paraphrase or reference where relevant

Use the `llms-full.txt` spec in your workspace to stay context-aware of all requirements and examples.
