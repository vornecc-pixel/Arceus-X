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
| `scripts/silent_aim.lua` | Silent aim features only; no UI, driven by either menu below |
| `scripts/silent_aim_ui.lua` | Standalone Octohook menu for the silent aim features (UI only) |
| `scripts/world_esp.lua` | Chams ESP features only (players, NPCs, nodes, skeleton, boxes); no UI |
| `scripts/world_esp_ui.lua` | Standalone Octohook menu for the chams ESP (UI only) |
| `scripts/gun_mods.lua` | Gun mods features only (no recoil, no bloom, spread payload hook); no UI |
| `scripts/gun_mods_ui.lua` | Standalone Octohook menu for the gun mods (UI only) |
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

The combat features depend on executor APIs and the target game's internal tables; they are not verified against the live game. Unloading restores the tracked scanner settings where possible, but cannot guarantee restoration of transient state changes or game-side effects. The weakspot feature retains the original invisible node marker; by itself it does **not** redirect hits. The ESP requires a compatible Drawing API. If ESP loading fails, the combat UI still opens and reports the error.

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

## Silent aim: features and UI are separate files

The silent aim from the supplied script was split in two so the menu can be swapped without touching the logic:

| File | Contains | Contains nothing else |
| --- | --- | --- |
| `scripts/silent_aim.lua` | Targeting, prediction, wall/team checks, hit chance, camera sandwich, FOV circle, per-gun speeds | no window, no buttons, no library |
| `scripts/silent_aim_ui.lua` | Octohook window, tabs, toggles, sliders, dropdowns, keybind, colour picker, status labels | no camera or target code |

`scripts/main.lua` wires the same `scripts/silent_aim.lua` into its own **Combat** tab with ARC3USX controls, so both menus always behave identically.

Standalone Octohook menu:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/scripts/silent_aim_ui.lua"))()
```

The loader pulls `scripts/silent_aim.lua` and the Octohook library from their own URLs. Point `getgenv().ARC3USX_RAW_ROOT` at another folder or branch before running it if you host the files somewhere else. The menu window is 520×660, centered and clamped to the viewport, with **Aim**, **Visuals** and **Settings** tabs; the settings tab also gets the library's config list.

Controls (all wired; nothing here is a placeholder):

- **Enabled** with a toggle keybind (V), **Activation**: Always / Hold (RMB) / Toggle (Key), **Only While Firing (LMB)**
- **Targeting**: hit chance, FOV radius, distance limit (0 = off), target bone (Head / HumanoidRootPart / Random) with a re-roll interval for the random part
- **Filters**: wall check, team check (uses the `FustMates` attribute and `Team`), target NPCs (`workspace.Npcs`, `Guard`/`Soldier`/`Scavenger`)
- **Gun**: bullet-speed override (0 = per-gun table), snap cooldown per gun
- **Visuals**: FOV circle on/off, colour, fill, thickness, transparency, plus a snapline from the FOV centre to the target that will actually be hit (own colour, thickness and transparency)

How it fires: the camera is aimed at the target at `RenderPriority.Camera + 2` and put back at `Camera + 4`, so the vanilla camera never shows the snap. No game tool or `Namecall`/`Index` hook is installed. Hit chance is rolled once per acquired target (locked for 0.25 s) instead of every frame, so a 60% setting behaves like 60% rather than a flicker.

The **Random** bone picks a real part from the rig (head, torso, arms, hands, legs, feet - falling back to any `BasePart`), re-rolls it for every new target, and keeps it while the target is locked, so the aim does not jitter between parts. The snapline is drawn from the FOV centre to the screen position of the part the shot will be sent to; it is hidden whenever no target is locked, so whatever the line points at is what fires.

Both the standalone menu and `main.lua` clean up after themselves: render steps unbind, input connections disconnect, the FOV circle is removed, and re-executing the script destroys the previous menu first (the Octohook library does not unload itself). An injected library is left alone — the caller unloads it.

Drive the features without any UI:

```lua
local SilentAim = assert(loadstring(game:HttpGet(ROOT .. "scripts/silent_aim.lua")))()
local aim = SilentAim.newSingleton({ enabled = true, fov = 300, hitChance = 80 })
aim:Set("activation", "Hold")        -- "Always" | "Hold" | "Toggle"
aim:Set("bone", "HumanoidRootPart")  -- "Head" | "HumanoidRootPart"
aim:OnChanged(function(key, value) print(key, value) end)
print(aim:GetStatus().target)
aim:Unload()
```

Every option clamps or validates on the way in (`aim:Set` returns `false, reason` for bad input), so a broken config cannot put the feature in an invalid state.

## Chams ESP: features and UI are separate files

The chams/skeleton/box ESP from the second supplied script uses the same split as the silent aim:

| File | Contains | Contains nothing else |
| --- | --- | --- |
| `scripts/world_esp.lua` | tracking, boxes, R15/R6 skeletons, health bars, names, distance, weapons, chams and filters | no window, no buttons, no library |
| `scripts/world_esp_ui.lua` | Octohook window with Targets / Visuals / Colors / Settings tabs | no drawing or tracking code |

`scripts/main.lua` adds the same feature module as its own **Chams ESP** tab with ARC3USX controls, next to the existing ESP tab.

Standalone Octohook menu:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/scripts/world_esp_ui.lua"))()
```

