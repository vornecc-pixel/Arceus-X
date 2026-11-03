-- Script path: game:GetService("ReplicatedStorage").Fust.Wear
-- Decompile time: 20.46 ms

local Fabric, err, material, success
local u860 = {
    SLOTS = {"head", "torso", "torso_armor", "legs", "legs_armor", "feet"},
    SLOT_LABEL = {
        head = "HEAD",
        torso = "SHIRT",
        torso_armor = "CHEST",
        legs = "PANTS",
        legs_armor = "LEG ARMOR",
        feet = "FEET",
    },
    REGIONS = {"head", "torso", "legs", "feet"},
    REGION_LABEL = {head = "Head", torso = "Torso", legs = "Legs", feet = "Feet"},
    SLOT_REGIONS = {
        head = {"head"},
        torso = {"torso"},
        torso_armor = {"torso"},
        legs = {"legs"},
        legs_armor = {"legs"},
        feet = {"feet"},
    },
    MAX_PROTECTION = 0.8,
}
u860.REF_SIZE = {
    Head = Vector3.new(1.2000000476837158, 1.2000000476837158, 1.2000000476837158),
    UpperTorso = Vector3.new(2, 1.600000023841858, 1),
    LowerTorso = Vector3.new(2, 0.4000000059604645, 1),
    LeftUpperArm = Vector3.new(1, 1.1699999570846558, 1),
    RightUpperArm = Vector3.new(1, 1.1699999570846558, 1),
    LeftLowerArm = Vector3.new(1, 1.0499999523162842, 1),
    RightLowerArm = Vector3.new(1, 1.0499999523162842, 1),
    LeftUpperLeg = Vector3.new(1, 1.2200000286102295, 1),
    RightUpperLeg = Vector3.new(1, 1.2200000286102295, 1),
    LeftLowerLeg = Vector3.new(1, 1.190000057220459, 1),
    RightLowerLeg = Vector3.new(1, 1.190000057220459, 1),
    LeftFoot = Vector3.new(1, 0.30000001192092896, 1),
    RightFoot = Vector3.new(1, 0.30000001192092896, 1),
}
u860.REST = {
    Head = Vector3.new(0, 5.199999809265137, 0),
    UpperTorso = Vector3.new(0, 3.799999952316284, 0),
    LowerTorso = Vector3.new(0, 2.799999952316284, 0),
    LeftUpperArm = Vector3.new(-1.5, 4, 0),
    RightUpperArm = Vector3.new(1.5, 4, 0),
    LeftLowerArm = Vector3.new(-1.5, 2.950000047683716, 0),
    RightLowerArm = Vector3.new(1.5, 2.950000047683716, 0),
    LeftUpperLeg = Vector3.new(-0.5, 2, 0),
    RightUpperLeg = Vector3.new(0.5, 2, 0),
    LeftLowerLeg = Vector3.new(-0.5, 0.8500000238418579, 0),
    RightLowerLeg = Vector3.new(0.5, 0.8500000238418579, 0),
    LeftFoot = Vector3.new(-0.5, 0.15000000596046448, 0),
    RightFoot = Vector3.new(0.5, 0.15000000596046448, 0),
}
local u862 = Color3.fromRGB(176, 150, 106)
local v1 = Color3.fromRGB(160, 135, 95)
local v2 = Color3.fromRGB(140, 115, 80)
local v3 = Color3.fromRGB(150, 106, 60)

local function v(a1, a2, a3) -- Line: 85; types: a1: number, a2: number, a3: number
    return (Vector3.new(a1, a2, a3))
end

