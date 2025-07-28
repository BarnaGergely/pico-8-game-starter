# Retro Pico-8 Platformer Starter Template

This project is a **simple yet extensible platformer game starter** built for the PICO-8 fantasy console. It includes the core structure and basic mechanics required to quickly build and iterate on a classic retro-style platformer.

This README provides **context for GitHub Copilot** and other AI-assisted tools to help generate relevant and consistent code suggestions while working in this repo.

## Gameplay Overview

This is a side-scrolling pixel-art platformer prototype where the player can move left and right, jump, crouch. The game uses a tile-based map and animated sprites. All characters and tiles are 8×8 pixels. The screen is 128×128 pixels, allowing for a small but detailed game world.

## Core Mechanics

- **Left/Right Movement** with smooth acceleration and friction
- **Jumping** with gravity and basic physics
- **Wall Collisions** (horizontal and vertical)
- **Map-based Levels** using PICO-8's built-in map editor
- **Simple Animation System** for walking, idling, crouching

## Controls

- **D-Pad (Arrow Keys)**  
  - `←`: Move left  
  - `→`: Move right  
  - `↑`: Look up (show a special upward looking sprite)  
  - `↓`: Crouch / squat (show a special crouching and shrink the hitbox sprite)

- **O Button (Z / N / C key)**  
  - Jump
- **X Button (X / M / V key)**  
  - not used yet

## Project Structure

- `src/`: Contains the main game code.
- `docs/`: Contains documentations, references, tutorials and examples.

## Notes for Copilot

- Use PICO-8 Lua syntax.
- Use docs and examples as references from the `docs` folder.
  - Use the official PICO-8 documentation as a reference in the `docs\pico-8_manual.txt` file.
  - There are many simmilar platformer games source code avaliable in the `docs\examples` folder. Use them as a reference.
  - Use the tutorials in the `docs` folder for collision detection!
- Write easy-to-read, maintainable code for beginners.
- Use descriptive variable and function names.
- Keep functions small and modular.
