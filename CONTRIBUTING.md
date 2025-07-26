# Contributing to PICO-8 Game

This document provides guidelines for developers who want to work on this project.

## Getting Started

### PICO-8 Tutorials and Resources

#### PICO-8 Game Development

- [Best basic video tutorial for beginners by Nerdy Teachers](https://nerdyteachers.com/PICO-8/Course/)
- Detailed tutorials about specific topics
    - [by Nerdy Teachers](https://nerdyteachers.com/PICO-8/Tutorials/)
    - [by SpaceCat](https://www.youtube.com/playlist?list=PLavIQQGm3RCmPt93jcg4LEQTvoZRFf9l0)
- [Official documentation](https://www.lexaloffle.com/dl/docs/pico-8_manual.html)
- [Advanced full free courses](https://www.youtube.com/@LazyDevs/playlists)
- [Best payed full course](https://www.spacecatdev.com/pico-8-noob-to-pro)

#### Game design

- [Game Design and Theory course by the creator of The Sims](https://www.masterclass.com/classes/will-wright-teaches-game-design-and-theory)
- [So You Wanna Make Games?? by Riot Games (creators of LoL)](https://youtube.com/playlist?list=PL42m9XiTqPHJdJuVXO6Vf5ta5D07peiVx&si=171pL1Boisbcf1SO)
- [Game Design 101 by Game Maker's Toolkit](https://youtube.com/playlist?list=PLc38fcMFcV_vToz9Nvc_YQTNH8hkIQ2uC&si=ih-Mx9b9tYN6kyml)
- [Game Maker's Toolkit free courses](https://www.youtube.com/@GMTK/playlists)
- [Udemy payed video courses](https://www.udemy.com/courses/design/game-design/)

#### Pixel art

- [Very basics in 10 mins](https://youtu.be/v-ibXM3xBjg?si=2HXMc35Ripf5cBTM)
- [Pixel Art Classes by AdamCYounis](https://www.youtube.com/playlist?list=PLLdxW--S_0h4dlWUpl-TzBp-ulqK3NiM_)
- [Pixel Art 101 by Peter Milko](https://youtube.com/playlist?list=PLmac3HPrav-9UWt-ahViIZxpyQxJ2wPSH&si=VeD5pankdu5uyZeV)
- [Udemy payed video courses](https://www.udemy.com/topic/pixel-art/)
- [SpaceCat's pixel art course](https://www.spacecatdev.com/pixel-art-for-game-devs)

### Development environment features

- **Visual Studio Code**: A powerful code editor with many features for developers.
- **PICO-8 Language Server**: Provides syntax highlighting, code completion, and linting for PICO-8 code (for `.p8` files).
- **PICO-8 Runner**: Allows you to run PICO-8 carts directly from VSCode on the payed version of PICO-8 console.
    - To run the cart, use the command palette (`Ctrl+Shift+P` or `Ctrl+F1`) and select `PICO-8: Run Cart`.
    - If you don't have the payed version, you can still edit the code and run it on the PICO-8 [education edition web player](https://www.pico-8-edu.com/).
        - Simply drag and drop the edited `.p8` file into the [web player](https://www.pico-8-edu.com/) and run `RUN` command.
- **Git Integration**: Use the Source Control panel in VSCode to manage your commits, branches, and pull requests.

### Prerequisites

- [PICO-8](https://www.lexaloffle.com/pico-8.php)
    - To use the PICO-8 Runner, licensed payed version required
    - [Education edition](https://www.pico-8-edu.com/) also works, fully functional and free, but not as convenient
- Git for version control
- Visual Studio Code for advanced code editing and git user interface

### Windows Setup

1. Install [PICO-8](https://www.lexaloffle.com/pico-8.php), if you bought it
2. Install [Git](https://git-scm.com/downloads) with default settings
3. Install [Visual Studio Code](https://code.visualstudio.com/)
4. Restart your computer
5. Install the following VSCode extensions:
   - [PICO-8 Language Server](https://marketplace.visualstudio.com/items?itemName=pollywoggames.pico8-ls)
   - [PICO-8 Runner](https://marketplace.visualstudio.com/items?itemName=crowoncrowbar.pico8-runner)
6. Clone the repository
6. In the `.vscode/settings.json` file set PICO-8 runner (path to `pico8.exe`) and cart location (path to your PICO-8 cart in the `src/` folder)

### LUA Setup

If you want to `#include` `.lua` files, you should set up the VSCode LUA support for PICO-8! [More info here](https://www.lexaloffle.com/bbs/?tid=53227)

### Commiting summary

1. Make sure your code is working
2. Save you game (.p8) into the `src/` folder
3. On the left side of VSCode, click on the Source Control icon (`Ctrl+Shift+G`)
4. Write a descriptive commit message
5. Click the `Commit` button and then `Push` to upload your changes

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