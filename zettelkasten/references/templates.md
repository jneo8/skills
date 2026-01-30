# Note Templates for Zettelkasten

Templates for different note types in a Zettelkasten vault.

## Permanent Note Template

For your own synthesized insights and ideas.

```markdown
---
UID: {{date:YYYYMMDDHHmm}}
Status: #wip
Series:
Tags:
---

# {{title}}

## Insight
<!-- One atomic idea - keep it focused and self-contained -->


## Summary


## View


## Cases


---

## Related Notes
<!-- Link to connected permanent notes -->
-

## Questions
<!-- Prompts for future connections -->
- What does this connect to?
- What contradicts this?

---
## Source
<!-- Link to literature note if applicable -->


## References
```

## Literature Note Template

For summarizing external sources (books, articles, talks).

```markdown
---
UID: {{date:YYYYMMDDHHmm}}
Status: #wip
Series:
Tags:
---

# {{title}}

## Summary


## Terminology


## Notes


---

## Related Notes
<!-- Link to connected notes -->
-

## Questions
<!-- Prompts for future connections -->
-

---
## References
```

## Daily Note Template

For daily logs and journals.

```markdown
---
UID: {{date:YYYYMMDDHHmm}}
Status:
Series: #daily
Tags:
---

# {{title}}

## Tasks
- [ ]

## Notes


## References
```

**Note**: Keep daily templates simple. Avoid heavy dataview queries that clutter archives.

## MOC Template

For Maps of Content (navigation hubs).

```markdown
---
UID: {{date:YYYYMMDDHHmm}}
Tags: [moc, topic-name]
---

# MOC - Topic Name

Brief description of this topic area.

## Key Notes
- [[Note 1]] - description
- [[Note 2]] - description

## All Related Notes
\`\`\`dataview
LIST FROM #topic-tag
SORT file.name ASC
\`\`\`

## Questions to Explore
-

## Related MOCs
- [[MOC-Related-Topic]]
```

## Project Note Template

For time-bound project work.

```markdown
---
UID: {{date:YYYYMMDDHHmm}}
Status: #on-going
Tags: [project]
---

# {{title}}

## Goal


## Tasks
- [ ]

## Notes


## Related Notes
-

## References
```

## Archive Note Template

For consolidated archive notes (e.g., monthly daily archives).

```markdown
---
UID: YYYYMM01
Tags: [archive, category, year]
Status: #finish
---

# YYYY-MM Category Archive

## YYYY-MM-DD
Content from that day...

## YYYY-MM-DD
Content from that day...
```

## Template Tips

1. **Keep frontmatter consistent** - Always include UID, Status, Tags
2. **Use Templater** - `{{date:YYYYMMDDHHmm}}` and `{{title}}` for auto-fill
3. **Avoid dataview in daily notes** - Makes archiving cleaner
4. **Include Related Notes section** - Encourages linking
5. **Add Questions section** - Prompts future connections
