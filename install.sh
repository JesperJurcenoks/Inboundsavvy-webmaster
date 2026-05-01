#!/usr/bin/env bash
set -e

MCP_ENDPOINT="https://beta.inboundsavvy.com/mcp"
SKILL_DIR="$HOME/.claude/skills/inboundsavvy-webmaster"
REPO_RAW="https://raw.githubusercontent.com/JesperJurcenoks/Inboundsavvy-webmaster/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve SKILL.md source: use local copy when run from a clone, otherwise fetch from GitHub
install_skill() {
  mkdir -p "$SKILL_DIR"
  if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
    cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
  else
    curl -fsSL "$REPO_RAW/SKILL.md" -o "$SKILL_DIR/SKILL.md"
  fi
}

echo "InboundSavvy Webmaster — installer"
echo ""

# Update-only path: .mcp.json already exists in this directory
if [ -f .mcp.json ]; then
  echo "Detected existing .mcp.json — updating skill only."
  echo ""
  install_skill
  echo "✓ Skill updated at $SKILL_DIR/SKILL.md"
  echo ""
  echo "MCP config unchanged. To use a new token, delete .mcp.json and run install.sh again."
  exit 0
fi

# Full install path
echo "This will:"
echo "  1. Write .mcp.json in the current directory (per-project MCP config)"
echo "  2. Install the skill at $SKILL_DIR/SKILL.md"
echo "  3. Add .mcp.json and is_mcp_* to .gitignore"
echo ""

# Prompt for token without echoing it
printf "Paste your InboundSavvy MCP token (input hidden): "
read -rs MCP_TOKEN
echo ""

if [ -z "$MCP_TOKEN" ]; then
  echo "Error: no token provided. Aborting." >&2
  exit 1
fi

if [[ "$MCP_TOKEN" != is_mcp_* ]]; then
  echo "Warning: token does not start with 'is_mcp_'. Make sure you copied the full token."
fi

# Write per-project .mcp.json
cat > .mcp.json <<EOF
{
  "mcpServers": {
    "inboundsavvy": {
      "type": "http",
      "url": "$MCP_ENDPOINT",
      "headers": {
        "Authorization": "Bearer $MCP_TOKEN"
      }
    }
  }
}
EOF
echo "✓ .mcp.json written to current directory"

# Add to .gitignore
GITIGNORE_ENTRIES=(".mcp.json" "is_mcp_*")
if [ -f .gitignore ]; then
  for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if ! grep -qxF "$entry" .gitignore; then
      echo "$entry" >> .gitignore
      echo "✓ Added '$entry' to .gitignore"
    else
      echo "  '$entry' already in .gitignore"
    fi
  done
else
  printf '%s\n' "${GITIGNORE_ENTRIES[@]}" > .gitignore
  echo "✓ Created .gitignore with token exclusions"
fi

# Install/update skill globally
if [ -f "$SKILL_DIR/SKILL.md" ]; then
  install_skill
  echo "✓ Skill updated at $SKILL_DIR/SKILL.md"
else
  install_skill
  echo "✓ Skill installed at $SKILL_DIR/SKILL.md"
fi

echo ""
echo "Done. Open Claude Code in this directory and type /inboundsavvy-webmaster to get started."
echo ""
echo "Security reminder: never commit .mcp.json or share your MCP token."
