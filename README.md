# 📝 Note Keeper - ChatGPT App

A powerful note-taking app built with the ChatGPT Apps SDK. Create, manage, search, and organize your notes directly within ChatGPT with a beautiful custom UI.

## ✨ Features

- **Create Notes**: Quickly create notes with titles, content, and tags
- **List & View**: View all your notes in a beautiful card-based UI
- **Search**: Find notes by content or filter by tags
- **Update**: Edit existing notes
- **Delete**: Remove notes you no longer need
- **Tag System**: Organize notes with custom tags

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ installed
- npm or pnpm package manager
- ChatGPT with Developer Mode enabled

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd note-keeper-app
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the app:
   ```bash
   npm run build
   ```

4. Run the MCP server:
   ```bash
   npm start
   ```

   Or use the dev server with auto-reload:
   ```bash
   npm run dev
   ```

## 📋 Available Tools

The app provides the following tools for ChatGPT:

### `create_note`
Create a new note with a title, content, and optional tags.

**Parameters:**
- `title` (string, required): The note title
- `content` (string, required): The note content
- `tags` (array of strings, optional): Tags to categorize the note

**Example:**
```
Create a note titled "Meeting Notes" with content "Discussed Q4 goals" and tags ["work", "meetings"]
```

### `list_notes`
Display all notes in a beautiful card-based UI.

**Example:**
```
Show me all my notes
```

### `get_note`
Retrieve a specific note by its ID.

**Parameters:**
- `id` (string, required): The note ID

**Example:**
```
Get note with ID abc123
```

### `update_note`
Update an existing note's title, content, or tags.

**Parameters:**
- `id` (string, required): The note ID
- `title` (string, optional): New title
- `content` (string, optional): New content
- `tags` (array of strings, optional): New tags

**Example:**
```
Update note abc123 with new content "Updated meeting notes"
```

### `delete_note`
Delete a note by its ID.

**Parameters:**
- `id` (string, required): The note ID to delete

**Example:**
```
Delete note abc123
```

### `search_notes`
Search notes by content or filter by tag.

**Parameters:**
- `query` (string, optional): Search term to match in title or content
- `tag` (string, optional): Filter by specific tag

**Example:**
```
Search for notes containing "meeting" or Show notes tagged with "work"
```

## 🏗️ Project Structure

```
note-keeper-app/
├── src/
│   └── server.ts          # MCP server with note management tools
├── web/
│   ├── src/
│   │   └── component.tsx  # React UI component for displaying notes
│   └── dist/
│       └── component.js   # Built UI component
├── dist/                  # Built server files
├── app.json              # App manifest
├── package.json          # Project configuration
├── tsconfig.json         # TypeScript config for server
└── README.md            # This file
```

## 🛠️ Development

### Build Commands

- `npm run build` - Build both server and web components
- `npm run build:server` - Build only the MCP server
- `npm run build:web` - Build only the React UI component
- `npm run dev` - Run the dev server with tsx
- `npm start` - Run the production server

### Tech Stack

- **MCP SDK**: [@modelcontextprotocol/sdk](https://www.npmjs.com/package/@modelcontextprotocol/sdk)
- **Validation**: [Zod](https://zod.dev)
- **UI Framework**: React 19
- **Build Tools**: TypeScript, esbuild
- **Runtime**: Node.js

## 📱 Using in ChatGPT

1. Enable Developer Mode in your ChatGPT settings
2. Add this app to your ChatGPT environment
3. Start chatting! Try commands like:
   - "Create a note about my project ideas"
   - "Show all my notes"
   - "Search for notes about work"
   - "Delete the note with ID xyz789"

## 🎨 UI Components

The app includes a beautiful React-based UI that displays notes in a card grid layout with:
- Note titles and content
- Creation dates
- Tags with color coding
- Note IDs for easy reference
- Empty state for when no notes exist

## 📝 Notes

- Notes are stored in-memory. Restarting the server will clear all notes.
- For production use, consider adding persistent storage (file system, database, etc.)
- The app uses the Model Context Protocol (MCP) standard

## 🤝 Contributing

This is a demo app built for learning the ChatGPT Apps SDK. Feel free to fork and extend it!

## 📄 License

ISC

## 🔗 Resources

- [ChatGPT Apps SDK Documentation](https://developers.openai.com/apps-sdk/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [OpenAI Apps Examples](https://github.com/openai/openai-apps-sdk-examples)

---

Built with ❤️ using the ChatGPT Apps SDK
