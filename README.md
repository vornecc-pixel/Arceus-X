# ARC3USX.EXE UI Library

A dark, purple-accent Roblox UI library with an animated intro.

- Draggable window, touch-friendly controls, responsive single/two-column layouts, rotation support, and floating reopen button
- Controls: Toggle (+ keybind + color swatches), Slider, Dropdown, Textbox, Button, Label, Keybind, Color picker
- **19 built-in themes**, plus NH palettes, live theme switching, per-color editing, theme export/import (all in the Settings tab)
- **ESP preview**: an animated mock player that reacts live to your ESP toggles and colors
- **Auto-load**: pick a config and it loads itself the next time the script runs
- **Customizable appearance**: edit every theme color, save your own named themes, change font, UI scale and window opacity (all remembered between sessions)
- Config system (in memory; saved to files too if your environment provides file functions)
- Notifications, menu keybind, floating logo button when the menu is hidden
- **Intro sequence**
  1. Hacker-style terminal typing in the background while real compatibility checks run
  2. `ACCESS GRANTED` pops up with your logo above it
  3. The logo's eye glows, it slices the box in two
  4. A pin locks onto the window's logo slot, the logo circles in and smashes into it, and the window appears

## Files

| File | What it is |
| --- | --- |
| `ARC3USX.lua` | The library |
| `example.lua` | Demo using every control |
| `ARC3USX_NH.lua` | NH-style theme mixes and HUD layer |
| `logo.lua` | Embedded PNG logo loader |
| `example_mixes.lua` | Example of the mix API |
| `scripts/ui_bootstrap.lua` | Shared logo, intro, and mix UI startup |
| `scripts/main.lua` | Main script with combat and weakspot controls; loads ESP separately |
| `scripts/esp.lua` | Player, NPC, resource, loot, deployable, helicopter, and staff ESP; usable standalone or in the main script |
| `logo.png` | The logo image (upload this to your repo for `LogoUrl`) |
| `README.md` | This file |

## Setup

1. **Logo** — pick one:
   - **PNG from GitHub (no upload):** put `logo.png` in your repo and set `Library.LogoUrl = "https://raw.githubusercontent.com/USER/REPO/main/logo.png"`. The library downloads it once to `ARC3USX/logo.png` and loads it with `getcustomasset`. This needs an environment with file functions (`writefile`, `isfile`, ...) and `getcustomasset`; Roblox Studio does not have them.
   - **Roblox asset id (works everywhere):** upload the PNG to Roblox (Creator Hub → Development Items → Decals/Images) and set `Library.Logo = "rbxassetid://YOUR_ID"`. If `LogoUrl` can't be used, the library falls back to this.
   - To refresh a cached PNG, delete `ARC3USX/logo.png` from your workspace folder.
2. Put the repo on GitHub, then load it with the raw URL:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/ARC3USX.lua"))()
```

   Or in Roblox Studio, add `ARC3USX.lua` as a **ModuleScript** and `require` it from a **LocalScript**.

3. Create a window:

```lua
Library.LogoUrl = "https://raw.githubusercontent.com/USER/REPO/main/logo.png"
Library.Logo = "rbxassetid://YOUR_ID" -- fallback

local Window = Library:CreateWindow({ Name = "ARC3USX.EXE", Intro = true })
local Tab = Window:AddTab("Main")
local Group = Tab:AddGroup("General", "Left") -- "Left" or "Right"

Group:AddToggle({ Name = "Enabled", Flag = "enabled", Bind = true, Callback = print })
Group:AddSlider({ Name = "Range", Min = 0, Max = 100, Default = 50, Suffix = "%" })

