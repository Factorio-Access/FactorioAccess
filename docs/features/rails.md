# Virtual Train Driving

Virtual train driving allows you to plan and build rail networks by "driving" a virtual train and having it lay tracks behind you.

## Getting Started

1. Select a rail planner from your inventory (straight rail, curved rail, etc.)
2. Use the read-tile action on an existing rail to lock onto it
3. The system will automatically choose which end of the rail to start from
4. Use keyboard controls to extend the track

To exit virtual train driving, clear your hand (press X to put the rail planner away).

## Keyboard Controls

### Movement
- **Comma (,)**: Extend track forward
- **M**: Extend track to the left
- **Period (.)**: Extend track to the right
- **Alt+Comma**: Flip to the other end of the current rail

### Speculation Mode
- **Slash (/)**: Toggle speculation mode
  - In speculation mode, you can preview where rails would go without building them
  - Press slash again to exit speculation and return to where you started

### Bookmarks
- **Shift+B**: Create a bookmark at the current position (only works when building)
- **B**: Jump back to the last bookmark, removing all track placed after it

### Signals
- **Ctrl+M**: Place chain signal on the left
- **Ctrl+Period**: Place chain signal on the right
- **Shift+M**: Place regular signal on the left
- **Shift+Period**: Place regular signal on the right

### Status
- **K**: Announce current position, direction, and mode

### Undo
- **Backspace**: Remove the most recently placed rail (only works when building)
  - If you backspace all the way to the starting rail, you'll exit virtual train driving

## How It Works

Virtual train driving maintains a history of all the rails you've placed. When you extend forward, left, or right, the system:
1. Calculates where the next rail should go based on rail geometry
2. Places the rail (unless you're in speculation mode)
3. Updates your cursor position to the new rail
4. Announces the new location

Flipping to the other end of a rail doesn't place anything new - it just changes which direction you're facing.

## Tips

- Use speculation mode to preview a route before committing to it
- Use bookmarks to mark decision points in your rail network
- The backspace key lets you undo mistakes without manually removing rails
