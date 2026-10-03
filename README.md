# Jungle Jump

Godot 4.7.2 platformer prototype. The starting scene is Levels/level01.tscn.
The current level is a small test platform; this is a work in progress.

## Open and play
1. Install Godot 4.7.2 (standard edition).
2. Import project.godot and press F6 in level01, or F5 to run the project.
3. Move with A/D or Left/Right. Jump with Space.

## Export for itch.io
Install matching Godot export templates. The Web preset uses the Compatibility renderer and disables threads.
Create build/web, then export the Web preset as build/web/index.html.
ZIP the CONTENTS of build/web, so index.html is at the ZIP root.
Upload that ZIP to an itch.io HTML project and select "This file will be played in the browser".

## Upload source to GitHub
Extract Jungle-Jump-GitHub-Source.zip first. Upload the extracted project files (including project.godot, export_presets.cfg, assets, Levels, items and player), rather than just uploading the ZIP, to make a browsable source repository. Include .gitignore and the other dotfiles when using Git.
Generated .godot caches and build output are excluded from version control.
You can also attach Jungle-Jump-Itch-Web.zip to a GitHub Release as a downloadable web build.

No license is assigned by this package. Confirm your permissions for the included assets before choosing a repository license.
