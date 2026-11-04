# ARC3USX.EXE

A Roblox UI library (`ARC3USX.lua`) plus a single-script hub (`scripts/main.lua`).

The old modular runtime was removed: the previous combat/gun/bow/ammo mods, the separate
`scripts/esp.lua` overlay suite, the intro/mix/logo bootstrap, and the mock tests for those
features are gone. `scripts/main.lua` is now the only feature script, containing the
**Ultimate Optimized Hub** described below.

## The hub — `scripts/main.lua`

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/6af703ac-arceus-x/scripts/main.lua"))()
```

The hub downloads the UI library from `refs/heads/main/ARC3USX.lua` at startup. Change
`LIBRARY_URL` at the top of the script to load the library from another branch or fork.

### Features

- **UI ESP engine** — overlays built from `ScreenGui` frames/labels (no Drawing dependency):
  corner or full boxes, names, distance in metres, equipped weapon, health bar, R6/R15
  skeleton, and visible/occluded chams via `Highlight`.
  - **No stuck overlays** — every frame reconciles what was actually drawn: anything that
    died, left, went off screen/out of range, or was toggled off is hidden exactly once,
    and overlays for removed objects are destroyed. The `ScreenGui` is rebuilt if it is
    removed externally.
  - **No stutter** — one throttled `RenderStepped` pass drives all ESP categories, flags
    are read once per pass, line-of-sight raycasts are cached for 0.12 s, property writes
    are skipped when unchanged, box corners reuse scratch tables, and new ore
    `ViewportFrame` icons are capped to two per pass.
  - **Player ESP** — adjustable update rate (30–240 Hz), max distance, box style, and per-element
    colors for box, name, health, distance, weapon, skeleton and chams.
  - **NPC ESP** — models under `workspace.Npcs`, with the same box/name/distance/weapon/chams
    controls.
  - **Ore ESP** — 3D item icons in `ViewportFrame`s from the game's optional
    `ReplicatedStorage.Fust.ItemIcons` module, with an abbreviation fallback. Filters for
    Cactus, MetalNode, SulfurNode, Tree, Meteor and StoneNode, plus a distance toggle.
  - **Heli ESP** — `PatrolHeli` models with box, chams and distance.
  - **ESP Preview** — a live preview widget wired to the player ESP toggles/colors.
- **Silent Insta-Hit weakspot** — snaps the camera at the nearest resource weakspot for one
  tick, activates the equipped mining tool (and a synthetic click), then restores the camera.
  Radius: 50 studs; 0.12 s cooldown; no visible camera lock.
- **Aimbot (mouse-relative lock)** — picks the valid target closest to the mouse inside a
  pixel FOV, then nudges the mouse toward it with `mousemoverel`. Head or `HumanoidRootPart`
  bone, optional bullet-travel prediction from `AssemblyLinearVelocity` and a configurable
  bullet speed, smoothing divisor, max distance, NPC targets, `FustMates` team check, and
  an optional line-of-sight wall check. An optional `Drawing` FOV circle follows the mouse.
  - **Lock modes** — `Always` (the keybind toggles the aimbot) or `Hold` (the aimbot only
    runs while the key is held). The keybind defaults to `Q` and is rebindable in the UI.
- **Staff detection** — reads `AdminRole` attributes or the game's optional
  `Fust.StaffState` / `Fust.AdminPerms` modules; role labels, ranks, colors, a monitor with
  notifications, role-change hooks, and staff highlights.
- **System** — `Unload Script & Clear Memory` disconnects connections, unbinds render steps,
  removes drawings/overlays and unloads the UI.

### Tabs and defaults

| Tab | Groups |
| --- | --- |
| ESP / World | Player ESP, NPC ESP, Ore ESP (Icons), Heli ESP, ESP Preview |
| Combat | Aimbot, Aimbot Options |
| Misc | Staff Detection, Staff ESP, Mining (Silent Insta-Hit), System |
| Settings | themes, config/auto-load, appearance (`Window:AddSettingsTab()`) |

Master switches start **on**, but every category's ESP toggle starts **off** — enable the
individual **ESP Toggle** and any elements you want. The aimbot, staff monitor, staff ESP and
insta-hit all start off. Aimbot defaults: FOV 220 px, bone `Head`, unlimited distance,
smoothing 2, prediction on, bullet speed 900, FOV circle off, NPC/wall/team checks off,
lock mode `Always` with the `Q` keybind. The ESP pass runs at 60 Hz by default
(`ESP Update Rate (Hz)`).

### Requirements and caveats

- Needs an executor with `loadstring`, `HttpGet`, `CoreGui` parenting and `RenderStepped`.
  The aimbot needs `mousemoverel` to move the mouse; its FOV circle uses the executor's
  `Drawing` API, and both are optional — a no-op stand-in keeps the rest of the hub running
  if they are unavailable.
- Ore icons, staff labels and the `FustMates`/`Fust` data the aimbot reads depend on
  game-specific replicated modules/attributes. Missing modules fall back to abbreviations
  and built-in role labels. Only client-replicated objects can be detected, so streaming
  affects ESP. `workspace.Npcs` is used for optional NPC targets.
- The hub is client-side and is not verified against the live game or its anticheat. The
  decompiled game scripts in `ItemIcons.lua` and `Vex.txt` are reference material only.
- `tests/hub_mock.lua` checks the feature set, ESP/insta-hit/aimbot/staff lifecycles and
  unload with mocks. Run it from the repository root with a Lua 5.3 interpreter
  (`lua tests/hub_mock.lua`), or without Lua via
  `npm install --no-save fengari && node tests/run_hub_mock.js`.
  Mocked tests do not replace in-game testing.

## Files

| File | What it is |
| --- | --- |
| `ARC3USX.lua` | The UI library (loaded by the hub at runtime) |
| `scripts/main.lua` | The hub: ESP, insta-hit, mouse-relative aimbot, staff detection and UI |
| `tests/hub_mock.lua`, `tests/run_hub_mock.js` | Mocked lifecycle/feature test for the hub (Lua 5.3 or fengari) |
| `ItemIcons.lua` | Decompiled reference copy of the game's `Fust.ItemIcons` module |
| `Vex.txt` | Decompiled reference copy of game combat code |
| `ARC3USX-UI-Preview.html`, `preview/` | Standalone static preview of the UI library |
| `README.md` | This file |

## UI library

A dark, purple-accent library with tabs and two-column groups; Toggle (with keybind and color
swatches), Slider, Dropdown, Textbox, Button, Label, Keybind, Color picker; an in-memory or
file-based config system; notifications; a draggable, mobile-friendly window; 19 built-in
themes; and an animated intro (disabled by the hub with `Intro = false`).

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/ARC3USX.lua"))()
local Window = Library:CreateWindow({ Name = "ARC3USX.EXE", Theme = "Purple", Intro = false })
local Tab = Window:AddTab("Main")
local Group = Tab:AddGroup("General", "Left") -- "Left" or "Right"

Group:AddToggle({ Name = "Enabled", Flag = "enabled", Default = true, Callback = print })
Group:AddSlider({ Name = "Range", Min = 0, Max = 100, Default = 50, Suffix = "%" })

Window:AddSettingsTab()
```

