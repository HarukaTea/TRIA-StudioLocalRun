--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

repeat task.wait() until workspace:WaitForChild("Map", 999)

local isSwimming = false
local currentWater: BasePart = nil

local splashCD = 0
local maxOxygen = 100
local timePerLoss = 0.085
local oxygenDepletion = 1

local defaultOxygen = workspace.Map.Settings.Main:GetAttribute("DefaultOxygen") :: number

Add(char.Head.Touched:Connect(function(hit: BasePart)
    if hit:IsA("BasePart") and (string.find(hit.Name, "_Liquid") or string.find(hit.Name, "_Gas")) then
        isSwimming = true

        currentWater = hit
    end
end))
Add(char.Head.TouchEnded:Connect(function(hit: BasePart)
    if hit:IsA("BasePart") and (string.find(hit.Name, "_Liquid") or string.find(hit.Name, "_Gas")) then
        isSwimming = false

        currentWater = nil
    end
end))
Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit:IsA("BasePart")
        and hit.Name == "Hitbox"
        and hit.Parent
        and hit.Parent.Name == "AirTank" then

            local oxygenGiven = hit.Parent:GetAttribute("Oxygen") :: number

            char:SetAttribute("MaxOxygen", oxygenGiven)
            char:SetAttribute("CurrentOxygen", oxygenGiven)

            maxOxygen = oxygenGiven

            hit.Parent:Destroy()
        end
end))

--- air controls
local function decreaseAir()
    splashCD = 2

    char:SetAttribute("CurrentOxygen", math.clamp(char:GetAttribute("CurrentOxygen") - oxygenDepletion, 0, maxOxygen))

    if char:GetAttribute("CurrentOxygen") < 100 and maxOxygen == 300 then
        maxOxygen = 100
        char:SetAttribute("MaxOxygen", maxOxygen)
    end
end
local function increaseAir()
    splashCD = math.max(0, splashCD - 0.25)

    if splashCD <= 0 then
        timePerLoss = 0.065

        char:SetAttribute("CurrentOxygen", math.clamp(char:GetAttribute("CurrentOxygen") + 1, 0, maxOxygen))
    end
end

Add(task.spawn(function()
    while task.wait(timePerLoss) do
        if char.Humanoid.Health > 0 then
            if isSwimming then
                if currentWater then
                    local state = currentWater:GetAttribute("Type") :: string

                    if state == "water" then
                        oxygenDepletion = 1
                        timePerLoss = 0.085

                    elseif state == "acid" then
                        oxygenDepletion = 1
                        timePerLoss = 0.04

                    elseif state == "lava" then
                        char:SetAttribute("CurrentOxygen", 0)

                    elseif state == "custom" then
                        oxygenDepletion = (currentWater:GetAttribute("OxygenDepletion") or 1) / (1 / 0.085)
                        timePerLoss = 0.085
                    end
                end

                decreaseAir()

            elseif not isSwimming then
                if char:GetAttribute("MaxOxygen") > (defaultOxygen or 100) then
                    continue

                elseif maxOxygen <= defaultOxygen then
                    increaseAir()
                end
            end

            if char:GetAttribute("CurrentOxygen") <= 0 then
                char.Humanoid.Health = 0
            end
        else
            break
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
