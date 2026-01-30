---
name: zettelkasten
description: Guide for organizing Obsidian notes following the Zettelkasten method. Use this skill when (1) setting up a new Obsidian vault with Zettelkasten structure, (2) reorganizing existing notes into Zettelkasten format, (3) creating atomic notes, literature notes, or permanent notes, (4) building Maps of Content (MOCs), (5) improving note linking and connections, (6) compressing or consolidating fragmented notes, (7) archiving old daily notes or work notes, or (8) when the user mentions Zettelkasten, slip-box, atomic notes, or MOCs.
---

# Zettelkasten Method for Obsidian

Guide for implementing the Zettelkasten (slip-box) method in Obsidian vaults.

## Core Principles

1. **Atomic Notes** - One idea per note, self-contained
2. **Unique Identifiers** - Use timestamp UIDs (YYYYMMDDHHmm)
3. **Linking Over Filing** - Notes gain value from connections, not folders
4. **Three Note Types** - Fleeting → Literature → Permanent
5. **Entry Points** - MOCs (Maps of Content) as navigation hubs

## Recommended Folder Structure

```
0-Inbox (收件匣)/        # Fleeting notes, quick captures
1-Literature (文獻筆記)/ # Source-based notes (books, articles, talks)
2-Projects (專案筆記)/   # Active project notes (time-bound)
3-Permanent (永久筆記)/  # Synthesized insights (your own ideas)
4-MOCs (索引)/          # Maps of Content (entry points)
5-Daily (日記)/         # Daily notes
6-Archive (歸檔)/       # Completed projects, old notes
attachments/            # Images, PDFs
Extra/Templates/        # Note templates
```

**Key**: Flat structure within folders. Use tags and links for organization, not subfolders.

## Note Types

| Type | Purpose | Location | Lifecycle |
|------|---------|----------|-----------|
| Fleeting | Quick captures, raw ideas | 0-Inbox | Process within days |
| Literature | Summarize sources in your words | 1-Literature | Reference material |
| Permanent | Your synthesized insights | 3-Permanent | Evergreen knowledge |
| Project | Time-bound work | 2-Projects | Archive when done |
| Daily | Daily logs | 5-Daily | Archive when old |

## Status Tags

Use tags instead of folders for workflow state:

| Tag | Meaning |
|-----|---------|
| `#wip` | Work in progress (being written) |
| `#on-going` | Active work investing time in |
| `#someday` | Future exploration ideas |
| `#achieved` | Completed/accomplished |
| `#canceled` | Abandoned, kept for reference |
| `#finish` | Note content is finalized |

## Workflows

### Processing Inbox Notes
1. Read the fleeting note
2. Decide: Literature note, Permanent note, or delete?
3. Create proper note with template
4. Add links to related notes
5. Update relevant MOCs
6. Delete or archive original

### Creating Connections
1. After writing a note, ask: "What does this remind me of?"
2. Search for related notes by keyword
3. Add bidirectional links in "Related Notes" section
4. Consider adding to relevant MOCs

## Compression & Archival

### Finding Empty/Short Notes

```bash
# Find notes with minimal content
find "1-Literature" -name "*.md" -type f | while read file; do
  content=$(sed '/^---$/,/^---$/d; /^$/d; /^#/d' "$file" | wc -l)
  if [ "$content" -le 3 ]; then
    echo "$content lines: $(basename "$file")"
  fi
done | sort -n
```

### Compressing Topic Notes
When vault has many small/empty notes on same topic:
1. Find notes with <5 lines of content
2. Group by topic (e.g., Design Patterns, Algorithms, Database)
3. Create one comprehensive note with sections for each subtopic
4. Delete individual stub files
5. Update any broken links

**Example**: 23 empty Design Pattern notes → 1 consolidated `Design Patterns.md`

### Archiving Daily Notes by Month
For daily notes older than a threshold (e.g., 2 years):

1. Create monthly archive: `6-Archive/Daily/YYYY-MM-Monthly.md`
2. Extract only days with actual content (skip empty templates)
3. Format as sections: `## YYYY-MM-DD` followed by content
4. Delete original daily files
5. Delete monthly archives that have no content

**Script pattern:**
```bash
# Check if daily note has real content (not just template)
content=$(sed '/^---$/,/^---$/d; /^$/d; /^#/d; /dataview/,/\`\`\`/d' "$file" | wc -l)
if [ "$content" -eq 0 ]; then
  echo "Empty template: $file"
fi
```

### Archiving Work/Project Notes
For old work-related notes (meetings, training, sprints):

1. Group by category (e.g., OnBoarding, Meetings, Sprints)
2. Create consolidated archive note per category
3. Include section headers with original note titles
4. Keep only meaningful content, strip empty template sections
5. Move sensitive notes (credentials, secrets) to separate secure location

## Maintenance Schedule

### Weekly
- Process Inbox notes (should be near-empty)
- Review recent notes for missing links

### Monthly
- Update MOCs with new important notes
- Archive completed projects
- Check for orphan notes (no incoming links)

### Quarterly
- Compress/merge fragmented short notes
- Archive old daily notes (>1-2 years)
- Review and clean up unused tags

## Reference Documentation

- **[Migration Guide](./references/migration.md)** - How to migrate existing vaults
- **[Dataview Queries](./references/dataview.md)** - Useful queries for Zettelkasten
- **[Linking Strategies](./references/linking.md)** - Best practices for note connections
- **[Templates](./references/templates.md)** - Note template examples
