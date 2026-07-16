# Security Policy

## Reporting a vulnerability

Please report security issues privately via
[GitHub Security Advisories](https://github.com/gsjonio/winforge/security/advisories/new)
for this repository, instead of opening a public issue. You'll get a response as
soon as possible.

## Supported versions

Only the latest tagged release is supported. There is no long-term support branch.

## Things to know before using winforge

winforge changes real, system-level Windows state. Read this before running it.

- **It requires administrator rights** for most groups and applies changes
  directly: it writes registry values, disables a subset of Windows services,
  sets the power plan and Storage Sense, installs fonts, and (the `shell` group)
  edits your PowerShell profile.
- **The `optimize` group changes your privacy and performance posture.** By
  default (`-Profile safe`) it only applies reversible, low-risk tweaks and never
  disables VSS/System Restore, StorSvc (Microsoft Store), or SmartScreen. The
  heavier tweaks (`desktop`, `gaming`) are opt-in. Preview any run with `-WhatIf`,
  and undo it with `-Group restore`.
- **It downloads and runs software.** Programs are installed through winget →
  Chocolatey → (last resort) a direct installer URL. The `shell` group also
  downloads the Fira Code font and an Oh My Posh theme over HTTPS. Direct-URL
  installers can be pinned with a SHA256 (`InstallerSha256`); the `shell`
  downloads are not currently hash-pinned.
- **No telemetry.** winforge sends no data about you anywhere; it only contacts
  the package sources and download URLs above.

## Dependencies

winforge has no third-party runtime dependencies — it uses only PowerShell 7 and
built-in Windows tooling (`winget`, `powercfg`, `fsutil`), plus optional
Chocolatey as an install fallback. [Dependabot](.github/dependabot.yml) opens a
weekly PR for GitHub Actions updates; CI must pass before any of them merge.
