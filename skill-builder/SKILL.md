---
name: skill-builder
description: Guide for creating Claude Code skills. Use this skill when users want to create a new skill, update an existing skill, or learn about skill structure and best practices.
---

# Skill Builder

Guide for creating effective Claude Code skills that extend Claude's capabilities.

## What is a Skill?

A skill is a modular package that provides Claude with specialized knowledge, workflows, or tool integrations. Skills transform Claude from a general-purpose agent into a specialized one.

## Skill Structure

```
skill-name/
├── SKILL.md              # Required - main instructions
└── references/           # Optional - detailed docs loaded on-demand
    ├── guide.md
    └── examples.md
```

## SKILL.md Format

```yaml
---
name: my-skill
description: What this skill does and when to use it. Be comprehensive - this is the primary trigger mechanism.
---

# Skill Title

Instructions and guidance here...

## Reference Documentation

- **[Guide](./references/guide.md)** - Detailed guidance
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill name (creates `/slash-command`) |
| `description` | Yes | When Claude should use this skill |

## Key Principles

### 1. Concise is Key

Context window is shared. Only add what Claude doesn't already know.

- Keep SKILL.md under 500 lines
- Split detailed content into `references/` files
- Prefer examples over verbose explanations

### 2. Progressive Disclosure

```
Level 1: name + description     → Always loaded (~100 words)
Level 2: SKILL.md body          → When skill triggers (<500 lines)
Level 3: references/            → Loaded on-demand (unlimited)
```

### 3. Reference File Organization

For skills with variants or domains, organize by topic:

```
my-skill/
├── SKILL.md
└── references/
    ├── python.md      # Python-specific guide
    ├── go.md          # Go-specific guide
    └── patterns.md    # Common patterns
```

Claude loads only what's needed for the current task.

## Skill Creation Workflow

1. **Understand** - Gather concrete usage examples
2. **Plan** - Identify reusable resources (scripts, references)
3. **Create** - Write SKILL.md and reference files
4. **Validate** - Use `skills-ref` to validate structure
5. **Test** - Use the skill on real tasks
6. **Iterate** - Refine based on actual usage

## Tools

### skills-ref

A CLI tool for validating and managing skills. Install via pip:

```bash
pip install skills-ref
```

**Commands:**

| Command | Description |
|---------|-------------|
| `skills-ref validate <path>` | Validate skill structure |
| `skills-ref read-properties <path>` | Extract metadata as JSON |
| `skills-ref to-prompt <path>` | Generate XML for agent prompts |

See: https://github.com/agentskills/agentskills/tree/main/skills-ref

## Skill Locations

| Location | Path | Scope |
|----------|------|-------|
| Personal | `~/.claude/skills/<name>/SKILL.md` | All projects |
| Project | `.claude/skills/<name>/SKILL.md` | Current project |

## Reference

- **[Official Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)**
- **[skills-ref Repository](https://github.com/agentskills/agentskills/tree/main/skills-ref)** - Validation and management tools
- **[Skill Best Practices](./references/best-practices.md)** - Writing effective skills
