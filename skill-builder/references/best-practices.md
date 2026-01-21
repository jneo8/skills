# Skill Best Practices

## Description Writing

The `description` field is the primary trigger mechanism. Make it comprehensive:

```yaml
# Good
description: Guide for creating MCP servers. Use when building MCP servers to integrate external APIs or services, whether in Python or TypeScript.

# Bad
description: MCP server guide.
```

Include:
- What the skill does
- Specific triggers/contexts for when to use it
- Supported variants (languages, frameworks)

## Content Guidelines

### What to Include

- Procedural knowledge Claude doesn't have
- Domain-specific workflows
- Reusable scripts for repetitive tasks
- Reference documentation for APIs/schemas

### What NOT to Include

- Information Claude already knows well
- README or CHANGELOG files
- Installation guides for users
- Verbose explanations when examples suffice

## File Organization

### When to Split into References

Split content when:
- SKILL.md exceeds 300 lines
- Content is variant-specific (Python vs Go)
- Detailed examples bloat the main file
- Reference material is only needed sometimes

### Reference File Tips

- Include table of contents for files >100 lines
- Keep references one level deep from SKILL.md
- Name files descriptively (`python-guide.md` not `guide1.md`)

## Common Mistakes

1. **Overloading SKILL.md** - Keep it as a catalog, not encyclopedia
2. **Vague descriptions** - Be specific about triggers
3. **Missing references** - Always link to reference files from SKILL.md
4. **Framework pollution** - Keep domain layer framework-free
5. **Duplicate content** - Information lives in one place only
