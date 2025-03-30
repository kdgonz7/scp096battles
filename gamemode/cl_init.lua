-- cl_init.lua
-- Client-side initialization file for SCP-096 Battles gamemode

include("shared.lua")
include("scoreboard_hud.lua")

local colors = {
    background = Color(35, 35, 50, 230),
    header = Color(25, 25, 40, 255),
    scp = Color(255, 100, 100),
    human = Color(100, 150, 255),
    button = Color(60, 60, 80, 255),
    buttonHover = Color(80, 80, 100, 255),
    textNormal = Color(220, 220, 220),
    accent = Color(150, 120, 200),
    commandBg = Color(45, 45, 60, 200)
}

function GM:Initialize()
    print("SCP-096 Battles client initialized.")
end

-- Basic HUD Paint function
function GM:HUDPaint()
    draw.SimpleText("SCP-096 Battles", "Trebuchet24", ScrW() / 2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end

-- Function to create the Scoreboard panel
function CreateScoreboard()
    -- Define scores (Fetch dynamically)
    local SCP096Score = GetGlobalInt("SCP096Score", 0)
    local HumanScore = GetGlobalInt("HumansScore", 0)

    local frame = vgui.Create("DFrame")
    frame:SetTitle("") -- No default title bar text
    frame:SetSize(500, 300)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)

    -- Custom paint function for the frame using the shared color scheme
    frame.Paint = function(self, w, h)
        -- Main background with rounded corners
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        -- Header bar
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        -- Bottom border accent
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        -- Title text with shadow for better readability
        draw.SimpleText("Scoreboard", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT) -- Shadow
        draw.SimpleText("Scoreboard", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT) -- Actual text
    end

    -- Panel to contain the scores
    local scorePanel = vgui.Create("DPanel", frame)
    scorePanel:SetPos(25, 50)
    scorePanel:SetSize(450, 160)
    scorePanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 60, 200)) -- Slightly different background for contrast
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1) -- Accent outline
    end

    -- Title label for the score section
    local titleLabel = vgui.Create("DLabel", scorePanel)
    titleLabel:SetPos(0, 15) -- Centered horizontally, positioned vertically
    titleLabel:SetSize(450, 30)
    titleLabel:SetText("TEAM SCORES")
    titleLabel:SetFont("DermaLarge")
    titleLabel:SetTextColor(colors.accent)
    titleLabel:SetContentAlignment(5) -- Center alignment

    -- Label for SCP-096 score
    local scpLabel = vgui.Create("DLabel", scorePanel)
    scpLabel:SetPos(20, 60)
    scpLabel:SetSize(410, 30)
    scpLabel:SetText("SCP-096 Team Points: " .. tostring(SCP096Score))
    scpLabel:SetFont("Trebuchet24")
    scpLabel:SetTextColor(colors.scp)

    -- Label for Human score
    local humanLabel = vgui.Create("DLabel", scorePanel)
    humanLabel:SetPos(20, 100)
    humanLabel:SetSize(410, 30)
    humanLabel:SetText("Human Team Points: " .. tostring(HumanScore))
    humanLabel:SetFont("Trebuchet24")
    humanLabel:SetTextColor(colors.human)

    -- Close button
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("CLOSE")
    closeButton:SetFont("DermaDefaultBold")
    closeButton:SetTextColor(colors.textNormal)
    closeButton:SetSize(120, 40)
    closeButton:SetPos(frame:GetWide() / 2 - 60, 230) -- Centered horizontally
    closeButton.DoClick = function()
        frame:Close() -- Close the frame when clicked
    end

    -- Custom paint for the close button
    closeButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then -- Subtle highlight on hover
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1) -- Accent outline
    end

    -- Example of how you might update points (needs network message handling)
    -- This function would need to be called when scores change server-side
    function UpdatePoints(scpPoints, humanPoints)
        if IsValid(scpLabel) and IsValid(humanLabel) then -- Check if labels still exist
             scpLabel:SetText("SCP-096 Team Points: " .. scpPoints)
             humanLabel:SetText("Human Team Points: " .. humanPoints)
        end
    end
    -- You would likely use a net message receiver to call UpdatePoints
    -- net.Receive("UpdateScores", function()
    --     local scp = net.ReadInt(32)
    --     local human = net.ReadInt(32)
    --     UpdatePoints(scp, human)
    -- end)
