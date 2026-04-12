# Gravity Flip Lab

Gravity Flip Lab is a simple 2D educational action game built in Godot 4. The player moves sideways automatically, reverses direction when colliding with walls, and flips gravity with Space or tap input. The key rule is preserved throughout the game: gravity changes future acceleration only, and the player's current velocity is never reset.

## Overview

- Title -> Menu -> Level -> Result -> Menu or Next Level
- Four planet-based levels: Earth, Moon, Mars, Jupiter
- Different gravity strengths teach how acceleration changes motion
- Simple score model based on minimizing reduction events
- Flat, readable vector-style visuals for web and desktop

## Current Behavior

- The player auto-moves horizontally at a constant speed.
- Hitting a wall reverses horizontal direction automatically.
- Pressing `Space` or tapping flips gravity.
- Flipping gravity reverses vertical acceleration only.
- Existing velocity continues through the flip.
- Score starts at `150` and loses `10` points only on collision events: side-wall hit, top hit, or bottom hit.
- Level HUD starts clean (no top-left descriptions) and shows a centered score panel with live score text plus the hint `Hit wall / top / bottom: -10`.
- Spikes fail the run.
- Reaching the goal clears the level.
- Level HUD and result screen no longer show time/attempt text; score and reductions are the main outcome metrics.
- Result background uses dedicated images: `background_clear.png` for `Clear` and `background_tryagain.png` for `Try Again`, each scaled to cover the full screen.
- The pause menu supports Resume, Restart, Back To Menu, and Music ON/OFF.
- Music defaults to OFF on first launch, and that state is preserved when moving between screens.
- Action button minimum heights are now derived from viewport height ratios across title/menu/level/result screens for smartphone-friendly tapping.
- Title `How To Play` overlay now uses a concise description, a single input hint line (`Tap screen or press Space to flip gravity.`), and the `tap_space.png` image.

## Controls

- PC: `Space` to flip gravity
- PC: `Esc` to pause
- Mobile/Web: tap anywhere during gameplay to flip gravity

## Scenes

- `TitleScreen`: start flow, how-to-play overlay, quit, music toggle, and responsive title layout with logo-left/buttons-right on wide screens
- `MenuScreen`: level hub, scoreboard, level selection, back to title, viewport-scaled touch-friendly button sizing, and pill-style action buttons matching title screen (music icon button stays compact)
- `LevelScreen`: gameplay, HUD, pause menu, planet gravity rules, and pill-style action buttons (music control uses small ON/OFF icons shared with title/menu, placed next to `Paused`, and the paused panel lists Restart before Resume)
- `ResultScreen`: clear/fail summary with score breakdown, pill-style action buttons, and a compact music icon placed next to the top label
- Level display labels (for menu buttons and result top label) are defined in one place via `LevelCatalog.display_name()`

## Planets

- Earth: `1.0x`
- Moon: `0.16x`
- Mars: `0.38x`
- Jupiter: `2.5x`

## Build

- Main scene: `res://Main.tscn`
- GitHub Pages export is configured in `.github/workflows/github-pages.yml`
- Web export target name: `Web`

## Web Build

- Export the web build with Godot 4.5+:

```bash
mkdir -p build/web
godot4 --headless --path . --export-release Web build/web/index.html
```

- The export output is written to `build/web/`.
- To preview locally, serve the folder instead of opening `index.html` directly:

```bash
cd build/web
python3 -m http.server 8000
```

- Open `http://localhost:8000` in a browser.
- For GitHub Pages deployment, pushing to `main` triggers the workflow in `.github/workflows/github-pages.yml`.

## Validation

- Boot the project with Godot 4.5+.
- Validate the headless project load:

```bash
godot4 --headless --path . --quit
```

- Validate the web export too:

```bash
godot4 --headless --path . --export-release Web build/web/index.html
```

## Notes

- Music uses `assets/gamemusic.mp3` as a looping background track.
- On web, browsers may start audio in a suspended state. The game now resumes the browser audio context on the first real user input while music is ON.
- Level geometry is generated from tile strings to keep the prototype simple and easy to extend.