Window:AddSettingsTab()
```

## API

**Library**

| Member | Description |
| --- | --- |
| `Library.Logo` | `rbxassetid://...` image used in the title bar and intro |
| `Library.LogoUrl` | Direct PNG link (e.g. GitHub raw); downloaded and cached when the environment supports it |
| `Library.Accent` | Accent `Color3` (change at runtime with `Library:SetAccent(color)`) |
| `Library.MenuKey` | `Enum.KeyCode` that shows/hides the window (default `Insert`) |
| `Library:DetectDevice()` | Detects input capabilities, platform (when exposed), and orientation |
| `Library.Device` | Latest detected device profile; refreshed when the viewport changes |
| `Library.Parent` | Optional custom parent for the ScreenGui (set before `CreateWindow`) |
| `Library.ExtraChecks` | Extra intro checks: `{ {"Name", function() return "ok"/"warn"/"fail", "detail" end} }` |
| `Library.Flags` | `flag -> value` table |
| `Library.Options` | `flag -> control object` (use `:Set(value)`) |
| `Library:CreateWindow(opts)` | `Name`, `Logo`, `Accent`, `MenuKey`, `Size` (Vector2), `Intro` (bool) |
| `Library:SetTheme(nameOrTable, name)` | Apply a theme live |
| `Library:SetThemeColor(key, color)` | Change one theme color |
| `Library:RegisterTheme(name, table)` | Add a custom theme |
| `Library:ExportTheme()` / `ImportTheme(json)` | Theme JSON |
| `Library:SetFont(name)` / `SetUIScale(n)` / `SetOpacity(n)` | Appearance settings |
| `Library:SaveCustomTheme(name)` / `DeleteCustomTheme(name)` | Your own named themes |
| `Library:SetAutoLoad(name or nil)` / `GetAutoLoad()` | Config that loads on startup |
| `Library.RememberSettings` | `false` = don't persist appearance settings |
| `Library:Notify(text, seconds)` | Toast notification |
| `Library:Serialize()` / `Library:Deserialize(json)` | Export / import all option values |
| `Library:SaveConfig(name)` / `LoadConfig` / `DeleteConfig` / `ListConfigs` | Config helpers |
| `Library:Unload()` | Destroys the UI and disconnects everything |

**Window**: `AddTab(name)`, `AddSettingsTab()`, `Toggle()`, `Replay()` (replays the intro), `AutoLoad()`

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
| `AddESPPreview` | `Height, Animate, PlayerName, ToolName, Demo, Elements = {...}` (see above) |

## Themes

Open **Settings → Theme** to switch themes live, tweak individual colors (Accent, Background, Panel, Control, Input, Border, Text, Muted), and **export / import** a theme as JSON. Your current theme is also saved inside configs.

Built-in themes: `Purple` (default), `Midnight`, `Crimson`, `Emerald`, `Ocean`, `Sunset`, `Rose`, `Monochrome`, `Gold`, `Dracula`, `Nord`, `Cyberpunk`, `Arctic Light`.

```lua
Library:SetTheme("Midnight")                       -- by name (before or after CreateWindow)
Library:CreateWindow({ Theme = "Nord" })           -- or at creation
Library:SetThemeColor("Accent", Color3.fromRGB(255, 80, 80))

-- your own theme: appears in the Settings dropdown automatically
Library:RegisterTheme("My Theme", {
    Bg = Color3.fromRGB(12, 12, 12), P1 = Color3.fromRGB(20, 20, 20), P2 = Color3.fromRGB(28, 28, 28),
    Input = Color3.fromRGB(32, 32, 32), Line = Color3.fromRGB(50, 50, 50), Box = Color3.fromRGB(44, 44, 44),
    BoxLine = Color3.fromRGB(64, 64, 64), Text = Color3.fromRGB(220, 220, 220), Mute = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(255, 80, 80),
})
Library:SetTheme("My Theme")
```

Theme keys: `Bg`, `P1` (panel), `P2` (controls), `Input`, `Line` (borders), `Box` / `BoxLine` (checkbox), `Text`, `Mute`, `Accent`. Missing keys fall back to the Purple theme.

### Customizing the look (Settings → Theme)

- **Theme dropdown + 8 color pickers** (Accent, Background, Panel, Control, Input, Border, Text, Muted). Editing a color switches to "Custom".
- **Save Current as Theme / Delete Custom Theme**: name your colors and they appear in the theme dropdown. Built-in themes can't be overwritten or deleted.
- **Font**, **UI Scale** (60–140%) and **Window Opacity** (30–100%).
- **Remembered between sessions**: the theme, your saved themes, font, scale and opacity are written to `ARC3USX/settings.json` when the environment has file functions. Set `Library.RememberSettings = false` to turn that off.

```lua
Library:SetFont("Gotham")      -- SourceSans, Gotham, GothamMedium, Ubuntu, Arial, Roboto, RobotoMono, Code
Library:SetUIScale(1.1)
Library:SetOpacity(0.9)
Library:SaveCustomTheme("Night Mode")   -- saves the current colors under that name
Library:DeleteCustomTheme("Night Mode")
```