end

-- Function to open the Points Shop panel
function OpenPointsShop(pointsArena)
    if not pointsArena or not pointsArena[1] then
        print("Error: Invalid pointsArena data provided to OpenPointsShop.")
        chat.AddText(colors.scp, "[Shop Error] ", colors.textNormal, "Could not load shop items.")
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)

    -- Custom paint function using shared colors
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        draw.SimpleText("Points Shop", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT)
        draw.SimpleText("Points Shop", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT)
    end

    -- Scroll panel for shop items
    local shopPanel = vgui.Create("DScrollPanel", frame)
    shopPanel:SetPos(25, 50)
    shopPanel:SetSize(450, 300)

    -- Iterate through the points arena data (using SortedPairs for consistent order)
    for points, data in SortedPairs(pointsArena[1]) do
        local itemPanel = vgui.Create("DPanel", shopPanel)
        itemPanel:SetSize(430, 90) -- Adjusted size for better spacing
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(0, 0, 0, 10) -- Margin between items
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, colors.commandBg) -- Use commandBg for item background
            surface.SetDrawColor(colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        -- Label showing the cost
        local titleLabel = vgui.Create("DLabel", itemPanel)
        titleLabel:SetPos(10, 10)
        titleLabel:SetSize(300, 20)
        titleLabel:SetText("Unlock for " .. points .. " Points")
        titleLabel:SetFont("DermaDefaultBold") -- Make cost stand out
        titleLabel:SetTextColor(colors.accent)

        -- Label showing item details (health or weapons)
        local infoLabel = vgui.Create("DLabel", itemPanel)
        infoLabel:SetPos(10, 35) -- Position below cost
        infoLabel:SetSize(320, 45) -- Allow more space for wrapping
        infoLabel:SetWrap(true)
        infoLabel:SetFont("DermaDefault")
        infoLabel:SetTextColor(colors.textNormal)

        -- Determine what info to show based on player's team
        local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
        if SCPOrHuman == 1 then -- SCP-096 Team
            infoLabel:SetText("Health Bonus: +" .. (data.health or "N/A"))
        else -- Human Team
            local weaponsList = data.weapons and table.concat(data.weapons, ", ") or "None"
            infoLabel:SetText("Weapons: " .. weaponsList)
        end

        -- Buy button for the item
        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetText("BUY")
        buyButton:SetFont("DermaDefaultBold")
        buyButton:SetTextColor(colors.textNormal)
        buyButton:SetSize(80, 30)
        buyButton:SetPos(340, 30) -- Positioned to the right
        buyButton.DoClick = function()
            -- Send network message to server to handle purchase
            local netMsgName = (SCPOrHuman == 1) and "BuyPointsItemSCP" or "BuyPointsItemHuman"
            net.Start(netMsgName)
            net.WriteInt(points, 32) -- Send the cost (as identifier)
            net.SendToServer()
            print("Attempting to buy item for " .. points .. " points as " .. (SCPOrHuman == 1 and "SCP" or "Human"))
            -- Optional: Close shop after purchase or provide feedback
            -- frame:Close()
        end

        -- Custom paint for the buy button
        buyButton.Paint = function(self, w, h)
            local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
            draw.RoundedBox(4, 0, 0, w, h, buttonColor)
            if self:IsHovered() then
                draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
            end
            surface.SetDrawColor(colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end
end

-- Function to open the Pregame menu panel
function OpenPregamePanel()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(400, 240) -- Default size
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)

    -- Custom paint function
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        draw.SimpleText("Pregame Menu", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT)
        draw.SimpleText("Pregame Menu", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT)
    end

    -- Message shown when the panel is closed via the 'X' button
    frame.OnClose = function()
        chat.AddText(colors.textNormal, "Pregame menu closed. Use ", colors.accent, "!pregame", colors.textNormal, " or ", colors.accent, "open_pregame_menu", colors.textNormal, " to open it again.")
    end

    -- Button to open the Points Shop
    local pointsShopButton = vgui.Create("DButton", frame)
    pointsShopButton:SetText("Open Points Shop")
    pointsShopButton:SetFont("DermaDefaultBold")
    pointsShopButton:SetTextColor(colors.textNormal)
    pointsShopButton:SetSize(200, 40)
    pointsShopButton:SetPos(frame:GetWide() / 2 - 100, 50) -- Centered
    pointsShopButton.DoClick = function()
        local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
        local arenaData = (SCPOrHuman == 1) and pointsArenaForSCP096 or pointsArenaForHuman
        if arenaData then
             OpenPointsShop(arenaData)
             frame:Close() -- Close pregame menu when opening shop
        else
             chat.AddText(colors.scp, "[Error] ", colors.textNormal, "Shop data not available.")
        end
    end

    -- Custom paint for the button
    pointsShopButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    -- Button to open the Scoreboard
    local scoreboardButton = vgui.Create("DButton", frame)
    scoreboardButton:SetText("Open Scoreboard")
    scoreboardButton:SetFont("DermaDefaultBold")
    scoreboardButton:SetTextColor(colors.textNormal)
    scoreboardButton:SetSize(200, 40)
    scoreboardButton:SetPos(frame:GetWide() / 2 - 100, 110) -- Centered, below shop button
    scoreboardButton.DoClick = function()
        CreateScoreboard()
        frame:Close() -- Close pregame menu when opening scoreboard
    end

    -- Custom paint for the button
    scoreboardButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    -- Admin-only button to start the game
    if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
        local startGameButton = vgui.Create("DButton", frame)
        startGameButton:SetText("Start Game (Admin)")
        startGameButton:SetFont("DermaDefaultBold")
        startGameButton:SetTextColor(colors.textNormal)
        startGameButton:SetSize(200, 40)
        startGameButton:SetPos(frame:GetWide() / 2 - 100, 170) -- Centered, below scoreboard button
        startGameButton.DoClick = function()
            RunConsoleCommand("scp096_begin_game") -- Execute server command
            frame:Close()
        end

        -- Custom paint for the button
        startGameButton.Paint = function(self, w, h)
            local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
            draw.RoundedBox(4, 0, 0, w, h, buttonColor)
            if self:IsHovered() then
                draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
            end
            surface.SetDrawColor(colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        -- Adjust frame size if admin button is present
        frame:SetSize(400, 280) -- Increase height to fit the admin button
    else
         -- Keep original height if not admin
         frame:SetSize(400, 240)
    end
end

-- Function to open the Help panel
function OpenHelpPanel()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")

    -- Calculate size with minimums
    local minW = 500 -- Minimum width
    local minH = 400 -- Minimum height
    local desiredW = ScrW() * 0.6
    local desiredH = ScrH() * 0.7
    local finalW = math.max(minW, desiredW)
    local finalH = math.max(minH, desiredH)
    frame:SetSize(finalW, finalH)

    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)

    -- Starting with zero alpha for fade-in effect
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.3, 0)

    -- Custom paint function for the frame
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 30) -- Header height
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        draw.SimpleText("SCP-096 Battles Help", "DermaLarge", w / 2, 15, colors.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Create scrollable content panel
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(20, 40)
    scroll:SetSize(frame:GetWide(), frame:GetTall()) -- Leave space for padding and close button

    local helpContent = vgui.Create("DPanel", scroll)
    helpContent:SetSize(490, 800)
    helpContent:Dock(TOP)
    helpContent:DockMargin(0, 0, 0, 10)
    helpContent:SetPaintBackground(false)

    -- Helper function to add text sections easily
    local function AddSectionTitle(parent, text)
        local title = vgui.Create("DLabel", parent)
        title:SetText(text)
        title:SetFont("DermaLarge")
        title:SetTextColor(colors.accent)
        title:Dock(TOP)
        title:DockMargin(10, 15, 10, 5)
        title:SetTall(30)
        return title
    end

    local function AddParagraph(parent, text)
        local para = vgui.Create("DLabel", parent)
        para:SetText(text)
        para:SetFont("DermaDefault")
        para:SetTextColor(colors.textNormal)
        para:SetWrap(true)
        para:SetAutoStretchVertical(true)
        para:Dock(TOP)
        para:DockMargin(10, 0, 10, 10)
        return para
    end

    -- Helper function for command entries
    local function AddCommand(parent, name, command, description)
        local commandPanel = vgui.Create("DPanel", parent)
        commandPanel:SetTall(70)
        commandPanel:Dock(TOP)
        commandPanel:DockMargin(10, 5, 10, 5)
        commandPanel:SetAlpha(0)
        commandPanel:AlphaTo(255, 0.3, 0.1)

        commandPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, colors.commandBg)
            surface.SetDrawColor(colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        local nameLabel = vgui.Create("DLabel", commandPanel)
        nameLabel:SetPos(10, 5)
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetText(name)
        nameLabel:SetTextColor(colors.accent)
        nameLabel:SizeToContents()

        local commandLabel = vgui.Create("DLabel", commandPanel)
        commandLabel:SetPos(10, 25)
        commandLabel:SetFont("DermaDefault")
        commandLabel:SetText(command)
        commandLabel:SetTextColor(Color(255, 255, 100))
        commandLabel:SizeToContents()

        local descLabel = vgui.Create("DLabel", commandPanel)
        descLabel:SetPos(10, 45)
        descLabel:SetSize(commandPanel:GetWide() - 20, 20)
        descLabel:SetWrap(true)
        descLabel:SetText(description)
        descLabel:SetTextColor(colors.textNormal)
        descLabel:SetAutoStretchVertical(true)
    end

    -- Populate content --
    AddSectionTitle(helpContent, "Game Introduction")
    AddParagraph(helpContent, "Welcome to SCP-096 Battles! Players are divided into two teams: the SCP-096 team and the Human team. The objective is to score points by eliminating opponents. Use the points earned to buy upgrades from the Points Shop (!pointsshop) and dominate the battlefield!")

    AddSectionTitle(helpContent, "Available Commands")
    AddCommand(helpContent, "Pregame Menu", "!pregame or /pregame | console: open_pregame_menu", "Opens the pregame menu (Points Shop, Scoreboard).")
    AddCommand(helpContent, "Points Shop", "!pointsshop or /pointsshop | console: open_points_shop", "Directly opens the points shop.")
    AddCommand(helpContent, "Scoreboard", "!scoreboard or /scoreboard | console: open_scp_scores", "Directly opens the scoreboard.")
    AddCommand(helpContent, "Help", "!help or /help | console: open_help", "Opens this help panel.")

    AddSectionTitle(helpContent, "Game Tips")
    local tips = {
        "Work with your team! Humans should stick together, SCPs should coordinate attacks.",
        "Spend your points wisely in the shop. Health upgrades are crucial for SCPs, while weapons are key for Humans.",
        "Learn the map layouts to find advantageous positions.",
        "Communicate using team chat.",
        "Check the scoreboard (!scoreboard) to see how the match is progressing."
    }
    local lastTipLabel -- Keep track of the last added tip label
    for _, tip in ipairs(tips) do
        local tipLabel = vgui.Create("DLabel", helpContent)
        tipLabel:SetText("• " .. tip)
        tipLabel:SetFont("DermaDefault")
        tipLabel:SetTextColor(colors.textNormal)
        tipLabel:SetWrap(true)
        tipLabel:SetAutoStretchVertical(true)
        tipLabel:Dock(TOP)
        tipLabel:DockMargin(20, 5, 10, 5)
        lastTipLabel = tipLabel -- Update last label
    end

    -- Close button (positioned at the bottom of the main frame, not scroll panel)
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("CLOSE")
    closeButton:SetFont("DermaDefaultBold")
    closeButton:SetTextColor(colors.textNormal)
    closeButton:SetSize(120, 35)
    closeButton:SetPos(frame:GetWide() / 2 - 60, frame:GetTall() - 50) -- Position near the bottom center

    closeButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    closeButton.DoClick = function()
        -- Fade out animation before removing
        frame:AlphaTo(0, 0.3, 0, function()
            if IsValid(frame) then frame:Remove() end
        end)
    end
end


-- [[ NEW FUNCTION: OpenTestPanel ]]
-- Function to open a simple test panel
function OpenTestPanel()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("") -- No title bar text
    frame:SetSize(250, 150) -- Smaller size for a simple panel
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)

    -- Custom paint function using the shared color scheme
    frame.Paint = function(self, w, h)
        -- Main background with rounded corners
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        -- Header bar
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        -- Bottom border accent
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        -- Title text
        draw.SimpleText("Test Panel", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT) -- Shadow
        draw.SimpleText("Test Panel", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT) -- Text
    end

    -- Label displaying "hi"
    local hiLabel = vgui.Create("DLabel", frame)
    hiLabel:SetText("hi")
    hiLabel:SetFont("DermaLarge") -- Use a larger font
    hiLabel:SetTextColor(colors.textNormal)
    hiLabel:SizeToContents() -- Adjust size to fit text
    hiLabel:Center() -- Center the label within the frame
    hiLabel:SetPos(frame:GetWide()/2 - hiLabel:GetWide()/2, frame:GetTall()/2 - hiLabel:GetTall()/2) -- Manual centering calculation

    -- Optional: Add a close button if you don't want to rely only on the 'X'
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("OK")
    closeButton:SetFont("DermaDefaultBold")
    closeButton:SetTextColor(colors.textNormal)
    closeButton:SetSize(80, 30)
    closeButton:SetPos(frame:GetWide() / 2 - 40, frame:GetTall() - 45) -- Position near bottom center
    closeButton.DoClick = function()
        frame:Close()
    end

    -- Custom paint for the close button
    closeButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end


