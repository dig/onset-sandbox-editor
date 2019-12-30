local function Base_OnPlayerJoin(player)
  SetPlayerSpawnLocation(player, 125773.000000, 80246.000000, 1645.000000, 90.0)
end
AddEvent("OnPlayerJoin", Base_OnPlayerJoin)