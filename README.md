# Orasense UI

A full-featured Roblox UI library (Luau): windows, tabs, sections, and every
control a script hub needs — plus true liquid glass, menu particles, custom
backgrounds, sub/mini windows, tab boxes, dependency toggles, searchable
dropdowns, a global menu search, and a complete config system with
multi-select dropdowns.

## Loading

```luau
local BASE = "https://raw.githubusercontent.com/sickletone/hstdhhagshsdgahshsbshxbchbshaiagsgsdtxbbashaghsgvcbcdgvsjgauagvxjhhdhdjcgbbsdujbhdfhsujhahdggfyhdhsb/refs/heads/main/"
local Library = loadstring(game:HttpGet(BASE .. "main.luau"))()
Library.BaseUrl = BASE
```

See `Exemple` for a complete working setup (window, tabs, settings,
configs, theme, server browser, player panel).

## What's included

- **Window** — draggable, resizable, top or side tabs, footer actions,
  modals, confirms, mobile button, cursor, hotkey panel, notifications
  (normal / warning / danger / success).
- **Controls** — label, paragraph, button, button row, toggle (+ keybind,
  color pickers, gear popups), slider, dropdown (single, multi-select,
  searchable), input, search, keybind, color picker, divider, split,
  table, image.
- **Tab boxes** — `tab:Groupbox(title, side)` with `"left"`, `"middle"`,
  `"right"` (aliases: `TabBox`, `Box`, `LeftTabBox`, `MiddleTabBox`,
  `RightTabBox`, …). Three-column layout is created automatically.
- **Dependency toggles & sub toggles** —
  `toggle:Dependency(function(dep) ... end)` reveals extra options only
  while the toggle is on; `elements:SubToggle(opts)` creates an indented
  child toggle.
- **Menu search** — `Window:EnableMenuSearch()` (or `MenuSearch = true`
  in `Library:Window`) adds a search box that finds any feature by name
  and jumps to it. Dropdowns support `Search = true` too.
- **Liquid glass** — a real liquid look (tinted translucency + blur,
  specular wash, travelling sheen), not plain glassmorphism:
  `Library:SetLiquidGlass(true)`, plus `SetGlass`,
  `SetGlassBlur`, `SetGlassStrength`. Preset `liquid` in the theme manager.
- **Sub tabs** — `tab:SubTab("name")` adds a nested tab strip inside a tab.
  Each sub tab is a full tab (`:Section`, `:Groupbox`, `:Full`, …), and
  anything added to the parent tab afterwards lands in the active sub tab.
- **Menu particles** — `Library:SetParticles("snow" | "blizzard" |
  "stars" | "flowers" | "custom", assetId)` draws on a full-screen overlay
  above the menu, so the effect covers the whole screen and hides whenever
  the UI closes. Custom mode takes an `rbxassetid://` image or asset id.
  Built into the settings/effects section.
- **Custom background** — `Library:SetBackground(asset)` /
  `Window:SetBackground(asset, transparency)` with fade control.
- **Sub / mini windows** — `Window:SubWindow(opts)` (a window inside the
  window) and `Library:MiniWindow(opts)` (tiny floating widget).
- **Configs** — name, create, refresh list, overwrite, delete, load, set
  as autoload, remove autoload, copy to clipboard, import from clipboard,
  reset defaults (`SaveManager:BuildConfigSection`).
- **Addons** — `SaveManager`, `InterfaceManager`, `ThemeManager`
  (15 presets + liquid + custom colors). Settings tab is wired in `Exemple`.

## Repo

Source lives at
`sickletone/hstdhhagshsdgahshsbshxbchbshaiagsgsdtxbbashaghsgvcbcdgvsjgauagvxjhhdhdjcgbbsdujbhdfhsujhahdggfyhdhsb`
(`main.luau` + `addons/`). `getgenv().Orasense` is set on load
(`OrasenseUI` alias; legacy `Facility` alias kept for compatibility).
