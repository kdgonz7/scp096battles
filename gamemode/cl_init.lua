-- cl_init.lua
-- Client-side initialization file for SCP-096 Battles gamemode

include("shared.lua")

include("scoreboard_hud.lua")

-- Called when the gamemode is initialized on the client
function GM:Initialize()
    print("SCP-096 Battles client initialized.")
end

function GM:HUDPaint()
    draw.SimpleText("SCP-096 Battles", "Trebuchet24", ScrW() / 2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end

function CreateScoreboard()
    -- Define scores
    local SCP096Score = GetGlobalInt("SCP096Score", 0)
    local HumanScore = GetGlobalInt("HumansScore", 0)

    -- Define a color scheme for consistency
    local colors = {
        background = Color(35, 35, 50, 230),
        header = Color(25, 25, 40, 255),
        scp = Color(255, 100, 100),
        human = Color(100, 150, 255),
        button = Color(60, 60, 80, 255),
        buttonHover = Color(80, 80, 100, 255),
        textNormal = Color(220, 220, 220),
        accent = Color(150, 120, 200)
    }
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(500, 300)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)
    
    -- Custom paint function for the frame
    frame.Paint = function(self, w, h)
        -- Main background with rounded corners
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        
        -- Header bar with subtle gradient
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        
        -- Bottom border accent
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h-3, w, 3)
        
        -- Title with shadow
        draw.SimpleText("Scoreboard", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT)
        draw.SimpleText("Scoreboard", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT)
    end
    
    -- Create a panel for scores that has a subtle border
    local scorePanel = vgui.Create("DPanel", frame)
    scorePanel:SetPos(25, 50)
    scorePanel:SetSize(450, 160)
    scorePanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 60, 200))
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- Title for scoreboard
    local titleLabel = vgui.Create("DLabel", scorePanel)
    titleLabel:SetPos(0, 15)
    titleLabel:SetSize(450, 30)
    titleLabel:SetText("TEAM SCORES")
    titleLabel:SetFont("DermaLarge")
    titleLabel:SetTextColor(colors.accent)
    titleLabel:SetContentAlignment(5)
    
    local scpLabel = vgui.Create("DLabel", scorePanel)
    scpLabel:SetPos(20, 60)
    scpLabel:SetSize(410, 30)
    scpLabel:SetText("SCP-096 Team Points: " .. tostring(SCP096Score))
    scpLabel:SetFont("Trebuchet24")
    scpLabel:SetTextColor(colors.scp)

    
    local humanLabel = vgui.Create("DLabel", scorePanel)
    humanLabel:SetPos(20, 100)
    humanLabel:SetSize(410, 30)
    humanLabel:SetText("Human Team Points: " .. tostring(HumanScore))
    humanLabel:SetFont("Trebuchet24")
    humanLabel:SetTextColor(colors.human)
    
    -- Close button with improved styling
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("CLOSE")
    closeButton:SetFont("DermaDefaultBold")
    closeButton:SetTextColor(colors.textNormal)
    closeButton:SetSize(120, 40)
    closeButton:SetPos(frame:GetWide() / 2 - 60, 230)
    closeButton.DoClick = function()
        frame:Close()
    end
    
    closeButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w-4, h-4, Color(255, 255, 255, 15))
        end
        
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- Function to update points dynamically
    function UpdatePoints(scpPoints, humanPoints)
        scpLabel:SetText("SCP-096 Team Points: " .. scpPoints)
        humanLabel:SetText("Human Team Points: " .. humanPoints)
    end
end

