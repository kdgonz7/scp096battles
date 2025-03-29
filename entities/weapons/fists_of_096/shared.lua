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
    if SERVER and IsValid(self:GetOwner()) then
        self:GetOwner():EmitSound("scream.wav", 100, 70)
    end
    return false
end

local function PerformScream(ply)
    local weapon = ply:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "fists_of_096" then
        if SERVER then
            ply:EmitSound("scream.wav", 100, 70)
        end
    end
end

hook.Add("KeyPress", "SCP096_Scream", function(ply, key)
    if key == IN_USE and IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "fists_of_096" then
        PerformScream(ply)
    end
end)

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    
    owner:SetAnimation(PLAYER_ATTACK1)

    self:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
    self:SetNextPrimaryFire(CurTime() + 0.5)
    
    if CLIENT then return end
    
    owner:LagCompensation(true)
    
    local trace = {}
    trace.start = owner:GetShootPos()
    trace.endpos = trace.start + owner:GetAimVector() * 75
    trace.filter = owner
    trace.mask = MASK_SHOT_HULL
    
    local tr = util.TraceLine(trace)
    
    if !IsValid(tr.Entity) then
        trace.start = owner:GetShootPos()
        trace.endpos = trace.start + owner:GetAimVector() * 75
        trace.filter = owner
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

                surface.SetDrawColor(255, 0, 0, 150)
                surface.DrawRect(0, 0, ScrW(), ScrH())
            end)
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