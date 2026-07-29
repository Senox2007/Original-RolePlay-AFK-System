Config = {}

-- Másodperc amíg egy helyben kell állni, mielőtt AFK-nak számít (60 = 1 perc)
Config.AFKTimeout = 60

-- Másodperc AFK után kick (180 = 3 perc)
Config.KickAfter = 180

-- Mekkora elmozdulás (méter) számít még "állásnak"
Config.MoveThreshold = 0.5

-- Karakter átlátszósága AFK közben (0 = láthatatlan, 255 = teljesen látható)
Config.AFKAlpha = 140

-- Képernyőn megjelenő visszaszámláló AFK előtt
Config.ShowCountdown = true
-- Csak ha ennyi mp alatt van hátra (0 = mindig mutassa)
Config.CountdownOnlyBelow = 15

-- F8 konzol log
Config.LogToConsole = true
Config.LogInterval = 5

-- YTD kép a fej fölött (dict = fájlnév stream/afk.ytd, name = textúra neve a YTD-n belül)
Config.UseImage = true
Config.Image = {
    dict = "afk",
    name = "afk",
    width = 0.08,
    height = 0.08,
    offsetZ = 0.45,
}

-- Szöveg a kép alatt (mások is látják)
Config.ShowText = true
Config.Text = {
    label = "AFK",
    showMinutes = true,
    scale = 0.40,
    color = { r = 255, g = 50, b = 50, a = 255 },
    font = 4,
    outline = true,
    offsetZ = 0.25,
}

-- Kick indok amit a játékos lát
Config.KickReason = "AFK - Túl sokáig voltál inaktív"

-- Chat üzenet mindenkinek (%s = játékos neve)
Config.ChatMessage = "Original - AFK System %s játékos kickelve lett afk indokkal"