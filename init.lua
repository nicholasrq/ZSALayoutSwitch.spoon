--- === ZSALayoutSwitch ===
---
--- Allows setting layers on your ZSA keyboard depending on the current Input Source
---
--- Note: requires [Keymapp](https://apps.apple.com/us/app/zsa-keymapp/id6472865291) and [Kontroll](https://github.com/zsa/kontrollhttps://github.com/zsa/kontroll) to be
--- installed and the keyboard to support Kontroll (Moonlander, Voyager)
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipboardTool.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipboardTool.spoon.zip)
local log = hs.logger.new("kontroll", "debug")

local obj = {}
obj.__index = obj

obj.name = "ZSALayoutSwitch"
obj.version = "1.0"
obj.author = "Nick Skriabin <nick.skriabeen@gmail.com>"
obj.homepage = "https://github.com/nicholasrq/ZSALayoutSwitch"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.debug = false

obj.layers = {}
obj.kontrol_path = "$HOME/.bin/kontroll"

function obj:set_layers(layers)
    self.layers = layers
end

function obj:kontroll(command)
    return hs.execute(self.kontrol_path .. " " .. command)
end

function obj:check_connection()
    local keeb = self:kontroll("status | grep 'Connected' | awk '{print $NF}'")
    if keeb == "" then
        return false
    end
    return true
end

function obj:try_connect()
    self:kontroll("connect-any")
    return self:check_connection()
end

function obj:switch_layer(layer, retry)
    if self:check_connection() then
        self:kontroll("set-layer --index " .. layer)
        log.d("Switched to layer " .. layer)
        local app = hs.application.frontmostApplication()
        log.d(app:bundleID())
    elseif retry == true then
        return
    elseif self:try_connect() then
        self:switch_layer(layer, true)
    else
        log.f("Can't connect to keyboard")
    end
end

function obj:sync_layers()
    local layer = layer_for_input_source()

    if layer then
        self:switch_layer(layer.layer)
        return
    end
    self:switch_layer(0)
end

function obj:start()
    hs.keycodes.inputSourceChanged(function()
        self:sync_layers()
    end)

    local usb_watcher = hs.usb.watcher.new(function(data)
        if data["productName"] == "Voyager" then
            if data["eventType"] == "added" then
                if restart_keymapp() and self:try_connect() then
                    self:sync_layers()
                else
                    log.f("Error launching Keymapp")
                end
            elseif data["eventType"] == "removed" then
                kill_keymapp()
            end
        end
    end)

    usb_watcher:start()

    self:sync_layers()
end

-- Utils

-- Find `layer` for the current input source
function layer_for_input_source()
    local input_source = hs.keycodes.currentSourceID()
    local layer = obj.layers[input_source]
    log.d("Current input cource: '" .. input_source .. "' [" .. layer.title .. "]")
    return layer
end

-- Will kill currently running Keymapp
function kill_keymapp()
    local app = hs.appfinder.appFromName("Keymapp")
    if app then
        app:kill()
    end
end

-- Restart Keymapp
-- Upon start Keymapp will grab the focus even if "Start keymapp minimized" is on
-- To fight that, `restart_keymapp` will remember currently focused app
-- and will focus it back when Keymapp is started
function restart_keymapp()
    kill_keymapp()
    local current_app = hs.application.frontmostApplication()
    local bundle_id = nil

    if current_app ~= nil then
        bundle_id = current_app:bundleID()
    end

    local app = hs.application.launchOrFocus("Keymapp")

    if bundle_id ~= nil then
        hs.application.launchOrFocusByBundleID(bundle_id)
    end

    return app
end

return obj