local u866 = {}
u866.head = {
    {
        "Head",
        Vector3.new(1.340000033378601, 0.6000000238418579, 1.340000033378601),
        (Vector3.new(0, 0.2199999988079071, 0.019999999552965164)),
    },
    {
        "Head",
        Vector3.new(1.2400000095367432, 0.18000000715255737, 1.2400000095367432),
        (Vector3.new(0, 0.6000000238418579, 0.019999999552965164)),
    },
}
u866.torso = {
    {
        "UpperTorso",
        Vector3.new(2.1600000858306885, 1.659999966621399, 1.159999966621399),
        (Vector3.new(0, 0, 0)),
    },
    {
        "LowerTorso",
        Vector3.new(2.119999885559082, 0.4399999976158142, 1.1200000047683716),
        (Vector3.new(0, 0, 0)),
    },
    {
        "LeftUpperArm",
        Vector3.new(1.1200000047683716, 0.8999999761581421, 1.1200000047683716),
        (Vector3.new(0, 0.15000000596046448, 0)),
    },
    {
        "RightUpperArm",
        Vector3.new(1.1200000047683716, 0.8999999761581421, 1.1200000047683716),
        (Vector3.new(0, 0.15000000596046448, 0)),
    },
}
u866.legs = {
    {
        "LowerTorso",
        Vector3.new(2.1600000858306885, 0.47999998927116394, 1.159999966621399),
        (Vector3.new(0, -0.019999999552965164, 0)),
    },
    {
        "LeftUpperLeg",
        Vector3.new(1.1200000047683716, 1.2599999904632568, 1.1200000047683716),
        (Vector3.new(0, 0, 0)),
    },
    {
        "RightUpperLeg",
        Vector3.new(1.1200000047683716, 1.2599999904632568, 1.1200000047683716),
        (Vector3.new(0, 0, 0)),
    },
    {
        "LeftLowerLeg",
        Vector3.new(1.100000023841858, 1.1799999475479126, 1.100000023841858),
        (Vector3.new(0, 0.019999999552965164, 0)),
    },
    {
        "RightLowerLeg",
        Vector3.new(1.100000023841858, 1.1799999475479126, 1.100000023841858),
        (Vector3.new(0, 0.019999999552965164, 0)),
    },
}
u866.feet = {
    {
        "LeftFoot",
        Vector3.new(1.1200000047683716, 0.4399999976158142, 1.1799999475479126),
        (Vector3.new(0, 0.03999999910593033, -0.029999999329447746)),
    },
    {
        "RightFoot",
        Vector3.new(1.1200000047683716, 0.4399999976158142, 1.1799999475479126),
        (Vector3.new(0, 0.03999999910593033, -0.029999999329447746)),
    },
}
u866.torso_armor = {
    {
        "UpperTorso",
        Vector3.new(2.299999952316284, 1.5, 1.3200000524520874),
        (Vector3.new(0, 0.03999999910593033, 0)),
    },
    {
        "LowerTorso",
        Vector3.new(2.259999990463257, 0.5, 1.2799999713897705),
        (Vector3.new(0, -0.11999999731779099, 0)),
    },
}
u866.legs_armor = {
    {
        "LeftUpperLeg",
        Vector3.new(1.2400000095367432, 0.9800000190734863, 1.2400000095367432),
        (Vector3.new(0, 0.05999999865889549, -0.019999999552965164)),
    },
    {
        "RightUpperLeg",
        Vector3.new(1.2400000095367432, 0.9800000190734863, 1.2400000095367432),
        (Vector3.new(0, 0.05999999865889549, -0.019999999552965164)),
    },
    {
        "LeftLowerLeg",
        Vector3.new(1.2200000286102295, 0.9200000166893005, 1.2200000286102295),
        (Vector3.new(0, -0.019999999552965164, -0.019999999552965164)),
    },
    {
        "RightLowerLeg",
        Vector3.new(1.2200000286102295, 0.9200000166893005, 1.2200000286102295),
        (Vector3.new(0, -0.019999999552965164, -0.019999999552965164)),
    },
}
u860.FALLBACK = {
    burlap_headwrap = {color = u862, material = Enum.Material.Fabric},
    burlap_shirt = {color = u862, material = Enum.Material.Fabric},
    burlap_trousers = {color = v1, material = Enum.Material.Fabric},
    burlap_shoes = {color = v2, material = Enum.Material.Fabric},
    wood_chestplate = {color = v3, material = Enum.Material.WoodPlanks},
    wood_armor_pants = {color = v3, material = Enum.Material.WoodPlanks},
}
local u864 = {}
u864.color = {
    leather = Color3.fromRGB(122, 86, 56),
    hideDark = Color3.fromRGB(86, 58, 38),
    sole = Color3.fromRGB(56, 42, 32),
    fur = Color3.fromRGB(222, 210, 186),
    bone = Color3.fromRGB(228, 220, 198),
    boneDark = Color3.fromRGB(190, 178, 150),
    riot = Color3.fromRGB(34, 38, 46),
    rim = Color3.fromRGB(20, 22, 26),
    visor = Color3.fromRGB(168, 190, 206),
    olive = Color3.fromRGB(84, 90, 62),
    plate = Color3.fromRGB(62, 66, 48),
    pouch = Color3.fromRGB(100, 98, 72),
    strap = Color3.fromRGB(40, 42, 32),
    tan = Color3.fromRGB(106, 102, 76),
    pad = Color3.fromRGB(32, 32, 34),
}
u864.material = {}

