-- weapon_fists_096.lua

SWEP.PrintName = "SCP-096's Fists"
SWEP.Author = "Your Name"
SWEP.Instructions = "Left click to punch. Right click to rage."
SWEP.Category = "SCP-096 Battles"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false


function SWEP:Initialize()
    self:SetHoldType("fist")
    self:SetNWInt("XRayMetre", 100)
    self:SetNWBool("CanKill", true)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:SetWalkSpeed(owner:GetWalkSpeed() * 2)
        owner:SetRunSpeed(owner:GetRunSpeed() * 2)
    end
    return true
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:SetWalkSpeed(owner:GetWalkSpeed() / 2)
        owner:SetRunSpeed(owner:GetRunSpeed() / 2)
    end
    return true
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    
    if IsValid(owner) then
        owner:SetWalkSpeed(owner:GetWalkSpeed() / 2)
        owner:SetRunSpeed(owner:GetRunSpeed() / 2)
    end
end


function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:Reload()
    if SERVER and IsValid(self:GetOwner()) and not self:GetNWBool("KillMode", false) and self:GetNWBool("CanKill", false) then
        self:GetOwner():EmitSound("scream.wav", 100, 70)
        self:SetNWBool("KillMode", true)
        self:SetNWBool("CanKill", false)
        
        timer.Simple(3, function()
            if IsValid(self) then 
                self:SetNWBool("KillMode", false) 
            end
        end)

        timer.Simple(10, function()
            if IsValid(self) then 
                self:SetNWBool("CanKill", true) 
            end
        end)
    end

    return false
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    
    owner:SetAnimation(PLAYER_ATTACK1)

    self:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
    self:SetNextPrimaryFire(CurTime() + 0.5)
    
    if CLIENT then return end
    
    owner:LagCompensation(true)
    
    local trace = {}
    trace.start = owner:GetShootPos()
    trace.endpos = trace.start + owner:GetAimVector() * 100 -- Increased from 75 to 100
    trace.filter = owner
    trace.mask = MASK_SHOT_HULL
    
    local tr = util.TraceLine(trace)
    
    if !IsValid(tr.Entity) then
        trace.start = owner:GetShootPos()
        trace.endpos = trace.start + owner:GetAimVector() * 100 -- Increased from 75 to 100
        trace.filter = owner
        trace.mins = Vector(-10, -10, -10) -- Added hull size for a bigger hit radius
        trace.maxs = Vector(10, 10, 10)   -- Added hull size for a bigger hit radius
        trace.mask = MASK_SHOT_HULL
        tr = util.TraceHull(trace)
    end
    
    if IsValid(tr.Entity) then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(50)
        dmginfo:SetAttacker(owner)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageForce(owner:GetAimVector() * 10000)
        dmginfo:SetDamagePosition(tr.HitPos)
        dmginfo:SetDamageType(DMG_CLUB)
        tr.Entity:TakeDamageInfo(dmginfo)
        
        self:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1, 6) .. ".wav")
    else
        self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
    end
    
    owner:LagCompensation(false)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:Alive() then
        if CLIENT then
            hook.Add("HUDPaint", "RedScreenEffect", function()
                if not IsValid(owner) or not owner:Alive() then return end
                if owner == nil or owner == NULL then return end
                if not self or self == NULL then return end

                surface.SetDrawColor(255, 0, 0, 150)
                surface.DrawRect(0, 0, ScrW(), ScrH())
                
                if IsValid(self) and self:GetNWBool("CanKill", false) then
                    draw.SimpleText("You can now use kill mode (R)", "Trebuchet24", ScrW() / 2, ScrH() - 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                else
                    draw.SimpleText("Kill mode recharging", "Trebuchet24", ScrW() / 2, ScrH() - 50, Color(173, 173, 173), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                end
            end)

            if self:GetNWBool("KillMode", false) then
                halo.Add(player.GetAll(), Color(255, 0, 0), 5, 5, 2, true, true)
            end

            
        end
    else
        if CLIENT then
            hook.Remove("HUDPaint", "RedScreenEffect")
        end
    end

end

if CLIENT then
    local hintX = -200
    local targetX = 10
    local lerpSpeed = 5

    hook.Add("HUDPaint", "ScreamHint", function()
        local owner = LocalPlayer()
        if owner == nil or owner == NULL then return end

        if IsValid(owner) and IsValid(owner:GetActiveWeapon()) and owner:GetActiveWeapon():GetClass() == "fists_of_096" then
            hintX = Lerp(FrameTime() * lerpSpeed, hintX, targetX)
            draw.SimpleText("R to scream (idk why you would but you can)", "Trebuchet24", hintX, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        else
            hintX = -200
        end
    end)
end

function SWEP:SecondaryAttack()
    self:EmitSound("npc/zombie/zombie_alert" .. math.random(1, 3) .. ".wav")
    self:SetNextSecondaryFire(CurTime() + 2)
end
