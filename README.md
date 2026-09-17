# Calender Clock — Plasma 6 Widget

A minimalist clock widget for the KDE Plasma 6 panel.
It shows the weekday, date and time in your panel, with a month/year calendar
popup.

## Features

- Lives in the panel: `Tuesday   15 September   18:05`, ideal for a top bar
- Calendar popup: month view with today highlighted, plus a year view
  (12 months in 3 columns)
- Scroll changes month, right-click toggles month/year mode
- Colors: `#a6adc8` months/weekdays/today, `#555869` days, monospace
- Left-click the panel icon to open the calendar, middle-click to jump to today
- Double-click (or press-and-hold) to open the expanded view
- Custom panel font: pick any font installed on your system, plus size
- Tooltip with the full date/time plus calendar hint
- Right-click context actions: Today and Show month/year

## Requirements

KDE Plasma 6.

A Nerd Font is needed for the panel icons. Pick any font you like from
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts), then select it in the widget's font settings.

## Install

- **KDE Store:** grab the `.plasmoid` from the store listing, then
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

## Usage

- **Left-click** the panel icon: open / close the calendar popup
- **Middle-click** the panel icon: jump back to today (and open the popup)
- **Double-click** (or press-and-hold): open the expanded calendar view
- **Right-click**: standard widget menu plus Today and Show month/year actions,
  and **Configure…** for settings
- Inside the popup: **scroll** changes month/year, **right-click** toggles
  month/year mode, clicking a month in year view jumps to it

## Configuration

Right-click the widget → **Configure…**:

- **Panel font** — **Choose…** opens the system font dialog listing every font on
  your PC; pick a family and size, or **Default** to go back to system monospace.
  The choice applies to the panel clock text. (The calendar popup stays
  monospace calendar popup.)

## Project structure

```
.
├── com.calenderclock/               # The Plasma 6 widget
│   ├── metadata.json              # Plasmoid metadata
│   └── contents/
│       ├── ui/
│       │   ├── main.qml           # Clock + panel/popup calendar UI
│       │   └── configGeneral.qml  # Settings page (font picker)
│       ├── config/
│       │   ├── main.xml           # Config key definitions + defaults
│       │   └── config.qml         # Registers the settings page
│       └── icons/
│           └── calenderclock.svg  # Widget icon (browser + About page)
├── install.sh                     # Installs/updates the widget via kpackagetool6
```

## License

MIT License — Copyright (c) 2026 Wrenchy. See `LICENSE` for the full text.
