util.AddNetworkString("BuyPointsItemSCP")
util.AddNetworkString("BuyPointsItemHuman")

AddCSLuaFile("shared.lua")
include("shared.lua")

hook.Add("PlayerInitialSpawn", "CheckSinglePlayer", function(ply)
    if #player.GetAll() == 1 then
        timer.Simple(0.7, function()
            if IsValid(ply) then
                ply:SendLua([[Derma_Message("This game is not meant for singleplayer.", "Warning", "OK")]])
            end
        end)
    end
end)


gameInfo = {
    Started = false,
    LastWinner = nil,
    SCP096Health = pointsArenaForSCP096[1][0].health,
    HumanLoadout = pointsArenaForHuman[1][0].weapons,
    HumanAmmo = pointsArenaForHuman[1][0].ammo,
    HumanShield = pointsArenaForHuman[1][0].shield,
    SCP096Level = 0,
    HumanLevel = 0,
}

SetGlobalInt("SCP096Score", 0)
SetGlobalInt("HumansScore", 0)

SetGlobalEntity("PlayerWhoSCP", nil)
SetGlobalEntity("PlayerWhoHuman", nil)

function GM:Initialize()
    print("[SCP-096 Battles] Gamemode initializing...")

    -- Set up teams
    team.SetUp(TEAM_SCP_096, "SCP-096", Color(255, 0, 0))
    team.SetUp(TEAM_NTF, "NTF", Color(0, 0, 255))
end

hook.Add("PlayerInitialSpawn", "SetupPlayerPoints", function(ply)
    ply:SetNWInt("Points", 0)
end)

hook.Add("PlayerSpawn", "SetPlayerModelSCP096", function(ply)
    timer.Simple(0.8, function()
        ply:SetWalkSpeed(200) -- Reset walk speed to default
        ply:SetRunSpeed(400) -- Reset run speed to default

        if not GetGlobalBool("GameStarted", false) then
            ply:StripWeapons()
            ply:StripAmmo()
            ply:Spectate(OBS_MODE_ROAMING)
            ply:SendLua("OpenPregamePanel()")
        else
            ply:UnSpectate()

            if ply:Team() == TEAM_SCP_096 then
                ply:SetModel("models/player/scp096.mdl") -- Replace with SCP-096 model path
                ply:SetHealth(gameInfo.SCP096Health) -- Give SCp096 cur health
                ply:SetModelScale(1.5, 0) -- Make the player model bigger
                ply:Give("fists_of_096")
            elseif ply:Team() == TEAM_NTF then
                ply:SetModel("models/player/combine_soldier.mdl")
                for _, weapon in ipairs(gameInfo.HumanLoadout) do
                    ply:Give(weapon)
                end

                if gameInfo.HumanAmmo then
                    for ammoType, ammoAmount in pairs(gameInfo.HumanAmmo) do
                        ply:GiveAmmo(ammoAmount, ammoType, true)
                    end
                end

                if gameInfo.HumanShield > 0 then
                    ply:SetArmor(gameInfo.HumanShield)
                end
            end
        end
    end)
end)

hook.Add("PlayerDeath", "CheckSCP096Death", function(victim, inflictor, attacker)
    -- Stop any sounds when a player dies
    timer.Simple(0.1, function()
        if IsValid(victim) then
            victim:SendLua("RunConsoleCommand('stopsound')")
        end
        if IsValid(attacker) and attacker:IsPlayer() then
            attacker:SendLua("RunConsoleCommand('stopsound')")
        end
    end)


    if victim:Team() == TEAM_SCP_096 then
        PrintMessage(HUD_PRINTCENTER, "Humans Win!")
        SetGlobalBool("GameStarted", false)

        for _, ply in ipairs(player.GetAll()) do
            ply:KillSilent()
            ply:Spawn()
            ply:StripWeapons()
            ply:Spectate(OBS_MODE_ROAMING)
        end

        gameInfo.Started = false
        gameInfo.LastWinner = TEAM_NTF

        SetGlobalInt("HumansScore", GetGlobalInt("HumansScore") + 1)

        print("[SCP-096 Battles] Game has ended. Humans win!")
        print("[SCP-096 Battles] Humans Points: " .. GetGlobalInt("HumansScore"))
    elseif victim:Team() == TEAM_NTF then
        PrintMessage(HUD_PRINTCENTER, "SCP-096 Wins!")

        SetGlobalBool("GameStarted", false)

        for _, ply in ipairs(player.GetAll()) do
            ply:Spawn()
            ply:StripWeapons()
            ply:Spectate(OBS_MODE_ROAMING)
        end

        gameInfo.Started = false
        gameInfo.LastWinner = TEAM_SCP_096
        SetGlobalInt("SCP096Score", GetGlobalInt("SCP096Score") + 1)

        print("[SCP-096 Battles] Game has ended. SCP-096 wins!")
        print("[SCP-096 Battles] SCP-096 Points: " .. GetGlobalInt("SCP096Score"))
    end
end)

