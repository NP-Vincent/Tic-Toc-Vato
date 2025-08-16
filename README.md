# Tic Tac Vato — Farcaster Mini App (Minimal HTML + JS)

A minimalist Farcaster Mini App that lets users play Tic Tac Toe ("Tic Tac Vato") vs an unbeatable AI and pay with ETH on Arbitrum. Designed for simplicity and aligned with Farcaster Mini App guidelines (pure HTML + minimal JS + SDK).

## Features

- **Pure HTML + JS** (no frameworks, no npm/bundler)
- Lightweight: uses ESM import of Mini App SDK via CDN
- Enforces Arbitrum One network (chain ID `0xA4B1`)
- Implements dynamic prize pool with ETH fees:
  - **Pool range:** 0.001 – 0.1 ETH
  - **Fee:** 1% of current pool; 50% to house wallet, 50% to pool
  - **Payout trigger:** at 0.1 ETH, displays top-3 spenders (40/30/20%)
- **LLM-friendly**: includes navigation for Codex/AI agent assistance using Farcaster's `llms-full.txt`

## Contents

- `index.html`: Minimal Mini App implementation
- `README.md`: This file
- `AGENTS.md`: Instructions for interacting with the repo using AI agents

---

## Prerequisites

- You'll later need to **self-host** on a domain (e.g. GitHub Pages)
- Replace placeholders:
  - `0xHOUSE_WALLET_PLACEHOLDER` in `index.html`
  - Your GitHub Pages URL for manifest & domain identity
- Enable **Developer Mode** in Farcaster web to preview the app:
  1. Sign into Farcaster
  2. Visit [Farcaster Dev Tools](https://farcaster.xyz/~/settings/developer-tools)
  3. Toggle **Developer Mode** ON
  4. Use Manifest and Preview tools

---

## What’s next

1. **Create the GitHub repository** and add this `index.html`.
2. Fill in the **house wallet address**.
3. Set up **GitHub Pages** and note the domain (e.g., `https://your-gh-username.github.io/`)
4. Use the Domain to generate a proper `/.well-known/farcaster.json` manifest.
5. Enable badges, search/discovery, and AI-guided enhancements using LLM.

---

> “Please research and analyze this page: https://miniapps.farcaster.xyz/docs/getting-started so I can ask you questions about it. Once you have read it, prompt me with any questions I have. Do not post content from the page in your response. Any of my follow up questions must reference the site I gave you.”  
>
> Reference `https://miniapps.farcaster.xyz/llms-full.txt`

Keep the `llms-full.txt` document in your AI agent’s context for live assistance. Codex can refer to it for guidance.
