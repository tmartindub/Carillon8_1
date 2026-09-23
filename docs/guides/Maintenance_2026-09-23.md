# Carillon Bells v8.1

## Maintenance update - September 23, 2026

Both software packages now include the latest 32-bit Release executable.

- The morning report selects the correct yesterday play total instead of an older log summary.
- Restarting restores today's count from today's recorded Played Song entries, without extra checkpoint entries. Keep playback logging enabled for count recovery.
- Reports show total scheduled events and remaining events independently of the paused playback queue, respecting silence windows.
- Playlist duration is correctly interpreted as minutes:seconds or hours:minutes:seconds.

A previous update on September 2, 2026 corrected the error that could occur when saving Email Settings after System Settings.

Existing v8.1 users: close Carillon and replace only Carillon.exe. Keep your databases/carillon.db, music, and settings. The full and upgrade packages retain their existing 32-bit format; do not replace a 64-bit installation with the packaged 32-bit executable. All four builds are available in the repository's bin folder.

Choose the download that matches your needs.

## New installation or complete flash-drive replacement

Download **[CarillonBells_8_1_Portable_Full.zip](https://github.com/tmartindub/Carillon8_1/releases/download/v8.1.0/CarillonBells_8_1_Portable_Full.zip)**.

This package contains the program, required DLLs, sample database, help, documentation, converter, and the standard `Music` folder. Optional song libraries are available separately from the Carillon website.

1. Extract the ZIP.
2. Open the extracted `CarillonBells_8_1_Portable_Full` folder.
3. Copy everything inside that folder to the root of the USB flash drive.
4. Start Carillon from the flash drive using `start_carillon.vbs` or `Carillon.exe`.

## Upgrade an existing v7.2.4 installation

Download **[CarillonBells_7_2_4_to_8_1_Upgrade.zip](https://github.com/tmartindub/Carillon8_1/releases/download/v8.1.0/CarillonBells_7_2_4_to_8_1_Upgrade.zip)**.

The upgrade package contains Carillon 8.1, the database converter, required runtime DLLs, documentation, and step-by-step instructions. It contains no database or `Music` folder, so it does not replace the existing database, schedules, settings, or music. The converter creates a dated database backup before upgrading it.

Read the included `README.txt` and conversion instructions before beginning. Close Carillon before copying the files or running the converter. After copying the upgrade files, run `CarillonDBUpgrade724To81.exe`, back up and upgrade `databases\carillon.db`, and start Carillon only after the converter reports success.

## Verify the software downloads

- `CarillonBells_8_1_Portable_Full.zip`
  SHA-256: `6CCB3C1863F7EE8C82847696A67AAC9DE4896BB1D5E0C4C65E9B25EC8B0860E3`
- `CarillonBells_7_2_4_to_8_1_Upgrade.zip`
  SHA-256: `AEE41EB4281D7CAE1FF72A2B91D8FA4184576E734B69FB7557BE825730479DDC`

## Documentation

- [User Guide](https://github.com/tmartindub/Carillon8_1/releases/download/v8.1.0/Westminster_Chimes_and_Carillon_Bells_8_1_User_Guide.pdf)
- [Conversion Instructions](https://github.com/tmartindub/Carillon8_1/releases/download/v8.1.0/ConversionTo8_1.pdf)
- [Engineering Guide](https://github.com/tmartindub/Carillon8_1/releases/download/v8.1.0/Westminster_Chimes_and_Carillon_Bells_8_1_Engineering_Guide.pdf)

## License

Carillon Bells is free and open-source software available under the [MIT License](https://github.com/tmartindub/Carillon8_1/blob/main/LICENSE).

## Important GitHub notice

GitHub automatically displays `Source code (zip)` and `Source code (tar.gz)` on every tagged release. Those two files are **not Carillon installation packages** and should not be downloaded by users.