In Roblox Studio, add `ARC3USX.lua` as a **ModuleScript** and `require` it from a **LocalScript**.

### Library API

| Member | Description |
| --- | --- |
| `Library.Logo` / `Library.LogoUrl` | Roblox asset id or direct PNG link for the title bar/intro |
| `Library.Accent` | Accent `Color3` (change at runtime with `Library:SetAccent(color)`) |
| `Library.MenuKey` | Key that shows/hides the window (default `Insert`) |
| `Library.Parent` | Optional custom parent for the ScreenGui |
| `Library.ExtraChecks` | Extra intro checks |
| `Library.Flags` / `Library.Options` | `flag -> value` / `flag -> control object` (`:Set(value)`) |
| `Library:CreateWindow(opts)` | `Name`, `Logo`, `Accent`, `MenuKey`, `Size` (Vector2), `Intro`, `Theme` |
| `Library:SetTheme(nameOrTable, name)` / `SetThemeColor(key, color)` / `RegisterTheme(name, table)` | Theme control |
| `Library:ExportTheme()` / `ImportTheme(json)` | Theme JSON |
| `Library:SetFont(name)` / `SetUIScale(n)` / `SetOpacity(n)` | Appearance |
| `Library:SaveCustomTheme(name)` / `DeleteCustomTheme(name)` | Named custom themes |
| `Library:SetAutoLoad(name or nil)` / `GetAutoLoad()` | Config that loads on startup |
| `Library.RememberSettings` | `false` = don't persist appearance settings |
| `Library:Notify(text, seconds)` | Toast notification |
| `Library:Serialize()` / `Deserialize(json)` | Export / import all option values |
| `Library:SaveConfig(name)` / `LoadConfig` / `DeleteConfig` / `ListConfigs` | Config helpers |
| `Library:Unload()` | Destroys the UI and disconnects everything |

