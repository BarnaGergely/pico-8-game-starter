# Contributing to PICO-8 Game

This document provides guidelines for developers who want to work on this project.

## Getting Started

### Prerequisites

- [PICO-8](https://www.lexaloffle.com/pico-8.php) (licensed version recommended, but education edition also works)
- Git for version control
- Visual Studio Code for advanced code editing and version control

### Windows Setup

1. Install .. and ... VSCode extensions
2. In the `.vscode/settings.json` file set pico-8 runner and cart location

### Development environment features

## Project Structure

```
├── docs/           # Designs, graphics, docs, guides
├── include/        # TODO:
├── src/            # Main game source files (.p8 files)
├── CONTRIBUTING.md # TODO:
├── LICENSE         # License
└── README.md       # Project overview
```

## Development Guidelines

### PICO-8 Specific Guidelines

#### File Organization
- Keep main game logic in `src/main.p8`
- Split large features into separate `.p8` files
- Use meaningful file names that describe their purpose
- Maximum one game concept per file when possible

#### Code Style
- Use **small, but descriptive names** to keep the code readable on the PICO-8 console
    - Use abridgments, but keep it readable and consistent: `plr` for player, `upd` for update
- Use **lowercase** for all code, comments, and file names
- Use **snake_case**, if you want to separate words: `plr_speed`, `upd_enemies(input)`
- Add comments for:
    - every variable: `-- player speed in pixels per frame`
    - functions, complex logic and algorithms: `-- update enemies position based on absolute coordinates in pixels`

#### Naming Conventions
- **Variables**: `plr_x`, `enemy_count`, `is_jumping`
- **Functions**: `init_game()`, `upd_plr()`, `draw_ui()`
- **Sprites**: Use descriptive names in sprite editor
- **Maps**: `level_1`, `menu_bg`, `tileset_main`
- **Sound Effects**: `sfx_jump`, `sfx_coin`, `sfx_enemy_hit`
- **Music**: `mus_title`, `mus_level`, `mus_gameover`

#### Performance Guidelines
- Be mindful of the 8192 token limit
- Optimize sprite usage (128 sprites max)
- Use efficient algorithms for collision detection
- Minimize unnecessary calculations in `_update()` and `_draw()`
- Use `_update60()` only when necessary

### Version Control

#### Commit Guidelines

- Use clear, descriptive commit messages
- Start with a verb in present tense: "Add player movement", "Fix collision bug"
- Keep commits focused on single changes
- Reference issues when applicable: "Fix #123: Player falls through platforms"
- Atomic commits

## Documentation

- Update documentation when adding new features
- Keep the README.md current with setup instructions
- Add code comments for complex algorithms
- Document any external dependencies or tools

## Community Guidelines

- Be respectful and constructive in all interactions
- Help newcomers learn PICO-8 development
- Share knowledge and best practices
- Follow the project's code of conduct
- Give credit where credit is due

## Questions?

If you have questions about contributing:
- Check existing issues and discussions
- Create a new issue with the "question" label
- Reach out to maintainers

Thank you for contributing to making this PICO-8 game better! 🎮