-- [[[ CON COMMANDS ]]]
concommand.Add("scp096_begin_game", function(ply, cmd, args)
    if not ply:IsAdmin() then return end

    if #player.GetAll() < 2 then
        ply:ChatPrint("Not enough players to start the game!")
        return
    end

    SetGlobalBool("GameStarted", true)

    local scp096 = GetGlobalEntity("PlayerWhoSCP")
    local human = GetGlobalEntity("PlayerWhoHuman")

    if not IsValid(scp096) or not IsValid(human) then
        local players = player.GetAll()
        table.Shuffle(players)

        scp096 = players[1]
        SetGlobalEntity("PlayerWhoSCP", scp096)

        for i = 2, #players do
            if not IsValid(human) then
                human = players[i]
                SetGlobalEntity("PlayerWhoHuman", human)
            end
        end

        if IsValid(scp096) then
            scp096:SetNWInt("SCPOrHuman", 1)
        end

        if IsValid(human) then
            human:SetNWInt("SCPOrHuman", 2)
        end

        PrintMessage(HUD_PRINTTALK, "Arranged teams!")
    end

    if IsValid(scp096) then
        scp096:SetTeam(TEAM_SCP_096)
    end

    if IsValid(human) then
        human:SetTeam(TEAM_NTF)
    end

    for _, v in ipairs(player.GetAll()) do
        v:UnSpectate()
        v:Spawn()
    end

    gameInfo.Started = true

    print("[SCP-096 Battles] Game has started!")
end)

concommand.Add("scp096_swap_teams", function(ply, cmd, args)
    if not ply:IsAdmin() then return end

    local scp096 = GetGlobalEntity("PlayerWhoSCP")
    local human = GetGlobalEntity("PlayerWhoHuman")

    if not IsValid(scp096) or not IsValid(human) then
        ply:ChatPrint("Teams are not properly set up!")
        return
    end

    -- Swap teams
    scp096:SetTeam(TEAM_NTF)
    human:SetTeam(TEAM_SCP_096)

    -- Update global entities
    SetGlobalEntity("PlayerWhoSCP", human)
    SetGlobalEntity("PlayerWhoHuman", scp096)

    -- Respawn players to apply changes
    for _, v in ipairs(player.GetAll()) do
        v:UnSpectate()
        v:Spawn()
    end

    PrintMessage(HUD_PRINTTALK, "Teams have been swapped!")
    print("[SCP-096 Battles] Teams swapped successfully.")
end)

-- [[[ NET ]]]
net.Receive("BuyPointsItemSCP", function(len, ply)
    if ply:Team() ~= TEAM_SCP_096 then return end
    local itemID = net.ReadInt(32)
    local item = pointsArenaForSCP096[1][itemID]
    print(itemID)

    if not item then return end

    local playerPoints = GetGlobalInt("SCP096Score")

    if gameInfo.SCP096Level >= itemID then
        ply:ChatPrint("You already own this or a higher-level item!")
        return
    end

    if playerPoints >= itemID then
        SetGlobalInt("SCP096Score", playerPoints - itemID)
        
        gameInfo.SCP096Health = item.health

        ply:SetHealth(gameInfo.SCP096Health)
        ply:ChatPrint("You purchased: " .. itemID .. "-point health!")

        gameInfo.SCP096Level = itemID
        SetGlobalInt("SCP096Level", gameInfo.SCP096Level)
    else
        ply:ChatPrint("Not enough points to purchase this item!")
    end
end)

net.Receive("BuyPointsItemHuman", function(len, ply)
    if ply:Team() ~= TEAM_NTF then return end

    local itemID = net.ReadInt(32)
    local item = pointsArenaForHuman[1][itemID]

    if not item then return end

    local playerPoints = GetGlobalInt("HumansScore")

    if gameInfo.HumanLevel >= itemID then
        ply:ChatPrint("You already own this or a higher-level item!")
        return
    end

    if playerPoints >= itemID then
        SetGlobalInt("HumansScore", playerPoints - itemID)
        
        gameInfo.HumanLoadout = item.weapons or gameInfo.HumanLoadout
        gameInfo.HumanAmmo = item.ammo or gameInfo.HumanAmmo
        gameInfo.HumanShield = math.min(gameInfo.HumanShield + item.shield, 100)

        gameInfo.HumanLevel = itemID or gameInfo.HumanLevel
        SetGlobalInt("HumanLevel", gameInfo.HumanLevel)
        
        ply:ChatPrint("You purchased: " .. itemID .. "-point item!")
    else
        ply:ChatPrint("Not enough points to purchase this item!")
    end
end)

local welcomeMessage = {
    "============================================",
    "Welcome to SCP-096 Battles!",
    "============================================",
    "Objective:",
    "- SCP-096 Team: Eliminate all humans to win.",
    "- Human Team: Survive and defeat SCP-096 to win.",
    "",
    "Commands:",
    "- !pregame or open_pregame_menu: Opens the pregame menu with options for points shop and scoreboard.",
    "- !pointsshop or open_points_shop: Opens the points shop to purchase upgrades for your team.",
    "- !scoreboard or open_scp_scores: Opens the scoreboard to view current team scores.",
    "- !help or open_help: Opens the help menu with detailed information about the game.",
    "",
    "Tips:",
    "- Use your points wisely to gain an advantage.",
    "- SCP-096 is powerful but can be defeated with teamwork.",
    "- Humans should use their weapons and shields strategically.",
    "",
    "Have fun and good luck!",
    "============================================"
}

timer.Create("WelcomemessageLines", 0.1, #welcomeMessage, function()
    local line = welcomeMessage[#welcomeMessage - timer.RepsLeft("WelcomemessageLines") + 1]
    if line then
        PrintMessage(HUD_PRINTTALK, line)
    end
end)
