# Dataview Queries for Zettelkasten

Useful Dataview queries for managing a Zettelkasten vault in Obsidian.

## Status Dashboards

### All Work in Progress

```dataview
LIST
FROM #wip
SORT file.mtime DESC
```

### Active Projects

```dataview
TABLE file.mtime AS "Last Modified"
FROM "2-Projects"
WHERE Status = "#on-going"
SORT file.mtime DESC
```

### Someday/Maybe Ideas

```dataview
LIST
FROM #someday
SORT file.ctime DESC
```

## Inbox Management

### Unprocessed Notes (older than 7 days)

```dataview
TABLE file.ctime AS "Created"
FROM "0-Inbox"
WHERE date(now) - file.ctime > dur(7 days)
SORT file.ctime ASC
```

### Recent Inbox Items

```dataview
LIST
FROM "0-Inbox"
SORT file.ctime DESC
LIMIT 10
```

## Recent Notes

### Recently Modified

```dataview
TABLE file.folder AS "Location", file.mtime AS "Modified"
FROM ""
WHERE file.folder != "Templates" AND file.folder != "Attachments"
SORT file.mtime DESC
LIMIT 20
```

### Recently Created

```dataview
LIST
FROM "3-Permanent" OR "1-Literature"
SORT file.ctime DESC
LIMIT 10
```

## MOC Queries

### All Notes with Tag

```dataview
LIST
FROM #topic-tag
SORT file.name ASC
```

### Notes by Folder with Count

```dataview
TABLE length(rows) AS "Count"
FROM ""
WHERE file.folder != "Templates"
GROUP BY file.folder
SORT length(rows) DESC
```

### Notes Linking to Current Note

```dataview
LIST
FROM [[]]
SORT file.name ASC
```

## Orphan Detection

### Notes with No Outgoing Links

```dataview
LIST
FROM "3-Permanent"
WHERE length(file.outlinks) = 0
SORT file.mtime DESC
```

### Notes with No Incoming Links

```dataview
LIST
FROM "3-Permanent"
WHERE length(file.inlinks) = 0
SORT file.mtime DESC
```

## Content Analysis

### Short Notes (potential merge candidates)

```dataview
TABLE length(file.lists) AS "List Items", file.size AS "Size"
FROM "1-Literature"
WHERE file.size < 500
SORT file.size ASC
LIMIT 20
```

### Notes Missing Status Tag

```dataview
LIST
FROM "3-Permanent" OR "1-Literature"
WHERE !Status
SORT file.mtime DESC
```

## Calendar Views

### Notes Created This Week

```dataview
TABLE file.folder AS "Location"
FROM ""
WHERE file.ctime >= date(today) - dur(7 days)
SORT file.ctime DESC
```

### Notes Modified Today

```dataview
LIST
FROM ""
WHERE file.mtime >= date(today)
SORT file.mtime DESC
```

## Topic-Specific Queries

### Example: Kubernetes Notes

```dataview
TABLE file.folder AS "Location", file.mtime AS "Modified"
FROM ""
WHERE contains(file.name, "Kubernetes") OR contains(file.name, "k8s") OR contains(tags, "kubernetes")
SORT file.mtime DESC
```

### Example: Notes with Questions Section

```dataview
LIST
FROM "3-Permanent"
WHERE contains(file.content, "## Questions")
SORT file.mtime DESC
```