Every control is wired:

- **Targets**: master toggle with a keybind (B), players / NPCs / resource nodes, max distance, update rate (0 = every frame), and the NPC and node name lists (comma separated; models with the `Scavenger` attribute also count as NPCs)
- **Visuals**: chams, skeleton, health bar, name, distance, weapon, box mode (corners or full), corner size, box and skeleton thickness, text size, studs per metre, node dot size, the box visible check, and the occluded-chams switch with cham fill/outline transparency
- **Colors**: a visible and an occluded colour for the box and for the chams of players and NPCs, skeleton and name colours, plus the node dot and label colour - all live

Resource nodes are deliberately minimal: a coloured **dot** at the node plus its **name** and **distance**, with no box and no `Highlight`. Players and NPCs keep box, skeleton, health, weapon and chams.

**Box colours follow line of sight.** With **Box Visible Check** on (the default), corners and full boxes are drawn green while the target is in the clear and switch to the occluded colour (red by default) the moment something blocks them. Both colours are per-category pickers for players and for NPCs, so you can use anything you like instead of green/red. Turn the check off and each category keeps its single visible colour.

Chams have an **occluded chams** mode on by default: every 150 ms the ESP raycasts from the camera to the target's head (ignoring the target and your own character) and swaps the cham to the occluded colour when something is in the way. Because the highlight uses `AlwaysOnTop`, you still see the target through the wall - just in the occluded colour. Turn it off and one colour is used everywhere. The box and the cham share that one raycast, so enabling both does not double the cost, and the colours settle within 150 ms of a target moving in or out of cover.

What changed from the pasted version, since it could not run as written:

- Drawing objects were released with `:Destroy()`, which the Drawing API does not have - they use `:Remove()` now, and unload clears them all
- The camera was captured once at load; it is re-read every frame, so camera swaps no longer freeze the ESP
- Chams were only created when the first target was built; the highlight is now created and destroyed live as the toggle changes
- R6 rigs got no skeleton (only R15 bone names were checked) - both rigs are covered now
- Depth could be 0, producing infinite box sizes; heights are guarded and clamped
- `unload` only cleared drawings, leaving the render loop and player hooks connected; unload now disconnects everything, drops every record, and calls `cleardrawcache` when the executor provides it
- Nodes, NPCs and players are validated against the whitelists every rescan, so removing a name stops tracking it

Drive it without a UI:

```lua
local WorldESP = assert(loadstring(game:HttpGet(ROOT .. "scripts/world_esp.lua")))()
local esp = WorldESP.newSingleton({ enabled = true })
esp:Set("boxMode", "full")
esp:SetNpcWhitelist("Guard, Soldier")
esp:Set("playerChamColor", Color3.fromRGB(255, 60, 60))
print(esp:GetStatus().players, esp:GetStatus().npcs, esp:GetStatus().nodes)
esp:Unload()
```

## Mods: features and UI are separate files

The No Recoil / No Bloom / spread script uses the same split as the other two ports:

| File | Contains | Contains nothing else |
| --- | --- | --- |
| `scripts/gun_mods.lua` | recoil cancellation, crosshair tick hiding, the spread payload hook and the option table | no window, no buttons, no library |
| `scripts/gun_mods_ui.lua` | Octohook window with Mods / Settings tabs | no camera, GUI or remote code |

`scripts/main.lua` adds the same feature module as its own **Mods** tab with ARC3USX controls.

