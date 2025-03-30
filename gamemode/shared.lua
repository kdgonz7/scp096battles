-- Gamemode Information
GM.Name = "SCP-096 Battles"
GM.Author = "Kai"
GM.Email = "gkai@example.com"
GM.Website = "N/A"

TEAM_SCP_096 = 1
TEAM_NTF = 2

AddCSLuaFile()

pointsArenaForHuman = {
    {
        [0] = { -- Default loadout
            weapons = {"m9k_smgp90"}, ammo = {["SMG1"] = 30},
            shield=0,
        },
        [5] = { -- 5 points
            weapons = {"m9k_colt1911", "m9k_magpulpdr"}, ammo = {["Pistol"] = 20, ["SMG1"] = 30},
            shield=25,
        },
        [10] = { -- 10 points
            weapons = {"m9k_colt1911", "m9k_vector", "m9k_m3"}, ammo = {["Pistol"] = 30, ["SMG1"] = 50, ["Buckshot"] = 10},
            shield=75,
        },
        [20] = { -- 20 points
            weapons = {"m9k_coltpython", "m9k_honeybadger", "m9k_usas", "m9k_minigun"}, ammo = {["Pistol"] = 80, ["SMG1"] = 500, ["Buckshot"] = 75, ["RPG_Round"] = 2, ["AR2"] = 800,},
            shield=100,
        }
    }
}

pointsArenaForSCP096 = {
    {
        [0] = { -- 5 points
            health = 1500,
        },
        [5] = { -- 5 points
            health = 2000,
        },
    }
}

function GM:Initialize()
    -- Called when the gamemode is initialized
    print("SCP-096 Battles gamemode initialized!")
end

