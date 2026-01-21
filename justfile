# List available commands
default:
    @just --list

# Create symlink to ~/.claude/skills
link-claude:
    mkdir -p ~/.claude/skills
    ln -sf {{justfile_directory()}}/clean-architecture ~/.claude/skills/clean-architecture
    @echo "Linked clean-architecture to ~/.claude/skills/"

# Create symlink to ~/.gemini/skills
link-gemini:
    mkdir -p ~/.gemini/skills
    ln -sf {{justfile_directory()}}/clean-architecture ~/.gemini/skills/clean-architecture
    @echo "Linked clean-architecture to ~/.gemini/skills/"

# Create symlinks to both Claude and Gemini
link-all: link-claude link-gemini