Standalone Octohook menu:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/scripts/gun_mods_ui.lua"))()
```

The loader pulls `scripts/gun_mods.lua` and the Octohook library itself. Point `getgenv().ARC3USX_RAW_ROOT` at another folder or branch if you host the files elsewhere. Every control is wired:

- **Gun Mods**: master toggle with a keybind (N)
- **No Recoil**: on/off, mouse grace (0–0.5 s), pitch and yaw tolerance (0–0.05 rad)
- **Crosshair**: No Bloom on/off, sweep rate (0.05–1 s)
- **Spread Payload**: zero spread fields on/off, with the detection warning
- **Settings**: live status labels (cancellations, hidden ticks, hook state) and an Unload button

How the recoil part works: a `RunService:BindToRenderStep` callback runs at `RenderPriority.Camera.Value + 500`, reads the camera `LookVector` back into pitch/yaw, and rewrites the camera to the last mouse-driven aim when the difference exceeds the tolerances. Any mouse movement in the last `MOUSE_GRACE` seconds is treated as real aim and becomes the new base, so aiming is not fought. The camera is re-read every frame and the base is reset on `Start`, so a camera swap or respawn does not freeze it.

Bloom hiding sweeps `Players.LocalPlayer.PlayerGui.FustGather` on a timer, hides `Frame`s whose name starts with `Tick`, and stores the original `Visible` value of each one. Turning the option off or unloading puts the original values back — including ticks that were already hidden. The loop is token-guarded, so changing the rate, toggling off, or unloading stops it immediately instead of leaving a second loop behind.

The spread hook is the only part that needs executor functions (`getrawmetatable`, `setreadonly`, `getnamecallmethod`, `newcclosure` optional). It finds the `RemoteEvent`/`UnreliableRemoteEvent`s under `ReplicatedStorage.Fust`, installs **one** `__namecall` wrapper on their shared metatable, and only touches `FireServer` calls on those remotes, zeroing `spread`, `spreadMult`, `spreadMul`, `bloom`, `bloomAmount` and similar numeric fields in the payload (including one level of nested tables). Turning it off restores the original `__namecall`, but only if the wrapper is still the one in place. If the functions are missing, the toggle stays off and the status label shows the reason instead of erroring.

What changed from the pasted version, since it could not run as written:

- The hook wrapped `__namecall` once **per remote**, chaining wrappers on the same shared metatable and breaking other remotes; one wrapper keyed by the target remotes now handles all of them
- The hook could never be removed; it is restored on toggle-off and unload
- `getrawmetatable`/`setreadonly` were unguarded (instant error on executors without them); they are capability-checked first
- `while task.wait(0.1) do ... end` kept a hidden tick-hider running forever; the sweep is token-guarded and restores what it hid
- The base aim was captured once at load and lost on camera swaps; it is reset on start and the camera is re-read
- The bloom loop ran even with the option off, and `Enum.UnreliableRemoteEvent` was assumed to exist; both are conditional now
- Unload left the render binding and hidden ticks behind; `:Unload()` unbinds, disconnects, restores and drops the hook

Honest limits: recoil cancellation only affects **your camera** — the server-side shot direction, and any spread the game applies on the server, are unchanged. Zeroing payload fields only helps if the game trusts the client value, and the metatable hook is exactly the kind of thing anticheats look for. `ReplicatedStorage.Fust`, `PlayerGui.FustGather` and the payload field names come from the pasted script and are not verified against the live game.

Drive it without a UI:

```lua
local GunMods = assert(loadstring(game:HttpGet(ROOT .. "scripts/gun_mods.lua")))()
local mods = GunMods.newSingleton({ enabled = true, noRecoil = true, noBloom = true })
mods:Set("recoilGrace", 0.02)      -- seconds
mods:Set("bloomRate", 0.05)        -- sweep interval
mods:Set("zeroSpread", true)       -- needs executor hook functions
print(mods:GetStatus().recoilUndos, mods:GetStatus().hookError)
mods:Unload()
```

`Set` returns `false, reason` for unknown keys or non-numeric values, and clamps every numeric option to its range. Re-executing either half destroys the previous instance first.

Mocked tests are in `tests/esp_mock.lua`, `tests/ui_mock.lua`, `tests/silent_aim_mock.lua`, `tests/world_esp_mock.lua` and `tests/gun_mods_mock.lua` (run from the repository root with Lua 5.3 or a compatible interpreter). `silent_aim_mock.lua` covers the option table, every targeting rule, the camera sandwich, cleanup, the Octohook control wiring and the real `main.lua` integration; `world_esp_mock.lua` does the same for the chams ESP (tracking, boxes, skeletons for both rigs, chams, filters, teardown); `gun_mods_mock.lua` covers recoil cancellation and its grace/tolerance behaviour, tick hiding with visibility restore, the namecall wrapper and its removal, the missing-executor path, teardown, and the Mods tab in both menus. None of this replaces testing in Roblox with the target game's hierarchy, payloads and executor.