function OpenPointsShop(pointsArena)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)

    local colors = {
        background = Color(35, 35, 50, 230),
        header = Color(25, 25, 40, 255),
        textNormal = Color(220, 220, 220),
        accent = Color(150, 120, 200),
        button = Color(60, 60, 80, 255),
        buttonHover = Color(80, 80, 100, 255)
    }

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        draw.SimpleText("Points Shop", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT)
        draw.SimpleText("Points Shop", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT)
    end

    local shopPanel = vgui.Create("DScrollPanel", frame)
    shopPanel:SetPos(25, 50)
    shopPanel:SetSize(450, 300)

    for points, data in SortedPairs(pointsArena[1]) do
        local itemPanel = vgui.Create("DPanel", shopPanel)
        itemPanel:SetSize(430, 90)
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(0, 0, 0, 10)
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 60, 200))
            surface.SetDrawColor(colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end


        local titleLabel = vgui.Create("DLabel", itemPanel)
        titleLabel:SetPos(10, 10)
        titleLabel:SetSize(300, 20)
        titleLabel:SetText("Unlock for " .. points .. " Points")
        titleLabel:SetFont("DermaDefault")
        titleLabel:SetTextColor(colors.textNormal)

        local infoLabel = vgui.Create("DLabel", itemPanel)
        infoLabel:SetPos(10, 40)
        infoLabel:SetSize(400, 40)
        infoLabel:SetWrap(true)
        infoLabel:SetFont("DermaDefaultBold")
        infoLabel:SetTextColor(colors.textNormal)

        if LocalPlayer():GetNWInt("SCPOrHuman", 0) == 1 then
            infoLabel:SetText("Health Bonus: " .. (data.health or "N/A"))
        else
            local weaponsList = data.weapons and table.concat(data.weapons, ", ") or "None"
            infoLabel:SetText("Available Weapons: " .. weaponsList)
        end
        infoLabel:SetFont("DermaDefault")
        infoLabel:SetTextColor(colors.textNormal)

        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetText("BUY")
        buyButton:SetFont("DermaDefaultBold")
        buyButton:SetTextColor(colors.textNormal)
        buyButton:SetSize(80, 30)
        buyButton:SetPos(340, 30)
        buyButton.DoClick = function()
            local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
            print(SCPOrHuman)
            if SCPOrHuman == 1 then
            net.Start("BuyPointsItemSCP")
            else
            net.Start("BuyPointsItemHuman")
            end
            net.WriteInt(points, 32)
            net.SendToServer()
        end

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

function OpenPregamePanel()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(400, 240)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(false)

    local colors = {
        background = Color(35, 35, 50, 230),
        header = Color(25, 25, 40, 255),
        textNormal = Color(220, 220, 220),
        accent = Color(150, 120, 200),
        button = Color(60, 60, 80, 255),
        buttonHover = Color(80, 80, 100, 255)
    }

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        surface.SetDrawColor(colors.header)
        surface.DrawRect(0, 0, w, 25)
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 3, w, 3)
        draw.SimpleText("Pregame Menu", "DermaDefault", 10, 2, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT)
        draw.SimpleText("Pregame Menu", "DermaDefault", 9, 1, colors.textNormal, TEXT_ALIGN_LEFT)
    end

    frame.OnClose = function(...)
        chat.AddText(Color(255, 255, 255), "That's fine! To open this again, use ", Color(255,136,0), "!pregame", Color(255,255,255), " to open it again :)")
    end

    local pointsShopButton = vgui.Create("DButton", frame)
    pointsShopButton:SetText("Open Points Shop")
    pointsShopButton:SetFont("DermaDefaultBold")
    pointsShopButton:SetTextColor(colors.textNormal)
    pointsShopButton:SetSize(200, 40)
    pointsShopButton:SetPos(frame:GetWide() / 2 - 100, 50)
    pointsShopButton.DoClick = function()
        local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
        if SCPOrHuman == 1 then
            OpenPointsShop(pointsArenaForSCP096)
        else
            OpenPointsShop(pointsArenaForHuman)
        end
    end

    pointsShopButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local scoreboardButton = vgui.Create("DButton", frame)
    scoreboardButton:SetText("Open Scoreboard")
    scoreboardButton:SetFont("DermaDefaultBold")
    scoreboardButton:SetTextColor(colors.textNormal)
    scoreboardButton:SetSize(200, 40)
    scoreboardButton:SetPos(frame:GetWide() / 2 - 100, 110)
    scoreboardButton.DoClick = function()
        CreateScoreboard()
    end

    scoreboardButton.Paint = function(self, w, h)
        local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
        draw.RoundedBox(4, 0, 0, w, h, buttonColor)
        if self:IsHovered() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(255, 255, 255, 15))
        end
        surface.SetDrawColor(colors.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    if LocalPlayer():IsAdmin() then
        local startGameButton = vgui.Create("DButton", frame)
        startGameButton:SetText("Start Game")
        startGameButton:SetFont("DermaDefaultBold")
        startGameButton:SetTextColor(colors.textNormal)
        startGameButton:SetSize(200, 40)
        startGameButton:SetPos(frame:GetWide() / 2 - 100, 170)
        startGameButton.DoClick = function()
            RunConsoleCommand("scp096_begin_game")
            frame:Close()
        end

        startGameButton.Paint = function(self, w, h)
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

function OpenHelpPanel()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:SetSize(ScrW() / 1.5, ScrH() / 1.5)
        frame:Center()
        frame:SetBackgroundBlur(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:SetSizable(false)
        
        -- Starting with zero alpha for fade-in effect
        frame:SetAlpha(0)
        frame:AlphaTo(255, 0.3, 0, function() end)
        
        -- Define colors for consistency with other panels
        local colors = {
            background = Color(35, 35, 50, 230),
            header = Color(25, 25, 40, 255),
            textNormal = Color(220, 220, 220),
            accent = Color(150, 120, 200),
            button = Color(60, 60, 80, 255),
            buttonHover = Color(80, 80, 100, 255),
            commandBg = Color(45, 45, 60, 200)
        }

        -- Custom paint function for the frame
        frame.Paint = function(self, w, h)
            -- Background with rounded corners
            draw.RoundedBox(8, 0, 0, w, h, colors.background)
            
            -- Header bar
            surface.SetDrawColor(colors.header)
            surface.DrawRect(0, 0, w, 30)
            
            -- Bottom accent
            surface.SetDrawColor(colors.accent)
            surface.DrawRect(0, h-3, w, 3)
            
            -- Title
            draw.SimpleText("SCP-096 Battles Help", "DermaLarge", 20, 15, colors.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        -- Create scrollable content panel
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:SetPos(20, 50)
        scroll:SetSize(frame:GetWide(), frame:GetTall())
        
        local helpContent = vgui.Create("DPanel", scroll)
        helpContent:SetSize(490, 800)
        helpContent:Dock(TOP)
        helpContent:DockMargin(0, 0, 0, 10)
        helpContent.Paint = function() end

        -- Game introduction section
        local introTitle = vgui.Create("DLabel", helpContent)
        introTitle:SetText("Game Introduction")
        introTitle:SetFont("DermaLarge")
        introTitle:SetTextColor(colors.accent)
        introTitle:Dock(TOP)
        introTitle:DockMargin(10, 10, 10, 5)
        
        local introText = vgui.Create("DLabel", helpContent)
        introText:SetText("SCP-096 Battles is a gamemode where players are divided into two teams: SCP-096 team and Human team. Both teams compete for points to win rounds.")
        introText:SetFont("DermaDefault")
        introText:SetTextColor(colors.textNormal)
        introText:SetWrap(true)
        introText:SetAutoStretchVertical(true)
        introText:Dock(TOP)
        introText:DockMargin(10, 0, 10, 15)
        
        -- Commands section
        local commandsTitle = vgui.Create("DLabel", helpContent)
        commandsTitle:SetText("Available Commands")
        commandsTitle:SetFont("DermaLarge")
        commandsTitle:SetTextColor(colors.accent)
        commandsTitle:Dock(TOP)
        commandsTitle:DockMargin(10, 10, 10, 10)

        -- Helper function for command entries
        local function AddCommand(name, command, description)
            local commandPanel = vgui.Create("DPanel", helpContent)
            commandPanel:SetSize(470, 60)
            commandPanel:Dock(TOP)
            commandPanel:DockMargin(10, 5, 10, 5)
            
            -- Animate command panels when shown
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
            descLabel:SetPos(commandPanel:GetWide(), 25)
            descLabel:SetSize(260, 30)
            descLabel:SetWrap(true)
            descLabel:SetText(description)
            descLabel:SetTextColor(colors.textNormal)
        end

        AddCommand("Pregame Menu", "!pregame or console command: open_pregame_menu", "Opens the pregame menu with options for points shop and scoreboard.")
        AddCommand("Points Shop", "!pointsshop or console command: open_points_shop", "Opens the points shop to purchase upgrades for your team.")
        AddCommand("Scoreboard", "!scoreboard or console command: open_scp_scores", "Opens the scoreboard to view current team scores.")
        
        -- Tips section
        local tipsTitle = vgui.Create("DLabel", helpContent)
        tipsTitle:SetText("Game Tips")
        tipsTitle:SetFont("DermaLarge")
        tipsTitle:SetTextColor(colors.accent)
        tipsTitle:Dock(TOP)
        tipsTitle:DockMargin(10, 20, 10, 5)
        
        local tips = {
            "The more you play and win, the stronger you can become.",
            "Use the points shop strategically to gain advantages.",
            "Check the scoreboard regularly to track your team's progress."
        }
        
        for _, tip in ipairs(tips) do
            local tipLabel = vgui.Create("DLabel", helpContent)
            tipLabel:SetText("• " .. tip)
            tipLabel:SetFont("DermaDefault")
            tipLabel:SetTextColor(colors.textNormal)
            tipLabel:SetWrap(true)
            tipLabel:SetAutoStretchVertical(true)
            tipLabel:Dock(TOP)
            tipLabel:DockMargin(20, 5, 10, 5)
        end
        
        -- Close button with animation
        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("CLOSE")
        closeButton:SetFont("DermaDefaultBold")
        closeButton:SetTextColor(colors.textNormal)
        closeButton:SetSize(120, 40)
        closeButton:SetPos(frame:GetWide() / 2 - 60, 410)
        
        closeButton.Paint = function(self, w, h)
            local buttonColor = self:IsHovered() and colors.buttonHover or colors.button
            draw.RoundedBox(4, 0, 0, w, h, buttonColor)
            
            if self:IsHovered() then
                draw.RoundedBox(4, 2, 2, w-4, h-4, Color(255, 255, 255, 15))
            end
            
            surface.SetDrawColor(colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        
        closeButton.DoClick = function()
            frame:AlphaTo(0, 0.3, 0, function()
                frame:Remove()
            end)
        end
        
        -- Make it popup after created
        frame:MakePopup()
end


-- [[ CONCOMMANDS ]]


concommand.Add("open_help", function()
    OpenHelpPanel()
end)

concommand.Add("open_pregame_menu", function()
    OpenPregamePanel()
end)

concommand.Add("open_points_shop", function()
    local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)

    if SCPOrHuman == 1 then
        OpenPointsShop(pointsArenaForSCP096)
    else
        OpenPointsShop(pointsArenaForHuman)
    end
end)

concommand.Add("open_scp_scores", function()
    CreateScoreboard()
end)


-- [[[ CHAT COMMANDS ]]]


-- Chat command to open the pregame menu
hook.Add("OnPlayerChat", "OpenPregameMenuChatCommand", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!pregame" then
        OpenPregamePanel()
        return true
    end
end)

-- Chat command to open the points shop
hook.Add("OnPlayerChat", "OpenPointsShopChatCommand", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!pointsshop" then
        local SCPOrHuman = LocalPlayer():GetNWInt("SCPOrHuman", 0)
        if SCPOrHuman == 1 then
            OpenPointsShop(pointsArenaForSCP096)
        else
            OpenPointsShop(pointsArenaForHuman)
        end
        return true
    end
end)

-- Chat command to open the scoreboard
hook.Add("OnPlayerChat", "OpenScoreboardChatCommand", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!scoreboard" then
        CreateScoreboard()
        return true
    end
end)

hook.Add("OnPlayerChat", "OpenHelpChatCommand", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!help" then
        OpenHelpPanel()
        return true
    end
end)

print("Client")