## Auto-load a config

In **Settings → Configs**, select a config in the list and turn on **Auto Load Selected**. The label shows which config is set. Next time the script runs, that config loads automatically once the intro finishes and a notification confirms it. Changing the selection while the toggle is on updates the auto-load config; deleting it clears auto-load.

- Needs file functions to remember between sessions (the choice is stored in `ARC3USX/autoload.txt`). Without them it only works for the current session.
- `AddSettingsTab()` schedules the auto-load for you. If you add more controls after it with a delay, call `Window:AutoLoad()` yourself at the end of your script.
- `Library:SetAutoLoad("name")`, `Library:SetAutoLoad(nil)` and `Library:GetAutoLoad()` work from code.
- A config also stores your theme, so loading one can change the theme too.

## ESP preview

`Group:AddESPPreview({...})` adds an animated mock player (it sways, its health bar changes) that updates live from your own toggles. Point each element at the `Flag` of the control that drives it:

```lua
Group:AddESPPreview({
    Height = 280,
    Elements = {
        Box = "esp_box",          -- toggle; Colors[1] = outline, Colors[2] = fill
        BoxStyle = "esp_style",   -- dropdown: "Full" / "Corners"
        BoxFill = "esp_fill",     -- toggle
        Name = "esp_name", Health = "esp_health", Distance = "esp_dist", Tool = "esp_tool",
        Tracer = "esp_tracer", Skeleton = "esp_skeleton",
        Chams = "esp_chams",      -- toggle; Colors[1] = fill, Colors[2] = outline
    },
})
```

Colors come from the toggle's swatches (`Colors = {...}`), so users can recolor each element and see it instantly. Options: `Animate` (default true), `PlayerName`, `ToolName`, `Demo` (show every element). It is a preview only: it shows how your settings will look and draws nothing in the game itself. See `example.lua` for a full Visuals tab.

## Compatibility checks

The intro runs real checks and prints the results: platform, screen size, client version, game loaded, local player, PlayerGui, frame rate, network ping, and input type. If a check **fails**, a "Continue anyway" button appears before the intro continues.

## Notes

- The library is client-side UI only. It has no game-specific features, so wire up your own callbacks.
- Config files are only written when your environment provides file functions; otherwise configs stay in memory for the session. `Library:Serialize()` always works.
- Set `Intro = false` in `CreateWindow` to skip the animation.
- Please add a license file (for example MIT) before publishing, and make sure you have the rights to the logo image you upload.

## Full script with separate ESP

The main script loads `scripts/esp.lua` into the same window, using the shared `scripts/ui_bootstrap.lua` to load the library, embedded logo, and NH mix. The animated intro reports the detected device, input capabilities, orientation, and chosen layout before the NH Classic mix and HUD are applied. Choose from 11 mixes, including Sakura, Aurora, Obsidian, Copper, Solarized, and Violet Ice, in the Mixes tab. The loader and all of its dependencies point to the session branch:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/scripts/main.lua"))()
```

On phones and tablets, the loader requests landscape orientation before the intro and restores the previous orientation on unload if nothing else has changed it. Roblox, the game, or the device may override that request; the interface still adapts to portrait if rotation is unavailable. A circular floating logo stays visible: tap it to minimize or reopen the menu, or drag it to move it. Sliders have larger touch tracks, a thumb, and −/+ buttons for precise adjustments. The title-bar × also hides the menu. Desktop and touch-enabled hybrids do not have their orientation changed. Device detection does not guarantee that executor-only features are supported on a particular device; the mobile behavior has not been verified in a live Roblox session.

The embedded logo needs file APIs (`isfolder`, `makefolder`, `isfile`, `writefile`) and `getcustomasset` or `getsynasset`. Without them, the menu and intro still open but the logo falls back to the library's configured Roblox asset (by default a blank placeholder). If the mix cannot load, startup falls back to the stock UI. The settings tab's **Unload Menu** and the system unload button both clean up the ESP and combat loops.

The combat features depend on executor APIs and the target game's internal tables; they are not verified against the live game. Unloading restores the tracked scanner settings where possible, but cannot guarantee restoration of transient state changes or game-side effects. **Auto Weakspot** is a single toggle (no distance slider): it hooks the game's `Swing` remote and redirects each mining swing to the node's live `WeakSpot` attribute, so hits land on the weakspot the instant it appears, and it auto-aims/swings a held mining tool at the nearest node. The remote redirect needs executor `hookmetamethod` (or `getrawmetatable`) support; without it the feature falls back to camera aim only and says so. The ESP requires a compatible Drawing API. If ESP loading fails, the combat UI still opens and reports the error.

## Standalone ESP

`scripts/esp.lua` is an ESP-only replacement for the ESP portion of the supplied script; it does **not** include the gun, bow, ammo, or weakspot features. Run it in a Roblox environment with `loadstring`, HTTP access, and Drawing API support for `Square`, `Line`, and `Text`. When run standalone it uses the same logo, intro, and mix bootstrap as the full script. Right Shift opens the menu; turn on the individual **ESP Toggle** for each category you want. The master switches are on by default, but the ESP toggles are off.

Loader for the session branch:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/scripts/esp.lua"))()
```

