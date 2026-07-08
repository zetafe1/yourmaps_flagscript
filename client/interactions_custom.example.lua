--[[
  EXAMPLE — custom integration (yourmaps_flagscript)

  1) Copy this file to client/interactions_custom.lua
  2) Add to fxmanifest.lua (after interactions.lua):
       'client/interactions_custom.lua',

  3) In config.lua:
       Config.placedInteraction = 'custom'

  Available events:
    yourmaps_flags:custom:placedSpawned  — persistent flag spawned in the world
    yourmaps_flags:custom:placedDespawned — flag removed

  Exports (from another resource):
    exports.yourmaps_flagscript:PickupPlacedFlag(flagId)
]]

AddEventHandler('yourmaps_flags:custom:placedSpawned', function(ctx)
    -- ctx.id, ctx.coords, ctx.data, ctx.pickup()
    print(('[flags custom] spawn id=%s'):format(ctx.id))

    -- Example: register with your own target / menu
    -- ctx.pickup() triggers the official server pickup
end)

AddEventHandler('yourmaps_flags:custom:placedDespawned', function(flagId)
    print(('[flags custom] despawn id=%s'):format(flagId))
end)
