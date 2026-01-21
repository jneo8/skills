# List available commands
default:
    @just --list

# Create symlinks to ~/.claude/skills
link-claude:
    mkdir -p ~/.claude/skills
    @for skill in {{justfile_directory()}}/*/SKILL.md; do \
        skill_dir=$(dirname "$skill"); \
        skill_name=$(basename "$skill_dir"); \
        ln -sfn "$skill_dir" ~/.claude/skills/"$skill_name"; \
        echo "Linked $skill_name"; \
    done
    @echo "Linked all skills to ~/.claude/skills/"

# Create symlinks to ~/.gemini/skills
link-gemini:
    mkdir -p ~/.gemini/skills
    @for skill in {{justfile_directory()}}/*/SKILL.md; do \
        skill_dir=$(dirname "$skill"); \
        skill_name=$(basename "$skill_dir"); \
        ln -sfn "$skill_dir" ~/.gemini/skills/"$skill_name"; \
        echo "Linked $skill_name"; \
    done
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
    @for skill in {{justfile_directory()}}/*/SKILL.md; do \
        skill_dir=$(dirname "$skill"); \
        skill_name=$(basename "$skill_dir"); \
        echo "Validating $skill_name..."; \
        agentskills validate "$skill_dir"; \
    done

# Read skill properties as JSON (usage: just read-properties clean-architecture)
read-properties skill:
    agentskills read-properties {{justfile_directory()}}/{{skill}}

# Generate XML prompt for a skill (usage: just to-prompt clean-architecture)
to-prompt skill:
    agentskills to-prompt {{justfile_directory()}}/{{skill}}