for k, i in pairs({
    fabric = "Fabric",
    leather = "Leather",
    fur = "Carpet",
    bone = "Limestone",
    plastic = "SmoothPlastic",
    glass = "Glass",
    rubber = "Rubber",
}) do
    success, err = pcall(function() -- Line: 149; upvalues: i (val)
        return Enum.Material[i]
    end)
    material = u864.material
    Fabric = if not success then
        Enum.Material.Fabric
    else
        if typeof(err) ~= "EnumItem" then Enum.Material.Fabric else err
    material[k] = Fabric
end

local function s(a1, a2, a3, a4, a5, a6)
    -- Line: 154
    -- types: a1: string, a2: vector, a3: vector, a4: string, a5: string, a6: number?
    return {a1, a2, a3, a4, a5, a6}
end

local function pair(a1, a2, a3, a4, a5, a6, a7, a8)
    -- Line: 157
    -- types: a1: table, a2: string, a3: string, a4: vector, a5: vector, a6: string, a7: string, a8: boolean?
    table.insert(
        a1,
        {
            a2,
            a4,
            if not a8 then a5 else Vector3.new(-a5.X, a5.Y, a5.Z),
            a6,
            a7,
            nil,
        }
    )

    table.insert(
        a1,
        {a3, a4, a5, a6, a7, nil}
    )
end

local v4 = {
    hide_hood = {
        {
            "Head",
            Vector3.new(1.3600000143051147, 0.20000000298023224, 1.3600000143051147),
            Vector3.new(0, 0.6000000238418579, 0.03999999910593033),
            "leather",
            "leather",
            nil,
        },
        {
            "Head",
            Vector3.new(1.3600000143051147, 1.1200000047683716, 0.20000000298023224),
            Vector3.new(0, 0.05999999865889549, 0.6000000238418579),
            "leather",
            "leather",
            nil,
        },
        {
            "Head",
            Vector3.new(0.20000000298023224, 1.100000023841858, 1.2400000095367432),
            Vector3.new(-0.6600000262260437, 0.03999999910593033, 0.019999999552965164),
            "leather",
            "leather",
            nil,
        },
        {
            "Head",
            Vector3.new(0.20000000298023224, 1.100000023841858, 1.2400000095367432),
            Vector3.new(0.6600000262260437, 0.03999999910593033, 0.019999999552965164),
            "leather",
            "leather",
            nil,
        },
        {
            "Head",
            Vector3.new(1.440000057220459, 0.18000000715255737, 0.18000000715255737),
            Vector3.new(0, 0.5, -0.6200000047683716),
            "fur",
            "fur",
            nil,
        },
        {
            "Head",
            Vector3.new(0.18000000715255737, 0.8999999761581421, 0.18000000715255737),
            Vector3.new(-0.6600000262260437, 0, -0.6200000047683716),
            "fur",
            "fur",
            nil,
        },
        {
            "Head",
            Vector3.new(0.18000000715255737, 0.8999999761581421, 0.18000000715255737),
            Vector3.new(0.6600000262260437, 0, -0.6200000047683716),
            "fur",
            "fur",
            nil,
        },
        {
            "UpperTorso",
            Vector3.new(1.600000023841858, 0.2199999988079071, 1.1200000047683716),
            Vector3.new(0, 0.8600000143051147, 0.019999999552965164),
            "leather",
            "leather",
            nil,
        },
    },
    hide_vest = {
        {
            "UpperTorso",
            Vector3.new(2.140000104904175, 1.6399999856948853, 1.1399999856948853),
            Vector3.new(0, 0, 0),
            "leather",
            "leather",
            nil,
        },
        {
            "LowerTorso",
            Vector3.new(2.0999999046325684, 0.4399999976158142, 1.100000023841858),
            Vector3.new(0, 0, 0),
            "leather",
            "leather",
            nil,
        },
        {
            "UpperTorso",
            Vector3.new(1.2999999523162842, 0.20000000298023224, 1.2200000286102295),
            Vector3.new(0, 0.800000011920929, 0),
            "fur",
            "fur",
            nil,
        },
        {
            "UpperTorso",
            Vector3.new(0.10000000149011612, 1.399999976158142, 0.03999999910593033),
            Vector3.new(0, -0.05000000074505806, -0.5849999785423279),
            "hideDark",
            "leather",
            nil,
        },
    },
}

