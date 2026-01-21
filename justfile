# List available commands
default:
    @just --list

# Create symlinks to ~/.claude/skills
link-claude:
    mkdir -p ~/.claude/skills
    ln -sf {{justfile_directory()}}/clean-architecture ~/.claude/skills/clean-architecture
    ln -sf {{justfile_directory()}}/skill-builder ~/.claude/skills/skill-builder
    @echo "Linked all skills to ~/.claude/skills/"

# Create symlinks to ~/.gemini/skills
link-gemini:
    mkdir -p ~/.gemini/skills
    ln -sf {{justfile_directory()}}/clean-architecture ~/.gemini/skills/clean-architecture
    ln -sf {{justfile_directory()}}/skill-builder ~/.gemini/skills/skill-builder
    @echo "Linked all skills to ~/.gemini/skills/"

# Create symlinks to both Claude and Gemini
link-all: link-claude link-gemini

# Install skills-ref CLI tool (command: agentskills)
install-skills-ref:
    pipx install skills-ref

# Validate a skill (usage: just validate clean-architecture)
validate skill:
    agentskills validate {{justfile_directory()}}/{{skill}}

# Validate all skills
validate-all:
    @for skill in clean-architecture skill-builder; do \
        echo "Validating $skill..."; \
        agentskills validate {{justfile_directory()}}/$skill; \
    done

# Read skill properties as JSON (usage: just read-properties clean-architecture)
read-properties skill:
    agentskills read-properties {{justfile_directory()}}/{{skill}}

# Generate XML prompt for a skill (usage: just to-prompt clean-architecture)
to-prompt skill:
    agentskills to-prompt {{justfile_directory()}}/{{skill}}
