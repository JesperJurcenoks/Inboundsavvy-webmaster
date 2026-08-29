---

name: inboundsavvy-webmaster
description: AI designer for InboundSavvy websites. Use this skill whenever the user wants to edit, create, or redesign website content through their InboundSavvy CMS — including editing pages, adding sections, updating the hero, changing fonts or colors, managing the design system, uploading images, or creating new pages. Also use it when the user says things like "update my site", "change my homepage", "add a testimonials section", "make it look more modern", or any request involving their website content, layout, or branding — even if they don't say "InboundSavvy" explicitly.

---

# Skill: inboundsavvy-webmaster

**Trigger:** `/inboundsavvy-webmaster`
**Description:** AI designer for InboundSavvy websites — explore, create, and improve pages using schema-valid JSON via the InboundSavvy MCP server.

---

## Philosophy

InboundSavvy is an **opinionated site builder**. The content schema *is* the design system — every page is composed from a fixed library of layouts, components, and block-level elements. You cannot invent components, write arbitrary HTML, or bypass the schema. Creative work happens **within** these constraints, not around them. When something feels impossible, the answer is almost always "use a different component from the loaded schema," not "extend the schema."

Pages are responsive by default and must remain so. Layout is expressed almost entirely through **declarative `options` keys** — `size`, `padding`, `margin`, `display`, `flex`, `grid`, `gridColumns`, `imagesPerRow`, `maxColumns`, `position`, `transform`, `background`, etc. These cover the overwhelming majority of cases. The raw `options.css` field is available for rare situations where a CSS property isn't exposed as a named key, but it should not be the default reach — prefer the declarative keys whenever they can express what you want.

The breakpoint model is **inheritance, not duplication**:

- `options: { ... }` (base) is the desktop default — every property cascades to every viewport unless overridden.
- `options.tablet: { ... }` inherits from base and overrides only the fields it redeclares.
- `options.phone: { ... }` inherits from base and overrides only the fields it redeclares.
- `options.computer: { ... }` exists for the rare desktop-only override that shouldn't cascade.

So you write your desktop layout once at the base, then add a `phone` (and sometimes `tablet`) block that surgically overrides whatever would break on a narrow viewport — typically `flex.flexDirection: "column"`, reduced `padding`, smaller `gridColumns` / `imagesPerRow` / `maxColumns`, removed fixed `size.width`. You do **not** repeat unchanged fields.

One caveat: anything written in `options.css` **cannot be overridden by `phone` / `tablet` breakpoints** — the breakpoint system only operates on the declarative keys. That's another reason to prefer the named keys when both are available.

If a change can't survive a 375px-wide viewport, it doesn't ship.

---

## 1. Setup

1. **Get an MCP token** — CMS → **... More → MCP Tokens** → create token (starts with `is_mcp_`).
2. **Configure MCP server** — run `./install.sh` (writes `.mcp.json` + adds to `.gitignore`), or add manually:
   ```json
   {
     "mcpServers": {
       "inboundsavvy": {
         "type": "http",
         "url": "https://inboundsavvy.com/mcp",
         "headers": { "Authorization": "Bearer is_mcp_your_token_here" }
       }
     }
   }
   ```
3. **Install this skill** — `./install.sh` places it at `~/.claude/skills/inboundsavvy-webmaster/SKILL.md`.

**Never commit `.mcp.json`** — it contains your token. Add `is_mcp_*` to `.gitignore`.

---

## 2. Session Start Protocol

**Run automatically when `/inboundsavvy-webmaster` is invoked. No user questions needed.**

If the user typed `/inboundsavvy-webmaster refresh-schema`, delete `~/.claude/skills/inboundsavvy-webmaster/schema-cache.md` before continuing, then run steps 1–5 normally.

Execute in this order:

1. **Load schema rules** — version-check the local cache; fetch only when stale.

   Cache path: `~/.claude/skills/inboundsavvy-webmaster/schema-cache.md`

   a. Call `get_schema_version()` → `current_version`
   b. If cache exists: run `grep -m1 "schema-version" ~/.claude/skills/inboundsavvy-webmaster/schema-cache.md` → extract `cached_version`
   c. If no cache **or** `cached_version ≠ current_version`: call `get_content_schema_reference()` → write full response to cache path
   d. Find Section 7 start line: `grep -n "^## 7\." ~/.claude/skills/inboundsavvy-webmaster/schema-cache.md` → `line_N`
   e. `Read(cache_path, offset=line_N, limit=380)` → hold Section 7 rules in active context. Do **not** load the full document.

   **On-demand component/collection reads:** For any component or collection you are about to create or edit, grep the cached schema file (`~/.claude/skills/inboundsavvy-webmaster/schema-cache.md`) for its EXACT heading (per the §7 Reference map — e.g. `### 5D.` for a component, `### 4.5` for events) and Read only that section before writing. Do not reload the whole document.

