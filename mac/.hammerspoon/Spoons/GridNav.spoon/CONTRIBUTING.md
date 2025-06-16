# Contributing to GridNav

Thank you for your interest in contributing to GridNav! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We aim to foster an inclusive and welcoming community.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/GridNav.spoon.git
   ```
3. **Set up the development environment**:
   - Install [Hammerspoon](https://www.hammerspoon.org/) if you haven't already
   - Symlink or copy your local repository to `~/.hammerspoon/Spoons/GridNav.spoon`

## Development Workflow

1. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and test them thoroughly in Hammerspoon

3. **Follow the code style**:
   - Use camelCase for variable and function names
   - Add LuaDoc comments for all public functions
   - Keep code modular and well-organized
   - Ensure each module has a single responsibility

4. **Testing your changes**:
   ```lua
   -- Add to your Hammerspoon init.lua for testing:
   package.path = package.path .. ";/path/to/your/fork/?.lua"
   hs.loadSpoon("GridNav")
   ```

5. **Commit your changes** with a clear commit message:
   ```bash
   git commit -m "Feature: Brief description of your change"
   ```

## Submitting Changes

1. **Push your changes** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** from your fork to the main repository
   - Clearly describe what your changes do
   - Reference any relevant issues

3. **Code review** - Your pull request will be reviewed, and you might be asked to make further changes

## Bug Reports and Feature Requests

- Use the GitHub Issues section to report bugs or request features
- For bugs, include steps to reproduce, expected behavior, and actual behavior
- For feature requests, explain the use case and benefits

## Documentation

If your changes affect the user interface or add new functionality, please update:
- The README.md file
- LuaDoc comments in code
- Any relevant examples

Thank you for contributing!
