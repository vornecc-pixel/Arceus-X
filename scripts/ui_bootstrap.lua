-- Shared UI bootstrap for the full script and standalone ESP.
local ROOT = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/"
local function fetch(path)
    local ok, result = pcall(function()
        local code = game:HttpGet(ROOT .. path)
        return assert(loadstring(code))()
    end)
    if not ok then warn("[ARC3USX] " .. path .. " failed to load: " .. tostring(result)); return nil end
    return result
end

return function(opts)
    opts = opts or {}
    local library = fetch("ARC3USX.lua")
    if type(library) ~= "table" then return nil, "UI library unavailable" end
    if opts.OnLibrary then opts.OnLibrary(library) end
    local logo = fetch("logo.lua")
    local mix = fetch("ARC3USX_NH.lua")
    local window
    local windowOpts = {
        Name = opts.Name or "ARC3USX.EXE", Size = Vector2.new(750, 600),
        MenuKey = Enum.KeyCode.RightShift, Logo = logo, Mix = "NH Classic", Intro = true,
        MobileLandscape = true,
    }
    if type(mix) == "table" and type(mix.CreateWindow) == "function" then
        local ok, result = pcall(mix.CreateWindow, library, windowOpts)
        if ok and result then
            window = result
        elseif not (opts.IsCancelled and opts.IsCancelled()) then
            warn("[ARC3USX] Mix UI failed; falling back to stock UI: " .. tostring(result))
            library.OnUnload = nil
            pcall(function() library:Unload() end)
            if opts.OnLibrary then opts.OnLibrary(library) end
        end
    else
        warn("[ARC3USX] Mix module unavailable; falling back to stock UI.")
        mix = nil
    end
    if opts.IsCancelled and opts.IsCancelled() then return nil, "cancelled" end
    if not window then
        mix = nil
        local ok, result = pcall(function()
            local fallback = library:CreateWindow(windowOpts)
            fallback:WaitReady()
            return fallback
        end)
        if not ok then pcall(function() library:Unload() end); return nil, tostring(result) end
        window = result
    end
    if opts.IsCancelled and opts.IsCancelled() then return nil, "cancelled" end
    return { Library = library, Window = window, Mix = mix }
end