pair(v4.hide_vest, "LeftUpperArm", "RightUpperArm", Vector3.new(1.100000023841858, 0.30000001192092896, 1.100000023841858), Vector3.new(0, 0.44999998807907104, 0), "fur", "fur")

v4.hide_pants = {
    {
        "LowerTorso",
        Vector3.new(2.1600000858306885, 0.47999998927116394, 1.159999966621399),
        Vector3.new(0, -0.019999999552965164, 0),
        "leather",
        "leather",
        nil,
    },
    {
        "LowerTorso",
        Vector3.new(2.200000047683716, 0.14000000059604645, 1.2000000476837158),
        Vector3.new(0, 0.11999999731779099, 0),
        "hideDark",
        "leather",
        nil,
    },
}
pair(v4.hide_pants, "LeftUpperLeg", "RightUpperLeg", Vector3.new(1.1200000047683716, 1.2599999904632568, 1.1200000047683716), Vector3.new(0, 0, 0), "leather", "leather")
pair(v4.hide_pants, "LeftLowerLeg", "RightLowerLeg", Vector3.new(1.100000023841858, 1.1799999475479126, 1.100000023841858), Vector3.new(0, 0.019999999552965164, 0), "leather", "leather")
pair(v4.hide_pants, "LeftLowerLeg", "RightLowerLeg", Vector3.new(0.6200000047683716, 0.36000001430511475, 0.05999999865889549), Vector3.new(0, 0.3799999952316284, -0.5699999928474426), "hideDark", "leather")

v4.hide_boots = {}
pair(v4.hide_boots, "LeftFoot", "RightFoot", Vector3.new(1.1399999856948853, 0.46000000834465027, 1.2000000476837158), Vector3.new(0, 0.03999999910593033, -0.029999999329447746), "hideDark", "leather")
pair(v4.hide_boots, "LeftFoot", "RightFoot", Vector3.new(1.159999966621399, 0.10000000149011612, 1.2400000095367432), Vector3.new(0, -0.15000000596046448, -0.029999999329447746), "sole", "rubber")
pair(v4.hide_boots, "LeftLowerLeg", "RightLowerLeg", Vector3.new(1.1799999475479126, 0.30000001192092896, 1.1799999475479126), Vector3.new(0, -0.41999998688697815, 0), "fur", "fur")

