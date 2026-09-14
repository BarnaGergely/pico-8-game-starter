# Start Here

This is a small PICO-8 game project. You can use the paid PICO-8 native app or the free [PICO-8 Education web player](https://www.pico-8-edu.com/) to run it.

## 1. Open the project

Open this folder in [Visual Studio Code](https://code.visualstudio.com/). When VS Code asks about recommended extensions, install them.

### Useful features of the recommended extensions

- PICO-8 code highlighting and helpful errors: [PICO-8 Language Server](https://marketplace.visualstudio.com/items?itemName=pollywoggames.pico8-ls)
- Run PICO-8 game from VS Code: [PICO-8 Runner](https://marketplace.visualstudio.com/items?itemName=CrowonCrowbar.pico8-runner)
- Token usage tracker - [PICO-8 Toolkit](https://marketplace.visualstudio.com/items?itemName=Mesgegra.pico-8-toolkit)
- Rulers and warnings to indicate the size of the PICO-8 screen: [Line Length Checker](https://marketplace.visualstudio.com/items?itemName=SUPERTSY5.line-length-checker-vscode)
  - *Comment out the `"line-length-checker.lineLength"` setting in `.vscode/settings.json` to disable the `Overlength line` warning.*

## 2. Run the game

### Run the game with paid PICO-8

1. Install [PICO-8](https://www.lexaloffle.com/pico-8.php).
2. In VS Code, press `Ctrl+Shift+P`.
3. Choose `Run PICO-8 Cartridge` (`Ctrl + Shift + 8`).

> If that command cannot find PICO-8, open `.vscode/settings.json` and change
`pico8runner.pico8Path` to the location of the installed `pico8.exe` on your system.
>
> For example:
>
> ```text
> Failed to run PICO-8: spawn C:\Program Files (x86)\PICO-8\pico8.exe ENOENT
> ```

If the game is already open in PICO-8, you can also reload and run the cartridge for PICO-8 with: `Ctrl + R`. So you can edit code in VS Code, save your changes, then switch to PICO-8 and press `Ctrl + R` to test your changes.

### Run the game with Education Edition

1. Open the [PICO-8 Education web player](https://www.pico-8-edu.com/).
2. Open the `src/` folder in file explorer.
3. Drag `src/awesome_game.p8` into the page (while the online PICO-8 is in terminal mode).
4. Type `run` and press Enter to run your game.

## 3. Make a change

Use VS Code to edit Lua code. Use PICO-8 to edit sprites, maps, music, and sound effects. After making a change, save it, run the game, and test it.

### On the paid native app repeat this workflow:

1. Decide what to change.
2. Edit code in VS Code, or edit visual and audio assets in PICO-8.
3. Save your work.
4. Run the game (`Ctrl + Shift + 8` in VS Code or `Ctrl + R` in PICO-8) and test the change.
5. Fix problems or refine the result, then test again.

### Extra steps for the free web player

#### If you want to change the code, edit it in VS Code:
1. Edit the code in VS Code.
2. Open the `src/` folder in file explorer.
3. Drag `src/awesome_game.p8` into the page.
4. Type `run` and press Enter to run your game.

#### If you want to change sprites, maps, music, or sound effects, edit them in PICO-8:
1. Open the `src/` folder in file explorer.
2. Drag `src/awesome_game.p8` into the page.
3. Make the change.
4. Save your work by typing `save` in the console and pressing Enter. This will download a `.p8` file to your computer. 
5. Override the existing `src/awesome_game.p8` file with the downloaded file.

Keep changes small so they are easy to test and undo.

## Where things go

- `src/`: PICO-8 cartridges (`.p8`). Example code included: `src/awesome_game.p8`.
- `include/`: optional external Lua files.
- `docs/`: game design notes, docs and assets.
- `README.md`: your game's instructions and credits.

## When you finished commit changes to Git repository

1. Make sure the game runs from a fresh launch.
2. Update the controls and description in `README.md`.
3. In VS Code, open Source Control with `Ctrl+Shift+G`.
4. Write what you changed, then commit and push.

## Need help?

- [PICO-8 manual](https://www.lexaloffe.com/dl/docs/pico-8_manual.html)
- [PICO-8 Education tutorials](https://nerdyteachers.com/PICO-8/Course/)