This branch URL will only remain available while the branch exists. If the script is merged into `main`, use `refs/heads/main/scripts/esp.lua` instead.

The ESP / World tab has a global overlay toggle and update-rate slider, plus per-category toggles and distance limits. Player and NPC overlays can independently show boxes, names, distance, weapon, health, skeletons, tracers, chams, or only visible targets. Players also have a teammate filter. Loot and deployables have name, distance and highlight controls; deployable filters cover turrets, sleeping bags/beds, tool cupboards and other items. All category ESP switches start off. Existing category flags remain compatible with saved configs.

Players are tracked through player/character events. NPCs are models with a Humanoid under `workspace.Npcs`; helicopters are models named `PatrolHeli`. The NPC weapon label checks direct equipped Tools, known equipment attributes and replicated held-item values, using `Fust.Items.Defs` names when available. It says **Weapon unknown** when equipment is not replicated; it cannot read server-only inventory.

Loot and deployable scanners track top-level models or parts below `workspace.Loot` and `workspace.Deployables`, including later additions/removals. Names and item/deployable attributes classify turrets, bags and cupboards; unrecognized deployables fall under Other. Loot labels reflect replicated instance names or item IDs, not verified crate contents. Nested physical parts of a model are not labeled separately. Game-specific hierarchies may need adjusted classification.

Resources match names in `ORE_COLORS`. Ore icon previews use the game's optional `ReplicatedStorage.Fust.ItemIcons.Get` model and camera (as described in the repository's `ItemIcons.lua`), including assets it resolves from `Fust.Models`. A replicated drop-item attribute takes priority; fallback mappings cover metal ore, sulfur ore, stones and wood. If an item/model is unknown or unavailable, an abbreviation is shown instead of inventing an icon. At most 24 3D icons are active and at most two are built per update; further nodes use the labeled fallback. Change mappings or discovery rules if the game differs. Only client-replicated objects can be detected, so streaming may affect visibility. Staff detection depends on the game's `AdminRole` attribute or its optional `ReplicatedStorage.Fust` modules.

The script performs one initial workspace scan and handles later additions/removals through events, updates overlays at the selected rate (5–60 Hz), throttles visibility raycasts, and removes drawings on despawn, unload, and reinjection. Failed drawing operations clean up partial overlays and retry after a delay. Runtime performance depends on the number of tracked objects, chosen update rate, and executor. Use **Unload Script & Clear ESP** before switching scripts; the standalone script also cleans up a previous instance of itself on reinjection. The available candidate anticheat script is obfuscated and its identity is unconfirmed: neither these overlays nor the combat features are verified as undetected or safe from enforcement.

Mocked tests are in `tests/esp_mock.lua`, `tests/ui_mock.lua` and `tests/weakspot_mock.lua` (run from the repository root with Lua 5.3 or a compatible interpreter). They exercise ESP lifecycle, UI startup, fallback, cleanup, and the Auto Weakspot `Swing` redirect/appearance-gating/auto-swing, but do not replace testing in Roblox with the target game's hierarchy and executor.

**ESP visibility note:** the Drawing API's `Transparency` property is an *opacity* value — `1` is fully visible and `0` is fully invisible. Overlays are created with `Transparency = 1`; setting it to `0` hides every box, name, distance, tracer, skeleton and health bar while `Highlight`-based chams keep rendering (the "only chams works" symptom). A regression test asserts rendered overlays stay opaque.
