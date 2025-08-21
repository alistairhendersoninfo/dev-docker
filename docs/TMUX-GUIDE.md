# TMUX Tiling Workflow Guide

Your development environment comes with a pre-configured tmux setup optimized for tiling and productivity.

## 🚀 Quick Start

```bash
# Start new development session
dev

# Attach to existing session
deva

# List all sessions
devl
```

## 🎯 Key Bindings

### Session Management

- **Alt-t**: Create new window
- **Alt-k**: Kill current window
- **Alt-1,2,3...**: Switch to window 1, 2, 3...
- **Alt-r**: Reload tmux configuration

### Pane Management

- **|**: Split pane horizontally
- **-**: Split pane vertically
- **Alt-arrow**: Navigate between panes (no prefix needed)
- **Ctrl-arrow**: Resize panes

### Mouse Support

- **Click and drag**: Resize panes
- **Click**: Select pane
- **Scroll**: Scroll through history

## 🏗️ Typical Development Layout

### Layout 1: Code + Terminal

```
┌─────────────────┬─────────────────┐
│                 │                 │
│   Code Editor  │   Terminal      │
│   (Vim/Neo)    │   (Commands)    │
│                 │                 │
│                 │                 │
└─────────────────┴─────────────────┘
```

### Layout 2: Code + Terminal + Logs

```
┌─────────────────┬─────────────────┐
│                 │                 │
│   Code Editor  │   Terminal      │
│   (Vim/Neo)    │   (Commands)    │
├─────────────────┴─────────────────┤
│                                   │
│           Logs/Monitoring         │
│                                   │
└───────────────────────────────────┘
```

### Layout 3: Multi-Project

```
┌─────────────────┬─────────────────┐
│   Project 1     │   Project 2     │
│   (Frontend)    │   (Backend)     │
├─────────────────┴─────────────────┤
│                                   │
│           Database/API            │
│                                   │
└───────────────────────────────────┘
```

## 🔧 Customization

### Edit Configuration

```bash
# Edit tmux config
nano ~/.config/tmux/tmux.conf

# Reload config (Alt-r)
```

### Add Your Own Bindings


```bash
# Example: Add custom binding
bind -n M-s split-window -h
bind -n M-v split-window -v
```

## 💡 Productivity Tips

### 1. Use Windows for Different Tasks

- **Window 1**: Code editing
- **Window 2**: Terminal/commands
- **Window 3**: Logs/monitoring
- **Window 4**: Database queries
- **Window 5**: Git operations

### 2. Leverage Pane Splits

- Keep related tools in the same window
- Use horizontal splits for wide content
- Use vertical splits for side-by-side comparison

### 3. Quick Navigation

- **Alt-1**: Jump to code window
- **Alt-2**: Jump to terminal window
- **Alt-arrow**: Navigate panes quickly

### 4. Session Persistence

- Your tmux session persists even if you disconnect
- Reconnect with `deva` to resume exactly where you left off

## 🎨 Visual Enhancements

### Status Bar

- Shows current session, windows, and panes
- Color-coded for easy identification
- Git branch information (if in git repo)

### Colors

- 256-color support for rich terminal experience
- Syntax highlighting in supported tools
- Consistent theme across all panes

## 🔍 Troubleshooting

### Common Issues

```bash
# Session not responding
# Press Ctrl-a then :kill-session

# Pane not resizing
# Use Ctrl-arrow keys

# Mouse not working
# Check: tmux show-options -g mouse
```

### Reset Configuration

```bash
# Reset to defaults
rm ~/.config/tmux/tmux.conf
# Restart tmux
```

---

**Pro Tip**: Use `dev` to start your development session, then organize your workflow with the tiling layout. The pre-configured bindings make tmux feel natural and productive!
