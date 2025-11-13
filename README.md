<div align="center">
  <img src="config/bolt_logo.png" alt="Bolt Logo" width="200"/>

  
  **Lightning-fast template management for files and directories written in Zig**
</div>


## Overview

Bolt is a command-line template management tool that lets you save and reuse file and directory structures. Perfect for developers who frequently create similar project structures, configuration files, or boilerplate code.

- 📁 **Save Files & Directories** - Turn any file or folder into a reusable template
- ⚡ **Instant Creation** - Generate new files/directories from templates in seconds

## Installation 🔧

### Option 1: Download Pre-built Binary (Recommended)

Download the latest release for your platform from the [Releases page](https://github.com/yourusername/bolt/releases):

**Linux:**
```bash
# Download and install
curl -L https://github.com/yourusername/bolt/releases/latest/download/bolt-linux-x86_64 -o bolt
chmod +x bolt
sudo mv bolt /usr/local/bin/
```

**macOS:**
```bash
# Download and install
curl -L https://github.com/yourusername/bolt/releases/latest/download/bolt-macos-x86_64 -o bolt
chmod +x bolt
sudo mv bolt /usr/local/bin/
```

**Windows:**
Download `bolt-windows-x86_64.exe` from releases and add it to your PATH.

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/bolt.git
cd bolt

# Build with Zig (requires Zig 0.11.0+)
zig build -Doptimize=ReleaseFast

# The binary will be in zig-out/bin/
```

## Usage

### Save a Template

```bash
# Save a file as a template
bolt -s ./config.json my_config

# Save a directory as a template
bolt -s ./project_structure react_starter
```

### Create from Template

```bash
# Create a file or directory from a saved template
bolt -t my_config
bolt -t react_starter
```

### Overwrite a Template

```bash
# Update an existing template
bolt -o ./new_config.json my_config
```

### List All Templates

```bash
bolt -ls
# or
bolt --list
```

### Remove a Template

```bash
bolt -r my_config
# or
bolt --remove my_config
```

### Clear All Templates

```bash
bolt --clear
```

## Command Reference

| Command | Description |
|---------|-------------|
| `-h, --help` | Display help message |
| `-s <path> <name>` | Save file/directory as template |
| `-o <path> <name>` | Overwrite existing template |
| `-t <name>` | Create from template |
| `-ls, --list` | List all saved templates |
| `-r <name>, --remove <name>` | Remove a template |
| `--clear` | Delete all templates |

## How It Works

Bolt stores templates in `~/.bolt/cache/` along with a `cache.txt` file that tracks template metadata. When you create from a template, Bolt copies the saved file or recursively copies the directory structure to your current location.

## Examples

**Save a React component structure:**
```bash
bolt -s ./src/components/Button react_button
```

**Create the component in a new project:**
```bash
cd new-project/src/components
bolt -t react_button
```

**Save a configuration file:**
```bash
bolt -s ~/.vimrc my_vimrc
```

**Use it anywhere:**
```bash
cd ~/new-setup
bolt -t my_vimrc
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
