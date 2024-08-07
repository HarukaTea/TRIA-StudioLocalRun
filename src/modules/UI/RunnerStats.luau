--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function (plr: Player)
    local scope = Fusion.scoped({}) :: Fusion.Scope

    local char = plr.Character or plr.CharacterAdded:Wait()
    local oxygen = Fusion.Value(scope, 100)
    local maxOxygen = Fusion.Value(scope, 100)

    table.insert(scope, HarukaLib:Hydrate(char, {
        ["Attr-CurrentOxygen"] = function(o2: number)
            oxygen:set(o2)
        end,
        ["Attr-MaxOxygen"] = function(maxo2: number)
            maxOxygen:set(maxo2)
        end
    }))

    Components.ScreenGui(scope, {
        Name = "RunnerStats",
        Parent = plr.PlayerGui,

        [Children] = {
            Components.Frame(scope, {
                Name = "Bottom",
                AnchorPoint = v2New(0.5, 1),
                Position = fromScale(0.5, 1),
                Size = fromScale(1, 0.1),

                [Children] = {
                    Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.627 }),

                    Fusion.New(scope, "Frame")({
                        Name = "OxygenBG",
                        BackgroundColor3 = fromRGB(30, 30, 30),
                        Size = fromScale(0.2, 1),

                        [Children] = {
                            Fusion.New(scope, "UIListLayout")({
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0.1, 0)
                            }),
                            Components.Frame(scope, {
                                Name = "OxygenBarBG",
                                BackgroundTransparency = 0,
                                Size = fromScale(0.9, 0.1),
                                LayoutOrder = 1,
                                BackgroundColor3 = fromRGB(),

                                [Children] = {
                                    Components.Frame(scope, {
                                        Name = "OxygenBar",
                                        AnchorPoint = v2New(),
                                        Position = fromScale(0, 0),
                                        BackgroundTransparency = 0,
                                        BackgroundColor3 = fromRGB(255, 255, 255),

                                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                                            return fromScale(math.clamp(use(oxygen) / use(maxOxygen), 0, 1), 1)
                                        end), TweenInfo.new(0.5)),

                                        [Children] = {
                                            Fusion.New(scope, "UIGradient")({
                                                Color = ColorSequence.new({
                                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 227, 138)),
                                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 129, 129)),
                                                })
                                            })
                                        }
                                    })
                                }
                            }),
                            Components.TextLabel(scope, {
                                Name = "OxygenStats",
                                Size = fromScale(0.9, 0.45),
                                LayoutOrder = 0,
                                FontFace = Font.new(
                                    "rbxasset://fonts/families/Nunito.json",
                                    Enum.FontWeight.Bold
                                ),

                                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                                    return "Oxygen: "..math.floor(use(oxygen))
                                end)
                            })
                        }

                    }),
                    Fusion.New(scope, "Frame")({
                        Name = "TriangleBorder",
                        ZIndex = 0,
                        AnchorPoint = v2New(0, 0.5),
                        Size = fromScale(2, 2),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Position = fromScale(0.16, 1.35),
                        Rotation = 45,
                        BackgroundColor3 = fromRGB(30, 30, 30),

                        [Children] = {
                            Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.1, 0) })
                        }
                    })
                }
            })
        }
    })

    --// Clear
	local function onDead()
		Fusion.doCleanup(scope)
	end
	char.Humanoid.Died:Once(onDead)
end