-- [[ CONCOMMANDS ]] --

-- Register console command to open the help panel
concommand.Add("open_help", function(ply, cmd, args)
    OpenHelpPanel()
end)

-- Register console command to open the pregame menu
concommand.Add("open_pregame_menu", function(ply, cmd, args)
    OpenPregamePanel()
end)

-- Register console command to open the points shop
concommand.Add("open_points_shop", function(ply, cmd, args)
    local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
    local arenaData = (SCPOrHuman == 1) and pointsArenaForSCP096 or pointsArenaForHuman
    if arenaData then
         OpenPointsShop(arenaData)
    else
         chat.AddText(colors.scp, "[Error] ", colors.textNormal, "Shop data not available.")
    end
end)

-- Register console command to open the scoreboard
concommand.Add("open_scp_scores", function(ply, cmd, args)
    CreateScoreboard()
end)

-- [[ NEW CONCOMMAND: Test ]]
-- Register console command to open the test panel
concommand.Add("Test", function(ply, cmd, args)
    OpenTestPanel()
end)


-- [[[ CHAT COMMANDS ]]] --
-- Use a single hook for efficiency

hook.Add("OnPlayerChat", "SCPBattles_ChatCommands", function(ply, text, teamOnly, isDead)
    if ply != LocalPlayer() then return end -- Only process commands for the local player

    local cmd = string.lower(text)

    -- Allow both !command and /command formats
    if string.sub(cmd, 1, 1) == "!" or string.sub(cmd, 1, 1) == "/" then
        cmd = string.sub(cmd, 2) -- Remove the prefix

        if cmd == "pregame" then
            OpenPregamePanel()
            return true -- Stop further processing of this chat message
        elseif cmd == "pointsshop" or cmd == "shop" then
            local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
            local arenaData = (SCPOrHuman == 1) and pointsArenaForSCP096 or pointsArenaForHuman
            if arenaData then
                 OpenPointsShop(arenaData)
            else
                 chat.AddText(colors.scp, "[Error] ", colors.textNormal, "Shop data not available.")
            end
            return true
        elseif cmd == "scoreboard" or cmd == "scores" then
            CreateScoreboard()
            return true
        elseif cmd == "help" then
            OpenHelpPanel()
            return true
        end
    end
end)

print("SCP-096 Battles Client Lua Loaded Successfully.")
