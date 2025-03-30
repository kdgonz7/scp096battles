--[[---------------------------------------------------------------------------
Improved Scoreboard HUD for SCP096 Battles
- Enhanced visuals, layout, and information display.
- Shows Kills, Deaths, and Ping for each player.
- Uses columns for better team organization.
---------------------------------------------------------------------------]]

-- Define Fonts (Consider using fonts available on most systems or custom fonts if your server distributes them)
surface.CreateFont("Scoreboard.Title", {
    font = "Roboto", -- Primary font choice
    extended = true,
    size = 32,
    weight = 700,
    antialias = true,
})

surface.CreateFont("Scoreboard.TeamName", {
    font = "Roboto",
    extended = true,
    size = 26,
    weight = 600,
    antialias = true,
})

surface.CreateFont("Scoreboard.HeaderText", {
    font = "Roboto Condensed", -- A slightly narrower font for headers
    extended = true,
    size = 18,
    weight = 500,
    antialias = true,
})

surface.CreateFont("Scoreboard.PlayerText", {
    font = "Roboto Condensed",
    extended = true,
    size = 16,
    weight = 400,
    antialias = true,
})

-- Define Colors
local COLORS = {
    BACKGROUND = Color(30, 30, 30, 220), -- Darker, semi-transparent background
    BORDER = Color(80, 80, 80, 200), -- Subtle border
    TITLE = Color(255, 255, 255, 255), -- White title
    TEAM_SCP_HEADER = Color(166, 58, 255), -- Reddish for SCP team
    TEAM_HUMAN_HEADER = Color(96, 48, 124), -- Bluish for Human team
    HEADER_TEXT = Color(220, 220, 220, 255), -- Light gray for column headers
    PLAYER_TEXT = Color(240, 240, 240, 255), -- Slightly off-white for player names
    ROW_EVEN = Color(45, 45, 45, 200), -- Slightly lighter row background
    ROW_ODD = Color(40, 40, 40, 200), -- Slightly darker row background (for alternating)
    DIVIDER = Color(60, 60, 60, 200), -- Divider line color
}

-- Scoreboard Dimensions & Padding
local PADDING = 15
local ROW_HEIGHT = 22
local HEADER_HEIGHT = 25
local TEAM_SCORE_HEIGHT = 35
local COLUMN_WIDTH_NAME = 0.5 -- Percentage of team section width
local COLUMN_WIDTH_KILLS = 0.15
local COLUMN_WIDTH_DEATHS = 0.15
local COLUMN_WIDTH_PING = 0.20 -- Remaining width

-- Helper function to draw text
local function DrawText(text, font, x, y, color, alignX, alignY)
    surface.SetFont(font)
    surface.SetTextColor(color)
    surface.SetTextPos(x, y)
    surface.DrawText(tostring(text)) -- Ensure text is a string
end

-- Helper function to draw aligned text (using draw.SimpleText for convenience)
local function DrawAlignedText(text, font, x, y, color, alignX, alignY)
    draw.SimpleText(tostring(text), font, x, y, color, alignX, alignY)
end

