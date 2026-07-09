# YourMAPS FlagScript

A flag system for **RedM**, created to fill the gap in available scripts that allow players to equip and interact with flags as in-game items.

This system enables players to carry, drop, pick up and **place** flags in an immersive and configurable way. It supports full integration with item-based frameworks, animations, prompts and optional database persistence.

---

## Supported Frameworks

- ✅ **REDEMRP**
- ✅ **VORP**
- ✅ **OTHER**

## Includes (free release)

**4 flag props** in `stream/`: Mexico (`prop_flag_mx`), Canada (`prop_flag_ca`), LGBTQ (`prop_flag_lgbtq`), Trans.

**40+ flag items** are preconfigured in `config.lua` and SQL files (national, tribal, in-game state flags, etc.) — props for those flags are **not** included in this free release. Use your own streaming packs or the official YourMAPS flag packs.

**Gang flags** (`flaggang01` … `flaggang12`) are preconfigured in `config.lua` — requires the separate resource `yourmaps_gang_flags`.

---

![imagem](https://github.com/user-attachments/assets/df41b58d-4426-4485-aaa7-026e5259950c)

## Key Features

### Core
- **Carry flags in hand** - immersive animations and prop attachments
- **Drop & pick up** - configurable keybinds or native RedM prompts
- **Client & server logic** - attachment, distances, item checks, cleanup
- **Framework integration** - REDEMRP, VORP or custom
- **Job / item locking** - optional restrictions per flag
- **Automatic cleanup on respawn** - prevents stuck props

### New in this version

- **Persistent placed flags** — leave flags at camp, base or territory; they survive server restarts (MySQL + `oxmysql`, table `ym_flags_placed`)
- **Multiple world flags per player** — configurable limit (`Config.persistentMaxPerPlayer`)
- **Owner-only pickup** — optional; consume item on place, return on pickup
- **Interaction modes** — separate settings for ground flags vs equipped flag:
  - `Config.placedInteraction` — `drawtext`, `native`, `murphy_interact`, `blkb_interaction`, `pc_interaction`, `custom`
  - `Config.equippedInteraction` — `keys`, `native`, `drawtext`
  - Custom targets: see `client/interactions_custom.example.lua`
- **Internationalization** — `lang.lua` with `en`, `fr`, `pt`, `es`, `it`; override any string via `Config.Locale`
- **Gang flag support** — ready for `yourmaps_gang_flags` streaming pack

### Optional YourMAPS flag packs (separate resources)

These work with this script via `flagscript_config_snippet.lua` in each pack:

| Pack | Theme |
|------|--------|
| `yourmaps_gang_flags` | Outlaw / gang banners |
| `yourmaps_noble_flags` | Heraldic noble houses |
| `yourmaps_clan_flags` | Occult / witch clans |
| `yourmaps_cult_flags` | Dark cult / ritual banners |

---

![imagem](https://github.com/user-attachments/assets/31dde33b-d76a-48bb-be80-94f0de7b60df)

## Installation

### 1. Place the resource

Put the folder `yourmaps_flagscript` in your RedM resources directory.

### 2. Dependencies

- **oxmysql** — required when `Config.persistentFlags = true` (recommended)

```cfg
ensure oxmysql
ensure yourmaps_flagscript
```

If you use optional flag packs, start them **before** the script:

```cfg
ensure yourmaps_gang_flags
ensure yourmaps_flagscript
```

### 3. Persistent flags (optional)

1. Run `ym_flags_placed.sql` on your database
2. In `config.lua`: `Config.persistentFlags = true`
3. Adjust limits: `persistentMaxPerPlayer`, `persistentOwnerOnly`, `persistentConsumeOnPlace`, etc.

### 4. Interaction & language

**Interaction** (`config.lua`):

- `Config.placedInteraction` — how players interact with flags on the ground
- `Config.equippedInteraction` — how players place or stash while holding a flag
- `native` = RedM UiPrompt (not jo_libs)

**Language** (`config.lua` + `lang.lua`):

```lua
Config.LocaleLanguage = 'en'  -- en, fr, pt, es, it
Config.Locale['persistent_place'] = 'Custom text'  -- optional overrides
```

### 5. Create flag items

This script uses inventory items to spawn flags.

**You must create the flag items** in your inventory system:

- Your framework's item registration, **or**
- Run `flag_items_vorp.sql` or `flag_items_redemrp.sql` on your database

All usable items are listed in `config.lua` for easy reference.

### 6. Configure

Open `config.lua` — keybinds, flags, interaction mode, persistence and locale.

Restart the server and test, e.g.:

```
/additem canadianflag 1
/additem flaggang01 1
```

---

![imagem](https://github.com/user-attachments/assets/27960af6-3c6b-42e5-9230-5e153ca96f91)

## Open Source & Attribution

This script was developed because standalone flag systems for RedM were scarce. It is **fully open-source** — you are welcome to edit, extend and adapt it for your server.

**Please give credit when you use this work.**

If you run this script, redistribute it, include it in a server pack, or sell a product that uses it, we ask that you:

- **Credit YourMAPS / Tafé** (and link to this repository when possible)
- **Do not claim the script or included props as your own** — e.g. `prop_flag_ca`, `prop_flag_mx` and the free flag assets are part of this release
- **Mention the source** in your server credits, Tebex page, Discord or documentation

Open source does not mean anonymous, it means shared. Using free community resources in paid products without attribution hurts the people who maintain and improve them for everyone.

Contributions and improvements are encouraged: fork, PR, or share your changes so others can benefit.

---

**Tafé — YourMAPS**

Repository: [github.com/zetafe1/yourmaps_flagscript](https://github.com/zetafe1/yourmaps_flagscript)
