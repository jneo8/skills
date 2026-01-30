# Zettelkasten Migration Guide

How to migrate an existing Obsidian vault to Zettelkasten structure.

## Migration Strategy

Use a **gradual approach** - don't try to reorganize everything at once.

### Phase 1: Structure Setup (Non-destructive)

1. Create new folder structure alongside existing folders
2. Create initial MOC files with Dataview queries
3. Old folders remain untouched

```bash
# Create new folders (bilingual names optional)
mkdir "0-Inbox (收件匣)"
mkdir "1-Literature (文獻筆記)"
mkdir "2-Projects (專案筆記)"
mkdir "3-Permanent (永久筆記)"
mkdir "4-MOCs (索引)"
mkdir "5-Daily (日記)"
mkdir "6-Archive (歸檔)"
```

### Phase 2: Template Updates

1. Update templates with new conventions (Related Notes, Questions sections)
2. Configure Templater to use new folder paths
3. Update Daily Notes plugin settings

### Phase 3: Bulk Migration

Move notes from old folders to new structure:

```bash
# Move and flatten (removes subfolders)
find "Old Folder" -type f -name "*.md" -exec mv {} "New Folder/" \;

# Move attachments
find "Old Folder" -type f ! -name "*.md" -exec mv {} "attachments/" \;
```

### Phase 4: Compression

Reduce note count by merging related short notes.

### Phase 5: Cleanup

1. Remove empty old folders
2. Verify links still work

## Bulk Migration Commands

### Move all markdown files (flatten structure)

```bash
find "ZK - Literature Notes" -type f -name "*.md" -exec mv {} "1-Literature (文獻筆記)/" \;
```

### Add status tags to notes in bulk

```bash
for file in "Folder"/*.md; do
  if grep -q "^Status:" "$file"; then
    sed -i 's/^Status:.*/Status: #on-going/' "$file"
  fi
done
```

### Find short notes for compression

```bash
find "1-Literature" -name "*.md" -type f | while read file; do
  content=$(sed '/^---$/,/^---$/d; /^$/d; /^#/d' "$file" | wc -l)
  if [ "$content" -le 5 ]; then
    echo "$content lines: $(basename "$file")"
  fi
done | sort -n
```

### Find empty template notes

```bash
# Detect notes that are just empty templates (no real content)
for file in "5-Daily"/*.md; do
  real_content=$(sed '/^---$/,/^---$/d; /^$/d; /^#/d; /dataview/,/\`\`\`/d' "$file" | \
    grep -v "^<%" | wc -l)
  if [ "$real_content" -eq 0 ]; then
    echo "Empty: $(basename "$file")"
  fi
done
```

## Status Folder Migration

If you have status-based folders, migrate to tags:

| Old Folder | New Location | Tag |
|------------|--------------|-----|
| On Going | 2-Projects | `#on-going` |
| Someday/Maybe | 0-Inbox | `#someday` |
| Canceled | 6-Archive | `#canceled` |
| Achieved | 6-Archive | `#achieved` |

## Compressing Notes by Topic

When you find many small notes on the same topic:

1. **Identify the group** (e.g., 23 Design Pattern notes)
2. **Create consolidated note** with proper structure:

```markdown
---
UID: 202601301530
Tags: [topic-tag]
Status: #wip
---

# Topic Name

## Subtopic 1
Content from first note...

## Subtopic 2
Content from second note...
```

3. **Delete individual files**:
```bash
rm "Abstract Factory.md" "Singleton.md" "Observer.md" ...
```

## Archiving Daily Notes

### By Month (Recommended)

For old daily notes (>1-2 years):

```bash
# Create monthly archive
for ym in 202207 202208 202209; do
  year=${ym:0:4}
  month=${ym:4:2}
  output="6-Archive/Daily/${year}-${month}-Monthly.md"

  # Header
  cat > "$output" << EOF
---
UID: ${ym}01
Tags: [daily, archive, ${year}]
Status: #finish
---

# ${year}-${month} Monthly Archive

EOF

  # Append each day's content (only if has real content)
  for daily in "5-Daily"/Daily-${ym}*.md; do
    # Check for real content, skip empty templates
    content=$(sed '/^---$/,/^---$/d; /^$/d; /^#/d; /dataview/,/```/d' "$daily" | wc -l)
    if [ "$content" -gt 0 ]; then
      day=$(basename "$daily" | grep -oE "[0-9]{8}" | tail -c 3 | head -c 2)
      echo "## ${year}-${month}-${day}" >> "$output"
      sed '/^---$/,/^---$/d; /dataview/,/```/d' "$daily" >> "$output"
      echo "" >> "$output"
    fi
  done
done
```

### Delete Empty Archives

```bash
for monthly in "6-Archive/Daily"/*.md; do
  content=$(grep -v "^---" "$monthly" | grep -v "^#" | grep -v "^$" | \
    grep -v "^UID:" | grep -v "^Tags:" | grep -v "^Status:" | wc -l)
  if [ "$content" -eq 0 ]; then
    rm "$monthly"
    echo "Deleted empty: $(basename "$monthly")"
  fi
done
```

## Archiving Work Notes

For old work-related notes (meetings, training, etc.):

```bash
# Create category archive
output="6-Archive/Work-Training-Archive.md"
cat > "$output" << EOF
---
UID: 202203010000
Tags: [archive, work, training]
Status: #finish
---

# Work Training Archive

EOF

# Append each note
for file in "Work/Training"/*.md; do
  title=$(basename "$file" .md)
  echo "## $title" >> "$output"
  sed '/^---$/,/^---$/d' "$file" | head -50 >> "$output"
  echo "" >> "$output"
  echo "---" >> "$output"
done
```

## Verification Checklist

After migration:

- [ ] All notes moved to new folders
- [ ] Status tags applied correctly
- [ ] MOC Dataview queries return results
- [ ] Graph view shows MOCs as hub nodes
- [ ] Empty old folders deleted
- [ ] Daily notes plugin configured for new folder
- [ ] Templates updated with new paths
- [ ] Attachments consolidated

## Common Issues

### Broken Links
Obsidian usually auto-updates links on move. If not:
- Use "Show orphan files" to find broken links
- Install "Broken Links" community plugin

### Duplicate Files
Check for duplicates after flattening:
```bash
find "1-Literature" -name "*.md" | xargs -I{} basename {} | sort | uniq -d
```

### Large Vaults
For vaults >1000 notes, process in batches to avoid overwhelming Obsidian's sync.
