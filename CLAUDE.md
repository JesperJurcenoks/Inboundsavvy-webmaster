## What this repo is

`SKILL.md` is instructions an AI agent reads and then follows literally when
acting on a customer's live website through the MCP server. A wrong sentence
here produces broken content, or a stalled agent, as surely as a bug would.

There is no test framework, no build and no CI. Accuracy is the whole review.

## Verify a claim before writing it down

Every factual statement is checkable against code, and the code is on this
machine:

- the MCP server and its enforced limits: `../workflow-automation`
- the renderer and the content schemas: `../inboundsavvy-codebase`

Check the claim, then say which file you checked it against. Two examples of
what gets through otherwise, both found in review:

- "Builds are capped at 30 per environment per 24 hours." `_BUILD_CAP` in
  `build_operations.py` is 10 for production and stage, 30 for beta only. The
  number was right for one environment out of three, and wrong for the one where
  a wasted build costs.
- "`entries-list` cannot know which entry it is on." It is told, and it excludes
  on it. The wiring runs from `ModularSegment.astro` through
  `EntriesDataFetcher.ts`; it is dead only because `entrySchema.ts` has no `id`.
  The symptom was real, the diagnosis was not, and the doc then prescribed a
  per-site workaround for a one-line platform fix.

A doc change that replaces a missing statement with a wrong one is worse than the
gap it filled.

## Prefer deferring to the source over copying it

A number or a list copied into this file goes stale silently, and nothing here
can catch it: there is no test to pin it against the server.

Where the server already states a value in a tool description, point at that
instead of restating it. The description reaches the agent from `tools/list` on
every session, so it is always the deployed value. Where a copy is genuinely
needed, keep it in one place in this file rather than several.

## An installed copy does not update itself

`install.sh` writes `SKILL.md` to `~/.claude/skills/inboundsavvy-webmaster/`.
Merging here changes nothing for anyone who already installed it until they
re-run the installer, and there is no changelog or version marker to tell them
they are behind.

So a fix landing in this repo is not a fix reaching users. Say which you mean,
and mention the re-install when it matters.

## Writing

Plain ASCII. No em dashes, no smart quotes. The file is consumed by tooling as
well as read.

Keep the instruction sequence mechanical enough to follow without judgement:
every other step in this file specifies its check to the level of an exact
regex or command, and a step that leaves the extraction and the arithmetic to
the reader is a step down in the document's own rigour.
