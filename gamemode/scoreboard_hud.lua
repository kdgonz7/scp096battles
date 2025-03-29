-- scoreboard_hud.lua
-- Custom Scoreboard HUD for SCP096 Battles

surface.CreateFont("ScoreboardTitle", {
    font = "Arial",
    size = 36,
    weight = 700
})

surface.CreateFont("ScoreboardPlayer", {
    font = "Arial",
    size = 24,
    weight = 500
})

local function DrawScoreboard()
    if not input.IsKeyDown(KEY_TAB) then return end

    local scrW, scrH = ScrW(), ScrH()
    local boardWidth, boardHeight = scrW * 0.6, scrH * 0.5
    local boardX, boardY = (scrW - boardWidth) / 2, (scrH - boardHeight) / 2

    -- Background
    draw.RoundedBox(10, boardX, boardY, boardWidth, boardHeight, Color(50, 50, 50, 200))

    -- Title
    draw.SimpleText("SCP096 Battles - Scoreboard", "ScoreboardTitle", boardX + boardWidth / 2, boardY + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER)

    -- Team Scores
    draw.SimpleText("SCP-096 Team Points: " .. GetGlobalInt("SCP096Score", 0), "ScoreboardPlayer", boardX + 20, boardY + 60, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    draw.SimpleText("Human Team Points: " .. GetGlobalInt("HumansScore", 0), "ScoreboardPlayer", boardX + 20, boardY + 90, Color(255, 255, 255), TEXT_ALIGN_LEFT)

    -- Team Members
    local yOffset = 130
    draw.SimpleText("SCP-096 Team:", "ScoreboardPlayer", boardX + 20, boardY + yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    yOffset = yOffset + 30
    
    for _, ply in ipairs(player.GetAll()) do
        print(ply:Nick(), ply:Team())
        if ply:Team() == 1 then
            draw.SimpleText(ply:Nick(), "ScoreboardPlayer", boardX + 40, boardY + yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            yOffset = yOffset + 20
        end
    end

    yOffset = yOffset + 20
    draw.SimpleText("Human Team:", "ScoreboardPlayer", boardX + 20, boardY + yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    yOffset = yOffset + 30
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == 2 then
            draw.SimpleText(ply:Nick(), "ScoreboardPlayer", boardX + 40, boardY + yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            yOffset = yOffset + 20
        end
    end
end

hook.Add("HUDPaint", "DrawCustomScoreboard", DrawScoreboard)
hook.Add("ScoreboardShow", "DisableDefaultScoreboard", function()
    return false
end)