# Calender Clock — Plasma 6 Widget

[![KDE Store](https://img.shields.io/badge/KDE_Store-download-blue)](https://store.kde.org/p/2371591/)

A minimalist clock widget for the KDE Plasma 6 panel.
It shows the weekday, date and time in your panel, with a month/year calendar
popup.

## Features

- Lives in the panel: `Tuesday   15 September   18:05`, ideal for a top bar
  (a vertical panel shows the time only)
- Choose what the panel shows: weekday, date and time can each be turned off
- Calendar popup: month view with today highlighted, plus a year view
  (12 months in 3 columns)
- Scroll changes month, right-click toggles month/year mode
- Follows your Plasma color scheme, or the original fixed palette
  (`#a6adc8` months/weekdays/today, `#555869` days) if you prefer it
- Date language of your choice, or the system language; the week start
  follows your region settings
- Left-click the panel icon to open the calendar, middle-click to jump to today
- Custom panel font: pick any font installed on your system, plus size
- Panel icons from your icon theme, or Nerd Font glyphs
- Tooltip with the full date/time plus calendar hint
- Right-click context actions: Today and Show month/year

## Requirements

KDE Plasma 6.

The panel icons come from your icon theme by default. If you would rather
have Nerd Font glyphs, pick a font from
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) in the widget's font
settings and turn on **Use Nerd Font glyphs**.

## Install

- **KDE Store:** grab the `.plasmoid` from
  [store.kde.org/p/2371591](https://store.kde.org/p/2371591/), then
  right-click the panel → **Edit Panel** → **Add Widgets** → **Get New
  Widgets** → **Install from file…**
- **From source:**

```bash
git clone https://github.com/wrenchyyy/Plasma6-Calender-Clock
cd Plasma6-Calender-Clock
chmod +x install.sh
./install.sh
```

Then add it to your bar:

1. Right-click the top panel → **Edit Panel** → **Add Widgets**
2. Search **Calender Clock**, drag it onto the panel

To update after pulling new changes, just run `./install.sh` again.
To remove the widget and its icon, run `./install.sh --uninstall`.

## Usage

- **Left-click** the panel icon: open / close the calendar popup
- **Middle-click** the panel icon: jump back to today (and open the popup)
- **Press-and-hold** the panel icon: same as left-click
- **Right-click**: standard widget menu plus Today and Show month/year actions,
  and **Configure…** for settings
- Inside the popup: **scroll** changes month/year, **right-click** toggles
  month/year mode, clicking a month in year view jumps to it

## Configuration

Right-click the widget → **Configure…**:

- **Show in panel** — tick any of **Weekday**, **Date** and **Time**. The last
  one ticked stays on, so the panel is never empty. A vertical panel always
  shows the time only.
- **Date language** — the language of the weekday names, month names and
  digits, in the panel and in the calendar. **System default** follows your
  system language; pick any other one to use it whatever your system is set
  to. The widget's own menus and hints stay in English.
- **Panel font** — **Choose…** opens the system font dialog listing every font on
  your PC; pick a family and size, or **Default** to go back to system monospace.
  The choice applies to the panel clock text. (The calendar popup stays
  monospace.)
- **Panel icons** — tick **Use Nerd Font glyphs** to draw the calendar and
  clock icons with your panel font instead of the icon theme. The panel font
  must be a Nerd Font, otherwise the glyphs show as empty boxes.
- **Calendar colors** — **Follow the Plasma color scheme** is on by default.
  Turn it off for the original fixed palette, which is made for dark themes.

## Project structure

```
.
├── com.calenderclock/               # The Plasma 6 widget
│   ├── metadata.json              # Plasmoid metadata
│   └── contents/
│       ├── ui/
│       │   ├── main.qml           # Clock + panel/popup calendar UI
│       │   └── configGeneral.qml  # Settings page (font, icons, colors)
│       ├── config/
│       │   ├── main.xml           # Config key definitions + defaults
│       │   └── config.qml         # Registers the settings page
│       └── icons/
│           └── calenderclock.svg  # Widget icon, copied into the icon theme by install.sh
├── install.sh                     # Installs/updates/removes the widget via kpackagetool6
├── check.sh                       # Validates metadata and lints the QML (also run by CI)
```

## License

MIT License — Copyright (c) 2026 Wrenchy. See `LICENSE` for the full text.
