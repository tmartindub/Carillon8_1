# Carillon v8.1

Carillon v8.1, also documented as Westminster Chimes and Carillon Bells 8.1, is a portable Delphi FireMonkey application for scheduled church-bell and music playback.

The application is designed for churches, chapels, schools, and other organizations that need a Windows-based system for automatic chimes, bells, seasonal music, and daily playback schedules.

## Features

- Scheduled Westminster chimes, bell sounds, and music playback
- Playlist editor with daily scheduling support
- Seasonal and date-bound playback groups
- Random music directory rotation
- Silence schedule support for periods when playback should be suppressed
- Optional email settings and morning reports
- Application logging and log viewing
- Portable deployment without a traditional Windows installer
- Built-in HTML help files and user documentation

## Project Type

This is a Delphi FireMonkey (FMX) desktop application.

Primary project file:

```text
Carillon.dproj
```

Program entry point:

```text
Carillon.dpr
```

## Build Requirements

- Windows
- Embarcadero Delphi / RAD Studio with FireMonkey support
- The project is currently configured with Win32 and Win64 build targets

Open `Carillon.dproj` in RAD Studio, choose the desired Windows target, and build the project.

## Repository Layout

```text
.
|-- Carillon.dpr / Carillon.dproj   Main Delphi project files
|-- *.pas / *.fmx                   Application source and form files
|-- Help/                           Built-in HTML help system
|-- Images/                         Image assets used by documentation or the app
|-- docs/                           Application guides and generated documentation
|-- .gitignore                      Files intentionally excluded from Git
`-- .gitattributes                  Git text/binary handling rules
```

## Files Not Included in Git

This repository intentionally excludes generated and local-only files such as:

- Delphi build output: `*.dcu`, `*.exe`, `Win32/`, `Win64/`, `Debug/`, `Release/`
- Delphi local state: `*.local`, `*.identcache`, `__history/`, `__recovery/`
- Local databases and test data: `*.db`, `*.sqlite`, `*.sqlite3`
- Local archives: `*.zip`, `*.7z`, `*.rar`

If you need sample database content for development, add a sanitized sample under a clearly named folder such as `samples/`.

## Documentation

Additional documentation is available in the `docs/` folder, including application and user guides. The `Help/` folder contains the built-in HTML help system used by the application.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

Copyright (c) 2026 Tommy Martin.

## Author

Tommy Martin


