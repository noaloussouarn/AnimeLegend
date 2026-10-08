# Anime Legend — Server Code Foundation

This folder is the server/shared-code foundation for the Roblox game Anime Legend.

## Intended placement
- `ServerScriptService/AnimeLegend` -> ServerScriptService
- `ServerStorage/AnimeLegend` -> ServerStorage
- `ReplicatedStorage/AnimeLegend` -> ReplicatedStorage

The code is intentionally data-driven:
- zones, mobs, titles, champions, banners, bosses, swords, quests, powers and specials live in config/data modules
- services validate all rewards and progression on the server
- World 2+ can be added through data without rewriting the core systems

## Important
This is the server foundation, not the final 3D asset pack or client UI.
The framework exposes clean server APIs for a future client layer.

## Bootstrap
Run `ServerScriptService/AnimeLegend/Bootstrap/ServerMain.server.lua`.
