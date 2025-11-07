# 🚀 Setup Guide - Connecting to ChatGPT

## Prerequisites

1. **ChatGPT Plus or Pro account** with access to the Apps SDK preview
2. **Developer Mode enabled** in ChatGPT settings
3. **Node.js 18+** installed on your machine

## Step 1: Build the App (Already Done!)

```bash
npm run build
```

This compiles both the MCP server and the React UI component.

## Step 2: Configure ChatGPT to Use Your App

### Method A: Using ChatGPT Desktop App

1. Open ChatGPT Settings
2. Go to **Developer** section
3. Click **Add MCP Server**
4. Configure:
   - **Name**: Note Keeper
   - **Command**: `node`
   - **Arguments**: `["<FULL_PATH_TO_THIS_DIR>/dist/server.js"]`
   - **Working Directory**: `<FULL_PATH_TO_THIS_DIR>`

Replace `<FULL_PATH_TO_THIS_DIR>` with: `/home/user/PRJCTS`

So the full path would be: `/home/user/PRJCTS/dist/server.js`

### Method B: Manual MCP Configuration

Create or edit your MCP config file at:
- macOS/Linux: `~/.config/mcp/config.json`
- Windows: `%APPDATA%\mcp\config.json`

Add this configuration:

```json
{
  "mcpServers": {
    "note-keeper": {
      "command": "node",
      "args": ["/home/user/PRJCTS/dist/server.js"],
      "cwd": "/home/user/PRJCTS",
      "env": {}
    }
  }
}
```

## Step 3: Restart ChatGPT

After adding the MCP server configuration, restart ChatGPT completely.

## Step 4: Verify Connection

In ChatGPT, try:
- "List my available tools"
- "What can the Note Keeper app do?"

You should see 6 tools available:
- create_note
- list_notes
- get_note
- update_note
- delete_note
- search_notes

## Step 5: Start Using!

Try these commands:
```
Create a note titled "My First Note" with content "Hello from the ChatGPT Apps SDK!"
```

```
Show all my notes
```

The notes will display in a beautiful card-based UI!

## Troubleshooting

### Server Won't Start
```bash
# Check if it runs manually
npm start

# Should see: "Note Keeper MCP Server running on stdio"
```

### ChatGPT Can't Find the App
- Verify the path in your MCP config is absolute, not relative
- Restart ChatGPT completely
- Check Developer Mode is enabled

### Tools Not Appearing
- Make sure the build succeeded: `npm run build`
- Check that `dist/server.js` exists
- Look at ChatGPT developer console for errors

### UI Not Showing
- Verify `web/dist/component.js` exists
- The UI is rendered automatically when using `list_notes`

## Alternative: Using Apps SDK CLI (If Available)

If you have the official Apps SDK CLI installed:

```bash
chatgpt-apps install .
```

This should auto-detect the `app.json` and configure everything.

## What You'll See

When you ask ChatGPT to show your notes, you'll get:
- ✅ Beautiful card-based grid layout
- ✅ Note titles, content, and tags
- ✅ Creation dates
- ✅ Note IDs for reference
- ✅ Automatic empty state when no notes exist

## Development Mode

For development with auto-reload:

```bash
npm run dev
```

Then configure ChatGPT to use `tsx src/server.ts` instead of `node dist/server.js`.

## Current Location

Your app is installed at: `/home/user/PRJCTS/`

All files needed:
- ✅ `dist/server.js` - MCP server
- ✅ `web/dist/component.js` - React UI
- ✅ `app.json` - App manifest
- ✅ `package.json` - Dependencies

---

**Need Help?**
- Check the [official Apps SDK docs](https://developers.openai.com/apps-sdk/)
- Review `README.md` for API documentation
- See `USAGE_EXAMPLES.md` for example conversations
