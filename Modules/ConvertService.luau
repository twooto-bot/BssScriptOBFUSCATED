local BotState = _G.State

local Players = game:GetService("Players")

local ConvertService = {}

local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cache = ReplicatedStorage:FindFirstChild("ClientStatCache")
local hiveEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerHiveCommand")

local clientStatCache = require(cache)

function ConvertService.Init(services)
    ConvertService.Services = services
end

function ConvertService.ConvertPollen()
    print(BotState.isConverting)
    if BotState.isConverting == true then
        return
    end

    BotState.isConverting = true

    local hive = BotState.hive

    if not hive or not hive.Platform or not hive.Platform.Value then
        warn("[FarmService] Hive or hive platform missing in BotState")
        BotState.converting = false
        return
    end

    local platformModel = hive.Platform.Value
    local platformPart = platformModel:FindFirstChild("Platform")

    if not platformPart then
        warn("[FarmService] Hive platform model missing 'Platform' part")
        BotState.converting = false
        return
    end

    local position = platformPart.Position + Vector3.new(0, 10, 0)

    print("[FarmService] ConvertPollen: tweening to hive at", position)
    ConvertService.Services.TweenService.TweenPlayer(position)

    task.wait(0.5)

    hiveEvent:FireServer("ToggleHoneyMaking")

    while task.wait(0.5) do 

        if BotState.scriptStopped then 
            return
        end

        BotState.playerData = clientStatCache:Get()
        
        local pollen = BotState.playerData.Pollen

        local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        local magnitude = (root.Position - position).Magnitude

        if magnitude > 10 then 
            print("[FarmService] ConvertPollen: tweening to hive at", position)
            ConvertService.Services.TweenService.TweenPlayer(position)
            task.wait(0.5)
            hiveEvent:FireServer("ToggleHoneyMaking")
        end

        if BotState.convertBalloon then
            if not BotState.playerData.HiveBalloon and pollen <= 0 then
                -- balloon is gone, stop waiting
                print("[Convert] Balloon stoped to exist so balloon empty")
                break
            end
        else
            if pollen <= 0 then
                -- nothing to convert, stop
                print("[Convert] Bag pollen reached 0 (convertBalloon = false), stopping convert loop")
                break
            end
        end
    end

    task.wait(5)

    print("[FarmService] ConvertPollen: done converting")
    BotState.isConverting = false
    BotState.converting = false

    return
end

task.spawn(function()
    local start = nil

    while task.wait() do 
        local coreStats = localPlayer:FindFirstChild("CoreStats")
        local pollen = coreStats:FindFirstChild("Pollen")
        local capacity = coreStats:FindFirstChild("Capacity")

        local capacityValue = capacity.Value
        local pollenValue = pollen.Value
        local threshold = BotState.convertPercentage / 100

        if capacityValue > 0 and pollenValue / capacityValue >= threshold then

            if not start then 
                start = tick()
            end

            if start + BotState.waitConvertTime <= tick() then
                print("[ConvertService] Capacity threshold reached; requesting conversion")
                BotState.converting = true
                BotState.farmRunning = false
                start = nil
                print("ConvertService setting to false:", BotState.farmRunning )
            end

            continue
        end

        start = nil
    end
end)

return ConvertService