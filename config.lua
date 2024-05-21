local bs = require("BeefStranger.functions")
local log = require("BeefStranger.StrangeMagic.common").log
local magic = require("BeefStranger.StrangeMagic.common").magic

local configPath = "Strange Magic" -- The name of the config json file of your mod

-- The config table

local defaults = {
    enabled = true,
    addEnchant = false,
    logLevel = "NONE",
    luckImpact = 0.05,
    valueImpact = 0.005,
    combatOnly = false,

}

---@type table<string, boolean>
local config = mwse.loadConfig(configPath, defaults)

-- When the mod config menu is ready to start accepting registrations,
-- register this mod.
local function registerModConfig()
    -- Create the top level component Template
    -- The name will be displayed in the mod list on the lefthand pane
    local template = mwse.mcm.createTemplate({ name = configPath })

    -- Save config options when the mod config menu is closed
    template:saveOnClose(configPath, config)

    -- Create a simple container Page under Template
    local settings = template:createPage({ label = "Settings" })

    -- Create a button under Page that toggles a variable between true and false
    settings:createButton({
        buttonText = "Add Spells",
        callback = function()
            bs.bulkAddSpells(tes3.player, magic)
        end,
        inGameOnly = true
    })

    settings:createYesNoButton{
        label = "Transpose NPC's in combat only",
        variable = mwse.mcm.createTableVariable{id = "combatOnly", table = config}
    }

    settings:createSlider({
        variable = mwse.mcm.createTableVariable{id = "luckImpact", table = config},
        label = "Impact of Luck in chance to steal. Higher = easier to steal valuables.",
        min = 0.001,
        decimalPlaces = 3,
        max = 1.00,
        step = 0.001,
        jump = 0.010,
    })

    settings:createSlider({
        variable = mwse.mcm.createTableVariable{id = "valueImpact", table = config},
        label = "Impact of Value in chance to steal. Higher = harder to steal valuables.",
        min = 0.001,
        decimalPlaces = 3,
        max = 1.000,
        step = 0.001,
        jump = 0.010,
    })

    -- settings:createYesNoButton{
    --     label = "Add Enchant Level",
    --     variable = mwse.mcm.createTableVariable{id = "addEnchant", table = config}
    -- }

    settings:createDropdown{
        label = "Logging Level",
        options = {
            { label = "TRACE", value = "TRACE"},
            { label = "DEBUG", value = "DEBUG"},
            { label = "INFO", value = "INFO"},
            { label = "WARN", value = "WARN"},
            { label = "ERROR", value = "ERROR"},
            { label = "NONE", value = "NONE"},
        },
        variable = mwse.mcm.createTableVariable{ id = "logLevel", table = config},
        callback = function(self)
            log:setLogLevel(self.variable.value)
            tes3.messageBox("Adding Spells")
        end
    }

    -- Finish up.
    template:register()
end
event.register(tes3.event.modConfigReady, registerModConfig)

return config