v4.bone_helmet = {
    {
        "Head",
        Vector3.new(1.3600000143051147, 0.4000000059604645, 1.3600000143051147),
        Vector3.new(0, 0.4399999976158142, 0.019999999552965164),
        "bone",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(1.399999976158142, 0.07999999821186066, 1.399999976158142),
        Vector3.new(0, 0.25999999046325684, 0.019999999552965164),
        "hideDark",
        "leather",
        nil,
    },
    {
        "Head",
        Vector3.new(1.4199999570846558, 0.11999999731779099, 0.2199999988079071),
        Vector3.new(0, 0.23999999463558197, -0.6000000238418579),
        "boneDark",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(0.1599999964237213, 0.4399999976158142, 0.11999999731779099),
        Vector3.new(0, -0.03999999910593033, -0.6800000071525574),
        "bone",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(1.3600000143051147, 0.6600000262260437, 0.1599999964237213),
        Vector3.new(0, 0.05000000074505806, 0.6200000047683716),
        "bone",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(0.14000000059604645, 0.5, 0.6000000238418579),
        Vector3.new(-0.6800000071525574, -0.019999999552965164, -0.30000001192092896),
        "boneDark",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(0.14000000059604645, 0.5, 0.6000000238418579),
        Vector3.new(0.6800000071525574, -0.019999999552965164, -0.30000001192092896),
        "boneDark",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(0.11999999731779099, 0.25999999046325684, 0.11999999731779099),
        Vector3.new(-0.36000001430511475, 0.7400000095367432, 0.10000000149011612),
        "boneDark",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(0.11999999731779099, 0.25999999046325684, 0.11999999731779099),
        Vector3.new(0.36000001430511475, 0.7400000095367432, 0.10000000149011612),
        "boneDark",
        "bone",
        nil,
    },
    {
        "Head",
        Vector3.new(0.14000000059604645, 0.3199999928474426, 0.14000000059604645),
        Vector3.new(0, 0.7799999713897705, -0.05000000074505806),
        "boneDark",
        "bone",
        nil,
    },
}
v4.riot_helmet = {
    {
        "Head",
        Vector3.new(1.4199999570846558, 0.46000000834465027, 1.440000057220459),
        Vector3.new(0, 0.47999998927116394, 0.03999999910593033),
        "riot",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(1.4199999570846558, 0.5600000023841858, 0.1599999964237213),
        Vector3.new(0, -0.1599999964237213, 0.6800000071525574),
        "riot",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(0.1599999964237213, 0.6200000047683716, 1.1200000047683716),
        Vector3.new(-0.7200000286102295, -0.05999999865889549, 0.11999999731779099),
        "riot",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(0.1599999964237213, 0.6200000047683716, 1.1200000047683716),
        Vector3.new(0.7200000286102295, -0.05999999865889549, 0.11999999731779099),
        "riot",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(1.3200000524520874, 0.6000000238418579, 0.07000000029802322),
        Vector3.new(0, -0.019999999552965164, -0.7200000286102295),
        "visor",
        "glass",
        0.55,
    },
    {
        "Head",
        Vector3.new(1.440000057220459, 0.10000000149011612, 0.14000000059604645),
        Vector3.new(0, 0.30000001192092896, -0.6800000071525574),
        "rim",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(0.10000000149011612, 0.14000000059604645, 0.14000000059604645),
        Vector3.new(-0.7799999713897705, 0.30000001192092896, -0.5),
        "rim",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(0.10000000149011612, 0.14000000059604645, 0.14000000059604645),
        Vector3.new(0.7799999713897705, 0.30000001192092896, -0.5),
        "rim",
        "plastic",
        nil,
    },
}
v4.tactical_vest = {
    {
        "UpperTorso",
        Vector3.new(2.299999952316284, 1.5, 1.3200000524520874),
        Vector3.new(0, 0.03999999910593033, 0),
        "olive",
        "fabric",
        nil,
    },
    {
        "LowerTorso",
        Vector3.new(2.259999990463257, 0.5, 1.2799999713897705),
        Vector3.new(0, -0.11999999731779099, 0),
        "olive",
        "fabric",
        nil,
    },
    {
        "UpperTorso",
        Vector3.new(1.5, 1, 0.07999999821186066),
        Vector3.new(0, 0.18000000715255737, -0.699999988079071),
        "plate",
        "plastic",
        nil,
    },
    {
        "UpperTorso",
        Vector3.new(1.5, 1, 0.07999999821186066),
        Vector3.new(0, 0.18000000715255737, 0.699999988079071),
        "plate",
        "plastic",
        nil,
    },
    {
        "UpperTorso",
        Vector3.new(0.47999998927116394, 0.3799999952316284, 0.20000000298023224),
        Vector3.new(-0.5799999833106995, -0.47999998927116394, -0.7400000095367432),
        "pouch",
        "fabric",
        nil,
    },
    {
        "UpperTorso",
        Vector3.new(0.47999998927116394, 0.3799999952316284, 0.20000000298023224),
        Vector3.new(0, -0.47999998927116394, -0.7400000095367432),
        "pouch",
        "fabric",
        nil,
    },
    {
        "UpperTorso",
        Vector3.new(0.47999998927116394, 0.3799999952316284, 0.20000000298023224),
        Vector3.new(0.5799999833106995, -0.47999998927116394, -0.7400000095367432),
        "pouch",
        "fabric",
        nil,
    },
    {
        "UpperTorso",
        Vector3.new(0.25999999046325684, 0.4000000059604645, 0.1599999964237213),
        Vector3.new(-0.9200000166893005, 0.30000001192092896, -0.7200000286102295),
        "strap",
        "plastic",
        nil,
    },
}

