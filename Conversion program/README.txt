Carillon Database Upgrade 7.2.4 to 8.1

This folder contains a separate FMX utility project:

CarillonDBUpgrade724To81.dproj

Purpose:

- Upgrade a Carillon 7.2.4 SQLite database in place to the v8.1 schema.
- Create a database backup before changing anything.
- Convert PL_RAND_DIR_ROTATION from the old one-row wide format to the v8.1
  row-based slot format.
- Create the v8.1 silence_schedule table and 12 disabled rows.
- Add any missing PL_SETTINGS columns used by v8.1.
- Copy seasonal group dates and play time to matching playlist rows so group
  play times show in the main screen.
- Normalize stored time values so seconds are preserved.
- Write an upgrade report to the flash-drive logs folder.

Intended use:

Run CarillonDBUpgrade724To81.exe from the flash drive root, select
databases\carillon.db, check the confirmation box, then click Back Up and
Upgrade.

Do not run Carillon while converting the database.
