# Contributing

SKILL.md is not documentation. It is instruction an AI agent follows literally
against a customer's live website, loaded into context every session.

Two consequences: a wrong sentence breaks a real site, and every line is paid for
on every run. There is no test suite and no CI. Review is the only thing between
a bad sentence and a customer.

## The rule goes in the file. The story goes in the PR description.

Test every sentence you add: does an agent behave differently because this line
exists?

If no, it is justification, narrative, or a note to the next author. It goes in
the PR description, which a reviewer reads once, not in a file read every
session.

Do:

> No `build_id` means the build did not happen. A refusal comes back as a message
> rather than an error, so anything looking only for a `build_id` reads the
> absence of one as "nothing to poll" instead of as failure.

Do not:

> ...which is exactly how a replaced photograph stayed invisible for an afternoon
> on examplesite.org while every step reported clean. The report cost a day.

Same lesson: the first is a rule, the second is a memoir. Both belong in the
project, in different places.

The file was growing by roughly 40 lines per incident. Most of that was
narrative.

## Verify the claim, then name the source

Every claim here describes a system in another repository. Nothing in this repo
detects when one goes stale.

| Claim is about | Check against |
|---|---|
| An enforced limit, cap, or accepted-value list | The MCP tool description, and the constant behind it |
| Content shape, collection names, field types | `CONTENT_SCHEMA_REFERENCE.md` |
| How something renders | The renderer templates, the schemas, and a real build artifact |
| What a live site does right now | `curl -sI` against the domain |

Prefer a build artifact or a live response over reasoning from a config file.

Separate what you observed from what it implies. The recurring failure: observe a
real symptom, infer a mechanism, then write the inference in the voice of the
observation. The tell is the word "confirmed."

Date anything about a specific site. "Production returns a 301" is true on a day.
"The build emits a meta refresh at 200" is true of the build.

## Never copy a number the server states

Point at the tool description instead. The agent receives it from `tools/list`
every session, so it is always the deployed value. A copy here goes stale
silently.

Where a value varies by environment, state the shape and let the error carry the
number:

> Builds are rationed per website per environment on a rolling 24 hours,
> production tighter than beta; the refusal names the cap in force and the reset
> time.

The upload limit was written here as 3MB, went stale, and was corrected to 4MB
inside an unrelated PR about photography, by whoever happened to notice.

## File a platform bug, do not document it

A workaround written here applies to every site forever and makes the bug
permanent. If one has to ship before the fix lands, mark it temporary and link
the issue that deletes it.

## Practical

- Sections are append-only. Two open PRs both claiming `8f` is a conflict no
  rebase resolves for you.
- One lesson per PR. Two findings in one PR means the correct half waits on the
  disputed half.
- Merging does not update anyone's install. `install.sh` copies SKILL.md to
  `~/.claude/skills/inboundsavvy-webmaster/`, and there is no version marker.
