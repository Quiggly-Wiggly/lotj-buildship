# LotJ Buildship

Shipbuilding queues and optional cost estimates for Legends of the Jedi.
Maintained by Quiggly-Wiggly; adapted from the community Autobuildship script.

## Install and start

Download **LotJ Buildship.mpackage** from [Releases](https://github.com/Quiggly-Wiggly/lotj-buildship/releases/latest).
Remove older Buildship/Autobuildship automation before installing through Mudlet's
Package Manager. Use only one shipbuilding controller. Requires Mudlet 4.20+.

```text
autobuild help
autobuild add <your frame keyword>
autobuild start
```

The first frame is selected; later additions join the queue. Help is compact and
colored. Setup links fill the input line for review; Enter runs the command.

| Command | Action |
| --- | --- |
| `autobuild queue` | Current frame and waiting queue |
| `autobuild pause` / `autobuild resume` | Pause / resume or retry the current step |
| `autobuild clearqueue` | Remove waiting frames |
| `autobuild clear` | Stop and clear all frames |
| `autobuild gag` | Toggle work output |
| `autobuild gag prompt` | Also toggle prompt display |
| `autobuild blanklines` | Toggle blank-line filtering |
| `autobuild config` | Review estimator settings |

## Estimator setup

No material impacts, prices, recipes, or installation timings are bundled.
Enter values you learn in game before using estimates; building itself does not
require estimates. Existing in-memory settings are retained when code reloads.
Estimator settings and queues are session state; configure them after reopening
Mudlet. This package does not export your settings.

```text
autobuild config impact <material> <amount>
autobuild config price <material> <credits>
autobuild config seconds <seconds>
autobuild config engineers <count>
autobuild config verbose on
```

Materials: `hull`, `circuits`, `weapons`, `engines`. Use `verbose off` for compact
estimates. Requirements come from your own blueprint output. Estimated quantities
round up to whole items, and estimated time divides work across configured crew.

Completion and stock messages advance the queue. Unknown state and missing stock
can pause work. BOT recovery only runs for active work. Stopping cannot recall
commands already sent to the game.

## Development

```sh
python3 scripts/build.py
python3 -m unittest discover -s tests -v
```

Python's standard library builds a reproducible package; tests need LuaJIT/Lua 5.1
(or `LUA=/path/to/runtime`). `src/package.xml` defines aliases and triggers;
`src/scripts/` contains readable Lua source. Test values are fictional. No profile,
ship list, recipe library, or game export belongs in this repository. Older
alternative packages and personal working notes are kept outside this release.
Console output and behavior are tested with simulated Mudlet APIs; native visual
and live shipyard checks are not part of the automated suite.