pair(v4.tactical_vest, "UpperTorso", "UpperTorso", Vector3.new(0.41999998688697815, 0.11999999731779099, 1.3600000143051147), Vector3.new(0.6200000047683716, 0.800000011920929, 0), "strap", "fabric", true)

v4.combat_pants = {
    {
        "LowerTorso",
        Vector3.new(2.259999990463257, 0.18000000715255737, 1.2599999904632568),
        Vector3.new(0, 0.019999999552965164, 0),
        "pad",
        "rubber",
        nil,
    },
}
pair(v4.combat_pants, "LeftUpperLeg", "RightUpperLeg", Vector3.new(1.2400000095367432, 1.1200000047683716, 1.2400000095367432), Vector3.new(0, 0.019999999552965164, -0.019999999552965164), "tan", "fabric")
pair(v4.combat_pants, "LeftLowerLeg", "RightLowerLeg", Vector3.new(1.2200000286102295, 1.0800000429153442, 1.2200000286102295), Vector3.new(0, 0.05999999865889549, -0.019999999552965164), "tan", "fabric")
pair(v4.combat_pants, "LeftLowerLeg", "RightLowerLeg", Vector3.new(0.8600000143051147, 0.46000000834465027, 0.1599999964237213), Vector3.new(0, 0.41999998688697815, -0.6600000262260437), "pad", "rubber")
pair(v4.combat_pants, "LeftUpperLeg", "RightUpperLeg", Vector3.new(0.14000000059604645, 0.4399999976158142, 0.5600000023841858), Vector3.new(0.6600000262260437, -0.07999999821186066, 0), "pouch", "fabric", true)

u860.BUILT = v4
u864.color.nvg = Color3.fromRGB(40, 44, 40)
u864.color.nvgDark = Color3.fromRGB(24, 26, 24)
u864.color.nvgLens = Color3.fromRGB(70, 210, 100)

local function s_2(a1, a2, a3, a4, a5, a6)
    -- Line: 248
    -- types: a1: string, a2: vector, a3: vector, a4: string, a5: string, a6: number?
    return {a1, a2, a3, a4, a5, a6}
end

u860.BUILT.night_vision_goggles = {
    {
        "Head",
        Vector3.new(1.2999999523162842, 0.1599999964237213, 1.2999999523162842),
        Vector3.new(0, 0.23999999463558197, 0.019999999552965164),
        "strap",
        "fabric",
        nil,
    },
    {
        "Head",
        Vector3.new(0.1599999964237213, 0.07999999821186066, 1.2999999523162842),
        Vector3.new(0, 0.6399999856948853, 0.019999999552965164),
        "strap",
        "fabric",
        nil,
    },
    {
        "Head",
        Vector3.new(0.5, 0.30000001192092896, 0.11999999731779099),
        Vector3.new(0, 0.3799999952316284, -0.6800000071525574),
        "nvg",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(0.7200000286102295, 0.25999999046325684, 0.23999999463558197),
        Vector3.new(0, 0.14000000059604645, -0.800000011920929),
        "nvg",
        "plastic",
        nil,
    },
    {
        "Head",
        Vector3.new(0.25999999046325684, 0.25999999046325684, 0.4000000059604645),
        Vector3.new(-0.20999999344348907, 0.11999999731779099, -1),
        "nvgDark",
        "rubber",
        nil,
    },
    {
        "Head",
        Vector3.new(0.25999999046325684, 0.25999999046325684, 0.4000000059604645),
        Vector3.new(0.20999999344348907, 0.11999999731779099, -1),
        "nvgDark",
        "rubber",
        nil,
    },
    {
        "Head",
        Vector3.new(0.20000000298023224, 0.20000000298023224, 0.03999999910593033),
        Vector3.new(-0.20999999344348907, 0.11999999731779099, -1.2100000381469727),
        "nvgLens",
        "glass",
        0.15,
    },
    {
        "Head",
        Vector3.new(0.20000000298023224, 0.20000000298023224, 0.03999999910593033),
        Vector3.new(0.20999999344348907, 0.11999999731779099, -1.2100000381469727),
        "nvgLens",
        "glass",
        0.15,
    },
    {
        "Head",
        Vector3.new(0.41999998688697815, 0.30000001192092896, 0.14000000059604645),
        Vector3.new(0, 0.2199999988079071, 0.7200000286102295),
        "nvg",
        "plastic",
        nil,
    },
}

