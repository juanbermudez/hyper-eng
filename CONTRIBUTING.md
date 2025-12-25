# Contributing to Hyper-Engineering

Thanks for your interest in contributing! This document outlines how to get involved.

## Ways to Contribute

### Report Issues

Found a bug or have a feature request? [Open an issue](https://github.com/juanbermudez/hyper-eng/issues/new) with:

- Clear description of the problem or feature
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Your environment (Claude Code version, OS)

### Submit Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

### Improve Documentation

Documentation improvements are always welcome:

- Fix typos or unclear explanations
- Add examples
- Improve command descriptions
- Update outdated information

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/hyper-eng.git
cd hyper-eng

# Install the plugin locally for testing
claude mcp add-from-claude-plugin .
```

## Code Guidelines

### Agent and Command Files

- Use clear, descriptive names
- Include comprehensive descriptions
- Document all parameters
- Provide usage examples

### Commit Messages

Follow conventional commits:

```
feat: add new research agent for API analysis
fix: resolve Linear CLI authentication issue
docs: update installation instructions
refactor: simplify verification loop logic
```

### Pull Request Guidelines

- Keep PRs focused on a single change
- Update documentation if needed
- Add tests for new functionality
- Ensure existing tests pass

## Project Structure

```
hyper-eng/
├── plugins/
│   └── hyper-engineering/
│       ├── agents/           # AI agents
│       ├── commands/         # Slash commands
│       ├── skills/           # Reusable skills
│       ├── mcp-servers/      # MCP server configs
│       └── templates/        # Stack templates
├── .claude-plugin/           # Marketplace config
└── docs/                     # Documentation
```

## Questions?

- Open a [Discussion](https://github.com/juanbermudez/hyper-eng/discussions)
- Check existing [Issues](https://github.com/juanbermudez/hyper-eng/issues)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
