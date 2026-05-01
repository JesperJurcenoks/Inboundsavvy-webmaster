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

## Install

**Step 1 — Get an MCP token**

Log in to your InboundSavvy CMS → **Settings → API Tokens** → create a new token. Copy the value (it starts with `is_mcp_`).

**Step 2 — Run the installer in your project directory**

```bash
curl -fsSL https://raw.githubusercontent.com/JesperJurcenoks/Inboundsavvy-webmaster/main/install.sh | bash
```

Or clone and run locally:
```bash
git clone https://github.com/JesperJurcenoks/Inboundsavvy-webmaster
cd /your/project/directory
bash /path/to/Inboundsavvy-webmaster/install.sh
```

The installer prompts for your token (hidden input), writes `.mcp.json` in the current directory, adds it to `.gitignore`, and places the skill in `~/.claude/skills/inboundsavvy-webmaster/`.

**Already installed?** Running `install.sh` again from the same directory detects the existing `.mcp.json` and updates only the skill file — no token prompt. To change your token, delete `.mcp.json` first and re-run.

**Step 3 — Open Claude Code and type `/inboundsavvy-webmaster`**

That's it. The skill connects automatically and announces what it found.

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
> ✓ File updated. Preview your changes now at:
> https://beta.inboundsavvy.com/console/website/acmestudio.com/preview
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
- **Rotate tokens** any time in CMS → Settings → API Tokens

---

## Multi-AI support

| Tool | File | Status |
|---|---|---|
| Claude Code | `SKILL.md` | ✅ Supported |
| Cursor | `variants/cursor/.cursorrules` | 🚧 Coming soon |
| Codex CLI | `variants/codex/AGENTS.md` | 🚧 Coming soon |
