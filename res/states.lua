local utils = require 'utils' 

return {
    ["enemy1"] = {
        ["states"] = statesTable({
            ["idle"] = {
                ["spritesheet"] = "test",
                ["fps"] = 8
            },
            ["move"] = {
                ["spritesheet"] = "sword_erection",
                ["fps"] = 6
            }
        }, "idle"),
        ["transitions"] = {
            {
                ["from"] = "idle",
                ["to"] = "move",
                ["condition"] = {
                    "current == 'move'"
                }
            },
            {
                ["from"] = "move",
                ["to"] = "idle",
                ["condition"] = {
                    "current == 'wait'",
                }
            }
        },
        ["variables"] = {
            ["current"] = {
                "Timeline",
                "actions",
                { "Timeline", "curIndex" },
                1
            }
        }
    }
}
