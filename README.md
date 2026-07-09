# YourMAPS FlagScript

A flag system for **RedM**: equip, drop, pick up and **place** flags in the world with animations, native prompts, database persistence and a built-in **3D gizmo** for precise placement.

**Demo video (gizmo placement + persistence):**  
https://youtu.be/Ka2wxT5ej3A

---

## What's new

### Persistence across restarts

Placed flags **stay in the world** after a resource or full server restart.

- Position (`x`, `y`, `z`) and rotation (`heading`) saved to MySQL (`ym_flags_placed`)
- On join, flags are respawned automatically for all players
- Configurable per-character limit (`Config.persistentMaxPerPlayer`)
- Optional owner-only pickup (`Config.persistentOwnerOnly`)
- Optional consume item on place / return item on pickup

### 3D placement gizmo

Visual placement with a gizmo **built into flagscript**: **no** `jo_libs` or `object_gizmo` required.

- Move and rotate the flag on all three axes (pitch, roll, yaw)
- Camera locked on the flag; orbit with arrow keys
- Native RedM prompts (confirm, cancel, snap to ground, camera speed)
- Player ped blocked during gizmo (no crouch, hands up, movement, etc.)
- Gizmo strings in `lang.lua` (`en`, `fr`, `pt`, `es`, `it`)

---

## Supported frameworks

- **VORP**
- **REDEMRP**
- **OTHER** (generic identifier fallback)

---

## Dependencies

| Dependency | Required | Purpose |
|------------|----------|---------|
| **oxmysql** | Yes (with persistence) | Store placed flags |
| YourMAPS streaming packs | No | Extra props (gang, noble, clan, cult) |

```cfg
ensure oxmysql
ensure yourmaps_gang_flags      # optional - before flagscript
ensure yourmaps_noble_flags     # optional
ensure yourmaps_clan_flags      # optional
ensure yourmaps_cult_flags      # optional
ensure yourmaps_flagscript
```

---

## Quick installation

### 1. Resource

Place `yourmaps_flagscript` in your resources folder.

### 2. Inventory items

Run on your database:

- `flag_items_vorp.sql`: VORP
- `flag_items_redemrp.sql`: REDEMRP

Optional packs include their own SQL (`yourmaps_*_flags/flag_items_vorp.sql`).

### 3. Persistence (recommended)

1. Run **`ym_flags_placed.sql`** on your database
2. In `config.lua`:

```lua
Config.persistentFlags = true
Config.persistentMaxPerPlayer = 15
Config.persistentOwnerOnly = true
Config.persistentConsumeOnPlace = true
Config.persistentReturnItemOnPickup = true
```

3. Restart the server

### 4. Placement gizmo

In `config.lua`:

```lua
Config.placementMode = true
Config.placementMaxDist = 3.0          -- flag: max distance from initial position
Config.placementJoMaxCamDist = 45.0    -- camera: orbit around the flag
Config.placementJoMoveSpeed = 0.05     -- default camera speed (x0.050)
Config.placementAllowSnapToGround = true
```

### 5. Language & interaction

```lua
Config.LocaleLanguage = 'en'   -- en, fr, pt, es, it

Config.placedInteraction = 'native'    -- ground flag: drawtext | native | blkb_interaction | ...
Config.equippedInteraction = 'native'    -- equipped: keys | native | drawtext
```

---

## Persistence: how it works

### Player flow

1. Use the flag item from inventory (equips the flag)
2. Native prompt: **place flag**
3. **Gizmo** opens: adjust position and rotation
4. **Confirm**: flag stays in the world; server writes to the database
5. Other players see the flag; after restart it remains in place
6. Owner (if `persistentOwnerOnly`) approaches and **picks up**: item returns to inventory (if configured)

### Table `ym_flags_placed`

| Column | Description |
|--------|-------------|
| `char_id` | Owner character (VORP `charIdentifier`) |
| `flag_type` | Internal type (`american`, `gang01`, `bloodmoon`, ...) |
| `item_name` | Inventory item name |
| `x`, `y`, `z` | World position |
| `heading` | Rotation (yaw) |

### `config.lua` options

| Option | Description |
|--------|-------------|
| `persistentFlags` | Enable/disable persistence |
| `persistentMaxPerPlayer` | Max placed flags per character |
| `persistentOwnerOnly` | Only owner can pick up |
| `persistentConsumeOnPlace` | Remove item when placed |
| `persistentReturnItemOnPickup` | Return item when picked up |
| `persistentPickupDist` | Distance to pick up |
| `persistentDisplayDist` | Distance to show prompt |

### Sync

- **Server**: `server/persistence.lua` - insert/delete in DB, sync to all clients
- **Client**: `client/client.lua` - spawn world flags, pickup, cleanup

---

## Placement gizmo: controls

While the gizmo is active the **player ped is blocked** (movement, crouch, hands up, attack, etc.).

| Action | Key / control |
|--------|----------------|
| Move gizmo (axes) | Drag on screen / 3D handles |
| Toggle move / rotate | `R` (reload) |
| Confirm | `Enter` |
| Cancel | Secondary Tab |
| Snap to ground | `E` (snap Z to ground) |
| Move camera | Arrow keys (scripted fly) |
| Camera up / down | Prompt keys |
| Camera speed | Weapon scroll / prompts |

The camera stays **locked on the flag** (no free-look mode).

### Export for other resources

```lua
exports.yourmaps_flagscript:IsGizmoActive()  -- true while gizmo is open
-- or LocalPlayer.state.yourmaps_flagscript_gizmo
```

---

## YourMAPS flag packs

Items and `prop_map` entries are included in `config.lua` for:

| Pack | Items | Theme |
|------|-------|--------|
| `yourmaps_gang_flags` | `flaggang01` ... `flaggang12` | Outlaw / gang banners |
| `yourmaps_noble_flags` | `flagblackwood` ... `flagvarmont` | Heraldic noble houses |
| `yourmaps_clan_flags` | `flagbloodmoon` ... `flagcoldcauldron` | Occult / witch clans |
| `yourmaps_cult_flags` | `flagprofaneeye` ... `flagbloodchalice` | Dark cult / ritual banners |

Each pack needs `ensure` in `server.cfg` **before** flagscript and its item SQL.

---

## Included in the free release

**4 props** in `stream/`: Mexico, Canada, LGBTQ, Trans.

**40+ items** (national, tribal, in-game state flags, etc.) preconfigured in `config.lua`: props for those flags are **not** included in this free release. Use `yourmaps_flags` or your own streaming packs.

---

## In-game test

```
/additem canadianflag 1
/additem flaggang01 1
/additem flagbloodmoon 1
/additem flagprofaneeye 1
```

1. Use the item: equips the flag  
2. Place with the gizmo: confirm  
3. `restart yourmaps_flagscript`: the flag should remain in place  

See also: https://youtu.be/Ka2wxT5ej3A

---

## Open source & attribution

This script is **fully open-source**: you are welcome to edit, extend and adapt it for your server.

**Please give credit when you use this work:**

- **YourMAPS / Tafé** (link to this repository when possible)
- **Do not claim the script or included props as your own**
- **Mention the source** in server credits, Tebex page, Discord or documentation

Open source does not mean anonymous: it means shared. Contributions are encouraged: fork, PR, or share your improvements.

---

**Tafé - YourMAPS**

Repository: [github.com/zetafe1/yourmaps_flagscript](https://github.com/zetafe1/yourmaps_flagscript)
