import minestat

ms = minestat.MineStat('serverip', 25565)
if ms.online:
    print(str(ms.current_players))
else:
    print("0")
