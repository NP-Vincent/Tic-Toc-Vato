# Tic Tac Vato — Farcaster Mini App (Minimal HTML + JS)

A minimalist Farcaster Mini App that lets users play Tic Tac Toe ("Tic Tac Vato") vs an unbeatable AI and pay with ETH on Arbitrum. The app now talks directly to a prize-pool smart contract and stays aligned with Farcaster Mini App guidelines (pure HTML + minimal JS + SDK).

## Features

- **Pure HTML + JS** (no frameworks, no npm/bundler)
- Lightweight: uses ESM import of Mini App SDK and Ethers via CDN
- Enforces Arbitrum One network (chain ID `0xA4B1`)
- Interacts with the on-chain prize pool contract:
  - **Pool range:** 0.001 – 0.1 ETH
  - **Fee:** 1% of current pool; 50% to house wallet, 50% to pool
  - **Payout trigger:** at 0.1 ETH, displays top-3 spenders (40/30/20%)
- **LLM-friendly**: includes navigation for Codex/AI agent assistance using Farcaster's `llms-full.txt`

## Contents

- `index.html`: Minimal Mini App implementation with contract calls
- `contracts/TicTacVatoPrizePool.sol`: Prize pool smart contract
- `README.md`: This file
- `AGENTS.md`: Instructions for interacting with the repo using AI agents

---

## Deployment

- Live app: [https://vato.sqmu.io](https://vato.sqmu.io)
- Prize pool contract (proxy): `0xDB30fa8787C71Cf725E5b377130Df5fBEB3BbF5E`
- Implementation: `0xA82ad49C77160D09F49c6f5fDf35d3000685b624`
- ABI: `abi/TicTacVatoPrizePool.json`

`index.html` loads the contract address and ABI at runtime by fetching `abi/TicTacVatoPrizePool.json`. If the contract redeploys or the domain changes, update this JSON file rather than hard-coding values.

---

## Farcaster integration

- The site serves `/.well-known/farcaster.json` using the `miniapp` schema. It declares `requiredChains` with `eip155:42161` and lists the required capabilities the client expects (e.g., `wallet.getEthereumProvider`, `actions.ready`).
- `index.html` embeds `fc:miniapp` meta tags so Frames can launch the app via `launch_miniapp` and includes `fc:miniapp:domain` to reference the hosting domain.
- After the UI has rendered, the client calls `sdk.actions.ready()` to signal that the app has finished loading.

---

## Prerequisites
- You'll later need to **self-host** on a domain (e.g. GitHub Pages)
- If you fork this project, replace the domain and update `abi/TicTacVatoPrizePool.json` with your own deployment details.
- Enable **Developer Mode** in Farcaster web to preview the app:
  1. Sign into Farcaster
  2. Visit [Farcaster Dev Tools](https://farcaster.xyz/~/settings/developer-tools)
  3. Toggle **Developer Mode** ON
  4. Use Manifest and Preview tools

---

## What’s next

1. **Create the GitHub repository** and add this `index.html`.
2. Set up **GitHub Pages** and note the domain (e.g., `https://vato.sqmu.io`)
3. Use the Domain to generate a proper `/.well-known/farcaster.json` manifest.
4. Enable badges, search/discovery, and AI-guided enhancements using LLM.

---

> “Please research and analyze this page: https://miniapps.farcaster.xyz/docs/getting-started so I can ask you questions about it. Once you have read it, prompt me with any questions I have. Do not post content from the page in your response. Any of my follow up questions must reference the site I gave you.”  
>
> Reference `https://miniapps.farcaster.xyz/llms-full.txt`

Keep the `llms-full.txt` document in your AI agent’s context for live assistance. Codex can refer to it for guidance.
