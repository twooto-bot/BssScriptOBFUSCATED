local Initializer = {}

local URL = "https://raw.githubusercontent.com/twooto-bot/BssScriptOBFUSCATED/refs/heads/main/"

local modules = {
    ["TweenService"] = game:HttpGet(URL .. "Core/TweenService.luau"),
    ["StartUpService"] = game:HttpGet(URL .. "Core/StartUpService.luau"),
    ["FieldsService"] = game:HttpGet(URL .. "Modules/FieldsService.luau"),
    ["BrainService"] = game:HttpGet(URL .. "Modules/BrainService.luau"),
    ["FarmService"] = game:HttpGet(URL .. "Modules/FarmService.luau"),
    ["SettingService"] = game:HttpGet(URL .. "Modules/SettingService.luau"),
    ["DebugService"] = game:HttpGet(URL .. "Modules/DebugService.luau"),
    ["ConvertService"] = game:HttpGet(URL .. "Modules/ConvertService.luau"),
    ["GuiUpdateHelper"] = game:HttpGet(URL .. "Helpers/GuiUpdateHelper.luau"),
    ["WorldService"] = game:HttpGet(URL .. "Core/WorldService.luau"),
    ["TrackerService"] = game:HttpGet(URL .. "Modules/TrackerService.luau"),
}
function Initializer.LoadServices()
    local services = {}

    for name, module in pairs(modules) do 
        local loaded = loadstring(module)

        if loaded then
            local succes, result = pcall(function()
                services[name] = loaded()
            end)

            if not succes then 
                print(result)
                print("[Service] Error while loading: ", name)
            else
                print("[Service] " .. name .. " has been loaded")
            end
        else
            warn("[Service] Failed to compile module: ", name)
        end
    end

    for name, service in pairs(services) do
        if type(service) == "table" and type(service.Init) == "function" then
            local ok, err = pcall(service.Init, services)
            if not ok then
                warn("[Service] " .. name .. " Init crashed:", err)
            else
                print("[Service] " .. name .. " has been initialized")
            end
        else
            warn("[Service] ", name, "failed to initialize (no Init)")
        end
    end

    return services
end

return Initializer
