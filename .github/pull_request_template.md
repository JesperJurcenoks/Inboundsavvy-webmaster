<!--
SKILL.md is instruction an agent follows literally against a customer's live
site, and it is loaded every session. See CONTRIBUTING.md.

The house rule: the rule goes in the file, the story goes in the PR description.
Put the incident below, not in SKILL.md.
-->

## What changed

<!-- The rule, as it now reads in the file. -->

## Why — the incident

<!-- The war story goes HERE, not in SKILL.md: what broke, on which site, what
     you tried first, what it cost. This is the evidence for the reviewer. -->

## How it was verified

<!-- Name the source for each factual claim: the tool description and the
     constant behind it, the schema reference, the renderer, a build artifact,
     or a `curl -sI` against the live domain.

     Separate what you OBSERVED from what you INFERRED. -->

---

- [ ] Every sentence added to `SKILL.md` changes what an agent does — narrative and justification are in this description instead
- [ ] No limit, cap, or accepted-value list is copied into `SKILL.md` where the tool description already states it
- [ ] Each factual claim was checked against source or a live response, not recalled
- [ ] Any claim about what a specific site does right now is dated
- [ ] New sections are appended, not inserted into an existing letter sequence
- [ ] Any platform bug is filed rather than worked around here — or the workaround links the issue that will delete it
