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

## Component catalog

Every component is available on tabs, sub tabs and sections.

**Inputs and controls**

| Element | What it is |
| --- | --- |
| `Toggle` | classic check toggle, optional `:Dependency()` children |
| `ToggleSwitch` | sliding switch (alias `Switch`) |
| `BoxToggle` | bordered card toggle with hint (alias `CardToggle`) |
| `Checkbox` | compact checkbox |
| `SubToggle` / `DependencyToggle` | indented / dependent toggles |
| `RadioGroup` | single choice radio list |
| `Segmented` | segmented control (aliases `Tabs`, `Segment`) |
| `Slider` | drag slider |
| `SliderButtons` | slider with minus / plus buttons and a step |
| `Stepper` | numeric stepper (alias `Counter`) |
| `ProgressBar` | filled value bar |
| `ColorPicker` / `ColorSwatches` | colour picker and preset swatches |
| `Dropdown` / `MultiDropdown` | single and multi select |
| `Search` / `Input` / `TextArea` / `CopyField` | text entry variants |
| `Keybind` | hold or toggle keybind |
| `Button` / `ButtonRow` / `Link` | actions |

**Display**

| Element | What it is |
| --- | --- |
| `Label` / `Paragraph` | text and styled cards |
| `Badge` | pill tag (alias `Tag`) |
| `Banner` | alert / callout with icon and dismiss |
| `Stat` | metric card (alias `Metric`) |
| `Spinner` | animated loading dots |
| `Avatar` | round avatar row with optional thumbnail |
| `BulletList` | dotted list |
| `KeyValueGrid` | two column detail grid |
| `Table` / `Image` | data table and image card |
| `Divider` / `LabelDivider` | separators |
| `Card` | bordered container that holds other elements |
| `Split` | column split with builders |

`Library.Components` lists every component name and
`Library:ListComponents()` returns a copy of that list.

## Window resizing

Drag the grip in the bottom-right corner to resize. The scale stays
frozen while you drag, so the window follows the grip 1:1, and it is
clamped to the viewport. The fit pass runs once when you release.

## Notifications

`Library:Notify({ Title, Text, Style, Icon, Duration })` (also the
`Library:Success` / `Warn` / `Error` shortcuts) stacks minimal cards in the
bottom-right corner: a tinted icon chip, a truncated title, an optional body
and a hairline timer. They slide in, fade out, pause while hovered and can be
closed with the small x. `Notify` returns the card, so you can dismiss it
yourself:

```lua
local toast = Library:Notify({ Title = "saved", Text = "config written.", Style = "success" })
toast:Close()
```

## DPI

The settings tab has a **dpi** control next to **ui scale**. It maps the
classic 96 dpi baseline onto the window scale, so `96` is the default size and
`120` makes the whole menu a quarter larger. Both controls stay in sync and are
saved through the config system (`interface_scale`, `interface_dpi`).
