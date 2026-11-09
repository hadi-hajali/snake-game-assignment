# Snake - Lua Game Programming Assignment

A complete Snake game project built with Lua and LÖVE. The code follows the required module layout and includes the bonus observer-style event system.

## Run the game

1. Install LÖVE 11.4 from [love2d.org](https://love2d.org/).
2. Extract this folder if you received it as a ZIP.
3. Open a terminal in the `snake_game` folder and run:

   ```text
   love .
   ```

   On Windows, you can also drag the `snake_game` folder onto `love.exe`.

## Controls

- **Space** or **Enter**: start, or restart after a collision
- **Arrow keys** or **WASD**: steer
- **M**: return to the menu
- **Escape**: quit

## What is included

- Menu and playing states managed by `gamestate.lua`
- Entity component pattern with position, movement, and renderer components
- Grid based snake movement, random food, scoring, wall and self collision
- High score persistence
- Command based input bindings
- `Vector2` addition, equality, and string conversion metamethods
- Bonus event subscriptions and event emission for food and game over

## Lua 5.4 to-be-closed variable

The assignment asks for Lua 5.4's `<close>` variable feature, while LÖVE 11 commonly runs LuaJIT with Lua 5.1 syntax. In `highscore.lua`, the Lua 5.4 save and load functions are kept as source strings and compiled only when the interpreter identifies itself as Lua 5.4. That branch uses `local file <close>` so the handle closes automatically on return, including an error return. The LÖVE 11 compatibility path uses protected calls and closes the handle explicitly. This lets the project demonstrate the requested feature and remain loadable by the LÖVE 11 runtime described in the beginner guide.

## Project structure

```text
snake_game/
├── main.lua
├── conf.lua
├── gamestate.lua
├── entity.lua
├── vector2.lua
├── highscore.lua
├── input.lua
├── events.lua
├── snake_game.lua
└── states/
    ├── menu_state.lua
    └── game_state.lua
```

High scores are saved under LÖVE's writable save directory in `data/highscore.txt`.
