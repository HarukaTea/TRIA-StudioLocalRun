--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local char = script.Parent.Parent :: Model
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator
local HRP = humanoid.RootPart
local plr = Players.LocalPlayer

local animation = Instance.new("Animation")
animation.AnimationId = KSP:RegisterKeyframeSequence(ReplicatedStorage.Package.Keyframes.WallHang)

local walljumpAnim = animator:LoadAnimation(animation)
local lastJumped = tick()

humanoid.Touched:Connect(function()
    local isJumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if isJumping and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = Ray.new(HRP.Position, HRP.CFrame.LookVector * 2)
        local hit, pos, normal = workspace:FindPartOnRay(ray, char)

        if hit
            and (hit:GetAttribute("_action") == "WallJump" or hit:FindFirstChild("_WallJump"))
            and tick() - lastJumped > 0.1 then

            if hit:GetAttribute("UseFrontOnly") then
                local frontNormal = hit.CFrame.LookVector * 1

                if frontNormal:Dot(pos - hit.Position) <= 0 then return end
            end

            humanoid.AutoRotate = false

            HRP.Anchored = true
            HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + normal)

            walljumpAnim:Play()
            workspace.Sounds.SFXs.Walljump:Play()

            local start = tick()
            local jumped = false
            Spawn(function()
                UserInputService.JumpRequest:Wait()

                jumped = true
            end)
            repeat RunService.RenderStepped:Wait() until jumped or tick() - start > (hit:GetAttribute("Timeout") or 1.5)

            lastJumped = tick()

            humanoid.AutoRotate = true
            HRP.Anchored = false

            walljumpAnim:Stop()

            if jumped then
                local jumpPower = humanoid.JumpPower

                HRP.AssemblyLinearVelocity = Vector3.new(
                    normal.X * jumpPower,
                    jumpPower + normal.Y * jumpPower,
                    normal.Z * jumpPower
                )
            end
        end
    end
end)