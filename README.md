# YourMAPS FlagScript

A flag system for **RedM**, created to fill the gap in available scripts that allow players to equip and interact with flags as in-game items.

This system enables players to carry, drop, and pick up flags in an immersive and configurable way. 
It supports full integration with item-based frameworks, animations and prompts.

---

## Supported Frameworks

- ✅ **REDEMRP** 
- ✅ **VORP** 
- ✅ **OTHER** 

## Includes

4 yft flags: Mexico, Canada, Lgbtq, Trans

---
![imagem](https://github.com/user-attachments/assets/df41b58d-4426-4485-aaa7-026e5259950c)

## Key Features

- Carry Flags in Hand:
Players can equip and carry flags using immersive animations and prop attachments.

- Drop & Pick Up with Keybinds:
Easily drop flags on the ground or pick them up again using fully configurable keybinds.

- Client & Server-Side Logic:
Handles full animation flow, object attachment, drop/pickup distances, item checks, and cleanup logic.

- Optional Slash Commands & Item Requirements:
Works with REDEMRP, VORP, or any other framework. You can restrict flags to specific items or jobs if desired.

- Automatic Cleanup on Respawn:
Ensures flags are removed or reset when a player dies or respawns, preventing visual or logic issues.

- Only Mexico, Canada, LGBTQ, and Trans flags are included by default. 40+ Flags Preconfigured
including national, tribal, and in-game state flags not included on the free release.

- Support Available:
Join our community for help, updates, and suggestions regarding the flag system or other mapping support.

![imagem](https://github.com/user-attachments/assets/31dde33b-d76a-48bb-be80-94f0de7b60df)

---

Installation

    Place the resource:

Put the folder yourmaps_flags inside your RedM resources directory.

    Persistent flags (optional):

Execute `ym_flags_placed.sql` in your database. Requires `oxmysql`.
Set `Config.persistentFlags = true` in config.lua — placed flags survive restarts.

    Interaction modes (`config.lua`):

- `Config.placedInteraction` — ground flags: `drawtext`, `native` (RedM prompt, not jo_libs), `murphy_interact`, `blkb_interaction`, `pc_interaction`, `custom`
- `Config.equippedInteraction` — while holding: `keys`, `native`, `drawtext`
- See `client/interactions_custom.example.lua` for custom target integration

    Language (`config.lua` + `lang.lua`):

- `Config.LocaleLanguage = 'en'` — supported: `en`, `fr`, `pt`, `es`, `it`
- Override any string: `Config.Locale['persistent_place'] = 'Custom text'`

    Start the script:

Add this line to your server.cfg:

 ensure yourmaps_flags

    Configure the script:

Open config.lua and adjust the settings, keybinds, language translation and flags to your preference.

    Create the flag items:

This script uses inventory items to spawn flags.

**You must create the flag items in your inventory system**, using either:

    Your framework's item registration method, OR

    Directly inserting them into your database via SQL.

    ⚠️ Note: All usable flag items are already listed inside config.lua and on SQL file for easy copy/paste into your item database.

After that, restart your server and enjoy! 

---

![imagem](https://github.com/user-attachments/assets/27960af6-3c6b-42e5-9230-5e153ca96f91)


This script was developed due to the lack of standalone flag systems available for RedM.

It is a fully open-source. Feel free to edit, expand, or adapt the code to fit your server's needs.
If you add new features or improvements, we encourage you to share them with the community so others can benefit too!

---

**Tafé - YourMAPS**   

