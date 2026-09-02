# inboundsavvy-webmaster

An AI designer skill for InboundSavvy websites. Install it once, then use `/inboundsavvy-webmaster` in Claude Code to explore, create, and improve your site — with schema-valid JSON every time.

---

## What it does

```
/inboundsavvy-webmaster explore my website and improve the landing page, adding movement to the hero
/inboundsavvy-webmaster create a services page in a boho chic style
/inboundsavvy-webmaster update our design system — suggest something warmer and more editorial
```

The skill connects to your InboundSavvy website via MCP, loads your current design system and page inventory, and generates changes that it validates against the InboundSavvy schema before writing anything. It shows you exactly what it's about to change, waits for your confirmation, then writes the file and gives you a live preview link instantly — or triggers a full beta build if you need it.

---

## How it works

The skill talks to your live InboundSavvy website over the network — it does **not** need any downloaded website files. The local directory you create below is just a workspace that holds your API token (`.mcp.json`). Your actual website content stays on the InboundSavvy servers; the skill reads and writes it directly via the MCP API.

Each InboundSavvy MCP token is scoped to one website. If you manage several sites, install each one as a separate MCP server with a name based on its primary domain, for example `inboundsavvy_acmestudio.com`. The endpoint stays the same; the server name and token change.

---

## Install

**Step 1 — Create a local workspace folder for your website**

Create an empty directory anywhere on your machine and open a terminal there. One folder per website — if you manage multiple sites, give each its own folder.

```bash
mkdir my-website && cd my-website
```

**Step 2 — Get an MCP token for this website**

Log in to your InboundSavvy CMS → **select the website you want to work on** → **... More → MCP Tokens** → create a new token. Copy the value (it starts with `is_mcp_`).

> Each token is scoped to one website. If you manage multiple sites, make sure you're inside the right website before creating the token.

**Step 3 — Run the installer inside that folder**

```bash
curl -fsSL https://raw.githubusercontent.com/JesperJurcenoks/Inboundsavvy-webmaster/main/install.sh | bash -s -- --domain acmestudio.com
```

The installer prompts for your token (hidden input), writes `.mcp.json` in the current directory using a domain-based MCP server name such as `inboundsavvy_acmestudio.com`, adds `.mcp.json` to `.gitignore`, and installs the skill at `~/.claude/skills/inboundsavvy-webmaster/`.

Or run from a local clone instead:
```bash
git clone https://github.com/JesperJurcenoks/Inboundsavvy-webmaster
cd my-website
bash /path/to/Inboundsavvy-webmaster/install.sh
```

**Step 4 — Open Claude Code in that folder and type `/inboundsavvy-webmaster`**

```bash
claude .
```

Then in Claude Code:

```
/inboundsavvy-webmaster
```

The skill connects to your live site, loads your design system and page list, and tells you what it found. You never need to download or copy any website files.

---

**Already installed?** Running `install.sh` again from the same folder detects the existing `.mcp.json` and updates only the skill — no token prompt. To switch to a different token, delete `.mcp.json` first and re-run.

---

## Example session

```
/inboundsavvy-webmaster I want to update the hero in the index page — replace the image 
with new-hero.jpg and change the h1 to "Work in progress"

> Connected to Acme Studio (acmestudio.com). I can see 6 pages: index, about, services,
> blog, events, contact. Design system: Playfair Display / Source Sans Pro, 
> primary #2563eb. What would you like to work on?
>
> I'll update pages/index. Let me load it...
>
> I'm about to:
> • Change the hero title from "Welcome to Acme Studio" to "Work in progress"
> • Replace the hero image src from "hero.jpg" to "new-hero.jpg"
>
> Shall I proceed? [yes/no]
>
> ✓ File updated. Log into your console at https://inboundsavvy.com to view your changes.
>
> Would you also like me to trigger a beta build?
>
> Build triggered (id: abc123). Checking status...
> Build complete: https://beta.acmestudio.com/
```

---

## Token security

- **Never commit `.mcp.json`** — the installer adds it to `.gitignore` automatically
- **One token per site** — each token is scoped to one website; create a new one for each project directory
- **Name each MCP server after the site's primary domain** — for example `inboundsavvy_acmestudio.com`, `inboundsavvy_example.org`, or `inboundsavvy_northwindcafe.com`
- **Rotate tokens** any time in CMS → select the website → ... More → MCP Tokens

---

## Multi-AI support

| Tool | File | Status |
|---|---|---|
| Claude Code | `SKILL.md` | ✅ Supported |
| Cursor | `variants/cursor/.cursorrules` | 🚧 Coming soon |
| Codex CLI | `variants/codex/AGENTS.md` | 🚧 Coming soon |
