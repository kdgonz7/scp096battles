-- Gamemode Information
GM.Name = "SCP-096 Battles"
GM.Author = "Your Name"
GM.Email = "your.email@example.com"
GM.Website = "http://yourwebsite.com"

AddCSLuaFile()

pointsArenaForHuman = {
    {
        [0] = { -- Default loadout
            weapons = {"weapon_smg1"}, ammo = {["SMG1"] = 30},
            shield=0,
        },
        [5] = { -- 5 points
            weapons = {"weapon_pistol", "weapon_smg1"}, ammo = {["Pistol"] = 20, ["SMG1"] = 30},
            shield=25,
        },
        [10] = { -- 10 points
            weapons = {"weapon_pistol", "weapon_smg1", "weapon_shotgun"}, ammo = {["Pistol"] = 30, ["SMG1"] = 50, ["Buckshot"] = 10},
            shield=75,
        },
        [20] = { -- 20 points
            weapons = {"weapon_pistol", "weapon_smg1", "weapon_shotgun", "weapon_rpg"}, ammo = {["Pistol"] = 50, ["SMG1"] = 100, ["Buckshot"] = 20, ["RPG_Round"] = 2},
            shield=100,
        }
    }
}

pointsArenaForSCP096 = {
    {
        [0] = { -- 5 points
            health = 500,
        },
        [5] = { -- 5 points
            health = 650,
        },
    }
}

function GM:Initialize()
    -- Called when the gamemode is initialized
    print("SCP-096 Battles gamemode initialized!")
end