2. **Load site identity** — call `get_content_file("globalsitesettings", "globalsitesettings")`. Extract:
   - `siteName` — the site's display name
   - `seo.url` — the canonical domain (e.g. `https://acmestudio.com`)
   - Derive beta preview base URL: `https://beta.{domain}/` (strip `https://` from `seo.url`)

3. **Load design system** — call `get_content_file("globaldesignsettings", "globaldesignsettings")`. Extract:
   - `colorDesign` — the hex values the user has set for each CSS variable in their design system; use these when updating `globaldesignsettings`. In page/content JSON always reference them as `var(--...)` instead.
   - `fontSelection` — heading and body fonts (use when describing the current design system to the user)

4. **Load page inventory** — call `list_content_files("pages")`. Note available page slugs.

5. **Announce** — output a brief connection summary:
   > "Connected to **{siteName}** ({domain}). I can see {N} pages: {slug-list}. Design system: {headingFont}/{bodyFont}, primary color {hex value of --primaryColor from colorDesign}. What would you like to work on?"

   If the page-slug list contains no slug resembling a blog, articles, or events index (e.g. `blog`, `articles`, `events`, `news`), you MAY append a heuristic note that those collection types may be unreachable. This is cheaply inferable from the already-loaded slug list only — do **not** read every page file to verify.

---

## 3. Imperatives

Always enforce these.

- **NEVER** change a file's slug — the slug is the URL
- **NEVER** invent a `type` or `tag` value — only use the ones defined in the loaded schema instructions
- **NEVER** hardcode a design system color in page/content JSON — use `var(--primaryColor)` etc. (Hex values belong in `globaldesignsettings` only.)
- **NEVER** use custom CSS keyframe animations in `options.css`
- **NEVER** put a `backgroundColor` key inside an element's `options` — Set a section or element background with the `background` key in `options` (e.g. `"background": "var(--backgroundColor)"`); a `backgroundColor` key inside `options` is not rendered on the live site. The hex `backgroundColor` belongs only in `globaldesignsettings.colorDesign`, and the CSS variable `var(--backgroundColor)` is always valid as a *value* inside `background`. (This forbids only the JSON key; using `var(--backgroundColor)` as a value inside `background` is always correct.)
- **NEVER** remove `meta.title` or `meta.status.published`
- **NEVER** ship a change that breaks mobile — base `options` is the desktop default and cascades to every viewport; whenever any declarative property at the base (`size`, `flex.flexDirection`, `grid.columns`, `gridColumns`, `imagesPerRow`, `maxColumns`, `padding`, etc.) would not survive a narrow viewport, add a `phone` (and if needed `tablet`) override block that redeclares only the fields that change. No horizontal overflow at 375px
- **ALWAYS** run the pre-write validation checklist before any MCP write call
- **ALWAYS** show the approval gate diff before writing
- **ALWAYS** update the pagemap when creating a new navigable page - a page absent from the pagemap is not rendered at all, and its route 404s after a green build
- **ALWAYS** set the collection's `designs/{collection}-design.json` before judging how a collection looks: the template ships it with every `options` block empty, which renders entries hard-left with no reading measure (see 8f)
- **ALWAYS** auto-detect and use an installed design skill for creative work (see Section 4) — never ask the user whether one is installed
- **ALWAYS** after creating or editing collection entries (articles/blog/events/products/collaborators), ensure a page carries the collection's listing component (`entries-list` with the right `entryType` / `events-list` / `collaborators-list`) AND a pagemap entry, or the content is not reachable on the site.
- **ALWAYS** when you CREATE or EDIT a collection entry, confirm a listing page already exists AND appears in the pagemap: for any page slug that looks like an index (e.g. blog, articles, events, products, news), call `get_content_file` on it and check for the listing tag/entryType before concluding none exists; if truly none, tell the user the content will be unreachable and offer to create the listing page.

