# homebox-mcp

An [MCP](https://modelcontextprotocol.io) server for a [Homebox](https://github.com/sysadminsmedia/homebox)
inventory, over stdio. It is what the Discord inventory agent uses, and it works the
same from Claude Code or any other MCP client.

Tested against Homebox **0.26** (the `/v1/entities` API). Older releases are not
supported.

## Tools

| Tool | What it does |
|---|---|
| `list_locations` | The location tree, with item counts |
| `find_items` | Search items by name, description or location |
| `location_contents` | What is in one location, including nested ones |
| `get_details` | Full details of one item or location |
| `create_location` | Add a location, optionally inside another |
| `add_items` | Add one or more items to a location |
| `update_item` | Change an item's name, quantity, description or notes |
| `move` | Move an item or location somewhere else |
| `delete` | Delete an item or an empty location |
| `attach_photo` | Attach an image file to an item or location |
| `record_feedback` | Note a mistake or correction for later review (see `HOMEBOX_MCP_FEEDBACK`) |

IDs are checked as UUIDs before any request, so a model can't steer a call to some
other API path, and `attach_photo` only accepts image files.

## Running it

Needs [uv](https://docs.astral.sh/uv/). Pin a tag so an update is a deliberate change:

```json
{
  "mcpServers": {
    "homebox": {
      "type": "stdio",
      "command": "uvx",
      "args": ["--from", "git+https://github.com/benfugate/homebox-mcp@v1.0.0", "homebox-mcp"],
      "env": {
        "HOMEBOX_URL": "${HOMEBOX_URL}",
        "HOMEBOX_API_KEY": "${HOMEBOX_API_KEY}"
      }
    }
  }
}
```

Or with Claude Code:

```bash
claude mcp add homebox -e HOMEBOX_URL=https://homebox.example -e HOMEBOX_API_KEY=hb_... -- uvx --from git+https://github.com/benfugate/homebox-mcp@v1.0.0 homebox-mcp
```

The first start downloads the package and its dependencies into uv's cache; later
starts are offline.

## Settings

| Variable | Default | |
|---|---|---|
| `HOMEBOX_URL` | (required) | Homebox base URL, e.g. `http://homebox:7745` |
| `HOMEBOX_API_KEY` | (required) | An API key from Homebox's Profile page. Every change is made as that user. |
| `HOMEBOX_MCP_LOG_MODE` | `changes` | What `audit.jsonl` records. `changes`: every call that modifies Homebox, plus any call that fails. `verbose`: every call, reads included, with fuller results. `off`: nothing. |
| `HOMEBOX_MCP_FEEDBACK` | `on` | Offers the `record_feedback` tool, which writes to `feedback.jsonl`. `off` removes it. |
| `HOMEBOX_MCP_LOG_DIR` | `$XDG_STATE_HOME/homebox-mcp` (`~/.local/state/homebox-mcp`) | Where `audit.jsonl` and `feedback.jsonl` go. Each rotates at 5 MB. |

## Tests

Both run in Docker:

```bash
docker build --target test -t homebox-mcp:test .
```

```bash
docker run --rm homebox-mcp:test
```

The live test runs every tool against a real Homebox, inside a throwaway location
that it deletes afterwards:

```bash
docker run --rm -e HOMEBOX_URL=http://... -e HOMEBOX_API_KEY=hb_... homebox-mcp:test python tests/test_live.py
```
