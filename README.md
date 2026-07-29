
## Config beállítások

| Beállítás | Alap | Leírás |
|-----------|------|--------|
| `AFKTimeout` | 60 | Másodperc állás után AFK |
| `KickAfter` | 180 | Másodperc AFK után kick (3 perc) |
| `MoveThreshold` | 0.5 | Elmozdulás határ (méter) |
| `AFKAlpha` | 140 | Átlátszóság (0–255) |
| `ShowCountdown` | true | Visszaszámláló a képernyőn |
| `CountdownOnlyBelow` | 15 | Csak utolsó X mp-ben mutassa |
| `UseImage` | true | YTD kép a fej fölött |
| `Image.dict` | "afk" | YTD fájlnév (afk.ytd) |
| `Image.name` | "afk" | Textúra neve a YTD-n belül |
| `ShowText` | true | AFK szöveg + perc |
| `KickReason` | ... | Kick indok |
| `ChatMessage` | ... | Chat üzenet (`%s` = név) |

## YTD készítés (OpenIV)

1. OpenIV → Edit Mode
2. New → Texture dictionary (.ytd) → `afk`
3. Import → `afk.png`
4. Textúra neve: `afk` (kisbetű)
5. Mentés → másold `stream/afk.ytd`-be

PNG ajánlott méret: 128x128 vagy 256x256 (power of 2).
Átlátszósághoz DXT5 formátum.

## Hibakeresés

- **Fehér téglalap:** a `Image.name` nem egyezik a YTD-n belüli textúra névvel
- **Nincs kép:** `stream/afk.ytd` hiányzik, vagy `dict` név rossz
- **F8:** `[afk_system] YTD betöltve: afk` = sikeres

## Verzió

2.0.0
