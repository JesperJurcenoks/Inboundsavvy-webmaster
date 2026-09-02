# Contributing

`SKILL.md` is not documentation. It is instruction that an AI agent follows
literally against a paying customer's live website, and it is loaded into the
agent's context on every session.

Two consequences run through everything below: **a wrong sentence breaks a real
site**, and **every line is paid for on every run**. There is no test suite, no
build and no CI here, so review is the only thing standing between a bad sentence
and a customer.

---

## The rule goes in the file. The story goes in the PR description.

The incident that taught you something is how you prove a rule to a reviewer. It
is not instruction, and the agent does not act differently for having read it.
Reviewers read the PR description once; the agent reads the file every session.

So put the rule in `SKILL.md`, and put the war story — what broke, on which site,
what it cost, what you tried first — in the PR description, where it belongs and
where it will actually be read.

The test for any sentence you are about to add:

> **Does an agent behave differently because this line exists?**

If no, it is justification, narrative, or a note to the next author. Move it to
the PR description.

**Do:**

```markdown
No `build_id` means the build did not happen. A refusal comes back as a message
rather than an error, so anything that only looks for a `build_id` reads the
absence of one as "nothing to poll" instead of as failure.
```

**Don't:**

```markdown
...which is exactly how a replaced photograph stayed invisible for an afternoon
on examplesite.org while every step of the publish reported clean. The report
cost a day.
```

Same lesson. The first one is a rule; the second is a memoir. Both belong in the
project — in different places.

Why this is a rule and not a preference: the file was growing by roughly 40 lines
per incident, and most of the growth was narrative rather than instruction.

---

## Verify the claim, then name the source

Every factual claim in `SKILL.md` is about a system that lives in another
repository. Nothing here can detect when one goes stale, so check it before you
write it, and say where you checked.

The authoritative sources:

| Claim is about | Check against |
|---|---|
| An enforced limit, cap, or accepted-value list | The MCP tool's own description, and the constant it is generated from |
| Content shape, collection names, field types | `CONTENT_SCHEMA_REFERENCE.md` — what `get_content_schema_reference` serves |
| How something renders | The renderer templates and schemas, and a real build artifact |
| What a live site does right now | `curl -sI`, against the actual domain |

Prefer a build artifact or a live response over reasoning from a config file.

**Separate what you observed from what it implies.** The recurring failure here
is to observe a real symptom, infer a mechanism, and then write the inference in
the voice of the observation. The tell is the word "confirmed". If you measured
one thing and concluded another, say both, and mark the second as the conclusion
it is.

**Date anything about a particular site.** "Production returns a 301" is true on
a day, about a site. "The build emits a meta-refresh at 200" is true of the
build. The first needs a date; the second does not.

---

## Never copy a number the server already states

If a value is stated in an MCP tool description, point at the description instead
of restating it. The agent receives those descriptions from `tools/list` every
session, so they are always the deployed value — a copy here is stale the moment
the server changes and nothing in this repo will notice.

Where a value varies by environment or deployment, state the rule's *shape* and
let the error message carry the number:

> Builds are rationed per website per environment on a rolling 24 hours,
> production tighter than beta; the refusal names the cap in force and the reset
> time.

This is not hypothetical thrift. The upload limit was written here as 3 MB, went
stale, and was corrected to 4 MB inside an unrelated PR about photography — by
whoever happened to notice.

---

## A platform bug gets filed, not documented

If the right fix is one line in the renderer, file it there. A workaround written
into `SKILL.md` is applied to every site forever and makes the bug permanent.

If a workaround genuinely has to ship before the fix lands, mark it as temporary
and link the issue that will delete it.

---

## Practical notes

- **Sections are append-only.** Add a new one at the end of its group rather than
  inserting a letter in the middle — two open PRs both claiming `8f` is a
  conflict that a rebase cannot resolve for you.
- **Keep one PR to one lesson.** Two unrelated findings in one PR means the
  correct half waits on the disputed half.
- **Merging here does not update anyone's install.** `install.sh` copies
  `SKILL.md` to `~/.claude/skills/inboundsavvy-webmaster/`, and there is no
  version marker. Landing a fix is not the same as users receiving it.
