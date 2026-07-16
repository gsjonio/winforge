# winforge — beginner's guide

EN | [PT-BR](GUIDE.pt-BR.md)

<!--
  Assume the reader knows nothing. Explain every term and warning in plain
  language. This is not a command reference (that's the wiki) and not a feature
  list (that's the README). GUIDE.pt-BR.md must stay structurally identical.
-->

## What is this?

When you install Windows fresh, you normally spend an afternoon downloading
programs one by one, changing settings, and turning things off. winforge does
that for you: you run one command and it installs a set of programs and applies
a set of tweaks.

It is organized into **groups** so you can pick what you want — for example
`base` (everyday programs like a browser and a media player) or `shell` (a nicer
terminal). You never have to run all of it.

The important part: winforge only changes your system when you tell it to, it can
show you what it *would* do without doing it, and it has an "undo" for the risky
part. You do not need to know PowerShell to use it.

## Key terms

- **PowerShell** — the program that runs winforge. Windows comes with an old
  version; winforge needs version 7 (a free download).
- **Administrator (admin)** — permission to change system-wide settings. Some
  steps (installing fonts, changing services) need it; Windows shows a popup
  asking for permission.
- **Group** — a named bundle of work. `base`, `dev`, `gaming`, `system` install
  programs; `optimize`, `customize`, `shell` change settings; `restore` undoes
  the optimize changes. You choose one with `-Group`, or run all of them.
- **winget / Chocolatey** — two "app stores" for the command line. winforge asks
  winget first; if that fails it tries Chocolatey; as a last resort a direct
  download link.
- **Idempotent** — a fancy word for "safe to run again". winforge checks whether
  a program is already installed and skips it, so running twice does no harm.
- **Registry** — Windows' big settings database. Many tweaks are just values
  written here.
- **Service** — a background program Windows runs. Some can be turned off to save
  resources; a few must stay on (winforge no longer touches those).
- **Profile** — how aggressive the `optimize` group is. `safe` (the default) only
  makes reversible, low-risk changes. `desktop` adds power tweaks; `gaming` adds
  network and heavier tweaks. They stack: gaming includes desktop includes safe.
- **`-WhatIf`** — a "preview" switch. Add it and winforge lists what it *would*
  change without changing anything.
- **restore** — the undo. `-Group restore` puts the services and settings the
  `optimize` group changed back to Windows defaults.
- **VSS / System Restore, StorSvc, SmartScreen** — parts of Windows that older
  versions of winforge disabled and broke (rollback, the Microsoft Store, and a
  security check). winforge no longer disables them; `restore` can turn them back
  on if an old run left them off.

## Reading the output

winforge prints a timestamped line for each step, with a symbol that tells you
what happened:

- `[i]` information — a step is starting or a note.
- `[+]` success — the step worked.
- `[!]` warning — something minor went wrong; winforge kept going.
- `[x]` error — a step failed (winforge logs it and moves on to the next).
- `[~]` skipped — nothing to do (e.g. the program was already installed).

Lines framed in `=====` are group headers, marking which group is running.

## Common questions

- **Do I have to run all of it?** No. Use `-Group <name>` to run just one group.
- **Is it safe?** The default is safe by design: it never disables System Restore,
  the Microsoft Store service, or SmartScreen. The heavier changes are opt-in.
- **How do I see what it will do first?** Add `-WhatIf` — it previews everything
  and changes nothing.
- **How do I undo it?** Run `.\setup.ps1 -Group restore` (preview it first with
  `-WhatIf`). See [RESTORE.md](RESTORE.md).
- **Nothing got installed — why?** winforge skips programs you already have, and
  needs `winget`. If `winget` is missing, install "App Installer" from the
  Microsoft Store.
- **The Microsoft Store or Game Bar broke after an old run.** An older winforge
  disabled things it should not have. `-Group restore` fixes that; see the
  [wiki FAQ](https://github.com/gsjonio/winforge/wiki).
- **Where are the details?** Command reference and troubleshooting live in the
  [wiki](https://github.com/gsjonio/winforge/wiki); per-tweak details are in
  [docs/OPTIMIZE.md](OPTIMIZE.md) and [docs/SERVICES.md](SERVICES.md).
