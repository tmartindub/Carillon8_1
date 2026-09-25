# Playback crash diagnostics - September 25, 2026

This is a diagnostic build, not a verified correction for the playback crash.
No scheduling, media lifetime, or playback-loop logic has been changed.
File writes add some timing overhead, so a failure disappearing while tracing
does not by itself prove that the underlying problem is resolved.

## Files to retain

- The tested Carillon.exe and its matching detailed Carillon.map build output.
- The executable's SHA-256 hash and build configuration.
- The newest logs\diagnostics\CarillonPlayback-*.log next to the tested executable.
- The normal logs\CarillonPlayLog.txt and the observed crash time.
- Any Windows crash dump from %LOCALAPPDATA%\Carillon\CrashDumps on this PC.

Each run creates a separate trace with millisecond timestamps, process/thread
IDs, a monotonic tick count, executable path, architecture, and configuration.
Paired begin/end markers surround media loading, duration probing, playback,
message processing during preparation, and player cleanup. Trace entries are
flushed to disk immediately and do not enter the normal play log or song counts.
An unwritable trace file must not cause playback to fail. Traces are not pruned
automatically; retain failed sessions, and remove unneeded traces after testing.

## Windows crash dumps

The observed 0xC0000602 fail-fast exception bypasses ordinary Delphi exception
handlers. This build intentionally does not install an exception filter that
would falsely promise to catch it. Windows Error Reporting (WER) LocalDumps is
configured separately on the test PC, not by the portable application.

The approved test configuration uses the per-application Carillon.exe key under
HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps in the
32-bit and 64-bit registry views: DumpType=2 (full), DumpCount=3, and DumpFolder
(REG_EXPAND_SZ)=%LOCALAPPDATA%\Carillon\CrashDumps. This targets the executable
name Carillon.exe, regardless of drive letter; it does not target Old_Carillon.exe.
Both per-application keys were absent before this setup. The pre-change state is
recorded with the project backup on D:. No global WER settings are changed.

To undo this specific test setup after approval, remove only the Carillon.exe
LocalDumps subkey from both views. Do not remove LocalDumps itself or other apps'
settings. This PC-only setting does not travel with a USB drive. Another PC would
need its own approved setup. A debugger configured to start automatically after
a crash can prevent WER local-dump collection.

Full dumps can contain passwords, email settings, and other private memory.
Keep them local; do not commit, publish, or upload them to a public issue.
The repository ignores .dmp files and logs directories. WER is set to retain at
most three dumps, but a full dump can be large; monitor free disk space.

## Test procedure

Leave the older executable's comparison run undisturbed. When ready, close it
normally, preserve both executables, and use the diagnostic Carillon.exe in the
same portable installation. Do not replace the live database or audio files.
Use the same architecture as the affected installation (currently Win32).
Confirm a new trace appears at startup. Record which songs ran and whether the
app exited. A few successful plays do not establish long-term stability.

Do not publish this diagnostic executable in customer packages as a fix.
Build maps and dumps are diagnostic artifacts, not customer downloads.
The code tests verify trace creation, immediate persistence, Unicode handling,
failure isolation, and unchanged report/count behavior without playing audio or
using the live database. CrashDumpProbe.dpr is a separate minimal console test:
compile it into an isolated test folder, use the name Carillon.exe there to
exercise the per-application WER setting, and pass --verify-crash-capture.
It deliberately raises 0xC0000602 and loads no Carillon code or customer data.
Record its PID and time so its synthetic crash is not confused with a real
playback failure. Successful probe capture verifies the WER mechanism, not a
diagnosis or fix of the audio-decoder crash.

Reference: https://learn.microsoft.com/en-us/windows/win32/wer/collecting-user-mode-dumps
