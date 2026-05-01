# InboundSavvy Webmaster — Codex CLI adaptation
# Status: stub — full port coming after Claude Code workflows are validated
#
# This file will contain the inboundsavvy-webmaster logic adapted for Codex CLI.
# Source of truth: ../../SKILL.md
#
# When complete, this file will instruct Codex CLI to:
# - Connect to the InboundSavvy MCP server on session start
# - Load globaldesignsettings + globalsitesettings for design system context
# - Enforce schema imperatives before any content file write
# - Follow the pre-write validation checklist
# - Show approval gate diffs before writing
# - Run the write → build → verify loop
#
# See SKILL.md for the full workflow specification.