function u860.IsSlot(a1) -- Line: 266; upvalues: u860 (val)
    local v1 = false

    if type(a1) == "string" then
        v1 = u860.SLOT_REGIONS[a1] ~= nil
    end

    return v1
end

function u860.ProtectionTable(a1, a2) -- Line: 272; upvalues: u860 (val)
    local v1, v2
    local v3 = {head = 0, torso = 0, legs = 0, feet = 0}

    if type(a1) ~= "table" then
        return v3
    end

    local v4, v5 = a1, a2

    for i, v in ipairs(u860.SLOTS) do
        v1 = v4[v]
        v2 = not (type(v1) ~= "string") and v5[v1] or nil
        v1 = v2
            and v2.kind == "wear" and v2.wear == v and tonumber(v2.protection)
            or 0

        if v1 and v1 == v1 and v1 > 0 then
            for i2, i3 in ipairs(u860.SLOT_REGIONS[v]) do
                v3[i3] = v3[i3] + v1
            end
        end
    end

    for k, j in pairs(v3) do
        v3[k] = (math.clamp(j, 0, u860.MAX_PROTECTION))
    end

    return v3
end

function u860.ProtectionText(a1) -- Line: 294; upvalues: u860 (val)
    if type(a1) == "table" and a1.kind == "wear" and u860.IsSlot(a1.wear) then
        local v1 = math.floor(((tonumber(a1.protection)) or 0) * 100 + 0.5)
        local v2 = {}

        for i, v in ipairs(u860.SLOT_REGIONS[a1.wear]) do
            table.insert(v2, u860.REGION_LABEL[v] .. " " .. v1 .. "%")
        end

        return "Protection: " .. table.concat(v2, ", ")
    end

    return ""
end

local function prep(a1) -- Line: 310; types: a1: userdata
    a1.Anchored = false
    a1.CanCollide = false
    a1.CanQuery = false
    a1.CanTouch = false
    a1.Massless = true
    a1.CastShadow = true
end

local function offsetOf(a1, a2) -- Line: 319; types: a1: userdata, a2: userdata
    local Attribute = a1:GetAttribute("Offset")

    if typeof(Attribute) == "CFrame" then
        return Attribute
    end

    if typeof(Attribute) == "Vector3" then
        return CFrame.new(Attribute)
    end

    if a2:GetAttribute("PivotIsOrigin") == true then
        return (a2:GetPivot()):ToObjectSpace(a1.CFrame)
    end

    return CFrame.identity
end

local function importedPieces(a1) -- Line: 332; upvalues: u860 (val), offsetOf (val)
    local Parent = script.Parent
    local Models = Parent and Parent:FindFirstChild("Models")
    local v1 = Models

    if v1 then
        v1 = false

        if type(a1.model) == "string" then
            v1 = Models:FindFirstChild(a1.model)
        end
    end

    if v1 and v1:IsA("Model") then
        local v2, v3
        local v4 = {}

        for i, v in ipairs(v1:GetDescendants()) do
            if v:IsA("BasePart") and u860.REF_SIZE[v.Name] then
                v2 = offsetOf(v, v1)
                v3 = v:Clone()

                for i2, i3 in ipairs(v3:GetDescendants()) do
                    if i3:IsA("BaseScript")
                        or i3:IsA("JointInstance")
                        or i3:IsA("WeldConstraint")
                        or i3:IsA("BasePart") then
                        i3:Destroy()
                    end
                end

                v3.Anchored = false
                v3.CanCollide = false
                v3.CanQuery = false
                v3.CanTouch = false
                v3.Massless = true
                v3.CastShadow = true

                table.insert(
                    v4,
                    {part = v.Name, inst = v3, offset = v2}
                )
            end
        end

        if #v4 == 0 then
            return nil
        end

        return v4
    end

    return nil
