import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";

// In-memory storage for notes
interface Note {
  id: string;
  title: string;
  content: string;
  createdAt: string;
  tags: string[];
}

const notes: Map<string, Note> = new Map();

// Zod schemas for validation
const CreateNoteSchema = z.object({
  title: z.string().min(1, "Title is required"),
  content: z.string(),
  tags: z.array(z.string()).optional().default([]),
});

const UpdateNoteSchema = z.object({
  id: z.string(),
  title: z.string().optional(),
  content: z.string().optional(),
  tags: z.array(z.string()).optional(),
});

const DeleteNoteSchema = z.object({
  id: z.string(),
});

const GetNoteSchema = z.object({
  id: z.string(),
});

const SearchNotesSchema = z.object({
  query: z.string().optional(),
  tag: z.string().optional(),
});

// Create MCP server
const server = new Server(
  {
    name: "note-keeper-app",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Generate unique ID
function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "create_note",
        description: "Create a new note with title, content, and optional tags",
        inputSchema: {
          type: "object",
          properties: {
            title: {
              type: "string",
              description: "The title of the note",
            },
            content: {
              type: "string",
              description: "The content/body of the note",
            },
            tags: {
              type: "array",
              items: { type: "string" },
              description: "Optional tags to categorize the note",
            },
          },
          required: ["title", "content"],
        },
      },
      {
        name: "list_notes",
        description: "List all notes with their details",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "get_note",
        description: "Get a specific note by its ID",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "The ID of the note to retrieve",
            },
          },
          required: ["id"],
        },
      },
      {
        name: "update_note",
        description: "Update an existing note",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "The ID of the note to update",
            },
            title: {
              type: "string",
              description: "New title for the note",
            },
            content: {
              type: "string",
              description: "New content for the note",
            },
            tags: {
              type: "array",
              items: { type: "string" },
              description: "New tags for the note",
            },
          },
          required: ["id"],
        },
      },
      {
        name: "delete_note",
        description: "Delete a note by its ID",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "The ID of the note to delete",
            },
          },
          required: ["id"],
        },
      },
      {
        name: "search_notes",
        description: "Search notes by content or filter by tag",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "Search query to match in title or content",
            },
            tag: {
              type: "string",
              description: "Filter notes by this tag",
            },
          },
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "create_note": {
        const validated = CreateNoteSchema.parse(args);
        const id = generateId();
        const note: Note = {
          id,
          title: validated.title,
          content: validated.content,
          tags: validated.tags,
          createdAt: new Date().toISOString(),
        };
        notes.set(id, note);

        return {
          content: [
            {
              type: "text",
              text: `Note created successfully! ID: ${id}\n\n**${note.title}**\n${note.content}\n\nTags: ${note.tags.join(", ") || "None"}`,
            },
            {
              type: "resource",
              resource: {
                uri: `note:///${id}`,
                mimeType: "application/json",
                text: JSON.stringify(note, null, 2),
              },
            },
          ],
        };
      }

      case "list_notes": {
        const allNotes = Array.from(notes.values());
        if (allNotes.length === 0) {
          return {
            content: [
              {
                type: "text",
                text: "No notes found. Create your first note!",
              },
            ],
          };
        }

        const notesList = allNotes
          .map(
            (note) =>
              `**${note.title}** (ID: ${note.id})\n${note.content.substring(0, 100)}${note.content.length > 100 ? "..." : ""}\nTags: ${note.tags.join(", ") || "None"}\nCreated: ${new Date(note.createdAt).toLocaleString()}`
          )
          .join("\n\n---\n\n");

        return {
          content: [
            {
              type: "text",
              text: `Found ${allNotes.length} note(s):\n\n${notesList}`,
            },
            {
              type: "resource",
              resource: {
                uri: "notes:///all",
                mimeType: "application/json",
                text: JSON.stringify(allNotes, null, 2),
              },
            },
          ],
        };
      }

      case "get_note": {
        const { id } = GetNoteSchema.parse(args);
        const note = notes.get(id);

        if (!note) {
          return {
            content: [
              {
                type: "text",
                text: `Note with ID "${id}" not found.`,
              },
            ],
            isError: true,
          };
        }

        return {
          content: [
            {
              type: "text",
              text: `**${note.title}**\n\n${note.content}\n\nTags: ${note.tags.join(", ") || "None"}\nCreated: ${new Date(note.createdAt).toLocaleString()}\nID: ${note.id}`,
            },
            {
              type: "resource",
              resource: {
                uri: `note:///${id}`,
                mimeType: "application/json",
                text: JSON.stringify(note, null, 2),
              },
            },
          ],
        };
      }

      case "update_note": {
        const validated = UpdateNoteSchema.parse(args);
        const note = notes.get(validated.id);

        if (!note) {
          return {
            content: [
              {
                type: "text",
                text: `Note with ID "${validated.id}" not found.`,
              },
            ],
            isError: true,
          };
        }

        if (validated.title) note.title = validated.title;
        if (validated.content) note.content = validated.content;
        if (validated.tags) note.tags = validated.tags;

        return {
          content: [
            {
              type: "text",
              text: `Note updated successfully!\n\n**${note.title}**\n${note.content}\n\nTags: ${note.tags.join(", ") || "None"}`,
            },
            {
              type: "resource",
              resource: {
                uri: `note:///${note.id}`,
                mimeType: "application/json",
                text: JSON.stringify(note, null, 2),
              },
            },
          ],
        };
      }

      case "delete_note": {
        const { id } = DeleteNoteSchema.parse(args);
        const note = notes.get(id);

        if (!note) {
          return {
            content: [
              {
                type: "text",
                text: `Note with ID "${id}" not found.`,
              },
            ],
            isError: true,
          };
        }

        notes.delete(id);

        return {
          content: [
            {
              type: "text",
              text: `Note "${note.title}" deleted successfully!`,
            },
          ],
        };
      }

      case "search_notes": {
        const { query, tag } = SearchNotesSchema.parse(args);
        let results = Array.from(notes.values());

        if (tag) {
          results = results.filter((note) => note.tags.includes(tag));
        }

        if (query) {
          const lowerQuery = query.toLowerCase();
          results = results.filter(
            (note) =>
              note.title.toLowerCase().includes(lowerQuery) ||
              note.content.toLowerCase().includes(lowerQuery)
          );
        }

        if (results.length === 0) {
          return {
            content: [
              {
                type: "text",
                text: "No notes found matching your search criteria.",
              },
            ],
          };
        }

        const resultsList = results
          .map(
            (note) =>
              `**${note.title}** (ID: ${note.id})\n${note.content.substring(0, 100)}${note.content.length > 100 ? "..." : ""}\nTags: ${note.tags.join(", ") || "None"}`
          )
          .join("\n\n---\n\n");

        return {
          content: [
            {
              type: "text",
              text: `Found ${results.length} matching note(s):\n\n${resultsList}`,
            },
            {
              type: "resource",
              resource: {
                uri: "notes:///search",
                mimeType: "application/json",
                text: JSON.stringify(results, null, 2),
              },
            },
          ],
        };
      }

      default:
        return {
          content: [
            {
              type: "text",
              text: `Unknown tool: ${name}`,
            },
          ],
          isError: true,
        };
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
      isError: true,
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Note Keeper MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
