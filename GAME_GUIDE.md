# Jungle Jump

A complete two-level pixel-art platformer built with Godot 4.7.2.

## Play
Open project.godot in Godot and press F5. Start Adventure begins at level01.
The browser release is Jungle-Jump-Complete-Itch.zip. Upload it directly to an itch.io HTML project and select "This file will be played in the browser". Set an initial embed size of 960 x 540 and enable fullscreen.

### Controls
- A/D or Left/Right: move.
- Space: jump; press again in the air for a double jump. Release early for a shorter jump.
- W/S or Up/Down: climb ladders.
- Escape or the pause button: pause/resume.
- R: retry the current level.
- M: toggle sound.

### Adventure
Explore Sunlit Shores and Twilight Canopy. Cherries earn 10 points, gems earn 25, and stomping an opossum earns 50. Reach each cabin exit for a 100-point completion bonus. Finishing the second trail opens the victory screen.

You have three hearts. Enemy hits briefly grant invulnerability. Falling costs one heart and returns you to the starting point or the checkpoint sign. Losing all hearts opens the retry menu. Retrying restores three hearts and resets the score to the start of that level.

Trees, bushes, rocks, crates, signs, cabins, and ladder artwork have no obstacle collisions. Terrain and rideable platforms provide support. Collectibles use non-blocking triggers; enemy encounters detect overlap without physically blocking the player. Ladder interaction is a position check, with no ladder collision shapes.

## Project layout
- ui/title.tscn: title, retry, and victory menus.
- main.tscn: loads the current level.
- game_state.gd: persistent score, transitions, and audio.
- Levels/level01.tscn and level02.tscn: editable terrain and item placements.
- Levels/level_base.gd: shared scenery, enemies, ladders, platforms, checkpoint, exit, and HUD setup.
- player/: movement, animations, health, and landing particles.
- enemies/: patrolling opossums with stomp feedback.
- objects/: moving and stationary one-way platforms.
- tests/: deterministic movement, interaction, and route tests.

The shared level script assembles scenery and interactive objects at runtime. Terrain and collectible markers remain editable TileMaps in each level scene.

## Export
Install the matching Godot export templates. Create build/web, then run:

    godot --headless --path . --export-release Web build/web/index.html

ZIP the contents of build/web so index.html is at the archive root. The Web preset uses Compatibility rendering without threads. Serve browser exports over HTTP; opening index.html directly from disk will not work.

## Tests
    godot --headless --path . --script res://tests/test_game.gd --fixed-fps 60
    godot --headless --path . --script res://tests/test_routes.gd --fixed-fps 60

The interaction suite covers jumping, climbing, item pickup, enemy stomp, health, invulnerability, checkpoint respawn, pause, transitions, victory, and retry. The route suite isolates geometry from combat and traverses both trails using movement and jump inputs.

## Credits
See CREDITS.md and the original assets/audio/credit.txt.
