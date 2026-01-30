# Linking Strategies for Zettelkasten

Best practices for creating meaningful connections between notes.

## Types of Links

### 1. Direct Links (Explicit Connections)

Links you intentionally create in the "Related Notes" section.

```markdown
## Related Notes
- [[Concept A]] - explains the foundation
- [[Concept B]] - contrasting approach
- [[Project X]] - practical application
```

### 2. Contextual Links (Inline References)

Links embedded within your writing.

```markdown
This approach builds on the principles of [[Atomic Notes]]
while avoiding the pitfalls described in [[Over-Engineering]].
```

### 3. MOC Links (Structural Navigation)

Links from and to Maps of Content for navigation.

```markdown
## Part of
- [[MOC-Kubernetes]]

## See Also
- [[MOC-DevOps]]
```

## Linking Workflow

### After Writing a Note

1. **Ask**: "What does this remind me of?"
2. **Search**: Use Obsidian's search for related keywords
3. **Link**: Add connections in "Related Notes" section
4. **Backlink**: Consider adding reverse link in the target note
5. **MOC**: Update relevant MOCs if this is a significant note

### Questions to Prompt Connections

- What concept does this support or contradict?
- Where have I seen this pattern before?
- What would someone need to understand before reading this?
- What's the next logical topic to explore?
- How does this relate to my active projects?

## Link Relationship Types

### Hierarchical

```markdown
## Parent Concepts
- [[Broader Topic]]

## Child Concepts
- [[Specific Detail 1]]
- [[Specific Detail 2]]
```

### Sequential

```markdown
## Prerequisites
- [[Read This First]]

## Next Steps
- [[Continue Here]]
```

### Associative

```markdown
## Related Notes
- [[Similar Concept]]
- [[Contrasting Approach]]
- [[Real-World Example]]
```

### Source Attribution

```markdown
## Source
- [[Literature Note - Book Title]]
```

## MOC Linking Patterns

### Hub and Spoke

MOC links to all related notes; notes link back to MOC.

```
       ┌─────────────┐
       │   MOC       │
       └─────────────┘
        /    |    \
       /     |     \
      v      v      v
   Note1  Note2  Note3
```

### Nested MOCs

For large topic areas, create sub-MOCs.

```
MOC-Programming
├── MOC-Python
│   ├── Python Basics
│   └── Python Advanced
├── MOC-Rust
│   ├── Rust Basics
│   └── Rust Ownership
└── MOC-Go
```

## Anti-Patterns to Avoid

### 1. Over-Linking

Don't link every mention of a concept. Link when it adds value.

**Bad:**
```markdown
[[Python]] is a [[programming language]] that uses [[indentation]]
for [[code blocks]].
```

**Good:**
```markdown
Python uses indentation for code blocks, similar to the approach
in [[Haskell's Layout Rule]].
```

### 2. Orphan Notes

Notes with no links are lost knowledge. Every permanent note should have at least:
- One outgoing link (what it relates to)
- One incoming link (or MOC reference)

### 3. Link-Only Notes

Notes that are just lists of links provide no value. Add your own synthesis.

**Bad:**
```markdown
# Topic
- [[Note 1]]
- [[Note 2]]
- [[Note 3]]
```

**Good:**
```markdown
# Topic

Overview of the key concepts and how they relate.

## Key Ideas
- [[Note 1]] - foundation concept
- [[Note 2]] - builds on Note 1
- [[Note 3]] - practical application
```

## Tools for Link Management

### Obsidian Features

- **Graph View**: Visualize connections
- **Backlinks Panel**: See what links to current note
- **Outgoing Links Panel**: See what current note links to
- **Random Note**: Discover forgotten notes

### Plugins

- **Dataview**: Query notes by links
- **Graph Analysis**: Find clusters and orphans
- **Breadcrumbs**: Navigate hierarchical relationships

## Maintenance

### Weekly Review

1. Check orphan notes (no incoming links)
2. Review recent notes for missing connections
3. Update MOCs with new significant notes

### Monthly Review

1. Prune broken links
2. Consolidate over-fragmented topics
3. Create new MOCs for emerging themes