-- Main Scoreboard Drawing Function
local function DrawScoreboard()
    -- Only draw when TAB is held down
    if not input.IsKeyDown(KEY_TAB) then return end

    local scrW, scrH = ScrW(), ScrH()

    -- Define board dimensions (adjust percentages as needed)
    local boardWidth = scrW * 0.75 -- Wider board
    local boardHeight = scrH * 0.6 -- Slightly taller board
    local boardX = (scrW - boardWidth) / 2
    local boardY = (scrH - boardHeight) / 2

    -- 1. Draw Background and Border
    draw.RoundedBox(12, boardX, boardY, boardWidth, boardHeight, COLORS.BACKGROUND)
    surface.SetDrawColor(COLORS.BORDER)
    surface.DrawOutlinedRect(boardX, boardY, boardWidth, boardHeight, 2) -- Draw a 2px border

    -- 2. Draw Title
    local titleY = boardY + PADDING
    DrawAlignedText("SCP096 Battles - Scoreboard", "Scoreboard.Title", boardX + boardWidth / 2, titleY, COLORS.TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    local currentY = titleY + draw.GetFontHeight("Scoreboard.Title") + PADDING * 0.5

    -- 3. Draw Team Scores Area (Optional - could integrate into team headers)
    -- Example:
    -- local scpScore = GetGlobalInt("SCP096Score", 0)
    -- local humanScore = GetGlobalInt("HumansScore", 0)
    -- DrawAlignedText("Scores: SCP-096 [" .. scpScore .. "] vs Humans [" .. humanScore .. "]", "Scoreboard.TeamName", boardX + boardWidth / 2, currentY, COLORS.TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    -- currentY = currentY + draw.GetFontHeight("Scoreboard.TeamName") + PADDING

    -- 4. Define Team Sections
    local teamSectionWidth = (boardWidth - PADDING * 3) / 2 -- Width per team, allowing for padding between them
    local team1X = boardX + PADDING
    local team2X = team1X + teamSectionWidth + PADDING
    local playersYStart = currentY + PADDING -- Where the player list starts

    -- Function to draw a single team's section
    local function DrawTeamSection(teamID, teamName, headerColor, startX, startY, sectionWidth)
        local y = startY

        -- Team Header Background
        draw.RoundedBoxEx(8, startX, y, sectionWidth, TEAM_SCORE_HEIGHT, headerColor, true, true, false, false) -- Top corners rounded

        -- Team Name & Score
        local score = 0
        if teamID == 1 then -- Assuming Team 1 is SCP
            score = GetGlobalInt("SCP096Score", 0)
        elseif teamID == 2 then -- Assuming Team 2 is Humans
            score = GetGlobalInt("HumansScore", 0)
        end
        DrawAlignedText(teamName .. " - Score: " .. score, "Scoreboard.TeamName", startX + sectionWidth / 2, y + (TEAM_SCORE_HEIGHT / 2), COLORS.TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        y = y + TEAM_SCORE_HEIGHT

        -- Column Headers Background
        surface.SetDrawColor(Color(headerColor.r * 0.8, headerColor.g * 0.8, headerColor.b * 0.8, headerColor.a)) -- Darker shade for header bg
        surface.DrawRect(startX, y, sectionWidth, HEADER_HEIGHT)

        -- Column Headers Text
        local headerTextY = y + (HEADER_HEIGHT / 2)
        local currentX = startX + PADDING * 0.5
        DrawAlignedText("Player", "Scoreboard.HeaderText", currentX, headerTextY, COLORS.HEADER_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        currentX = startX + sectionWidth * COLUMN_WIDTH_NAME -- Position for Kills header
        DrawAlignedText("K", "Scoreboard.HeaderText", currentX + sectionWidth * COLUMN_WIDTH_KILLS * 0.5, headerTextY, COLORS.HEADER_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        currentX = currentX + sectionWidth * COLUMN_WIDTH_KILLS -- Position for Deaths header
        DrawAlignedText("D", "Scoreboard.HeaderText", currentX + sectionWidth * COLUMN_WIDTH_DEATHS * 0.5, headerTextY, COLORS.HEADER_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        currentX = currentX + sectionWidth * COLUMN_WIDTH_DEATHS -- Position for Ping header
        DrawAlignedText("Ping", "Scoreboard.HeaderText", currentX + sectionWidth * COLUMN_WIDTH_PING * 0.5, headerTextY, COLORS.HEADER_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        y = y + HEADER_HEIGHT

        -- Player Rows
        local playerCount = 0
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsValid() and ply:Team() == teamID then
                playerCount = playerCount + 1
                local rowColor = (playerCount % 2 == 1) and COLORS.ROW_ODD or COLORS.ROW_EVEN

                -- Draw row background
                surface.SetDrawColor(rowColor)
                surface.DrawRect(startX, y, sectionWidth, ROW_HEIGHT)

                -- Draw player data
                local playerTextY = y + (ROW_HEIGHT / 2)
                local playerX = startX + PADDING * 0.5

                -- Player Name (clipped if too long)
                surface.SetFont("Scoreboard.PlayerText")
                local nameW, _ = surface.GetTextSize(ply:Nick())
                local maxWidth = sectionWidth * COLUMN_WIDTH_NAME - PADDING -- Max width for name
                if nameW > maxWidth then
                    -- Simple clipping (GMod doesn't have built-in ellipsis easily)
                    local clippedName = ply:Nick()
                    while nameW > maxWidth and #clippedName > 0 do
                        clippedName = string.sub(clippedName, 1, -2) -- Remove last character
                        nameW, _ = surface.GetTextSize(clippedName .. "...")
                    end
                    DrawAlignedText(clippedName .. "...", "Scoreboard.PlayerText", playerX, playerTextY, COLORS.PLAYER_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                     DrawAlignedText(ply:Nick(), "Scoreboard.PlayerText", playerX, playerTextY, COLORS.PLAYER_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end


                -- Kills
                playerX = startX + sectionWidth * COLUMN_WIDTH_NAME
                DrawAlignedText(ply:Frags(), "Scoreboard.PlayerText", playerX + sectionWidth * COLUMN_WIDTH_KILLS * 0.5, playerTextY, COLORS.PLAYER_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Deaths
                playerX = playerX + sectionWidth * COLUMN_WIDTH_KILLS
                DrawAlignedText(ply:Deaths(), "Scoreboard.PlayerText", playerX + sectionWidth * COLUMN_WIDTH_DEATHS * 0.5, playerTextY, COLORS.PLAYER_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Ping
                playerX = playerX + sectionWidth * COLUMN_WIDTH_DEATHS
                DrawAlignedText(ply:Ping(), "Scoreboard.PlayerText", playerX + sectionWidth * COLUMN_WIDTH_PING * 0.5, playerTextY, COLORS.PLAYER_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                y = y + ROW_HEIGHT

                -- Draw thin divider line between players
                surface.SetDrawColor(COLORS.DIVIDER)
                surface.DrawRect(startX, y, sectionWidth, 1)
            end
        end

         -- Add a bottom border to the player list section
        surface.SetDrawColor(COLORS.BORDER)
        surface.DrawRect(startX, y, sectionWidth, 1)

    end

    -- 5. Draw the two team sections
    DrawTeamSection(1, "SCP-096 Team", COLORS.TEAM_SCP_HEADER, team1X, playersYStart, teamSectionWidth)
    DrawTeamSection(2, "Human Team", COLORS.TEAM_HUMAN_HEADER, team2X, playersYStart, teamSectionWidth)

end

-- Hook into HUDPaint to draw the scoreboard
hook.Add("HUDPaint", "DrawCustomScoreboard_Enhanced", DrawScoreboard)

-- Disable the default scoreboard
hook.Add("ScoreboardShow", "DisableDefaultScoreboard_Enhanced", function()
    return false -- Returning false prevents the default scoreboard from showing
end)

-- Optional: Clean up fonts when the script is removed (e.g., on gamemode change)
hook.Add("ShutDown", "RemoveScoreboardFonts_Enhanced", function()
    -- Note: GMod doesn't have a direct way to 'delete' fonts created with surface.CreateFont.
    -- They persist until the game closes or map changes. This is mostly a placeholder.
    print("[Scoreboard HUD] Shutting down.")
end)

print("[Scoreboard HUD] Enhanced scoreboard loaded.")
