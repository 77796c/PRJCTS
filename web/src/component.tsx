import React from 'react';

interface Note {
  id: string;
  title: string;
  content: string;
  createdAt: string;
  tags: string[];
}

interface NotesDisplayProps {
  notes: Note[];
}

export function NotesDisplay({ notes }: NotesDisplayProps) {
  if (!notes || notes.length === 0) {
    return (
      <div style={styles.emptyState}>
        <div style={styles.emptyIcon}>📝</div>
        <h3 style={styles.emptyTitle}>No notes yet</h3>
        <p style={styles.emptyText}>Create your first note to get started!</p>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2 style={styles.title}>📚 My Notes</h2>
        <span style={styles.count}>{notes.length} note{notes.length !== 1 ? 's' : ''}</span>
      </div>
      <div style={styles.notesGrid}>
        {notes.map((note) => (
          <NoteCard key={note.id} note={note} />
        ))}
      </div>
    </div>
  );
}

function NoteCard({ note }: { note: Note }) {
  const date = new Date(note.createdAt);
  const formattedDate = date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  return (
    <div style={styles.card}>
      <div style={styles.cardHeader}>
        <h3 style={styles.noteTitle}>{note.title}</h3>
        <span style={styles.date}>{formattedDate}</span>
      </div>
      <p style={styles.content}>{note.content}</p>
      {note.tags && note.tags.length > 0 && (
        <div style={styles.tags}>
          {note.tags.map((tag, index) => (
            <span key={index} style={styles.tag}>
              #{tag}
            </span>
          ))}
        </div>
      )}
      <div style={styles.footer}>
        <span style={styles.noteId}>ID: {note.id}</span>
      </div>
    </div>
  );
}

// Styles
const styles: { [key: string]: React.CSSProperties } = {
  container: {
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    padding: '20px',
    maxWidth: '1200px',
    margin: '0 auto',
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '24px',
    paddingBottom: '16px',
    borderBottom: '2px solid #e5e7eb',
  },
  title: {
    margin: 0,
    fontSize: '24px',
    fontWeight: '700',
    color: '#111827',
  },
  count: {
    fontSize: '14px',
    color: '#6b7280',
    backgroundColor: '#f3f4f6',
    padding: '4px 12px',
    borderRadius: '12px',
    fontWeight: '500',
  },
  notesGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
    gap: '16px',
  },
  card: {
    backgroundColor: '#ffffff',
    border: '1px solid #e5e7eb',
    borderRadius: '12px',
    padding: '16px',
    boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
    transition: 'transform 0.2s, box-shadow 0.2s',
    cursor: 'pointer',
  },
  cardHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: '12px',
  },
  noteTitle: {
    margin: 0,
    fontSize: '18px',
    fontWeight: '600',
    color: '#111827',
    flex: 1,
  },
  date: {
    fontSize: '12px',
    color: '#9ca3af',
    whiteSpace: 'nowrap',
    marginLeft: '8px',
  },
  content: {
    margin: '0 0 12px 0',
    fontSize: '14px',
    color: '#4b5563',
    lineHeight: '1.6',
    display: '-webkit-box',
    WebkitLineClamp: 4,
    WebkitBoxOrient: 'vertical',
    overflow: 'hidden',
  },
  tags: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '6px',
    marginBottom: '12px',
  },
  tag: {
    fontSize: '12px',
    color: '#3b82f6',
    backgroundColor: '#eff6ff',
    padding: '2px 8px',
    borderRadius: '6px',
    fontWeight: '500',
  },
  footer: {
    paddingTop: '12px',
    borderTop: '1px solid #f3f4f6',
  },
  noteId: {
    fontSize: '11px',
    color: '#9ca3af',
    fontFamily: 'monospace',
  },
  emptyState: {
    textAlign: 'center',
    padding: '60px 20px',
    color: '#6b7280',
  },
  emptyIcon: {
    fontSize: '64px',
    marginBottom: '16px',
  },
  emptyTitle: {
    fontSize: '20px',
    fontWeight: '600',
    color: '#374151',
    marginBottom: '8px',
  },
  emptyText: {
    fontSize: '14px',
    color: '#9ca3af',
  },
};

// Export for use in ChatGPT
export default NotesDisplay;