**Window**: `AddTab(name)`, `AddSettingsTab()`, `Toggle()`, `Replay()`, `AutoLoad()`

**Tab**: `AddGroup(title, "Left" | "Right")`

**Group**

| Method | Options |
| --- | --- |
| `AddToggle` | `Name, Flag, Default, Callback, Bind, BindDefault, Colors = {Color3...}, ColorCallback(index, color)` |
| `AddSlider` | `Name, Flag, Min, Max, Default, Rounding, Suffix, Callback` |
| `AddDropdown` | `Name, Flag, Options, Default, Callback` (`obj:SetOptions(list)`) |
| `AddTextbox` | `Name, Flag, Default, Placeholder, Callback` |
| `AddButton` | `Name, Callback` |
| `AddLabel(text)` | returns object with `:SetText(text)` |
| `AddKeybind` | `Name, Flag, Default, Callback, Changed(key)` |
| `AddColor` | `Name, Flag, Default, Callback(color)` |
| `AddCustom(height)` | returns an empty Frame you can fill yourself |
| `AddESPPreview` | `Height, Animate, PlayerName, ToolName, Demo, Elements = {...}` |

### Themes and configs

Open **Settings → Theme** to switch themes live, tweak individual colors (Accent, Background,
Panel, Control, Input, Border, Text, Muted), and export/import theme JSON. Built-in themes:
`Purple`, `Midnight`, `Crimson`, `Emerald`, `Ocean`, `Sunset`, `Rose`, `Monochrome`, `Gold`,
`Dracula`, `Nord`, `Cyberpunk`, `Arctic Light`, plus more.

```lua
Library:SetTheme("Midnight")
Library:RegisterTheme("My Theme", { Bg = Color3.fromRGB(12, 12, 12), Accent = Color3.fromRGB(255, 80, 80) })
Library:SetFont("Gotham")      -- SourceSans, Gotham, GothamMedium, Ubuntu, Arial, Roboto, RobotoMono, Code
Library:SaveCustomTheme("Night Mode")
```

Theme keys: `Bg`, `P1` (panel), `P2` (controls), `Input`, `Line`, `Box` / `BoxLine`, `Text`,
`Mute`, `Accent`. Missing keys fall back to the Purple theme. Configs also store the theme.
Auto-load a config from **Settings → Configs**; it is remembered in `ARC3USX/autoload.txt`
when file functions are available.

### ESP preview

`AddESPPreview` adds an animated mock player that reacts live to your ESP toggles and colors.
Point each element at the `Flag` of the control that drives it:

```lua
Group:AddESPPreview({
    Height = 280,
    Elements = {
        Box = "plr_box", BoxStyle = "plr_style", Name = "plr_name",
        Health = "plr_health", Distance = "plr_dist", Tool = "plr_weapon",
        Skeleton = "plr_skel", Chams = "plr_chams",
    },
})
```

Colors come from the toggle's swatches (`Colors = {...}`). It is a preview only: it draws
nothing in the game itself. The hub uses this in the **ESP Preview** group.

### Notes

- The library is client-side UI only; the hub wires up the game-specific callbacks.
- Config files are only written when the environment provides file functions; otherwise
  configs stay in memory for the session. `Library:Serialize()` always works.
- Set `Intro = false` in `CreateWindow` to skip the animated intro (the hub does this).
- Please add a license file before publishing, and make sure you have the rights to any logo
  you upload.