end

local function fallbackPieces(a1, a2) -- Line: 359; upvalues: u860 (val), u862 (val), u866 (val); types: a1: string
    local Part
    local v1 = u860.FALLBACK[a1]
    local color = v1 and v1.color
        or not (typeof(a2.color) ~= "Color3") and a2.color or u862
    local material = v1 and v1.material or Enum.Material.Fabric
    v1 = {}
    local _ipairs = ipairs
    local v2 = u866[a2.wear] or {}

    for i, v in _ipairs(v2) do
        Part = Instance.new("Part")
        Part.Name = v[1]
        Part.Size = v[2]
        Part.Color = color
        Part.Material = material
        Part.TopSurface = Enum.SurfaceType.Smooth
        Part.BottomSurface = Enum.SurfaceType.Smooth
        Part.Anchored = false
        Part.CanCollide = false
        Part.CanQuery = false
        Part.CanTouch = false
        Part.Massless = true
        Part.CastShadow = true

        table.insert(
            v1,
            {part = v[1], inst = Part, offset = CFrame.new(v[3])}
        )
    end

    return v1
end

local function builtPieces(a1) -- Line: 379; upvalues: u860 (val), u864 (val), u862 (val); types: a1: string
    local BUILT = u860.BUILT and u860.BUILT[a1]

    if type(BUILT) == "table" and #BUILT ~= 0 then
        local Fabric, Part, v1
        local v2 = {}

        for i, v in ipairs(BUILT) do
            if u860.REF_SIZE[v[1]] then
                Part = Instance.new("Part")
                Part.Name = v[1]
                Part.Size = v[2]
                v1 = u864.color[v[4]] or u862
                Part.Color = v1
                Fabric = u864.material[v[5]] or Enum.Material.Fabric
                Part.Material = Fabric
                Part.Transparency = if type(v[6]) ~= "number" then 0 else v[6]
                Part.TopSurface = Enum.SurfaceType.Smooth
                Part.BottomSurface = Enum.SurfaceType.Smooth
                Part.Anchored = false
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.Massless = true
                Part.CastShadow = true

                table.insert(
                    v2,
                    {part = v[1], inst = Part, offset = CFrame.new(v[3])}
                )
            end
        end

        if #v2 > 0 then
            return v2
        end

        return nil
    end

    return nil
end

function u860.BuildPieces(a1, a2)
    -- Line: 405
    -- upvalues: u860 (val), importedPieces (val), builtPieces (val), fallbackPieces (val)
    -- types: a1: string
    local v1 = a2[a1]

    if type(v1) == "table" and v1.kind == "wear" and u860.IsSlot(v1.wear) then
        local success, err = pcall(importedPieces, v1)

        if success and err then
            return err
        end

        if not success then
            warn("[Fust] Wear: model for", a1, "unusable:", err)
        end

        local success_2, err_2 = pcall(builtPieces, a1)

        if success_2 and err_2 then
            return err_2
        end

        return (fallbackPieces(a1, v1))
    end

    return {}
end

function u860.BuildPreview(a1, a2) -- Line: 425; upvalues: u860 (val); types: a1: string
    local inst
    local v1 = u860.BuildPieces(a1, a2)

    if #v1 == 0 then
        return nil
    end

    local Model = Instance.new("Model")
    Model.Name = a1

    for i, v in ipairs(v1) do
        inst = v.inst
        inst.Anchored = true
        inst.CastShadow = false
        inst.CFrame = (CFrame.new(u860.REST[v.part] or Vector3.new(0, 0, 0)))
            * v.offset
        inst.Parent = Model
    end

    return Model
end

return u860