---

## 4. Design Delegation Protocol

When the user asks for creative direction (style, motion, redesign, "make it more boho"):

1. **Auto-detect a design skill from your available skills list.** Do **not** ask the user — the available skills are visible to you in your system context. Scan it for any skill whose purpose is visual design, UI/UX, or aesthetic direction. Common candidates (in rough order of preference for this work): `frontend-design`, `ui-ux-pro-max`, `design-html`, `design-consultation`, `design-shotgun`. Match by intent, not just by name — anything described as "designs interfaces", "design system", "creative direction", "visual design" qualifies.

2. **If a design skill is available** — silently invoke it with this context prefix:

   > Using InboundSavvy schema constraints:
   > - Layout system: semanticTag (section/div), blockLevelElement (title/text/image/link/etc.), layout (header-layout-1), component (gallery/testimonials/entries-list/etc.)
   > - Colors must use CSS variables: var(--primaryColor), var(--accentColor), var(--headingColor), var(--backgroundColor), var(--textColor), var(--white), var(--black)
   > - Motion: CSS transition + hover pseudo-states only — no keyframe animations
   > - Layout is expressed via declarative `options` keys (size, flex, grid, padding, etc.); `options.css` is available but rarely needed
   > - Mobile-first inheritance: base `options` is the desktop default and cascades down — output must include `phone` (and `tablet` where useful) override blocks that redeclare only the fields that need to change for narrow viewports
   > - Current design system: {headingFont} headings, {bodyFont} body, primary {hex value of --primaryColor}
   > - Design request: {user's original request}

   Receive the design intent output. Translate it to schema-valid InboundSavvy JSON:
   - Map style intent → nearest valid `type`/`tag` from the loaded schema instructions
   - Replace any invented colors with the nearest CSS variable
   - Replace any animation declarations with `transition` + `hover`
   - Verify a `phone` override exists wherever the desktop layout would break on mobile

3. **If no design skill is available** — proceed using the loaded schema instructions as creative constraints, then surface a one-line recommendation to the user:

   > "For richer creative direction, consider installing a design skill of your preference (e.g. `frontend-design`, `ui-ux-pro-max`, `design-html`). Without one I'll work directly within the schema's component library — fine for most edits, but a design skill helps for full redesigns."

   Then generate schema-valid JSON that interprets the user's style intent within the available component library.

---

## 5. Pre-Write Validation Checklist

Before calling `create_content_file` or `update_content_file`, run this checklist silently. If any item fails, fix it before writing — do not ask the user to approve invalid JSON.

```
▢ 1. type values — only "semanticTag" | "blockLevelElement" | "layout" | "component"
▢ 2. tag values — only ones defined in the loaded schema instructions; no invented tags
▢ 3. meta.title — present, non-empty string
▢ 4. meta.status.published — present, boolean
▢ 5. No hardcoded design colors in page/content JSON — var(--...) used for all brand colors
▢ 6. Image src values — filenames only; no paths
▢ 7. alt text — present on every image and coverImage
▢ 8. slug format — ^[a-z0-9-]+$
▢ 9. No filename changes — slug in call matches existing file slug (for updates)
▢ 10. Required entry fields — see collection-specific list in the loaded schema instructions
▢ 11. pagemap write ready — second MCP call prepared if creating a new navigable page
▢ 12. Mobile-safe — wherever a base `options` declaration would break a narrow viewport (multi-column flex/grid, fixed `size.width`, `gridColumns`/`imagesPerRow`/`maxColumns` > 2, large `padding`), a `phone` override block redeclares only the fields that need to change. No horizontal overflow at 375px
▢ 13. A11y beyond alt text — heading hierarchy is sequential (one h1 per page; h2 before h3, etc.); link text is descriptive (no "click here" / "read more" without context); any new color pairing maintains readable contrast against the design system background
```

---

## 6. Approval Gate

Before any `create_content_file` or `update_content_file` call, show the user a plain-English summary of what will change:

> "I'm about to:
> - **Change** the hero section title from 'Welcome' to 'Work in Progress'
> - **Replace** the hero image with `new-hero.jpg`
> - **Update** `pages/index` (1 file)
>
> Shall I proceed?"

Wait for explicit confirmation before writing. If the user says no, stop. If they ask to change something, revise the proposed JSON and show the gate again.

The diff summary should describe intent ("change the hero title") not structure ("modify `header.content.header-title.text`").

---

## 7. Write → Preview → Build Loop

### Writing

```
create_content_file(collection, slug, content)     ← new files
update_content_file(collection, slug, content)     ← existing files
```

If creating a new page that should appear in navigation:
1. Call `create_content_file("pages", "{slug}", {...})`
2. Call `update_content_file("pagemap", "pagemap", {...})` — add the new page entry with `showInMenu: true`

### Preview (preferred — free, instant)

After a successful write, always offer the live preview first:
> "File saved. Log into your console at https://inboundsavvy.com to view your changes.
> Would you also like me to trigger a build?"

### Building (optional — costs money, needed for full fidelity)

If the user wants a full build:
```
trigger_build(environment="beta") → build_id
```

### Monitoring

Poll `get_build_status(build_id)` sequentially in the agentic loop:
- Wait 20 seconds between each call (`sleep 20`)
- Report status after each call: "Build running... (checking again in 20s)"
- Maximum 20 calls (~7 minutes) before stopping and asking the user to check manually
- On `SUCCEEDED`: report built URL as `https://beta.{domain}/{slug}` (domain from session start; only applicable for page changes)
- On `FAILED`: call `get_build_logs(build_id)` (use default limit), surface the error to the user

```
get_build_logs(build_id, limit=50)   ← on failure only; offer "show more" if user asks
```

---

## 8. Workflows

### 8a. Explore + Improve Existing Page

1. Ask the user which page to work on (or list available pages from session start inventory)
2. Call `get_content_file("pages", "{slug}")` to load current content
3. Summarize what you see: sections, current hero, any style issues (hardcoded colors, missing alt text)
4. Propose improvements based on the user's request
5. Generate modified JSON → validation checklist → approval gate → write → offer build

### 8b. Create a New Page

1. Confirm the slug with the user (`^[a-z0-9-]+$`, no existing file with that slug)
2. Confirm whether it should appear in navigation
3. If creative style requested, run Design Delegation Protocol (Section 4)
4. Generate page JSON: `meta` + `header` + `main`
5. Validation checklist → approval gate
6. Call `create_content_file("pages", "{slug}", {...})`
7. Unless user explicitly said not to: call `update_content_file("pagemap", "pagemap", {...})` — add new page entry with `showInMenu: true`
8. Offer preview → offer build

### 8c. Update Design System

1. Call `get_content_file("globaldesignsettings", "globaldesignsettings")` to load current settings
2. Summarize current palette, fonts, and logo setup
3. Propose changes based on user's style direction (e.g., "boho chic" → warmer palette, serif headings)
4. Show approval gate with specific field changes listed
5. Call `update_content_file("globaldesignsettings", "globaldesignsettings", {...})`
6. Offer build — note that design system changes affect the entire site

### 8d. Upload an Asset + Reference It

Accept the file in whichever way the user provides it:

- **File path** (preferred): user types or pastes a local path (e.g. `~/Downloads/hero.jpg`), or drags a file into the terminal which pastes its path. Run `base64 -w0 <path>` via Bash to encode it. Detect content type from the extension (`.jpg`/`.jpeg` → `image/jpeg`, `.png` → `image/png`, `.webp` → `image/webp`, `.gif` → `image/gif`, `.svg` → `image/svg+xml`).

- **Image attached to the conversation**: if the user drops/attaches an image directly in the chat, Claude sees a visual preview but cannot extract the raw binary from it. Ask for the local file path instead so it can be encoded properly.

Steps:
1. Get the file path (or ask for it if not provided)
2. Validate: file size ≤ 3MB (`stat -c%s <path>`); filename matches `^[a-z0-9._-]+$` (rename to kebab-case if not)
3. Encode: `base64 -w0 <path>` → `content_base64`
4. Determine the correct folder:
   - Default: `"images"` (for page/global assets)
   - Multi-entry collections: use the collection name as the folder — `"blog"`, `"articles"`, `"events"`, `"products"`, `"collaborators"`, `"layouts"`, etc.
   - If the upload is for a specific collection entry (e.g. the cover image of a blog post), always pass `folder="{collection}"` so the asset lands in `assets/{collection}/` rather than `assets/images/`
5. Call `upload_asset(filename, content_base64, content_type, folder="{folder}")` → returns the asset URL
6. Reference the filename only (no paths) in whichever form fits the context:
   - **Image element** (`"tag": "image"`): `"src": "filename.jpg"` in the element's content
   - **Background image**: `"options": { "background": "url('/filename.jpg')", "background-size": "cover", "background-position": "center center" }` — prefer `options.background` over writing raw CSS in `options.css`. Use `url('/filename.jpg')` with a leading slash — this is the canonical stored form (matches the editor export; the live build strips and resolves it via the asset gallery). Filename only — no directory path.

### 8e. Manage Collection Entries

Use this workflow for multi-entry collections: `blog`, `articles`, `events`, `products`, `collaborators`, and `layouts`.

**Do not use for `staticpages`** — write operations are blocked. Do not attempt to create or delete singleton collections (`globalsitesettings`, `globaldesignsettings`, `pagemap`, etc.) — update them with `update_content_file` only.

#### Listing + reading entries

```
list_content_files("blog")            ← list all slugs in a collection
get_content_file("blog", "{slug}")    ← read a single entry
```

#### Creating a new entry

1. Confirm the slug with the user (`^[a-z0-9-]+$`)
2. Confirm required `entry` fields for the collection (see loaded schema instructions):

   | Collection | Required `entry` fields |
   |---|---|
   | `blog` / `articles` | `title`, `description`, `collaborator`, `publicationDate`, `coverImage.src`, `coverImage.alt`, `tags` |
   | `events` | `title`, `description`, `facilitators`, `startTime`, `duration`, `maxParticipants`, `audience`, `accommodation`, `price`, `location.type`, `location.address`, `coverImage`, `thumbnailImage`, `tags` |
   | `products` | `title`, `description`, `coverImage.src`, `coverImage.alt`, `price`, `category`, `specifications` |
   | `collaborators` | `name`, `email`, `photos.header`, `photos.profile`, `birthdate` |
   | `layouts` | No `entry` object — just `main` array (reusable section structure) |

3. Build the full JSON: `meta` (with `title` and `status.published`) + `entry` + `main`
4. Validation checklist → approval gate
5. Call `create_content_file("{collection}", "{slug}", {...})`

#### Editing an existing entry

1. Call `get_content_file("{collection}", "{slug}")` to load current state
2. Summarize the current entry fields to the user
3. Apply requested changes — preserve all existing fields not explicitly changed
4. Validation checklist → approval gate
5. Call `update_content_file("{collection}", "{slug}", {...})`

### 8f. Lay out a collection: articles, blog, products

**The layout of every entry in a collection lives in one file:
`content/designs/{collection}-design.json`. Not in the entries.** Style an entry
and you have styled one page; style the design and you have styled all of them.

**The trap.** The greenfield template ships this file with every `options` block
empty:

```json
"collectionHeader": { ... "options": {} },
"collectionMain":   { "options": {} },
"collectionFooter": { ... "options": {} }
```

Empty options are not defaults. They are nothing. An article rendered against
that file comes out hard against the left edge with no margin, no reading
measure, and a cover image at whatever intrinsic size it happens to be. If a
collection looks unstyled, this file is the reason, and no amount of per-entry
`options` will fix it properly.

#### The four things to set

**1. `collectionMain.options.sectionOptions` - the reading measure.** This is
applied to every section of every entry body and is what centers the text.

```json
"collectionMain": { "options": {
  "sectionOptions": {
    "size": { "width": "100%", "maxWidth": "42rem" },
    "margin": [0, "auto"],
    "padding": [0, 24],
    "phone":  { "padding": [0, 20] }
  },
  "titlesOptions": { "textAlign": "left" },
  "textsOptions":  { "textAlign": "left" }
}}
```

`42rem` is roughly 70 characters, which is the usual target for body text.
`titlesOptions` and `textsOptions` set defaults for every heading and paragraph
in every entry; per-element `options` still win, so keep these minimal or they
fight the content.

**2. `collectionHeader` - the hero.** The cover photograph is the dominant thing
on an article. To take it wall to wall out of a constrained parent:

```json
"options": {
  "size": { "width": "100%" },
  "css": "display:block; width:100vw; margin-left:calc(50% - 50vw); height:72vh; object-fit:cover;",
  "tablet": { "css": "... height:60vh; ..." },
  "phone":  { "css": "... height:52vh; ..." }
}
```

`width:100vw` with `margin-left:calc(50% - 50vw)` escapes the container. `72vh`
is what makes it dominant rather than a strip: **a hero is defined by height, not
by width.** A full-width image 200px tall is a band, and a band is the one thing
it must not be.

Put the breadcrumb, title and description in a `div` **below** the image, inside
the same measure as the body, so the text column is continuous from the title to
the end of the article.

**3. `collectionFooter`.** Byline, then related entries. Give it the same
`maxWidth` and `margin: [0, "auto"]` as the body or it will not line up with the
column above it.

**4. Read a working example before writing one.** If another site in the estate
has a collection that looks right, pull its design file and copy the structure:

```
get_content_file("designs", "articles-design")
```

That is faster and safer than deriving it, and it shows which keys the renderer
actually honors.

#### Images inside an entry body

**A photograph beside its text, not stacked above it.** Two children in a flex
row: the figure at 38.2% and the words at 61.8%, both dropping to 100% on phone
and tablet. Alternate the side down the article so it does not read as a
template.

```json
{"type": "semanticTag", "tag": "section", "options": {},
 "content": [{"type": "blockLevelElement", "tag": "div",
   "options": {"size": {"width": "100%", "maxWidth": "58rem"},
               "margin": [0, "auto"], "padding": [28, 24],
               "display": "flex",
               "flex": {"flexDirection": "row", "alignItems": "center", "gap": "2.5rem"},
               "phone":  {"flex": {"flexDirection": "column", "alignItems": "stretch"}},
               "tablet": {"flex": {"flexDirection": "column", "alignItems": "stretch"}}},
   "content": [ FIGURE_38_PERCENT, WORDS_62_PERCENT ]}]}
```

Note the container is **wider than the reading measure** - 58rem against 42rem.
A figure block is not a paragraph and should breathe past the text column.

Use `figure` + `figcaption` rather than a bare `image` whenever the photograph
has something to say: a date, a place, what it is evidence of.

#### Rules that keep being relearned

**One full-bleed band per page, and it is the hero at the top.** A second band
flattens the page into a stack of identical letterboxes. The band is not the
default treatment for a photograph; it is the exception, spent once.

**Never crop a portrait photograph into a band.** Ask what the photograph needs
in order to work. A tall tree needs height. A wide ridgeline needs width. A
detail needs to be large enough to read. If the answer is not "a short horizontal
strip", it does not go in a band. Portraits get a side-by-side block instead.

**A band must never crop out the evidence.** If a photograph contains the one
thing that makes it work - a person for scale, a bird in the corner - check that
the crop keeps it.

**Vertical rhythm comes from one container, not from stacked sections.** A
section per heading, each with 80px of padding top and bottom, renders as 160px
of empty page between a heading and the paragraph before it. Put consecutive
prose in a single container with a gap and a margin above each heading.

#### Do not surface a collection with `entries-list` without testing a build

`entries-list` is documented as the way to make a collection reachable, and on at
least one site it fails the build outright - and a failed build deploys nothing,
so the whole site 404s. Add it, build, and check the site is still up before
adding anything else. If it fails, build the grid by hand from
`link-container` + `image` + `subtitle` + `text` in a wrapping flex row.

Related: **a page that is not in `pagemap` is not rendered at all.** Its route
404s even after a green build. When bisecting a build failure, a page under test
that is absent from the pagemap will produce a false green.

---

## 9. Common Errors + How to Fix

| Error | Cause | Fix |
|---|---|---|
| MCP tools not available / no `inboundsavvy` server | `.mcp.json` missing or misconfigured, or session started before config was added | Confirm `.mcp.json` exists in the project directory (see README for format); restart Claude Code to reload MCP config |
| `Token invalid or revoked` | MCP token expired or deleted | Go to CMS → ... More → MCP Tokens → create a new token; re-run `install.sh` |
| `Website not found` | Token scoped to a different website | Confirm you're in the correct project directory with the right `.mcp.json` |
| Schema validation failure | Invalid `type`/`tag` or missing required field | Run the pre-write checklist (Section 5); check the Component Selection Guide in the loaded schema instructions |
| Build failed | Code or content error in the generated JSON | Call `get_build_logs(build_id)` → read the error; common causes: invalid JSON, missing required field, asset filename not found |
| Asset too large | File exceeds 3MB limit | Compress the image before uploading; use a tool like Squoosh or ImageOptim |
| Asset filename rejected | Filename contains spaces or special characters | Rename to `kebab-case.jpg` before uploading |

