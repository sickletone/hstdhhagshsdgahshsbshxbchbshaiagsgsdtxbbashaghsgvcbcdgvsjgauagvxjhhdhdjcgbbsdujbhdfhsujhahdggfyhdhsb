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
  modals, confirms, touch-only mobile button, cursor, hotkey panel, notifications, watermark
  (normal / warning / danger / success).
- **Controls** — label, paragraph, button, button row, toggle (+ keybind,
  color pickers, gear popups), slider, dropdown (single, multi-select,
  searchable), input, search, keybind, color picker, divider, split,
  table, image.
- **Tab boxes** — `tab:Groupbox(title, side)` with `"left"`, `"center"`,
  `"right"` (aliases: `TabBox`, `Box`, `LeftTabBox`, `MiddleTabBox` /
  `CenterTabBox`, `RightTabBox`, …). Asking for the center or right box builds
  the full three-column layout automatically. The title can be a table,
  `{ Title = "arcade servers", Icon = "settings", Side = "left" }`, to get a
  header icon like the reference hubs.
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
  `SetGlassBlur`, `SetGlassStrength`. Blur is off by default; the glass
  controls (including blur) live in settings > themes. Preset `liquid` in the
  theme manager.
- **Sub tabs** — `tab:SubTab("name")` adds a nested tab strip inside a tab:
  a row of text tabs with an accent underline on the active one (plus the
  parent tab's icon at the left). Each sub tab is a full tab (`:Section`,
  `:Groupbox`, `:Full`, …), and anything added to the parent tab afterwards
  lands in the active sub tab.
- **Menu particles** — `Library:SetParticles("snow" | "blizzard" |
  "stars" | "flowers" | "custom", assetId)` draws on a full-screen overlay
  above the menu, so the effect covers the whole screen and hides whenever
  the UI closes. Custom mode takes an `rbxassetid://` image or asset id.
  Rate, size, speed, start/end speed and spread are adjustable from settings
  (or with `Library:SetParticleOptions{ ... }`).
  Built into the settings/effects section.
- **Custom background** — `Library:SetBackground(asset)` /
  `Window:SetBackground(asset, transparency)` with fade control.
- **Sub / mini windows** — `Window:SubWindow(opts)` (a window inside the
  window) and `Library:MiniWindow(opts)`, a second floating window that is
  smaller than the menu but keeps the same chrome: its own title bar, drag,
  close button, scrollable body and a bottom-right corner grip. Its
  `Content` accepts every component in the library, and `:SetVisible`,
  `:Toggle`, `:SetPosition` and `:SetSize` drive it from a toggle, button or
  dropdown.
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

## Icons (Molto)

Every icon is drawn from [Molto](https://molto.pages.dev/) using its `lucide`
provider: the module is fetched once, the provider is loaded lazily on the first
icon, and the sheet URL plus rect are cached by Molto itself.

```lua
local Orasense = loadstring(game:HttpGet("..."))()
-- Icon names are Molto names: "sliders-horizontal", "settings", "wrench", ...
window:Tab("misc", "wrench")
```

Set `Orasense.IconProvider` before the first window is built to switch provider:
`lucide` (default), `tabler`, `heroicons`, `solar` or `phosphor`. Any `Icon =`
argument also accepts an `rbxassetid://` image or a raw asset id. The resolver is
wrapped so that if Molto cannot load (Roblox Studio, no `HttpGet`/`loadstring`,
unknown provider or unknown icon) the bundled Lucide sprite table in
`addons/Icons.luau` is used instead — icons never go blank.

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

Drag the grip in the bottom-right corner to resize. Grabbing it anchors the
window by its top-left corner in screen pixels, then the drag only writes
`Size`, so the opposite corner is fixed by construction and the edge tracks
the cursor without the jitter the old per-frame position correction caused.
The scale stays frozen while you drag, and releasing does not re-run the fit
pass, so the menu does not snap or jump at the end. Mini windows resize the
same way with their own grip.

## Notifications

`Library:Notify({ Title, Text, Style, Icon, Duration })` (also the
`Library:Success` / `Warn` / `Error` shortcuts) stacks clean cards in the
bottom-right corner: a soft border, an accent rail down the left edge, an
optional icon chip, a truncated title, an optional body and a hairline timer.
They fade in, pause while hovered and can be closed with the x (or by calling
`:Close()`). `Notify` returns the card, so you can dismiss it yourself:

```lua
local toast = Library:Notify({ Title = "saved", Text = "config written.", Style = "success" })
toast:Close()
```

## DPI

The settings tab has a **dpi** control and a **menu scale** control, and they
now do different things. `dpi` resizes the **components** — buttons, rows,
sliders, inputs, text, and the tab labels/icons — around the fixed 96 dpi
baseline (`120` makes them a quarter larger); the window frame, title bar and
footer stay exactly where they are, so the menu no longer grows or moves while
you drag it.
`menu scale` still scales the whole window. Both are saved through the config
system (`interface_dpi`, `interface_scale`).

`menu transparency` sits next to them and defaults to `0%` (fully opaque).

## Particles

`Library:SetParticles(mode, assetId)` picks the effect; the settings tab also
exposes six live sliders: **rate** (particle count), **size**, **speed**
(overall multiplier), **start speed** and **end speed** (px/s at spawn and at
the bottom of the fall) and **spread** (sideways drift). They are saved as
`orasense_particle_rate`, `_size`, `_speed`, `_start_speed`, `_end_speed` and
`_spread`, and apply without restarting the effect.

## Mobile

On touch devices (touch input without a keyboard) the library switches on
mobile sizing automatically: every interactive row is taller
(`Toggle` 22 -> 32, `Slider` 30 -> 40, inputs and buttons 26 -> 34, and the
same treatment for the component pack), group headers and sub tab pills get
bigger touch targets, tab labels get bigger text, the components start at
112% dpi, and windows are created 560 px wide so the fit pass scales the
whole menu up instead of down. `Library.Mobile` reports the detected mode,
and any window can still opt out by passing its own `Width`.

Small decorative hairlines (the bar under the title, the footer rule, the
content outline and the title separator) are no longer drawn, so the menu
reads as clean surfaces instead of boxed-in panels.
