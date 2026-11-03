-- Script path: game:GetService("ReplicatedStorage").Fust.ItemIcons
-- Decompile time: 336.35 ms

local lazyShown, v1, v2
local Fust = game:GetService("ReplicatedStorage"):WaitForChild("Fust")
local u6344 = require((Fust:WaitForChild("Items")))
local u6346 = {FOV = 30}
local u6347 = {
    Muzzle = true,
    SightFront = true,
    SightRear = true,
    Grip = true,
    LightAttach = true,
    Eye = true,
    Front = true,
}
local u6348 = {
    "BasePart",
    "DataModelMesh",
    "SurfaceAppearance",
    "Decal",
    "Texture",
    "Model",
    "Folder",
    "WeldConstraint",
    "JointInstance",
}
local u6349 = {}
u6349.tool = {
    dir = Vector3.new(1, 0.20000000298023224, 0.30000001192092896),
    rot = CFrame.Angles(-0.7853981633974483, 0, 0),
}
u6349.gun = {
    dir = Vector3.new(1, 0.14000000059604645, 0.05999999865889549),
    rot = CFrame.Angles(0.13962634015954636, 0, 0),
}
u6349.deploy = {dir = Vector3.new(1, 0.75, -1.25), rot = CFrame.identity}
u6349.wear = {dir = Vector3.new(0.550000011920929, 0.30000001192092896, -1), rot = CFrame.identity}
u6349.upright = {dir = Vector3.new(0.6000000238418579, 0.3499999940395355, -1), rot = CFrame.identity}
u6349.pile = {dir = Vector3.new(0.75, 0.949999988079071, -1), rot = CFrame.identity}
u6349.arrow = {
    dir = Vector3.new(1, 0.20000000298023224, 0.30000001192092896),
    rot = CFrame.Angles(0.7853981633974483, 0, 0),
}
u6349.rounds = {
    dir = Vector3.new(0.75, 0.699999988079071, -1),
    rot = CFrame.Angles(1.5707963267948966, 0, 0),
}
u6349.pack = {dir = Vector3.new(0.550000011920929, 0.30000001192092896, 1), rot = CFrame.identity}
local u6350 = {pistol_bullet = 3, handmade_shell = 3}
local u6351 = {
    wood = "WD",
    stones = "ST",
    metal_ore = "MO",
    sulfur_ore = "SO",
    cloth = "CL",
    metal_fragments = "MF",
    sulfur = "SU",
    charcoal = "CH",
    hqm_ore = "HQO",
    high_quality_metal = "HQM",
    scrap = "SCR",
    gears = "GR",
    metal_spring = "SPR",
    metal_pipe = "PIP",
    rope = "RP",
    tarp = "TRP",
    sewing_kit = "SEW",
    metal_blade = "BLD",
    tech_trash = "TT",
    sheet_metal = "SHM",
    semi_body = "SAB",
    smg_body = "SMB",
    workbench_t2 = "WB2",
    berries = "BER",
    apple = "APL",
    potato = "POT",
    baked_potato = "BKP",
    burnt_potato = "BRP",
    carrot = "CAR",
    can_of_beans = "BNS",
    can_of_tuna = "TNA",
    dino_meat = "DMT",
    dino_steak = "STK",
    trex_tooth = "TTH",
    dino_trophy = "TRO",
    candle_set = "CDL",
    lantern = "LNT",
    wall_lantern = "WLT",
    ceiling_light = "CLT",
    coffee_can_helmet = "CCH",
    road_sign_jacket = "RSJ",
    road_sign_kilt = "RSK",
    metal_facemask = "MFM",
    metal_chest_plate = "MCP",
    heavy_plate_pants = "HPP",
    m249 = "LMG",
    lock_key = "KEY",
    semi_auto_pistol = "SAP",
    ladder = "LAD",
    bolt_action_rifle = "BOLT",
    lr_sniper = "LR",
    red_dot_sight = "RDS",
    holo_sight = "HOLO",
    scope_4x = "4X",
    acog_sight = "ACOG",
    reflex_sight = "RFX",
    muzzle_brake = "BRK",
    silencer = "SUP",
    vertical_grip = "GRIP",
    laser_sight = "LSR",
    mag_extender = "XMAG",
    muzzle_boost = "BST",
    flashlight = "LGT",
    low_grade_fuel = "FUEL",
    large_furnace = "LFU",
    barricade_wall = "BAR",
    wood_barricade = "WBR",
    medical_syringe = "MSP",
    large_medkit = "MED",
    workbench_t3 = "WB3",
    mixing_table = "MIX",
    rocket_launcher = "RL",
    rocket = "RKT",
    jackhammer = "JKH",
    chainsaw = "SAW",
    solar_panel = "SOL",
    battery = "BAT",
    small_generator = "GEN",
    auto_turret = "TUR",
    aa_turret = "AA",
    aa_missile = "AAM",
    flare_pack = "FLR",
    smoke_grenade = "SMK",
    molotov = "MOL",
    duel_rifle = "ARF",
    duel_ammo = "ARA",
    garage_door = "GAR",
    window_bars = "BARS",
    wood_double_door = "WDD",
    metal_double_door = "MDD",
    armored_double_door = "ADD",
    ladder_hatch = "HAT",
    floor_grill = "GRL",
    tri_floor_grill = "TGR",
    tri_ladder_hatch = "THT",
    high_wood_wall = "HWW",
    high_stone_wall = "HSW",
    high_wood_gate = "HWG",
    high_stone_gate = "HSG",
    skin_bench = "SKN",
    double_barrel = "DB",
    supply_signal = "SIG",
    grenade = "GR",
    explosive_rifle_ammo = "EXP",
    hv_rocket = "HVR",
    incendiary_rocket = "INC",
    hv_rifle_ammo = "HV",
    crossbow = "XBOW",
    compound_bow = "CMP",
    buckshot_shell = "BUCK",
    slug_shell = "SLUG",
    bunker_keycard = "KEY",
    scar = "SCAR",
    pump_shotgun = "PUMP",
    service_pistol = "SVC",
    tactical_smg = "TSMG",
    drum_smg = "DRUM",
    lever_carbine = "LEVR",
    repair_bench = "REP",
    hide_hood = "HHD",
    hide_vest = "HVS",
    hide_pants = "HPN",
    hide_boots = "HBT",
    bone_helmet = "BNH",
    riot_helmet = "RIOT",
    tactical_vest = "TAC",
    combat_pants = "CMB",
    wardrobe = "WRD",
    locker = "LKR",
    storage_barrel = "BRL",
    bamboo_rack = "RCK",
    wall_mount = "WM",
    night_vision_goggles = "NVG",
    toilet = "WC",
    atv_wagon = "WGN",
    shelves = "SHF",
}
local u6352 = Color3.fromHex("5A5148")
local u6254 = {}
local u210 = Color3.fromRGB(122, 86, 52)
local u215 = Color3.fromRGB(88, 61, 39)
local v3 = Color3.fromRGB(128, 126, 120)
local v4 = Color3.fromRGB(100, 98, 94)
local v5 = Color3.fromRGB(165, 168, 172)
local v6 = Color3.fromRGB(120, 123, 128)
local v7 = Color3.fromRGB(150, 128, 92)
local v8 = Color3.fromRGB(40, 37, 34)
local v9 = Color3.fromRGB(64, 46, 34)
local Material = Enum.Material
local v10 = {}
local v11 = {}
local v12 = {}
local identity = CFrame.identity
local v13 = Color3.fromRGB(32, 32, 34)
v12[1] = "Handle"
v12[2] = (Vector3.new(0.1599999964237213, 0.550000011920929, 0.1599999964237213))
v12[3] = identity
v12[4] = v13
v12[5] = Material.Plastic
local v14 = {}
v13 = CFrame.new(0, 0.06, -0.3)
local v15 = Color3.fromRGB(62, 64, 67)
v14[1] = "Tank"
v14[2] = (Vector3.new(0.4000000059604645, 0.6200000047683716, 0.30000001192092896))
v14[3] = v13
v14[4] = v15
v14[5] = Material.Plastic
local v16 = {}
v15 = CFrame.new(0, 0.68, -0.2)
local v17 = Color3.fromRGB(226, 104, 32)
v16[1] = "Body"
v16[2] = (Vector3.new(0.5, 0.800000011920929, 0.6200000047683716))
v16[3] = v15
v16[4] = v17
v16[5] = Material.SmoothPlastic
local v18 = {}
v17 = CFrame.new(-0.28, 0.6, -0.22)
local v19 = Color3.fromRGB(62, 64, 67)
v18[1] = "Starter"
v18[2] = (Vector3.new(0.07000000029802322, 0.44999998807907104, 0.41999998688697815))
v18[3] = v17
v18[4] = v19
v18[5] = Material.Plastic
v13 = {}
v19 = CFrame.new(0.28, 0.92, -0.32)
local v20 = Color3.fromRGB(62, 64, 67)
v13[1] = "Clutch"
v13[2] = (Vector3.new(0.07000000029802322, 0.4000000059604645, 0.3400000035762787))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Plastic
v15 = {}
v20 = CFrame.new(-0.02, 0.92, 0.3)
local v21 = Color3.fromRGB(32, 32, 34)
v15[1] = "FrontBar"
v15[2] = (Vector3.new(0.6000000238418579, 0.10000000149011612, 0.10000000149011612))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Plastic
v17 = {}
v21 = CFrame.new(-0.3, 0.92, 0.05)
local v22 = Color3.fromRGB(32, 32, 34)
v17[1] = "FrontLeg"
v17[2] = (Vector3.new(0.10000000149011612, 0.10000000149011612, 0.550000011920929))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Plastic
v19 = {}
v22 = CFrame.new(0, 1.06, 0.22)
local v23 = Color3.fromRGB(32, 32, 34)
v19[1] = "Guard"
v19[2] = (Vector3.new(0.5, 0.05999999865889549, 0.3799999952316284))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Plastic
v20 = {}
v23 = CFrame.new(0, 1.86, -0.36)
local v24 = Color3.fromRGB(176, 178, 182)
v20[1] = "Bar"
v20[2] = (Vector3.new(0.05999999865889549, 1.649999976158142, 0.27000001072883606))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0, 1.875, -0.36)
local v25 = Color3.fromRGB(74, 74, 76)
v21[1] = "Chain"
v21[2] = (Vector3.new(0.03999999910593033, 1.7200000286102295, 0.3400000035762787))
v21[3] = v24
v21[4] = v25
v21[5] = Material.DiamondPlate
v11[1] = v12
v11[2] = v14
v11[3] = v16
v11[4] = v18
v11[5] = v13
v11[6] = v15
v11[7] = v17
v11[8] = v19
v11[9] = v20
v11[10] = v21
v10.chainsaw = v11
v11 = {}
v12 = {}
local identity_2 = CFrame.identity
v13 = Color3.fromRGB(32, 32, 34)
v12[1] = "Handle"
v12[2] = (Vector3.new(0.17000000178813934, 0.17000000178813934, 0.5600000023841858))
v12[3] = identity_2
v12[4] = v13
v12[5] = Material.Plastic
v14 = {}
v13 = CFrame.new(0, 0.13, 0.28)
v15 = Color3.fromRGB(32, 32, 34)
v14[1] = "GripTop"
v14[2] = (Vector3.new(0.17000000178813934, 0.41999998688697815, 0.15000000596046448))
v14[3] = v13
v14[4] = v15
v14[5] = Material.Plastic
v16 = {}
v15 = CFrame.new(0, 0.13, -0.28)
v17 = Color3.fromRGB(32, 32, 34)
v16[1] = "GripBottom"
v16[2] = (Vector3.new(0.17000000178813934, 0.41999998688697815, 0.15000000596046448))
v16[3] = v15
v16[4] = v17
v16[5] = Material.Plastic
v18 = {}
v17 = CFrame.new(0, 0.64, 0)
v19 = Color3.fromRGB(236, 184, 34)
v18[1] = "Body"
v18[2] = (Vector3.new(0.5, 0.8500000238418579, 0.6200000047683716))
v18[3] = v17
v18[4] = v19
v18[5] = Material.SmoothPlastic
v13 = {}
v19 = CFrame.new(0, 0.42, 0)
v20 = Color3.fromRGB(32, 32, 34)
v13[1] = "Vents"
v13[2] = (Vector3.new(0.5299999713897705, 0.14000000059604645, 0.6499999761581421))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Plastic
v15 = {}
v20 = CFrame.new(0, 1.3, -0.05)
v21 = Color3.fromRGB(96, 98, 102)
v15[1] = "Nose"
v15[2] = (Vector3.new(0.36000001430511475, 0.5, 0.36000001430511475))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = CFrame.new(0, 1.65, -0.05)
v22 = Color3.fromRGB(32, 32, 34)
v17[1] = "Chuck"
v17[2] = (Vector3.new(0.25999999046325684, 0.20000000298023224, 0.25999999046325684))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Plastic
v19 = {}
v22 = CFrame.new(0, 2.17, -0.05)
v23 = Color3.fromRGB(176, 178, 182)
v19[1] = "Bit"
v19[2] = (Vector3.new(0.10000000149011612, 0.8500000238418579, 0.10000000149011612))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(0, 2.7, -0.05)
v24 = Color3.fromRGB(96, 98, 102)
v20[1] = "Chisel"
v20[2] = (Vector3.new(0.2199999988079071, 0.23999999463558197, 0.05000000074505806))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(-0.4, 1.3, -0.05)
v25 = Color3.fromRGB(32, 32, 34)
v21[1] = "SideHandle"
v21[2] = (Vector3.new(0.47999998927116394, 0.12999999523162842, 0.12999999523162842))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Plastic
v11[1] = v12
v11[2] = v14
v11[3] = v16
v11[4] = v18
v11[5] = v13
v11[6] = v15
v11[7] = v17
v11[8] = v19
v11[9] = v20
v11[10] = v21
v10.jackhammer = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(1.0499999523162842, 0.8500000238418579, 1.100000023841858),
    CFrame.identity,
    v3,
    Material.Slate,
}
v14 = {}
v13 = (CFrame.new(0.12, 0.28, -0.18)) * CFrame.Angles(0.45, 0.6, 0.3)
v14[1] = "Head"
v14[2] = (Vector3.new(0.75, 0.6000000238418579, 0.699999988079071))
v14[3] = v13
v14[4] = v4
v14[5] = Material.Slate
v11[1] = v12
v11[2] = v14
v10.rock = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(0.2199999988079071, 2.200000047683716, 0.2199999988079071),
    CFrame.identity,
    u210,
    Material.WoodPlanks,
}
v14 = {}
v13 = CFrame.new(0, 1.2, 0)
v14[1] = "Head"
v14[2] = (Vector3.new(0.36000001430511475, 0.550000011920929, 0.36000001430511475))
v14[3] = v13
v14[4] = v9
v14[5] = Material.Fabric
v11[1] = v12
v11[2] = v14
v10.torch = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(0.2199999988079071, 2.4000000953674316, 0.2199999988079071),
    CFrame.identity,
    u210,
    Material.WoodPlanks,
}
v14 = {}
v13 = CFrame.new(0, 0.95, -0.28)
v14[1] = "Head"
v14[2] = (Vector3.new(0.25999999046325684, 0.550000011920929, 0.949999988079071))
v14[3] = v13
v14[4] = v3
v14[5] = Material.Slate
v16 = {}
v15 = CFrame.new(0, 0.95, 0)
v16[1] = "Lash"
v16[2] = (Vector3.new(0.30000001192092896, 0.3199999928474426, 0.30000001192092896))
v16[3] = v15
v16[4] = v7
v16[5] = Material.Fabric
v11[1] = v12
v11[2] = v14
v11[3] = v16
v10.stone_hatchet = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(0.2199999988079071, 2.4000000953674316, 0.2199999988079071),
    CFrame.identity,
    u210,
    Material.WoodPlanks,
}
v14 = {}
v13 = CFrame.new(0, 1, -0.15)
v14[1] = "Head"
v14[2] = (Vector3.new(0.25999999046325684, 0.30000001192092896, 1.600000023841858))
v14[3] = v13
v14[4] = v3
v14[5] = Material.Slate
v16 = {}
v15 = CFrame.new(0, 0.97, -1.15)
v16[1] = "Tip"
v16[2] = (Vector3.new(0.18000000715255737, 0.20000000298023224, 0.44999998807907104))
v16[3] = v15
v16[4] = v4
v16[5] = Material.Slate
v11[1] = v12
v11[2] = v14
v11[3] = v16
v10.stone_pickaxe = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(0.2199999988079071, 2.4000000953674316, 0.2199999988079071),
    CFrame.identity,
    u215,
    Material.WoodPlanks,
}
v14 = {}
v13 = CFrame.new(0, 0.95, -0.3)
v14[1] = "Head"
v14[2] = (Vector3.new(0.20000000298023224, 0.6000000238418579, 1))
v14[3] = v13
v14[4] = v5
v14[5] = Material.Metal
v16 = {}
v15 = CFrame.new(0, -0.8, 0)
v16[1] = "Wrap"
v16[2] = (Vector3.new(0.25999999046325684, 0.6000000238418579, 0.25999999046325684))
v16[3] = v15
v16[4] = v8
v16[5] = Material.Fabric
v11[1] = v12
v11[2] = v14
v11[3] = v16
v10.metal_hatchet = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(0.2199999988079071, 2.4000000953674316, 0.2199999988079071),
    CFrame.identity,
    u215,
    Material.WoodPlanks,
}
v14 = {}
v13 = CFrame.new(0, 1, -0.2)
v14[1] = "Head"
v14[2] = (Vector3.new(0.2199999988079071, 0.25999999046325684, 1.7999999523162842))
v14[3] = v13
v14[4] = v5
v14[5] = Material.Metal
v16 = {}
v15 = CFrame.new(0, 0.97, -1.3)
v16[1] = "Tip"
v16[2] = (Vector3.new(0.14000000059604645, 0.1599999964237213, 0.5))
v16[3] = v15
v16[4] = v6
v16[5] = Material.Metal
v11[1] = v12
v11[2] = v14
v11[3] = v16
v10.metal_pickaxe = v11
v11 = {}
v12 = {
    "Handle",
    Vector3.new(0.2199999988079071, 2.200000047683716, 0.2199999988079071),
    CFrame.identity,
    u210,
    Material.WoodPlanks,
}
v14 = {}
v13 = CFrame.new(0, 0.95, -0.15)
v14[1] = "Head"
v14[2] = (Vector3.new(0.30000001192092896, 0.4000000059604645, 0.6000000238418579))
v14[3] = v13
v14[4] = v3
v14[5] = Material.Slate
v11[1] = v12
v11[2] = v14
v10._generic = v11
u6254.TOOLS = v10
v10 = Color3.fromRGB(62, 66, 60)
v11 = Color3.fromRGB(34, 35, 36)
v12 = Color3.fromRGB(150, 152, 156)
v14 = Color3.fromRGB(217, 207, 184)

local function tilt(a1) -- Line: 208; types: a1: number
    return CFrame.Angles(math.rad(a1), 0, 0)
end

local TOOLS = u6254.TOOLS
v18 = {}
v13 = {
    "Handle",
    Vector3.new(0.14000000059604645, 1.2999999523162842, 0.20000000298023224),
    CFrame.identity,
    v10,
    Material.Metal,
}
v15 = {}
v20 = CFrame.new(0, -0.05, 0.04)
v15[1] = "Wrap"
v15[2] = (Vector3.new(0.18000000715255737, 0.36000001430511475, 0.23999999463558197))
v15[3] = v20
v15[4] = v8
v15[5] = Material.Fabric
v17 = {}
v21 = CFrame.new(0.08, 0.16, -0.02)
v17[1] = "Shelf"
v17[2] = (Vector3.new(0.05999999865889549, 0.03999999910593033, 0.1599999964237213))
v17[3] = v21
v17[4] = v10
v17[5] = Material.Metal
v19 = {}
v22 = (CFrame.new(0, 1.07, 0.14)) * CFrame.Angles(0.3141592653589793, 0, 0)
v19[1] = "LimbUpper"
v19[2] = (Vector3.new(0.11999999731779099, 0.8999999761581421, 0.07000000029802322))
v19[3] = v22
v19[4] = v11
v19[5] = Material.SmoothPlastic
v20 = {}
v23 = (CFrame.new(0, -1.07, 0.14)) * CFrame.Angles(-0.3141592653589793, 0, 0)
v20[1] = "LimbLower"
v20[2] = (Vector3.new(0.11999999731779099, 0.8999999761581421, 0.07000000029802322))
v20[3] = v23
v20[4] = v11
v20[5] = Material.SmoothPlastic
v21 = {}
v24 = CFrame.new(0, 1.5, 0.28)
v21[1] = "CamUpper"
v21[2] = (Vector3.new(0.07000000029802322, 0.23999999463558197, 0.23999999463558197))
v21[3] = v24
v21[4] = v12
v21[5] = Material.Metal
v22 = {}
v25 = CFrame.new(0, -1.5, 0.28)
v22[1] = "CamLower"
v22[2] = (Vector3.new(0.07000000029802322, 0.23999999463558197, 0.23999999463558197))
v22[3] = v25
v22[4] = v12
v22[5] = Material.Metal
v23 = {}
local v26 = CFrame.new(0, 0, 0.36)
v23[1] = "String"
v23[2] = (Vector3.new(0.02199999988079071, 3, 0.02199999988079071))
v23[3] = v26
v23[4] = v14
v23[5] = Material.SmoothPlastic
v24 = {}
local v27 = CFrame.new(0.03, 0, 0.24)
v24[1] = "Cable"
v24[2] = (Vector3.new(0.01600000075995922, 2.9000000953674316, 0.01600000075995922))
v24[3] = v27
v24[4] = v11
v24[5] = Material.SmoothPlastic
v25 = {}
local v28 = CFrame.new(0, -0.22, -0.36)
v25[1] = "Stabilizer"
v25[2] = (Vector3.new(0.05999999865889549, 0.05999999865889549, 0.550000011920929))
v25[3] = v28
v25[4] = v11
v25[5] = Material.SmoothPlastic
v26 = {}
local v29 = CFrame.new(-0.09, 0.32, -0.05)
v26[1] = "Sight"
v26[2] = (Vector3.new(0.03999999910593033, 0.14000000059604645, 0.05999999865889549))
v26[3] = v29
v26[4] = v12
v26[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v18[7] = v22
v18[8] = v23
v18[9] = v24
v18[10] = v25
v18[11] = v26
TOOLS.compound_bow = v18
local TOOLS_2 = u6254.TOOLS
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.05, 0)
v13[1] = "Handle"
v13[2] = (Vector3.new(0.1599999964237213, 1.5, 0.18000000715255737))
v13[3] = v19
v13[4] = u210
v13[5] = Material.Wood
v15 = {}
v20 = CFrame.new(0, -0.55, 0.08)
v15[1] = "Butt"
v15[2] = (Vector3.new(0.20000000298023224, 0.41999998688697815, 0.3400000035762787))
v15[3] = v20
v15[4] = u215
v15[5] = Material.Wood
v17 = {}
v21 = CFrame.new(0, 0.25, -0.11)
v17[1] = "Rail"
v17[2] = (Vector3.new(0.05999999865889549, 1.2000000476837158, 0.03999999910593033))
v17[3] = v21
v17[4] = v6
v17[5] = Material.Metal
v19 = {}
v22 = (CFrame.new(0, -0.15, 0.24)) * CFrame.Angles(-0.2617993877991494, 0, 0)
v19[1] = "TriggerGrip"
v19[2] = (Vector3.new(0.11999999731779099, 0.14000000059604645, 0.3199999928474426))
v19[3] = v22
v19[4] = u215
v19[5] = Material.Wood
v20 = {}
v23 = CFrame.new(0, 0.02, 0.14)
v20[1] = "Trigger"
v20[2] = (Vector3.new(0.029999999329447746, 0.07999999821186066, 0.10000000149011612))
v20[3] = v23
v20[4] = v6
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0, 0.82, -0.02)
v21[1] = "Prod"
v21[2] = (Vector3.new(1.7999999523162842, 0.10000000149011612, 0.07999999821186066))
v21[3] = v24
v21[4] = v5
v21[5] = Material.Metal
v22 = {}
v25 = CFrame.new(-0.88, 0.75, -0.02)
v22[1] = "ProdTipL"
v22[2] = (Vector3.new(0.07999999821186066, 0.14000000059604645, 0.10000000149011612))
v22[3] = v25
v22[4] = v6
v22[5] = Material.Metal
v23 = {}
v26 = CFrame.new(0.88, 0.75, -0.02)
v23[1] = "ProdTipR"
v23[2] = (Vector3.new(0.07999999821186066, 0.14000000059604645, 0.10000000149011612))
v23[3] = v26
v23[4] = v6
v23[5] = Material.Metal
v24 = {}
v27 = CFrame.new(0, 0.84, -0.02)
v24[1] = "Wrap"
v24[2] = (Vector3.new(0.23999999463558197, 0.1599999964237213, 0.20000000298023224))
v24[3] = v27
v24[4] = v8
v24[5] = Material.Fabric
v25 = {}
v28 = CFrame.new(0, 0.7, -0.02)
v25[1] = "String"
v25[2] = (Vector3.new(1.7599999904632568, 0.024000000208616257, 0.024000000208616257))
v25[3] = v28
v25[4] = v14
v25[5] = Material.SmoothPlastic
v26 = {}
v29 = CFrame.new(0, 0.95, 0.02)
v26[1] = "Stirrup"
v26[2] = (Vector3.new(0.25999999046325684, 0.05999999865889549, 0.05999999865889549))
v26[3] = v29
v26[4] = v6
v26[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v18[7] = v22
v18[8] = v23
v18[9] = v24
v18[10] = v25
v18[11] = v26
TOOLS_2.crossbow = v18

local function part(a1, a2, a3, a4, a5, a6, a7)
    -- Line: 239
    -- types: a1: userdata, a2: string, a3: vector, a4: userdata, a5: CFrame
    local Part = Instance.new("Part")
    Part.Name = a2

    if a7 then
        Part.Shape = a7
    end

    Part.Size = a3
    Part.CFrame = a4
    Part.Color = a5
    Part.Material = a6
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = false
    Part.CastShadow = false
    Part.TopSurface = Enum.SurfaceType.Smooth
    Part.BottomSurface = Enum.SurfaceType.Smooth
    Part.Parent = a1

    return Part
end

function u6254.tool(a1) -- Line: 260; upvalues: u6254 (val); types: a1: string
    local Part, v1, v2, v3, v4, v5
    local Model = Instance.new("Model")
    Model.Name = a1
    local _ipairs = ipairs
    local _generic = u6254.TOOLS[a1] or u6254.TOOLS._generic

    for i, v in _ipairs(_generic) do
        v3 = v[1]
        v4 = v[2]
        v5 = v[3]
        v1 = v[4]
        v2 = v[5]
        Part = Instance.new("Part")
        Part.Name = v3
        Part.Size = v4
        Part.CFrame = v5
        Part.Color = v1
        Part.Material = v2
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanTouch = false
        Part.CanQuery = false
        Part.CastShadow = false
        Part.TopSurface = Enum.SurfaceType.Smooth
        Part.BottomSurface = Enum.SurfaceType.Smooth
        Part.Parent = Model
    end

    return Model
end

v7 = Color3.fromRGB(44, 45, 48)
v6 = Color3.fromRGB(58, 61, 65)
v5 = Color3.fromRGB(140, 138, 132)
v4 = Color3.fromRGB(28, 29, 31)
v3 = CFrame.Angles(-0.317649923862968, 0, 0)
v10 = Color3.fromRGB(84, 96, 72)
v11 = Color3.fromRGB(62, 70, 54)
v12 = Color3.fromRGB(46, 48, 46)
v14 = {}
v16 = {}
v18 = {}
v17 = CFrame.new(0, 0.17, -0.25)
v18[1] = "Handle"
v18[2] = (Vector3.new(0.2199999988079071, 0.14000000059604645, 0.8999999761581421))
v18[3] = v17
v18[4] = v11
v18[5] = Material.Metal
v13 = {}
v19 = CFrame.new(0, 0.42, -0.55)
v13[1] = "Tube"
v13[2] = (Vector3.new(0.4399999976158142, 0.4399999976158142, 4.099999904632568))
v13[3] = v19
v13[4] = v10
v13[5] = Material.Metal
v15 = {}
v20 = CFrame.new(0, 0.42, 1.62)
v15[1] = "Bell"
v15[2] = (Vector3.new(0.5600000023841858, 0.5600000023841858, 0.550000011920929))
v15[3] = v20
v15[4] = v12
v15[5] = Material.Metal
v17 = {}
v21 = CFrame.new(0, 0.42, -2.56)
v17[1] = "MuzzleRing"
v17[2] = (Vector3.new(0.5, 0.5, 0.1599999964237213))
v17[3] = v21
v17[4] = v12
v17[5] = Material.Metal
v19 = {}
v22 = (CFrame.new(0, -0.04, 0.05)) * CFrame.Angles(-0.2617993877991494, 0, 0)
v19[1] = "PistolGrip"
v19[2] = (Vector3.new(0.15000000596046448, 0.41999998688697815, 0.2199999988079071))
v19[3] = v22
v19[4] = v4
v19[5] = Material.Plastic
v20 = {}
v23 = CFrame.new(0, 0.02, -1.3)
v20[1] = "FrontGrip"
v20[2] = (Vector3.new(0.15000000596046448, 0.4000000059604645, 0.20000000298023224))
v20[3] = v23
v20[4] = v4
v20[5] = Material.Plastic
v21 = {}
v24 = CFrame.new(0, 0.14, 0.85)
v21[1] = "ShoulderRest"
v21[2] = (Vector3.new(0.1599999964237213, 0.18000000715255737, 0.699999988079071))
v21[3] = v24
v21[4] = v4
v21[5] = Material.Fabric
v22 = {}
v25 = CFrame.new(-0.33, 0.42, 0.3)
v22[1] = "SightBracket"
v22[2] = (Vector3.new(0.25999999046325684, 0.05000000074505806, 0.07999999821186066))
v22[3] = v25
v22[4] = v12
v22[5] = Material.Metal
v23 = {}
v26 = CFrame.new(-0.34, 0.52, 0.3)
v23[1] = "SightFrame"
v23[2] = (Vector3.new(0.14499999582767487, 0.1599999964237213, 0.02500000037252903))
v23[3] = v26
v23[4] = v12
v23[5] = Material.Metal
v16[1] = v18
v16[2] = v13
v16[3] = v15
v16[4] = v17
v16[5] = v19
v16[6] = v20
v16[7] = v21
v16[8] = v22
v16[9] = v23
v14.rocket_launcher = v16
v16 = {}
v18 = {}
v17 = CFrame.new(0, 0.1675, -0.3628)
v18[1] = "Handle"
v18[2] = (Vector3.new(0.11999999731779099, 0.07500000298023224, 0.7699999809265137))
v18[3] = v17
v18[4] = v7
v18[5] = Material.Plastic
v13 = {}
v19 = CFrame.new(0, 0.15, 0.0547)
v13[1] = "Tang"
v13[2] = (Vector3.new(0.11999999731779099, 0.10000000149011612, 0.06499999761581421))
v13[3] = v19
v13[4] = v7
v13[5] = Material.Plastic
v15 = {}
v20 = CFrame.new(0, -0.06, 0.0198) * v3
v15[1] = "GripBlock"
v15[2] = (Vector3.new(0.1340000033378601, 0.4000000059604645, 0.20000000298023224))
v15[3] = v20
v15[4] = v7
v15[5] = Material.Plastic
v17 = {}
v21 = CFrame.new(0, 0.018, -0.2578)
v17[1] = "Guard"
v17[2] = (Vector3.new(0.08399999886751175, 0.026000000536441803, 0.30000001192092896))
v17[3] = v21
v17[4] = v7
v17[5] = Material.Plastic
v19 = {}
v22 = CFrame.new(0, 0.079, -0.4058)
v19[1] = "GuardFront"
v19[2] = (Vector3.new(0.08399999886751175, 0.12200000137090683, 0.026000000536441803))
v19[3] = v22
v19[4] = v7
v19[5] = Material.Plastic
v20 = {}
v23 = CFrame.new(0, 0.095, -0.2128)
v20[1] = "Trigger"
v20[2] = (Vector3.new(0.03400000184774399, 0.09000000357627869, 0.024000000208616257))
v20[3] = v23
v20[4] = v4
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0, -0.2652, 0.0873) * v3
v21[1] = "Mag"
v21[2] = (Vector3.new(0.12399999797344208, 0.03500000014901161, 0.2150000035762787))
v21[3] = v24
v21[4] = v4
v21[5] = Material.Metal
v22 = {}
v25 = CFrame.new(0, 0.27, -0.3878)
v22[1] = "Slide"
v22[2] = (Vector3.new(0.11400000005960464, 0.12999999523162842, 0.8299999833106995))
v22[3] = v25
v22[4] = v6
v22[5] = Material.Metal
v23 = {}
v26 = CFrame.new(-0.0305, 0.3565, -0.0008)
v23[1] = "SlideRearL"
v23[2] = (Vector3.new(0.028999999165534973, 0.0430000014603138, 0.03999999910593033))
v23[3] = v26
v23[4] = v6
v23[5] = Material.Metal
v24 = {}
v27 = CFrame.new(0.0305, 0.3565, -0.0008)
v24[1] = "SlideRearR"
v24[2] = (Vector3.new(0.028999999165534973, 0.0430000014603138, 0.03999999910593033))
v24[3] = v27
v24[4] = v6
v24[5] = Material.Metal
v25 = {}
v28 = CFrame.new(0, 0.3455, -0.7652)
v25[1] = "SlideFront"
v25[2] = (Vector3.new(0.02199999988079071, 0.03500000014901161, 0.029999999329447746))
v25[3] = v28
v25[4] = v6
v25[5] = Material.Metal
v26 = {}
v29 = CFrame.new(0.0185, 0.336, -0.1828)
v26[1] = "Port"
v26[2] = (Vector3.new(0.04500000178813934, 0.006000000052154064, 0.1599999964237213))
v26[3] = v29
v26[4] = v5
v26[5] = Material.Metal
v27 = {}
local v30 = CFrame.new(0, 0.25, -0.8068)
v27[1] = "Crown"
v27[2] = (Vector3.new(0.05999999865889549, 0.05999999865889549, 0.012000000104308128))
v27[3] = v30
v27[4] = v5
v27[5] = Material.Metal
v16[1] = v18
v16[2] = v13
v16[3] = v15
v16[4] = v17
v16[5] = v19
v16[6] = v20
v16[7] = v21
v16[8] = v22
v16[9] = v23
v16[10] = v24
v16[11] = v25
v16[12] = v26
v16[13] = v27
v14.semi_auto_pistol = v16
u6254.GUNS = v14

function u6254.gun(a1) -- Line: 308; upvalues: u6254 (val); types: a1: string
    local Part, v1, v2, v3, v4, v5, v6
    local v7 = u6254.GUNS[a1]

    if not v7 then
        return nil
    end

    local Model = Instance.new("Model")
    Model.Name = a1

    for i, v in ipairs(v7) do
        v5 = v[1]
        v6 = v[2]
        v1 = v[3]
        v2 = v[4]
        v3 = v[5]
        v4 = v[6]
        Part = Instance.new("Part")
        Part.Name = v5

        if v4 then
            Part.Shape = v4
        end

        Part.Size = v6
        Part.CFrame = v1
        Part.Color = v2
        Part.Material = v3
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanTouch = false
        Part.CanQuery = false
        Part.CastShadow = false
        Part.TopSurface = Enum.SurfaceType.Smooth
        Part.BottomSurface = Enum.SurfaceType.Smooth
        Part.Parent = Model
    end

    return Model
end

v10 = Color3.fromRGB(96, 58, 34)
v11 = Color3.fromRGB(70, 42, 26)
v12 = Color3.fromRGB(112, 108, 102)
v14 = Color3.fromRGB(46, 48, 54)
v16 = Color3.fromRGB(150, 150, 146)
local Cylinder_2 = Enum.PartType.Cylinder
v13 = CFrame.Angles(0, 1.5707963267948966, 0)
v15 = CFrame.Angles(0.10471975511965978, 0, 0)
local GUNS = u6254.GUNS
v19 = {}
v20 = {}
v23 = CFrame.new(0, 0.1, 0.12)
v20[1] = "Handle"
v20[2] = (Vector3.new(0.12999999523162842, 0.20000000298023224, 0.4399999976158142))
v20[3] = v23
v20[4] = v10
v20[5] = Material.Wood
v21 = {}
v24 = (CFrame.new(0, 0.01, 0.14)) * CFrame.Angles(-0.20943951023931956, 0, 0)
v21[1] = "GripBlock"
v21[2] = (Vector3.new(0.11999999731779099, 0.14000000059604645, 0.30000001192092896))
v21[3] = v24
v21[4] = v11
v21[5] = Material.Wood
v22 = {}
v25 = CFrame.new(0, 0.1, 0.62) * v15
v22[1] = "Stock"
v22[2] = (Vector3.new(0.15000000596046448, 0.2800000011920929, 0.5799999833106995))
v22[3] = v25
v22[4] = v10
v22[5] = Material.Wood
v23 = {}
v26 = CFrame.new(0, 0.03, 1.02) * v15
v23[1] = "Butt"
v23[2] = (Vector3.new(0.1599999964237213, 0.4399999976158142, 0.30000001192092896))
v23[3] = v26
v23[4] = v10
v23[5] = Material.Wood
v24 = {}
v27 = CFrame.new(0, 0.02, 1.19) * v15
v28 = Color3.fromRGB(34, 30, 28)
v24[1] = "ButtPad"
v24[2] = (Vector3.new(0.17000000178813934, 0.44999998807907104, 0.05000000074505806))
v24[3] = v27
v24[4] = v28
v24[5] = Material.Rubber
v25 = {}
v28 = CFrame.new(0, 0.29, -0.28)
v25[1] = "Receiver"
v25[2] = (Vector3.new(0.25, 0.23999999463558197, 0.4000000059604645))
v25[3] = v28
v25[4] = v12
v25[5] = Material.Metal
v26 = {}
v29 = CFrame.new(-0.07, 0.34, -1.51) * v13
v26[1] = "BarrelL"
v26[2] = (Vector3.new(2.0999999046325684, 0.13600000739097595, 0.13600000739097595))
v26[3] = v29
v26[4] = v14
v26[5] = Material.Metal
v26[6] = Cylinder_2
v27 = {}
v30 = CFrame.new(0.07, 0.34, -1.51) * v13
v27[1] = "BarrelR"
v27[2] = (Vector3.new(2.0999999046325684, 0.13600000739097595, 0.13600000739097595))
v27[3] = v30
v27[4] = v14
v27[5] = Material.Metal
v27[6] = Cylinder_2
v28 = {}
local v31 = CFrame.new(0, 0.403, -1.53)
v28[1] = "Rib"
v28[2] = (Vector3.new(0.05000000074505806, 0.029999999329447746, 2.059999942779541))
v28[3] = v31
v28[4] = v14
v28[5] = Material.Metal
v29 = {}
local v32 = CFrame.new(0, 0.232, -0.8)
v29[1] = "Handguard"
v29[2] = (Vector3.new(0.17000000178813934, 0.10999999940395355, 0.6000000238418579))
v29[3] = v32
v29[4] = v10
v29[5] = Material.Wood
v30 = {}
local v33 = CFrame.new(0, 0.12, -0.15)
v30[1] = "Trigger"
v30[2] = (Vector3.new(0.029999999329447746, 0.10000000149011612, 0.029999999329447746))
v30[3] = v33
v30[4] = v16
v30[5] = Material.Metal
v31 = {}
local v34 = CFrame.new(0, 0.04, -0.15)
v31[1] = "Guard"
v31[2] = (Vector3.new(0.03999999910593033, 0.02500000037252903, 0.25999999046325684))
v31[3] = v34
v31[4] = v14
v31[5] = Material.Metal
v19[1] = v20
v19[2] = v21
v19[3] = v22
v19[4] = v23
v19[5] = v24
v19[6] = v25
v19[7] = v26
v19[8] = v27
v19[9] = v28
v19[10] = v29
v19[11] = v30
v19[12] = v31
GUNS.double_barrel = v19
v10 = Color3.fromRGB(156, 134, 100)
v11 = Color3.fromRGB(40, 41, 44)
v12 = Color3.fromRGB(29, 30, 32)
v14 = Color3.fromRGB(25, 25, 26)
v16 = Color3.fromRGB(47, 49, 53)
v18 = Color3.fromRGB(59, 60, 62)
v13 = Color3.fromRGB(34, 35, 38)
v15 = Color3.fromRGB(91, 94, 98)
v17 = Color3.fromRGB(166, 169, 172)
local Cylinder_3 = Enum.PartType.Cylinder
v20 = CFrame.Angles(0, 1.5707963267948966, 0)
v21 = CFrame.Angles(-0.3490658503988659, 0, 0)
local GUNS_2 = u6254.GUNS
v23 = {}
v24 = {}
v27 = CFrame.new(0, 0.124, -0.06)
v24[1] = "Handle"
v24[2] = (Vector3.new(0.14300000667572021, 0.08900000154972076, 0.24799999594688416))
v24[3] = v27
v24[4] = v11
v24[5] = Material.Plastic
v25 = {}
v28 = CFrame.new(0, 0.408, -0.394)
v25[1] = "Upper"
v25[2] = (Vector3.new(0.20399999618530273, 0.25099998712539673, 1.5019999742507935))
v25[3] = v28
v25[4] = v10
v25[5] = Material.SmoothPlastic
v26 = {}
v29 = CFrame.new(0, 0.557, -0.823)
v26[1] = "Upper"
v26[2] = (Vector3.new(0.1120000034570694, 0.04600000008940697, 2.3480000495910645))
v26[3] = v29
v26[4] = v10
v26[5] = Material.SmoothPlastic
v27 = {}
v30 = CFrame.new(0, 0.396, -1.577)
v27[1] = "Handguard"
v27[2] = (Vector3.new(0.18299999833106995, 0.2759999930858612, 0.8650000095367432))
v27[3] = v30
v27[4] = v10
v27[5] = Material.SmoothPlastic
v28 = {}
v31 = CFrame.new(0, 0.224, -0.343)
v28[1] = "Lower"
v28[2] = (Vector3.new(0.18799999356269836, 0.12999999523162842, 1.4759999513626099))
v28[3] = v31
v28[4] = v11
v28[5] = Material.Plastic
v29 = {}
v32 = CFrame.new(0, 0.105, -0.807)
v29[1] = "Lower"
v29[2] = (Vector3.new(0.20900000631809235, 0.10899999737739563, 0.5220000147819519))
v29[3] = v32
v29[4] = v11
v29[5] = Material.Plastic
v30 = {}
v33 = CFrame.new(0, 0.028, -0.368)
v30[1] = "Lower"
v30[2] = (Vector3.new(0.0430000014603138, 0.019999999552965164, 0.3050000071525574))
v30[3] = v33
v30[4] = v11
v30[5] = Material.Plastic
v31 = {}
v34 = CFrame.new(0, 0.092, -0.534)
v31[1] = "Lower"
v31[2] = (Vector3.new(0.0430000014603138, 0.12700000405311584, 0.03799999877810478))
v31[3] = v34
v31[4] = v11
v31[5] = Material.Plastic
v32 = {}
local v35 = CFrame.new(0, 0.124, -0.359)
v32[1] = "Metal"
v32[2] = (Vector3.new(0.023000000044703484, 0.07599999755620956, 0.03200000151991844))
v32[3] = v35
v32[4] = v16
v32[5] = Material.Metal
v33 = {}
local v36 = CFrame.new(0, -0.178, -0.814)
v33[1] = "Mag"
v33[2] = (Vector3.new(0.12700000405311584, 0.6299999952316284, 0.43299999833106995))
v33[3] = v36
v33[4] = v17
v33[5] = Material.Metal
v34 = {}
local v37 = CFrame.new(0, -0.513, -0.836)
v34[1] = "Mag"
v34[2] = (Vector3.new(0.14800000190734863, 0.050999999046325684, 0.4519999921321869))
v34[3] = v37
v34[4] = v17
v34[5] = Material.Metal
v35 = {}
local v38 = CFrame.new(0, 0.356, 0.66)
v35[1] = "Stock"
v35[2] = (Vector3.new(0.1679999977350235, 0.3370000123977661, 0.6169999837875366))
v35[3] = v38
v35[4] = v11
v35[5] = Material.Plastic
v36 = {}
local v39 = CFrame.new(0, 0.321, 1.267)
v36[1] = "Stock"
v36[2] = (Vector3.new(0.19300000369548798, 0.41999998688697815, 0.7250000238418579))
v36[3] = v39
v36[4] = v11
v36[5] = Material.Plastic
v37 = {}
local v40 = CFrame.new(0, -0.007, 1.465)
v37[1] = "Stock"
v37[2] = (Vector3.new(0.19300000369548798, 0.23499999940395355, 0.3310000002384186))
v37[3] = v40
v37[4] = v11
v37[5] = Material.Plastic
v38 = {}
local v41 = CFrame.new(0, 0.562, 1.248)
v38[1] = "Stock"
v38[2] = (Vector3.new(0.15800000727176666, 0.07100000232458115, 0.5090000033378601))
v38[3] = v41
v38[4] = v11
v38[5] = Material.Plastic
v39 = {}
local v42 = CFrame.new(0, 0.205, 1.657)
v39[1] = "ButtPad"
v39[2] = (Vector3.new(0.20399999618530273, 0.6660000085830688, 0.054999999701976776))
v39[3] = v42
v39[4] = v14
v39[5] = Material.Rubber
v23[1] = v24
v23[2] = v25
v23[3] = v26
v23[4] = v27
v23[5] = v28
v23[6] = v29
v23[7] = v30
v23[8] = v31
v23[9] = v32
v23[10] = v33
v23[11] = v34
v23[12] = v35
v23[13] = v36
v23[14] = v37
v23[15] = v38
v23[16] = v39
v24 = {}
v27 = CFrame.new(0, 0.425, -2.118)
v24[1] = "Barrel"
v24[2] = (Vector3.new(0.13199999928474426, 0.1809999942779541, 0.17800000309944153))
v24[3] = v27
v24[4] = v16
v24[5] = Material.Metal
v25 = {}
v28 = CFrame.new(0, 0.593, 0.189)
v25[1] = "Irons"
v25[2] = (Vector3.new(0.11999999731779099, 0.0430000014603138, 0.1589999943971634))
v25[3] = v28
v25[4] = v13
v25[5] = Material.Metal
v26 = {}
v29 = CFrame.new(-0.066, 0.716, 0.192)
v26[1] = "Irons"
v26[2] = (Vector3.new(0.02500000037252903, 0.15800000727176666, 0.019999999552965164))
v26[3] = v29
v26[4] = v13
v26[5] = Material.Metal
v27 = {}
v30 = CFrame.new(0.066, 0.716, 0.192)
v27[1] = "Irons"
v27[2] = (Vector3.new(0.02500000037252903, 0.15800000727176666, 0.019999999552965164))
v27[3] = v30
v27[4] = v13
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(0, 0.782, 0.192)
v28[1] = "Irons"
v28[2] = (Vector3.new(0.15800000727176666, 0.02500000037252903, 0.019999999552965164))
v28[3] = v31
v28[4] = v13
v28[5] = Material.Metal
v29 = {}
v32 = CFrame.new(0, 0.649, 0.192)
v29[1] = "Irons"
v29[2] = (Vector3.new(0.15800000727176666, 0.02500000037252903, 0.019999999552965164))
v29[3] = v32
v29[4] = v13
v29[5] = Material.Metal
v30 = {}
v33 = CFrame.new(0, 0.593, -1.88)
v30[1] = "Irons"
v30[2] = (Vector3.new(0.11999999731779099, 0.0430000014603138, 0.1720000058412552))
v30[3] = v33
v30[4] = v13
v30[5] = Material.Metal
v31 = {}
v34 = CFrame.new(0, 0.665, -1.892)
v31[1] = "Irons"
v31[2] = (Vector3.new(0.014000000432133675, 0.10100000351667404, 0.017999999225139618))
v31[3] = v34
v31[4] = v13
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(-0.042, 0.673, -1.892)
v32[1] = "Irons"
v32[2] = (Vector3.new(0.009999999776482582, 0.11599999666213989, 0.07599999755620956))
v32[3] = v35
v32[4] = v13
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0.042, 0.673, -1.892)
v33[1] = "Irons"
v33[2] = (Vector3.new(0.009999999776482582, 0.11599999666213989, 0.07599999755620956))
v33[3] = v36
v33[4] = v13
v33[5] = Material.Metal
v34 = {}
v37 = CFrame.new(-0.154, 0.473, -1.045)
v34[1] = "Bolt"
v34[2] = (Vector3.new(0.10899999737739563, 0.04800000041723251, 0.0689999982714653))
v34[3] = v37
v34[4] = v15
v34[5] = Material.Metal
v35 = {}
v38 = CFrame.new(0.104, 0.41, -0.285)
v35[1] = "Bolt"
v35[2] = (Vector3.new(0.004000000189989805, 0.05299999937415123, 0.3050000071525574))
v35[3] = v38
v35[4] = v15
v35[5] = Material.Metal
v36 = {}
v39 = CFrame.new(0, -0.067, 0.024) * v21
v36[1] = "GripPanels"
v36[2] = (Vector3.new(0.14300000667572021, 0.4959999918937683, 0.23499999940395355))
v36[3] = v39
v36[4] = v12
v36[5] = Material.Plastic
v37 = {}
v40 = CFrame.new(0, 0.391, -2.309) * v20
v37[1] = "Barrel"
v37[2] = (Vector3.new(0.5979999899864197, 0.09399999678134918, 0.09399999678134918))
v37[3] = v40
v37[4] = v16
v37[5] = Material.Metal
v37[6] = Cylinder_3
v38 = {}
v42 = CFrame.new(0, 0.391, -2.734) * v20
v38[1] = "Brake"
v38[2] = (Vector3.new(0.289000004529953, 0.10700000077486038, 0.10700000077486038))
v38[3] = v42
v38[4] = v18
v38[5] = Material.Metal
v38[6] = Cylinder_3
v23[17] = v24
v23[18] = v25
v23[19] = v26
v23[20] = v27
v23[21] = v28
v23[22] = v29
v23[23] = v30
v23[24] = v31
v23[25] = v32
v23[26] = v33
v23[27] = v34
v23[28] = v35
v23[29] = v36
v23[30] = v37
v23[31] = v38
GUNS_2.scar = v23
v10 = Color3.fromRGB(31, 32, 34)
v11 = Color3.fromRGB(25, 26, 28)
v12 = Color3.fromRGB(20, 21, 22)
v14 = Color3.fromRGB(58, 59, 63)
v16 = Color3.fromRGB(37, 38, 42)
v18 = Color3.fromRGB(43, 44, 48)
v13 = Color3.fromRGB(32, 33, 37)
v15 = Color3.fromRGB(39, 40, 44)
v17 = Color3.fromRGB(60, 62, 67)
v19 = Color3.fromRGB(76, 79, 84)
v20 = Color3.fromRGB(201, 163, 90)
local Cylinder_4 = Enum.PartType.Cylinder
v22 = CFrame.Angles(0, 1.5707963267948966, 0)
local GUNS_3 = u6254.GUNS
v24 = {}
v25 = {}
v28 = CFrame.new(0, 0.03, 0.0185)
v25[1] = "Handle"
v25[2] = (Vector3.new(0.15000000596046448, 0.30000001192092896, 0.4099999964237213))
v25[3] = v28
v25[4] = v10
v25[5] = Material.Plastic
v26 = {}
v29 = (CFrame.new(0, -0.14, 0.076)) * CFrame.Angles(0.5410520681182421, 0, 0)
v26[1] = "Stock"
v26[2] = (Vector3.new(0.14000000059604645, 0.14000000059604645, 0.41999998688697815))
v26[3] = v29
v26[4] = v10
v26[5] = Material.Plastic
v27 = {}
v30 = (CFrame.new(0, -0.031, 0.725)) * CFrame.Angles(0.16144295580947549, 0, 0)
v27[1] = "Stock"
v27[2] = (Vector3.new(0.17000000178813934, 0.1599999964237213, 1.3930000066757202))
v27[3] = v30
v27[4] = v10
v27[5] = Material.Plastic
v28 = {}
v31 = (CFrame.new(0, -0.319, 0.875)) * CFrame.Angles(0.29670597283903605, 0, 0)
v28[1] = "Stock"
v28[2] = (Vector3.new(0.18000000715255737, 0.36000001430511475, 1.2599999904632568))
v28[3] = v31
v28[4] = v10
v28[5] = Material.Plastic
v29 = {}
v32 = CFrame.new(0, -0.345, 1.235)
v29[1] = "Stock"
v29[2] = (Vector3.new(0.1899999976158142, 0.550000011920929, 0.3700000047683716))
v29[3] = v32
v29[4] = v10
v29[5] = Material.Plastic
v30 = {}
v33 = CFrame.new(0, -0.369, 1.427)
v30[1] = "Spacer"
v30[2] = (Vector3.new(0.19200000166893005, 0.6000000238418579, 0.014000000432133675))
v30[3] = v33
v30[4] = v14
v30[5] = Material.Plastic
v31 = {}
v34 = CFrame.new(0, -0.369, 1.5)
v31[1] = "ButtPad"
v31[2] = (Vector3.new(0.20000000298023224, 0.6200000047683716, 0.13500000536441803))
v31[3] = v34
v31[4] = v12
v31[5] = Material.Rubber
v32 = {}
v35 = CFrame.new(-0.076, -0.02, 0.03)
v32[1] = "GripPanels"
v32[2] = (Vector3.new(0.006000000052154064, 0.17000000178813934, 0.25999999046325684))
v32[3] = v35
v32[4] = v11
v32[5] = Material.Plastic
v33 = {}
v36 = CFrame.new(0.076, -0.02, 0.03)
v33[1] = "GripPanels"
v33[2] = (Vector3.new(0.006000000052154064, 0.17000000178813934, 0.25999999046325684))
v33[3] = v36
v33[4] = v11
v33[5] = Material.Plastic
v34 = {}
v37 = CFrame.new(0, 0.1285, -0.7125)
v34[1] = "Receiver"
v34[2] = (Vector3.new(0.16599999368190765, 0.30000001192092896, 1.0700000524520874))
v34[3] = v37
v34[4] = v16
v34[5] = Material.Metal
v35 = {}
v38 = CFrame.new(0.084, 0.187, -0.808)
v35[1] = "Bolt"
v35[2] = (Vector3.new(0.006000000052154064, 0.04500000178813934, 0.30000001192092896))
v35[3] = v38
v35[4] = v19
v35[5] = Material.Metal
v36 = {}
v39 = CFrame.new(0, -0.035, -0.44)
v36[1] = "Lower"
v36[2] = (Vector3.new(0.1459999978542328, 0.05000000074505806, 0.47999998927116394))
v36[3] = v39
v36[4] = v18
v36[5] = Material.SmoothPlastic
v37 = {}
v40 = CFrame.new(0, -0.174, -0.43)
v37[1] = "Lower"
v37[2] = (Vector3.new(0.029999999329447746, 0.02199999988079071, 0.3400000035762787))
v37[3] = v40
v37[4] = v18
v37[5] = Material.SmoothPlastic
v38 = {}
v41 = CFrame.new(0, -0.1, -0.6)
v38[1] = "Lower"
v38[2] = (Vector3.new(0.029999999329447746, 0.14000000059604645, 0.02500000037252903))
v38[3] = v41
v38[4] = v18
v38[5] = Material.SmoothPlastic
v39 = {}
v42 = (CFrame.new(0, -0.095, -0.45)) * CFrame.Angles(0.20943951023931956, 0, 0)
v39[1] = "Metal"
v39[2] = (Vector3.new(0.019999999552965164, 0.08500000089406967, 0.02500000037252903))
v39[3] = v42
v39[4] = v17
v39[5] = Material.Metal
v40 = {}
local v43 = CFrame.new(0, 0.1845, -2.771) * v22
v40[1] = "Barrel"
v40[2] = (Vector3.new(3.059999942779541, 0.10700000077486038, 0.10700000077486038))
v40[3] = v43
v40[4] = v13
v40[5] = Material.Metal
v40[6] = Cylinder_4
v24[1] = v25
v24[2] = v26
v24[3] = v27
v24[4] = v28
v24[5] = v29
v24[6] = v30
v24[7] = v31
v24[8] = v32
v24[9] = v33
v24[10] = v34
v24[11] = v35
v24[12] = v36
v24[13] = v37
v24[14] = v38
v24[15] = v39
v24[16] = v40
v25 = {}
v28 = CFrame.new(0, 0.1845, -4.34) * v22
v25[1] = "Barrel"
v25[2] = (Vector3.new(0.07999999821186066, 0.11800000071525574, 0.11800000071525574))
v25[3] = v28
v25[4] = v13
v25[5] = Material.Metal
v25[6] = Cylinder_4
v26 = {}
v29 = CFrame.new(0, 0.247, -2.75)
v26[1] = "Barrel"
v26[2] = (Vector3.new(0.03999999910593033, 0.019999999552965164, 3))
v26[3] = v29
v26[4] = v13
v26[5] = Material.Metal
v27 = {}
v30 = CFrame.new(0, 0.262, -4.2636)
v27[1] = "Bead"
v27[2] = (Vector3.new(0.02199999988079071, 0.02199999988079071, 0.02199999988079071))
v27[3] = v30
v27[4] = v20
v27[5] = Material.Metal
v27[6] = Enum.PartType.Ball
v28 = {}
v31 = CFrame.new(0, 0.0547, -2.11) * v22
v28[1] = "Tube"
v28[2] = (Vector3.new(1.7400000095367432, 0.12200000137090683, 0.12200000137090683))
v28[3] = v31
v28[4] = v15
v28[5] = Material.Metal
v28[6] = Cylinder_4
v29 = {}
v32 = CFrame.new(0, 0.0547, -2.995) * v22
v29[1] = "Metal"
v29[2] = (Vector3.new(0.03999999910593033, 0.10999999940395355, 0.10999999940395355))
v29[3] = v32
v29[4] = v17
v29[5] = Material.Metal
v29[6] = Cylinder_4
v30 = {}
v33 = CFrame.new(0, 0.12, -2.93)
v30[1] = "Metal"
v30[2] = (Vector3.new(0.03999999910593033, 0.10000000149011612, 0.07999999821186066))
v30[3] = v33
v30[4] = v17
v30[5] = Material.Metal
v31 = {}
v34 = CFrame.new(-0.066, 0.0547, -1.38)
v31[1] = "Metal"
v31[2] = (Vector3.new(0.012000000104308128, 0.023000000044703484, 0.28999999165534973))
v31[3] = v34
v31[4] = v17
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(0.066, 0.0547, -1.38)
v32[1] = "Metal"
v32[2] = (Vector3.new(0.012000000104308128, 0.023000000044703484, 0.28999999165534973))
v32[3] = v35
v32[4] = v17
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0, 0.026, -2.1445)
v33[1] = "Handguard"
v33[2] = (Vector3.new(0.23999999463558197, 0.20000000298023224, 1.309999942779541))
v33[3] = v36
v33[4] = v10
v33[5] = Material.Plastic
v34 = {}
v37 = CFrame.new(-0.122, 0.026, -2.1445)
v34[1] = "HandguardGrip"
v34[2] = (Vector3.new(0.006000000052154064, 0.07000000029802322, 0.800000011920929))
v34[3] = v37
v34[4] = v11
v34[5] = Material.Plastic
v35 = {}
v43 = CFrame.new(0.122, 0.026, -2.1445)
v35[1] = "HandguardGrip"
v35[2] = (Vector3.new(0.006000000052154064, 0.07000000029802322, 0.800000011920929))
v35[3] = v43
v35[4] = v11
v35[5] = Material.Plastic
v24[17] = v25
v24[18] = v26
v24[19] = v27
v24[20] = v28
v24[21] = v29
v24[22] = v30
v24[23] = v31
v24[24] = v32
v24[25] = v33
v24[26] = v34
v24[27] = v35
GUNS_3.pump_shotgun = v24
local Cylinder_5 = Enum.PartType.Cylinder
local Ball_2 = Enum.PartType.Ball
v12 = CFrame.Angles(0, 1.5707963267948966, 0)
v14 = Color3.fromRGB(38, 39, 42)
v16 = Color3.fromRGB(48, 50, 54)
v18 = Color3.fromRGB(94, 96, 100)
v13 = Color3.fromRGB(23, 24, 26)
v15 = Color3.fromRGB(237, 235, 223)
local GUNS_4 = u6254.GUNS
v19 = {}
v20 = {}
v23 = CFrame.new(0, 0.17, -0.42)
v20[1] = "Handle"
v20[2] = (Vector3.new(0.11999999731779099, 0.09000000357627869, 0.800000011920929))
v20[3] = v23
v20[4] = v14
v20[5] = Material.Plastic
v21 = {}
v24 = CFrame.new(0, 0.17, 0.1)
v21[1] = "Frame"
v21[2] = (Vector3.new(0.11999999731779099, 0.07999999821186066, 0.10000000149011612))
v21[3] = v24
v21[4] = v14
v21[5] = Material.Plastic
v22 = {}
v25 = CFrame.new(0, 0.109, -0.71)
v22[1] = "Frame"
v22[2] = (Vector3.new(0.10000000149011612, 0.03999999910593033, 0.23999999463558197))
v22[3] = v25
v22[4] = v14
v22[5] = Material.Plastic
v23 = {}
v26 = (CFrame.new(0, -0.06, 0.016)) * CFrame.Angles(-0.27052603405912107, 0, 0)
v23[1] = "GripPanels"
v23[2] = (Vector3.new(0.15000000596046448, 0.41999998688697815, 0.20999999344348907))
v23[3] = v26
v23[4] = v14
v23[5] = Material.Plastic
v24 = {}
v27 = CFrame.new(0, 0.03, -0.29)
v24[1] = "Guard"
v24[2] = (Vector3.new(0.09000000357627869, 0.02800000086426735, 0.30000001192092896))
v24[3] = v27
v24[4] = v14
v24[5] = Material.Plastic
v25 = {}
v28 = CFrame.new(0, 0.075, -0.43)
v25[1] = "Guard"
v25[2] = (Vector3.new(0.09000000357627869, 0.10999999940395355, 0.029999999329447746))
v25[3] = v28
v25[4] = v14
v25[5] = Material.Plastic
v26 = {}
v29 = CFrame.new(0, 0.1, -0.22)
v26[1] = "Trigger"
v26[2] = (Vector3.new(0.03400000184774399, 0.09000000357627869, 0.024000000208616257))
v26[3] = v29
v26[4] = v13
v26[5] = Material.Metal
v27 = {}
v30 = (CFrame.new(0, 0.31, 0.13)) * CFrame.Angles(-0.2617993877991494, 0, 0)
v27[1] = "Hammer"
v27[2] = (Vector3.new(0.03999999910593033, 0.07500000298023224, 0.05000000074505806))
v27[3] = v30
v27[4] = v13
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(-0.07, 0.235, 0.02)
v28[1] = "Controls"
v28[2] = (Vector3.new(0.019999999552965164, 0.029999999329447746, 0.05999999865889549))
v28[3] = v31
v28[4] = v13
v28[5] = Material.Metal
v29 = {}
v32 = (CFrame.new(0, -0.075, 0.02)) * CFrame.Angles(-0.27052603405912107, 0, 0)
v29[1] = "Mag"
v29[2] = (Vector3.new(0.08500000089406967, 0.41999998688697815, 0.14000000059604645))
v29[3] = v32
v29[4] = v13
v29[5] = Material.Metal
v30 = {}
v33 = (CFrame.new(0, -0.29, 0.082)) * CFrame.Angles(-0.27052603405912107, 0, 0)
v30[1] = "Mag"
v30[2] = (Vector3.new(0.12999999523162842, 0.03500000014901161, 0.20999999344348907))
v30[3] = v33
v30[4] = v14
v30[5] = Material.Plastic
v31 = {}
v34 = CFrame.new(0, 0.2957, -0.402)
v31[1] = "Slide"
v31[2] = (Vector3.new(0.1599999964237213, 0.16699999570846558, 1.003999948501587))
v31[3] = v34
v31[4] = v16
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(-0.081, 0.2957, 0.02)
v32[1] = "SlideSerr"
v32[2] = (Vector3.new(0.006000000052154064, 0.10000000149011612, 0.14000000059604645))
v32[3] = v35
v32[4] = v13
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0.081, 0.2957, 0.02)
v33[1] = "SlideSerr"
v33[2] = (Vector3.new(0.006000000052154064, 0.10000000149011612, 0.14000000059604645))
v33[3] = v36
v33[4] = v13
v33[5] = Material.Metal
v34 = {}
v37 = CFrame.new(0.081, 0.33, -0.294)
v34[1] = "SlidePort"
v34[2] = (Vector3.new(0.004000000189989805, 0.05000000074505806, 0.20000000298023224))
v34[3] = v37
v34[4] = v18
v34[5] = Material.Metal
v35 = {}
v38 = CFrame.new(0, 0.3885, 0.033)
v35[1] = "SlideIrons"
v35[2] = (Vector3.new(0.10999999940395355, 0.01899999938905239, 0.05000000074505806))
v35[3] = v38
v35[4] = v13
v35[5] = Material.Metal
v19[1] = v20
v19[2] = v21
v19[3] = v22
v19[4] = v23
v19[5] = v24
v19[6] = v25
v19[7] = v26
v19[8] = v27
v19[9] = v28
v19[10] = v29
v19[11] = v30
v19[12] = v31
v19[13] = v32
v19[14] = v33
v19[15] = v34
v19[16] = v35
v20 = {}
v23 = CFrame.new(-0.035, 0.3965, 0.033)
v20[1] = "SlideIrons"
v20[2] = (Vector3.new(0.029999999329447746, 0.03500000014901161, 0.05000000074505806))
v20[3] = v23
v20[4] = v13
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0.035, 0.3965, 0.033)
v21[1] = "SlideIrons"
v21[2] = (Vector3.new(0.029999999329447746, 0.03500000014901161, 0.05000000074505806))
v21[3] = v24
v21[4] = v13
v21[5] = Material.Metal
v22 = {}
v25 = CFrame.new(0, 0.389, -0.856)
v22[1] = "SlideIrons"
v22[2] = (Vector3.new(0.024000000208616257, 0.019999999552965164, 0.03500000014901161))
v22[3] = v25
v22[4] = v13
v22[5] = Material.Metal
v23 = {}
v26 = CFrame.new(0, 0.39, -0.875)
v23[1] = "SlideDots"
v23[2] = (Vector3.new(0.012000000104308128, 0.012000000104308128, 0.004000000189989805))
v23[3] = v26
v23[4] = v15
v23[5] = Material.SmoothPlastic
v24 = {}
v27 = CFrame.new(-0.035, 0.404, 0.007)
v24[1] = "SlideDots"
v24[2] = (Vector3.new(0.012000000104308128, 0.012000000104308128, 0.004000000189989805))
v24[3] = v27
v24[4] = v15
v24[5] = Material.SmoothPlastic
v25 = {}
v28 = CFrame.new(0.035, 0.404, 0.007)
v25[1] = "SlideDots"
v25[2] = (Vector3.new(0.012000000104308128, 0.012000000104308128, 0.004000000189989805))
v25[3] = v28
v25[4] = v15
v25[5] = Material.SmoothPlastic
v26 = {}
v38 = CFrame.new(0, 0.304, -0.898) * v12
v26[1] = "Barrel"
v26[2] = (Vector3.new(0.019999999552965164, 0.07999999821186066, 0.07999999821186066))
v26[3] = v38
v26[4] = v18
v26[5] = Material.Metal
v26[6] = Cylinder_5
v19[17] = v20
v19[18] = v21
v19[19] = v22
v19[20] = v23
v19[21] = v24
v19[22] = v25
v19[23] = v26
GUNS_4.service_pistol = v19
v14 = Color3.fromRGB(44, 46, 49)
v16 = Color3.fromRGB(35, 36, 39)
v18 = Color3.fromRGB(37, 39, 42)
v13 = Color3.fromRGB(54, 55, 57)
v15 = Color3.fromRGB(24, 25, 27)
v17 = Color3.fromRGB(47, 49, 52)
v19 = Color3.fromRGB(87, 90, 95)
v20 = Color3.fromRGB(22, 23, 24)
local GUNS_5 = u6254.GUNS
v22 = {}
v23 = {}
v26 = CFrame.new(0, 0.13, -0.05)
v23[1] = "Handle"
v23[2] = (Vector3.new(0.14000000059604645, 0.09000000357627869, 0.27000001072883606))
v23[3] = v26
v23[4] = v16
v23[5] = Material.Plastic
v24 = {}
v27 = CFrame.new(0, 0.4075, -0.275)
v24[1] = "Receiver"
v24[2] = (Vector3.new(0.17000000178813934, 0.25, 1.149999976158142))
v24[3] = v27
v24[4] = v14
v24[5] = Material.Metal
v25 = {}
v28 = CFrame.new(0, 0.5474, -1.235) * v12
v25[1] = "Receiver"
v25[2] = (Vector3.new(0.10000000149011612, 0.10000000149011612, 0.7699999809265137))
v25[3] = v28
v25[4] = v14
v25[5] = Material.Metal
v25[6] = Cylinder_5
v26 = {}
v29 = CFrame.new(0, 0.365, -1.15)
v26[1] = "Handguard"
v26[2] = (Vector3.new(0.1599999964237213, 0.17000000178813934, 0.6100000143051147))
v26[3] = v29
v26[4] = v16
v26[5] = Material.Plastic
v27 = {}
v30 = CFrame.new(0, 0.3905, -1.66) * v12
v27[1] = "Barrel"
v27[2] = (Vector3.new(0.41999998688697815, 0.07500000298023224, 0.07500000298023224))
v27[3] = v30
v27[4] = v18
v27[5] = Material.Metal
v27[6] = Cylinder_5
v28 = {}
v31 = CFrame.new(0, 0.3905, -1.826) * v12
v28[1] = "Barrel"
v28[2] = (Vector3.new(0.09000000357627869, 0.10000000149011612, 0.10000000149011612))
v28[3] = v31
v28[4] = v13
v28[5] = Material.Metal
v28[6] = Cylinder_5
v29 = {}
v32 = CFrame.new(0, 0.215, -0.1)
v29[1] = "Lower"
v29[2] = (Vector3.new(0.14000000059604645, 0.12999999523162842, 0.6200000047683716))
v29[3] = v32
v29[4] = v16
v29[5] = Material.Plastic
v30 = {}
v33 = CFrame.new(0, 0.075, -0.2)
v30[1] = "Lower"
v30[2] = (Vector3.new(0.05000000074505806, 0.029999999329447746, 0.30000001192092896))
v30[3] = v33
v30[4] = v16
v30[5] = Material.Plastic
v31 = {}
v34 = CFrame.new(0, 0.12, -0.345)
v31[1] = "Lower"
v31[2] = (Vector3.new(0.05000000074505806, 0.11999999731779099, 0.029999999329447746))
v31[3] = v34
v31[4] = v16
v31[5] = Material.Plastic
v32 = {}
v35 = CFrame.new(0, 0.235, -0.62)
v32[1] = "Lower"
v32[2] = (Vector3.new(0.12999999523162842, 0.10000000149011612, 0.2199999988079071))
v32[3] = v35
v32[4] = v14
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0, 0.12, -0.17)
v33[1] = "Trigger"
v33[2] = (Vector3.new(0.029999999329447746, 0.09000000357627869, 0.02500000037252903))
v33[3] = v36
v33[4] = v15
v33[5] = Material.Metal
v34 = {}
v37 = CFrame.new(-0.078, 0.22, -0.02)
v34[1] = "Metal"
v34[2] = (Vector3.new(0.019999999552965164, 0.03999999910593033, 0.03999999910593033))
v34[3] = v37
v34[4] = v15
v34[5] = Material.Metal
v35 = {}
v38 = (CFrame.new(0, -0.06, 0.03)) * CFrame.Angles(-0.2617993877991494, 0, 0)
v35[1] = "GripPanels"
v35[2] = (Vector3.new(0.15000000596046448, 0.36000001430511475, 0.20999999344348907))
v35[3] = v38
v35[4] = v16
v35[5] = Material.Plastic
v36 = {}
v39 = (CFrame.new(0, 0.1109, -0.6167)) * CFrame.Angles(0.10471975511965978, 0, 0)
v36[1] = "Mag"
v36[2] = (Vector3.new(0.09000000357627869, 0.3499999940395355, 0.17000000178813934))
v36[3] = v39
v36[4] = v17
v36[5] = Material.Metal
v37 = {}
v40 = (CFrame.new(0, -0.2004, -0.6829)) * CFrame.Angles(0.3141592653589793, 0, 0)
v37[1] = "Mag"
v37[2] = (Vector3.new(0.09000000357627869, 0.3499999940395355, 0.17000000178813934))
v37[3] = v40
v37[4] = v17
v37[5] = Material.Metal
v38 = {}
v41 = (CFrame.new(0, -0.4939, -0.8074)) * CFrame.Angles(0.4886921905584123, 0, 0)
v38[1] = "Mag"
v38[2] = (Vector3.new(0.09000000357627869, 0.3499999940395355, 0.17000000178813934))
v38[3] = v41
v38[4] = v17
v38[5] = Material.Metal
v22[1] = v23
v22[2] = v24
v22[3] = v25
v22[4] = v26
v22[5] = v27
v22[6] = v28
v22[7] = v29
v22[8] = v30
v22[9] = v31
v22[10] = v32
v22[11] = v33
v22[12] = v34
v22[13] = v35
v22[14] = v36
v22[15] = v37
v22[16] = v38
v23 = {}
v26 = (CFrame.new(0, -0.6471, -0.8886)) * CFrame.Angles(0.4886921905584123, 0, 0)
v23[1] = "Mag"
v23[2] = (Vector3.new(0.10000000149011612, 0.03500000014901161, 0.1899999976158142))
v23[3] = v26
v23[4] = v16
v23[5] = Material.Plastic
v24 = {}
v27 = CFrame.new(0.087, 0.435, -0.681)
v24[1] = "Bolt"
v24[2] = (Vector3.new(0.004000000189989805, 0.05999999865889549, 0.2199999988079071))
v24[3] = v27
v24[4] = v19
v24[5] = Material.Metal
v25 = {}
v28 = CFrame.new(-0.105, 0.5474, -1.3555)
v25[1] = "ChargingHandle"
v25[2] = (Vector3.new(0.10999999940395355, 0.03500000014901161, 0.04500000178813934))
v25[3] = v28
v25[4] = v15
v25[5] = Material.Metal
v26 = {}
v29 = CFrame.new(-0.051, 0.5474, -1.2)
v26[1] = "Port"
v26[2] = (Vector3.new(0.004000000189989805, 0.029999999329447746, 0.4000000059604645))
v26[3] = v29
v26[4] = v15
v26[5] = Material.Metal
v27 = {}
v30 = CFrame.new(0, 0.553, 0.172)
v27[1] = "Irons"
v27[2] = (Vector3.new(0.11999999731779099, 0.03999999910593033, 0.09000000357627869))
v27[3] = v30
v27[4] = v14
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(0, 0.576, 0.172)
v28[1] = "Irons"
v28[2] = (Vector3.new(0.10000000149011612, 0.012000000104308128, 0.03500000014901161))
v28[3] = v31
v28[4] = v14
v28[5] = Material.Metal
v29 = {}
v32 = CFrame.new(-0.046, 0.617, 0.172)
v29[1] = "Irons"
v29[2] = (Vector3.new(0.02199999988079071, 0.10999999940395355, 0.03500000014901161))
v29[3] = v32
v29[4] = v14
v29[5] = Material.Metal
v30 = {}
v33 = CFrame.new(0.046, 0.617, 0.172)
v30[1] = "Irons"
v30[2] = (Vector3.new(0.02199999988079071, 0.10999999940395355, 0.03500000014901161))
v30[3] = v33
v30[4] = v14
v30[5] = Material.Metal
v31 = {}
v34 = CFrame.new(0, 0.662, 0.172)
v31[1] = "Irons"
v31[2] = (Vector3.new(0.11400000005960464, 0.019999999552965164, 0.03500000014901161))
v31[3] = v34
v31[4] = v14
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(0, 0.57, -1.521)
v32[1] = "Irons"
v32[2] = (Vector3.new(0.07999999821186066, 0.05000000074505806, 0.07000000029802322))
v32[3] = v35
v32[4] = v14
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0, 0.606, -1.521)
v33[1] = "Irons"
v33[2] = (Vector3.new(0.014000000432133675, 0.02199999988079071, 0.01600000075995922))
v33[3] = v36
v33[4] = v14
v33[5] = Material.Metal
v34 = {}
v37 = CFrame.new(-0.04, 0.625, -1.521)
v34[1] = "Irons"
v34[2] = (Vector3.new(0.012000000104308128, 0.07999999821186066, 0.05999999865889549))
v34[3] = v37
v34[4] = v14
v34[5] = Material.Metal
v35 = {}
v38 = CFrame.new(0.04, 0.625, -1.521)
v35[1] = "Irons"
v35[2] = (Vector3.new(0.012000000104308128, 0.07999999821186066, 0.05999999865889549))
v35[3] = v38
v35[4] = v14
v35[5] = Material.Metal
v36 = {}
v39 = CFrame.new(0, 0.671, -1.521)
v36[1] = "Irons"
v36[2] = (Vector3.new(0.09200000017881393, 0.012000000104308128, 0.05999999865889549))
v36[3] = v39
v36[4] = v14
v36[5] = Material.Metal
v37 = {}
v40 = CFrame.new(0, 0.475, 0.85)
v37[1] = "Stock"
v37[2] = (Vector3.new(0.14000000059604645, 0.10999999940395355, 1.25))
v37[3] = v40
v37[4] = v16
v37[5] = Material.Plastic
v38 = {}
v41 = (CFrame.new(0, 0.3, 1.1)) * CFrame.Angles(0.20943951023931956, 0, 0)
v38[1] = "Stock"
v38[2] = (Vector3.new(0.14000000059604645, 0.23999999463558197, 0.8500000238418579))
v38[3] = v41
v38[4] = v16
v38[5] = Material.Plastic
v22[17] = v23
v22[18] = v24
v22[19] = v25
v22[20] = v26
v22[21] = v27
v22[22] = v28
v22[23] = v29
v22[24] = v30
v22[25] = v31
v22[26] = v32
v22[27] = v33
v22[28] = v34
v22[29] = v35
v22[30] = v36
v22[31] = v37
v22[32] = v38
v23 = {}
v26 = CFrame.new(0, 0.29, 1.49)
v23[1] = "Stock"
v23[2] = (Vector3.new(0.15000000596046448, 0.46000000834465027, 0.2199999988079071))
v23[3] = v26
v23[4] = v16
v23[5] = Material.Plastic
v24 = {}
v41 = CFrame.new(0, 0.266, 1.607)
v24[1] = "ButtPad"
v24[2] = (Vector3.new(0.14000000059604645, 0.44999998807907104, 0.05000000074505806))
v24[3] = v41
v24[4] = v20
v24[5] = Material.Rubber
v22[33] = v23
v22[34] = v24
GUNS_5.tactical_smg = v22
v14 = Color3.fromRGB(42, 45, 52)
v16 = Color3.fromRGB(90, 50, 28)
v18 = Color3.fromRGB(70, 40, 24)
v13 = Color3.fromRGB(37, 40, 46)
v15 = Color3.fromRGB(46, 49, 56)
v17 = Color3.fromRGB(44, 47, 54)
v19 = Color3.fromRGB(78, 82, 90)
v20 = Color3.fromRGB(74, 78, 86)
v21 = Color3.fromRGB(24, 25, 27)
local GUNS_6 = u6254.GUNS
v23 = {}
v24 = {}
v27 = CFrame.new(0, 0.125, -0.05)
v24[1] = "Handle"
v24[2] = (Vector3.new(0.15000000596046448, 0.09000000357627869, 0.27000001072883606))
v24[3] = v27
v24[4] = v14
v24[5] = Material.Metal
v25 = {}
v28 = CFrame.new(0, 0.396, -0.263)
v25[1] = "Receiver"
v25[2] = (Vector3.new(0.17000000178813934, 0.20000000298023224, 1.1699999570846558))
v25[3] = v28
v25[4] = v14
v25[5] = Material.Metal
v26 = {}
v29 = CFrame.new(0, 0.23, -0.3)
v26[1] = "Lower"
v26[2] = (Vector3.new(0.17000000178813934, 0.12999999523162842, 0.949999988079071))
v26[3] = v29
v26[4] = v14
v26[5] = Material.Metal
v27 = {}
v30 = (CFrame.new(0, -0.07, 0.04)) * CFrame.Angles(-0.24434609527920614, 0, 0)
v27[1] = "GripPanels"
v27[2] = (Vector3.new(0.15000000596046448, 0.47999998927116394, 0.23000000417232513))
v27[3] = v30
v27[4] = v16
v27[5] = Material.Wood
v28 = {}
v31 = CFrame.new(0, 0.085, -0.17)
v28[1] = "Lower"
v28[2] = (Vector3.new(0.05000000074505806, 0.029999999329447746, 0.30000001192092896))
v28[3] = v31
v28[4] = v14
v28[5] = Material.Metal
v29 = {}
v32 = CFrame.new(0, 0.13, -0.31)
v29[1] = "Lower"
v29[2] = (Vector3.new(0.05000000074505806, 0.10999999940395355, 0.029999999329447746))
v29[3] = v32
v29[4] = v14
v29[5] = Material.Metal
v30 = {}
v33 = CFrame.new(0, 0.125, -0.15)
v30[1] = "Trigger"
v30[2] = (Vector3.new(0.029999999329447746, 0.09000000357627869, 0.02500000037252903))
v30[3] = v33
v30[4] = v21
v30[5] = Material.Metal
v31 = {}
v34 = CFrame.new(-0.093, 0.24, -0.05)
v31[1] = "Metal"
v31[2] = (Vector3.new(0.019999999552965164, 0.05000000074505806, 0.05000000074505806))
v31[3] = v34
v31[4] = v13
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(-0.093, 0.24, -0.2)
v32[1] = "Metal"
v32[2] = (Vector3.new(0.019999999552965164, 0.05000000074505806, 0.05000000074505806))
v32[3] = v35
v32[4] = v13
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0, -0.232, -0.67) * v12
v33[1] = "Mag"
v33[2] = (Vector3.new(0.30000001192092896, 1.0399999618530273, 1.0399999618530273))
v33[3] = v36
v33[4] = v17
v33[5] = Material.Metal
v33[6] = Cylinder_5
v34 = {}
v37 = CFrame.new(0, -0.232, -0.67) * v12
v34[1] = "MagPlate"
v34[2] = (Vector3.new(0.3199999928474426, 0.36000001430511475, 0.36000001430511475))
v34[3] = v37
v34[4] = v19
v34[5] = Material.Metal
v34[6] = Cylinder_5
v35 = {}
v38 = CFrame.new(0.1, -0.2, -0.835)
v35[1] = "MagPlate"
v35[2] = (Vector3.new(0.20000000298023224, 0.04500000178813934, 0.029999999329447746))
v35[3] = v38
v35[4] = v19
v35[5] = Material.Metal
v36 = {}
v39 = CFrame.new(0, 0.2, -0.67)
v36[1] = "Mag"
v36[2] = (Vector3.new(0.11999999731779099, 0.14000000059604645, 0.1599999964237213))
v36[3] = v39
v36[4] = v17
v36[5] = Material.Metal
v37 = {}
v40 = CFrame.new(0, 0.4168, -1.43) * v12
v37[1] = "Barrel"
v37[2] = (Vector3.new(1.190000057220459, 0.10000000149011612, 0.10000000149011612))
v37[3] = v40
v37[4] = v13
v37[5] = Material.Metal
v37[6] = Cylinder_5
v38 = {}
v41 = CFrame.new(0, 0.4168, -0.92) * v12
v38[1] = "Barrel"
v38[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v38[3] = v41
v38[4] = v13
v38[5] = Material.Metal
v38[6] = Cylinder_5
v39 = {}
v42 = CFrame.new(0, 0.4168, -0.985) * v12
v39[1] = "Barrel"
v39[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v39[3] = v42
v39[4] = v13
v39[5] = Material.Metal
v39[6] = Cylinder_5
v23[1] = v24
v23[2] = v25
v23[3] = v26
v23[4] = v27
v23[5] = v28
v23[6] = v29
v23[7] = v30
v23[8] = v31
v23[9] = v32
v23[10] = v33
v23[11] = v34
v23[12] = v35
v23[13] = v36
v23[14] = v37
v23[15] = v38
v23[16] = v39
v24 = {}
v27 = CFrame.new(0, 0.4168, -1.05) * v12
v24[1] = "Barrel"
v24[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v24[3] = v27
v24[4] = v13
v24[5] = Material.Metal
v24[6] = Cylinder_5
v25 = {}
v28 = CFrame.new(0, 0.4168, -1.115) * v12
v25[1] = "Barrel"
v25[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v25[3] = v28
v25[4] = v13
v25[5] = Material.Metal
v25[6] = Cylinder_5
v26 = {}
v29 = CFrame.new(0, 0.4168, -1.18) * v12
v26[1] = "Barrel"
v26[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v26[3] = v29
v26[4] = v13
v26[5] = Material.Metal
v26[6] = Cylinder_5
v27 = {}
v30 = CFrame.new(0, 0.4168, -1.245) * v12
v27[1] = "Barrel"
v27[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v27[3] = v30
v27[4] = v13
v27[5] = Material.Metal
v27[6] = Cylinder_5
v28 = {}
v31 = CFrame.new(0, 0.4168, -1.31) * v12
v28[1] = "Barrel"
v28[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v28[3] = v31
v28[4] = v13
v28[5] = Material.Metal
v28[6] = Cylinder_5
v29 = {}
v32 = CFrame.new(0, 0.4168, -1.375) * v12
v29[1] = "Barrel"
v29[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v29[3] = v32
v29[4] = v13
v29[5] = Material.Metal
v29[6] = Cylinder_5
v30 = {}
v33 = CFrame.new(0, 0.4168, -1.44) * v12
v30[1] = "Barrel"
v30[2] = (Vector3.new(0.03500000014901161, 0.13699999451637268, 0.13699999451637268))
v30[3] = v33
v30[4] = v13
v30[5] = Material.Metal
v30[6] = Cylinder_5
v31 = {}
v34 = CFrame.new(0, 0.4168, -2.112)
v31[1] = "Brake"
v31[2] = (Vector3.new(0.12200000137090683, 0.12200000137090683, 0.1720000058412552))
v31[3] = v34
v31[4] = v15
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(0, 0.47, -2.0475)
v32[1] = "Irons"
v32[2] = (Vector3.new(0.05000000074505806, 0.029999999329447746, 0.07999999821186066))
v32[3] = v35
v32[4] = v14
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0, 0.512, -2.0475)
v33[1] = "Irons"
v33[2] = (Vector3.new(0.01600000075995922, 0.09000000357627869, 0.03999999910593033))
v33[3] = v36
v33[4] = v14
v33[5] = Material.Metal
v34 = {}
v37 = CFrame.new(0, 0.507, 0.1314)
v34[1] = "Irons"
v34[2] = (Vector3.new(0.11999999731779099, 0.02199999988079071, 0.10000000149011612))
v34[3] = v37
v34[4] = v14
v34[5] = Material.Metal
v35 = {}
v38 = CFrame.new(-0.04, 0.5568, 0.1314)
v35[1] = "Irons"
v35[2] = (Vector3.new(0.019999999552965164, 0.09000000357627869, 0.03500000014901161))
v35[3] = v38
v35[4] = v14
v35[5] = Material.Metal
v36 = {}
v39 = CFrame.new(0.04, 0.5568, 0.1314)
v36[1] = "Irons"
v36[2] = (Vector3.new(0.019999999552965164, 0.09000000357627869, 0.03500000014901161))
v36[3] = v39
v36[4] = v14
v36[5] = Material.Metal
v37 = {}
v40 = CFrame.new(0, 0.6, 0.1314)
v37[1] = "Irons"
v37[2] = (Vector3.new(0.10000000149011612, 0.01600000075995922, 0.03500000014901161))
v37[3] = v40
v37[4] = v14
v37[5] = Material.Metal
v38 = {}
v41 = CFrame.new(0, 0.52, -0.6832)
v38[1] = "ChargingHandle"
v38[2] = (Vector3.new(0.05999999865889549, 0.05000000074505806, 0.07000000029802322))
v38[3] = v41
v38[4] = v20
v38[5] = Material.Metal
v39 = {}
v42 = CFrame.new(0, 0.4965, -0.6)
v39[1] = "Port"
v39[2] = (Vector3.new(0.019999999552965164, 0.004000000189989805, 0.5))
v39[3] = v42
v39[4] = v21
v39[5] = Material.Metal
v23[17] = v24
v23[18] = v25
v23[19] = v26
v23[20] = v27
v23[21] = v28
v23[22] = v29
v23[23] = v30
v23[24] = v31
v23[25] = v32
v23[26] = v33
v23[27] = v34
v23[28] = v35
v23[29] = v36
v23[30] = v37
v23[31] = v38
v23[32] = v39
v24 = {}
v27 = CFrame.new(0.087, 0.4232, -0.505)
v24[1] = "Bolt"
v24[2] = (Vector3.new(0.004000000189989805, 0.07000000029802322, 0.23999999463558197))
v24[3] = v27
v24[4] = v20
v24[5] = Material.Metal
v25 = {}
v28 = (CFrame.new(0, 0.36, 0.68)) * CFrame.Angles(0.12217304763960307, 0, 0)
v25[1] = "Stock"
v25[2] = (Vector3.new(0.15000000596046448, 0.2199999988079071, 0.75))
v25[3] = v28
v25[4] = v16
v25[5] = Material.Wood
v26 = {}
v29 = (CFrame.new(0, 0.13, 1.48)) * CFrame.Angles(0.12217304763960307, 0, 0)
v26[1] = "Stock"
v26[2] = (Vector3.new(0.17000000178813934, 0.46000000834465027, 0.8500000238418579))
v26[3] = v29
v26[4] = v16
v26[5] = Material.Wood
v27 = {}
v30 = (CFrame.new(0, 0.05, 1.918)) * CFrame.Angles(0.12217304763960307, 0, 0)
v27[1] = "ButtPad"
v27[2] = (Vector3.new(0.18000000715255737, 0.5600000023841858, 0.029999999329447746))
v27[3] = v30
v27[4] = v13
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(0, 0.13, -1.4875)
v28[1] = "Handguard"
v28[2] = (Vector3.new(0.12999999523162842, 0.41999998688697815, 0.20999999344348907))
v28[3] = v31
v28[4] = v16
v28[5] = Material.Wood
v29 = {}
v32 = CFrame.new(0, 0.24, -1.4875)
v29[1] = "Handguard"
v29[2] = (Vector3.new(0.13500000536441803, 0.029999999329447746, 0.2150000035762787))
v29[3] = v32
v29[4] = v18
v29[5] = Material.Wood
v30 = {}
v33 = CFrame.new(0, 0.12, -1.4875)
v30[1] = "Handguard"
v30[2] = (Vector3.new(0.13500000536441803, 0.029999999329447746, 0.2150000035762787))
v30[3] = v33
v30[4] = v18
v30[5] = Material.Wood
v31 = {}
v34 = CFrame.new(0, 0, -1.4875)
v31[1] = "Handguard"
v31[2] = (Vector3.new(0.13500000536441803, 0.029999999329447746, 0.2150000035762787))
v31[3] = v34
v31[4] = v18
v31[5] = Material.Wood
v32 = {}
v35 = CFrame.new(0, -0.09, -1.4875)
v32[1] = "Metal"
v32[2] = (Vector3.new(0.15000000596046448, 0.029999999329447746, 0.2199999988079071))
v32[3] = v35
v32[4] = v14
v32[5] = Material.Metal
v33 = {}
v42 = CFrame.new(0, 0.34, -1.4875)
v33[1] = "Metal"
v33[2] = (Vector3.new(0.09000000357627869, 0.05999999865889549, 0.14000000059604645))
v33[3] = v42
v33[4] = v14
v33[5] = Material.Metal
v23[33] = v24
v23[34] = v25
v23[35] = v26
v23[36] = v27
v23[37] = v28
v23[38] = v29
v23[39] = v30
v23[40] = v31
v23[41] = v32
v23[42] = v33
GUNS_6.drum_smg = v23
v14 = Color3.fromRGB(38, 42, 49)
v16 = Color3.fromRGB(90, 51, 32)
v18 = Color3.fromRGB(34, 38, 44)
v13 = Color3.fromRGB(126, 130, 135)
v15 = Color3.fromRGB(48, 53, 60)
v17 = Color3.fromRGB(21, 21, 21)
v19 = Color3.fromRGB(24, 25, 27)
v20 = Color3.fromRGB(201, 163, 90)
local GUNS_7 = u6254.GUNS
v22 = {}
v23 = {}
v26 = CFrame.new(0, 0.025, -0.013)
v23[1] = "Handle"
v23[2] = (Vector3.new(0.14000000059604645, 0.20000000298023224, 0.41999998688697815))
v23[3] = v26
v23[4] = v16
v23[5] = Material.Wood
v24 = {}
v27 = (CFrame.new(0, -0.03, 0.43)) * CFrame.Angles(0.15707963267948966, 0, 0)
v24[1] = "Stock"
v24[2] = (Vector3.new(0.14000000059604645, 0.20000000298023224, 0.5))
v24[3] = v27
v24[4] = v16
v24[5] = Material.Wood
v25 = {}
v28 = (CFrame.new(0, -0.13, 1.05)) * CFrame.Angles(0.13962634015954636, 0, 0)
v25[1] = "Stock"
v25[2] = (Vector3.new(0.15000000596046448, 0.4000000059604645, 0.75))
v25[3] = v28
v25[4] = v16
v25[5] = Material.Wood
v26 = {}
v29 = (CFrame.new(0, -0.13, 1.48)) * CFrame.Angles(0.13962634015954636, 0, 0)
v26[1] = "ButtPad"
v26[2] = (Vector3.new(0.1599999964237213, 0.4000000059604645, 0.05999999865889549))
v26[3] = v29
v26[4] = v17
v26[5] = Material.Rubber
v27 = {}
v30 = CFrame.new(0, 0.04, -0.62)
v27[1] = "Receiver"
v27[2] = (Vector3.new(0.14000000059604645, 0.30000001192092896, 0.9200000166893005))
v27[3] = v30
v27[4] = v14
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(0, 0.14, -0.05)
v28[1] = "Receiver"
v28[2] = (Vector3.new(0.07999999821186066, 0.029999999329447746, 0.25))
v28[3] = v31
v28[4] = v14
v28[5] = Material.Metal
v29 = {}
v32 = (CFrame.new(0, 0.125, -0.23)) * CFrame.Angles(-0.4363323129985824, 0, 0)
v29[1] = "Hammer"
v29[2] = (Vector3.new(0.03799999877810478, 0.18000000715255737, 0.05999999865889549))
v29[3] = v32
v29[4] = v14
v29[5] = Material.Metal
v30 = {}
v33 = CFrame.new(0.0728, 0.0204, -0.9227)
v30[1] = "LoadingGate"
v30[2] = (Vector3.new(0.006000000052154064, 0.06499999761581421, 0.15000000596046448))
v30[3] = v33
v30[4] = v15
v30[5] = Material.Metal
v31 = {}
v34 = CFrame.new(0.073, 0.1349, -0.6141)
v31[1] = "Bolt"
v31[2] = (Vector3.new(0.004999999888241291, 0.0560000017285347, 0.32499998807907104))
v31[3] = v34
v31[4] = v13
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(0, -0.14, -0.19)
v32[1] = "Trigger"
v32[2] = (Vector3.new(0.02500000037252903, 0.07000000029802322, 0.02500000037252903))
v32[3] = v35
v32[4] = v19
v32[5] = Material.Metal
v33 = {}
v36 = CFrame.new(0, -0.08, -0.94)
v33[1] = "Lever"
v33[2] = (Vector3.new(0.03500000014901161, 0.09000000357627869, 0.07999999821186066))
v33[3] = v36
v33[4] = v14
v33[5] = Material.Metal
v34 = {}
v37 = CFrame.new(0, -0.125, -0.6)
v34[1] = "Lever"
v34[2] = (Vector3.new(0.03500000014901161, 0.03999999910593033, 0.7200000286102295))
v34[3] = v37
v34[4] = v14
v34[5] = Material.Metal
v35 = {}
v38 = (CFrame.new(0, -0.1925, -0.2)) * CFrame.Angles(-0.6747407981625038, 0, 0)
v35[1] = "Lever"
v35[2] = (Vector3.new(0.03500000014901161, 0.1599999964237213, 0.03500000014901161))
v35[3] = v38
v35[4] = v14
v35[5] = Material.Metal
v36 = {}
v39 = CFrame.new(0, -0.252, -0.02)
v36[1] = "Lever"
v36[2] = (Vector3.new(0.03500000014901161, 0.029999999329447746, 0.28999999165534973))
v36[3] = v39
v36[4] = v14
v36[5] = Material.Metal
v37 = {}
v40 = CFrame.new(0, -0.165, 0.105)
v37[1] = "Lever"
v37[2] = (Vector3.new(0.03500000014901161, 0.18000000715255737, 0.029999999329447746))
v37[3] = v40
v37[4] = v14
v37[5] = Material.Metal
v38 = {}
v41 = CFrame.new(0, 0.1222, -1.97) * v12
v38[1] = "Barrel"
v38[2] = (Vector3.new(1.7899999618530273, 0.10000000149011612, 0.10000000149011612))
v38[3] = v41
v38[4] = v18
v38[5] = Material.Metal
v38[6] = Cylinder_5
v22[1] = v23
v22[2] = v24
v22[3] = v25
v22[4] = v26
v22[5] = v27
v22[6] = v28
v22[7] = v29
v22[8] = v30
v22[9] = v31
v22[10] = v32
v22[11] = v33
v22[12] = v34
v22[13] = v35
v22[14] = v36
v22[15] = v37
v22[16] = v38
v23 = {}
v26 = CFrame.new(0, 0.0331, -1.935) * v12
v23[1] = "Tube"
v23[2] = (Vector3.new(1.7200000286102295, 0.07199999690055847, 0.07199999690055847))
v23[3] = v26
v23[4] = v14
v23[5] = Material.Metal
v23[6] = Cylinder_5
v24 = {}
v27 = CFrame.new(0, 0.0331, -2.81) * v12
v24[1] = "Metal"
v24[2] = (Vector3.new(0.03999999910593033, 0.07999999821186066, 0.07999999821186066))
v24[3] = v27
v24[4] = v18
v24[5] = Material.Metal
v24[6] = Cylinder_5
v25 = {}
v28 = CFrame.new(0, 0.075, -2.65)
v25[1] = "Metal"
v25[2] = (Vector3.new(0.10999999940395355, 0.20000000298023224, 0.03999999910593033))
v25[3] = v28
v25[4] = v14
v25[5] = Material.Metal
v26 = {}
v29 = CFrame.new(0, 0.0535, -1.4802)
v26[1] = "Forend"
v26[2] = (Vector3.new(0.15000000596046448, 0.17000000178813934, 0.800000011920929))
v26[3] = v29
v26[4] = v16
v26[5] = Material.Wood
v27 = {}
v30 = CFrame.new(0, 0.0535, -1.895)
v27[1] = "Metal"
v27[2] = (Vector3.new(0.1550000011920929, 0.17499999701976776, 0.029999999329447746))
v27[3] = v30
v27[4] = v14
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(0, 0.198, -1.54)
v28[1] = "Irons"
v28[2] = (Vector3.new(0.10000000149011612, 0.052000001072883606, 0.05000000074505806))
v28[3] = v31
v28[4] = v14
v28[5] = Material.Metal
v29 = {}
v32 = CFrame.new(-0.035, 0.234, -1.54)
v29[1] = "Irons"
v29[2] = (Vector3.new(0.02500000037252903, 0.019999999552965164, 0.03999999910593033))
v29[3] = v32
v29[4] = v14
v29[5] = Material.Metal
v30 = {}
v33 = CFrame.new(0.035, 0.234, -1.54)
v30[1] = "Irons"
v30[2] = (Vector3.new(0.02500000037252903, 0.019999999552965164, 0.03999999910593033))
v30[3] = v33
v30[4] = v14
v30[5] = Material.Metal
v31 = {}
v34 = CFrame.new(0, 0.187, -2.79)
v31[1] = "Irons"
v31[2] = (Vector3.new(0.029999999329447746, 0.029999999329447746, 0.10000000149011612))
v31[3] = v34
v31[4] = v14
v31[5] = Material.Metal
v32 = {}
v35 = CFrame.new(0, 0.213, -2.7936)
v32[1] = "Irons"
v32[2] = (Vector3.new(0.012000000104308128, 0.02199999988079071, 0.029999999329447746))
v32[3] = v35
v32[4] = v14
v32[5] = Material.Metal
v33 = {}
v41 = CFrame.new(0, 0.2176, -2.7936)
v33[1] = "Bead"
v33[2] = (Vector3.new(0.013000000268220901, 0.013000000268220901, 0.013000000268220901))
v33[3] = v41
v33[4] = v20
v33[5] = Material.Metal
v33[6] = Ball_2
v22[17] = v23
v22[18] = v24
v22[19] = v25
v22[20] = v26
v22[21] = v27
v22[22] = v28
v22[23] = v29
v22[24] = v30
v22[25] = v31
v22[26] = v32
v22[27] = v33
GUNS_7.lever_carbine = v22

function u6254.deploy(a1)
    -- Line: 608
    -- upvalues: Fust (val), u6344 (val), u210 (val), u215 (val), Material (val)
    -- types: a1: string
    local Cobblestone, Cobblestone_2, Cylinder, Cylinder_2, Cylinder_3, DefenseKinds, DiamondPlate, Durability,
        Electric, Fabric, Fabric_2, Fabric_3, Fabric_4, Fabric_5, Ladders, Lamp, Light, Metal, Metal_2, Metal_3,
        Metal_4, Metal_5, Metal_6, Metal_7, Metal_8, Metal_9, Model, Part, Part_10, Part_11, Part_12, Part_13,
        Part_14, Part_15, Part_16, Part_17, Part_18, Part_19, Part_2, Part_20, Part_21, Part_22, Part_23, Part_24,
        Part_25, Part_26, Part_27, Part_28, Part_3, Part_4, Part_5, Part_6, Part_7, Part_8, Part_9, Slate, Slate_2,
        SmoothPlastic, Truss, WagonShared, Wood, WoodPlanks, WoodPlanks_10, WoodPlanks_2, WoodPlanks_3, WoodPlanks_4,
        WoodPlanks_5, WoodPlanks_6, WoodPlanks_7, WoodPlanks_8, WoodPlanks_9, Wood_2, err_10, err_11, err_12, err_13,
        err_14, err_15, err_8, err_9, success_10, success_11, success_12, success_13, success_14, success_15,
        success_16, success_9, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19,
        v20
    local BaseLights = Fust:FindFirstChild("BaseLights")

    if BaseLights then
        local success, err = pcall(require, BaseLights)

        if success and type(err) == "table" and err.KINDS[a1] then
            local Color, color
            v15 = err.BuildFallback(a1)

            for i, v in ipairs(v15:GetDescendants()) do
                if v:IsA("BasePart") then
                    if v.Name == "Glass" or v.Name == "Bulb" then
                        v.Material = Enum.Material.Neon
                        Color = v.Color
                        color = err.KINDS[a1].color
                        v.Color = Color:Lerp(color, 0.6)
                        v.Transparency = 0.1
                    end
                end
            end

            return v15
        end
    end

    if type(a1) == "string" and string.sub(a1, 1, 5) == "high_" then
        local HighWalls = Fust:FindFirstChild("HighWalls")

        if HighWalls and HighWalls:IsA("ModuleScript") then
            local success_2, err_2 = pcall(require, HighWalls)

            if success_2
                and type(err_2) == "table"
                and type(err_2.Is) == "function"
                and err_2.Is(a1) then
                local success_3, err_3 = pcall(err_2.Build, a1)

                if success_3 and err_3 then
                    return err_3
                end
            end
        end
    end

    if a1 == "wall_mount" then
        local WallMount = Fust:FindFirstChild("WallMount")

        if WallMount and WallMount:IsA("ModuleScript") then
            local success_4, err_4 = pcall(require, WallMount)

            if success_4 and type(err_4) == "table" and type(err_4.BuildFallback) == "function" then
                local success_5, err_5 = pcall(err_4.BuildFallback)

                if success_5 and err_5 then
                    pcall(
                        err_4.ShowGear,
                        err_5,
                        {torso = "burlap_shirt", legs = "burlap_trousers", feet = "burlap_shoes"},
                        "small_backpack",
                        u6344.Defs,
                        nil,
                        {"stone_hatchet"}
                    )
                    return err_5
                end
            end
        end
    end

    if a1 ~= "storage_barrel" and a1 ~= "bamboo_rack" then
        if a1 == "atv_wagon" then
            WagonShared = Fust:FindFirstChild("WagonShared")

            if WagonShared and WagonShared:IsA("ModuleScript") then
                success_9, err_8 = pcall(require, WagonShared)

                if success_9
                    and type(err_8) == "table"
                    and type(err_8.BuildFallback) == "function" then
                    success_10, err_9 = pcall(err_8.BuildFallback)

                    if success_10 and err_9 then
                        return err_9
                    end
                end
            end
        end

        if a1 == "ladder" then
            Ladders = Fust:FindFirstChild("Ladders")

            if Ladders and Ladders:IsA("ModuleScript") then
                success_11, err_10 = pcall(require, Ladders)

                if success_11 and type(err_10) == "table" and type(err_10.Build) == "function" then
                    success_12, err_11 = pcall(err_10.Build)

                    if success_12 and err_11 then
                        Truss = err_11:FindFirstChild("Truss")

                        if Truss then
                            Truss:Destroy()
                        end

                        return err_11
                    end
                end
            end

            return nil
        end

        Electric = Fust:FindFirstChild("Electric")

        if Electric and Electric:IsA("ModuleScript") then
            success_13, err_12 = pcall(require, Electric)

            if success_13
                and type(err_12) == "table"
                and type(err_12.HasFallback) == "function"
                and err_12.HasFallback(a1) then
                v16 = err_12.BuildFallback(a1)
                Lamp = v16:FindFirstChild("Lamp", true)

                if Lamp and Lamp:IsA("BasePart") then
                    Lamp.Material = Enum.Material.Neon
                    Lamp.Color = err_12.LAMP_ON
                end

                return v16
            end
        end

        DefenseKinds = Fust:FindFirstChild("DefenseKinds")

        if DefenseKinds then
            success_14, err_13 = pcall(require, DefenseKinds)

            if success_14
                and type(err_13) == "table"
                and err_13.KINDS
                and err_13.KINDS[a1] then
                v16 = err_13.BuildFallback(a1)
                Light = v16:FindFirstChild("Light")

                if Light and Light:IsA("BasePart") then
                    Light.Material = Enum.Material.Neon
                    Light.Color = err_13.LIGHT_ON
                end

                return v16
            end
        end

        if a1 == "repair_bench" then
            Durability = Fust:FindFirstChild("Durability")

            if Durability and Durability:IsA("ModuleScript") then
                success_15, err_14 = pcall(require, Durability)

                if success_15
                    and type(err_14) == "table"
                    and type(err_14.BuildBench) == "function" then
                    success_16, err_15 = pcall(err_14.BuildBench)

                    if success_16 and err_15 then
                        return err_15
                    end
                end
            end

            return nil
        end

        Model = Instance.new("Model")
        Model.Name = a1
        v15 = Color3.fromRGB(118, 116, 110)
        v16 = Color3.fromRGB(84, 82, 78)
        v17 = u210
        v18 = u215
        v19 = Color3.fromRGB(110, 113, 118)

        if a1 == "workbench_t1" then
            v20 = CFrame.new(0, 3, 0)
            WoodPlanks = Material.WoodPlanks
            Part = Instance.new("Part")
            Part.Name = "Top"
            Part.Size = Vector3.new(6, 0.4000000059604645, 3)
            Part.CFrame = v20
            Part.Color = v17
            Part.Material = WoodPlanks
            Part.Anchored = true
            Part.CanCollide = false
            Part.CanTouch = false
            Part.CanQuery = false
            Part.CastShadow = false
            Part.TopSurface = Enum.SurfaceType.Smooth
            Part.BottomSurface = Enum.SurfaceType.Smooth
            Part.Parent = Model
            v20 = CFrame.new(-2.6, 1.4, 0)
            WoodPlanks_2 = Material.WoodPlanks
            Part_2 = Instance.new("Part")
            Part_2.Name = "LegL"
            Part_2.Size = Vector3.new(0.5, 2.799999952316284, 2.5999999046325684)
            Part_2.CFrame = v20
            Part_2.Color = v18
            Part_2.Material = WoodPlanks_2
            Part_2.Anchored = true
            Part_2.CanCollide = false
            Part_2.CanTouch = false
            Part_2.CanQuery = false
            Part_2.CastShadow = false
            Part_2.TopSurface = Enum.SurfaceType.Smooth
            Part_2.BottomSurface = Enum.SurfaceType.Smooth
            Part_2.Parent = Model
            v20 = CFrame.new(2.6, 1.4, 0)
            WoodPlanks_3 = Material.WoodPlanks
            Part_3 = Instance.new("Part")
            Part_3.Name = "LegR"
            Part_3.Size = Vector3.new(0.5, 2.799999952316284, 2.5999999046325684)
            Part_3.CFrame = v20
            Part_3.Color = v18
            Part_3.Material = WoodPlanks_3
            Part_3.Anchored = true
            Part_3.CanCollide = false
            Part_3.CanTouch = false
            Part_3.CanQuery = false
            Part_3.CastShadow = false
            Part_3.TopSurface = Enum.SurfaceType.Smooth
            Part_3.BottomSurface = Enum.SurfaceType.Smooth
            Part_3.Parent = Model
            v20 = CFrame.new(0, 0.8, 0)
            WoodPlanks_4 = Material.WoodPlanks
            Part_4 = Instance.new("Part")
            Part_4.Name = "Shelf"
            Part_4.Size = Vector3.new(4.699999809265137, 0.30000001192092896, 2.4000000953674316)
            Part_4.CFrame = v20
            Part_4.Color = v18
            Part_4.Material = WoodPlanks_4
            Part_4.Anchored = true
            Part_4.CanCollide = false
            Part_4.CanTouch = false
            Part_4.CanQuery = false
            Part_4.CastShadow = false
            Part_4.TopSurface = Enum.SurfaceType.Smooth
            Part_4.BottomSurface = Enum.SurfaceType.Smooth
            Part_4.Parent = Model
            v20 = CFrame.new(2.2, 3.5, -0.9)
            Metal = Material.Metal
            Part_5 = Instance.new("Part")
            Part_5.Name = "Vise"
            Part_5.Size = Vector3.new(0.800000011920929, 0.6000000238418579, 0.699999988079071)
            Part_5.CFrame = v20
            Part_5.Color = v19
            Part_5.Material = Metal
            Part_5.Anchored = true
            Part_5.CanCollide = false
            Part_5.CanTouch = false
            Part_5.CanQuery = false
            Part_5.CastShadow = false
            Part_5.TopSurface = Enum.SurfaceType.Smooth
            Part_5.BottomSurface = Enum.SurfaceType.Smooth
            Part_5.Parent = Model

            return Model
        end

        if a1 == "workbench_t2" then
            v20 = Color3.fromRGB(96, 100, 104)
            v1 = Color3.fromRGB(62, 65, 68)
            v2 = CFrame.new(0, 3.1, 0)
            DiamondPlate = Material.DiamondPlate
            Part_6 = Instance.new("Part")
            Part_6.Name = "Top"
            Part_6.Size = Vector3.new(6.400000095367432, 0.3499999940395355, 3.200000047683716)
            Part_6.CFrame = v2
            Part_6.Color = v20
            Part_6.Material = DiamondPlate
            Part_6.Anchored = true
            Part_6.CanCollide = false
            Part_6.CanTouch = false
            Part_6.CanQuery = false
            Part_6.CastShadow = false
            Part_6.TopSurface = Enum.SurfaceType.Smooth
            Part_6.BottomSurface = Enum.SurfaceType.Smooth
            Part_6.Parent = Model
            v2 = CFrame.new(-2.9, 1.47, 0)
            Metal_2 = Material.Metal
            v20 = Instance.new("Part")
            v20.Name = "LegL"
            v20.Size = Vector3.new(0.4000000059604645, 2.950000047683716, 2.799999952316284)
            v20.CFrame = v2
            v20.Color = v1
            v20.Material = Metal_2
            v20.Anchored = true
            v20.CanCollide = false
            v20.CanTouch = false
            v20.CanQuery = false
            v20.CastShadow = false
            v20.TopSurface = Enum.SurfaceType.Smooth
            v20.BottomSurface = Enum.SurfaceType.Smooth
            v20.Parent = Model
            v2 = CFrame.new(2.9, 1.47, 0)
            Metal_3 = Material.Metal
            Part_7 = Instance.new("Part")
            Part_7.Name = "LegR"
            Part_7.Size = Vector3.new(0.4000000059604645, 2.950000047683716, 2.799999952316284)
            Part_7.CFrame = v2
            Part_7.Color = v1
            Part_7.Material = Metal_3
            Part_7.Anchored = true
            Part_7.CanCollide = false
            Part_7.CanTouch = false
            Part_7.CanQuery = false
            Part_7.CastShadow = false
            Part_7.TopSurface = Enum.SurfaceType.Smooth
            Part_7.BottomSurface = Enum.SurfaceType.Smooth
            Part_7.Parent = Model
            v2 = CFrame.new(2.3, 3.6, -1.1)
            v3 = Color3.fromRGB(70, 92, 120)
            Metal_4 = Material.Metal
            Part_8 = Instance.new("Part")
            Part_8.Name = "Vise"
            Part_8.Size = Vector3.new(0.8999999761581421, 0.699999988079071, 0.800000011920929)
            Part_8.CFrame = v2
            Part_8.Color = v3
            Part_8.Material = Metal_4
            Part_8.Anchored = true
            Part_8.CanCollide = false
            Part_8.CanTouch = false
            Part_8.CanQuery = false
            Part_8.CastShadow = false
            Part_8.TopSurface = Enum.SurfaceType.Smooth
            Part_8.BottomSurface = Enum.SurfaceType.Smooth
            Part_8.Parent = Model
            v2 = CFrame.new(0, 4.4, 1.5)
            Metal_5 = Material.Metal
            Part_9 = Instance.new("Part")
            Part_9.Name = "Rack"
            Part_9.Size = Vector3.new(5.599999904632568, 2.200000047683716, 0.20000000298023224)
            Part_9.CFrame = v2
            Part_9.Color = v1
            Part_9.Material = Metal_5
            Part_9.Anchored = true
            Part_9.CanCollide = false
            Part_9.CanTouch = false
            Part_9.CanQuery = false
            Part_9.CastShadow = false
            Part_9.TopSurface = Enum.SurfaceType.Smooth
            Part_9.BottomSurface = Enum.SurfaceType.Smooth
            Part_9.Parent = Model

            return Model
        end

        if a1 == "furnace" then
            v20 = CFrame.new(0, 1.7, 0)
            Cobblestone = Material.Cobblestone
            Part_10 = Instance.new("Part")
            Part_10.Name = "Body"
            Part_10.Size = Vector3.new(4, 3.4000000953674316, 4)
            Part_10.CFrame = v20
            Part_10.Color = v15
            Part_10.Material = Cobblestone
            Part_10.Anchored = true
            Part_10.CanCollide = false
            Part_10.CanTouch = false
            Part_10.CanQuery = false
            Part_10.CastShadow = false
            Part_10.TopSurface = Enum.SurfaceType.Smooth
            Part_10.BottomSurface = Enum.SurfaceType.Smooth
            Part_10.Parent = Model
            v20 = CFrame.new(0, 4, 0)
            Cobblestone_2 = Material.Cobblestone
            Part_11 = Instance.new("Part")
            Part_11.Name = "Top"
            Part_11.Size = Vector3.new(3.200000047683716, 1.2000000476837158, 3.200000047683716)
            Part_11.CFrame = v20
            Part_11.Color = v15
            Part_11.Material = Cobblestone_2
            Part_11.Anchored = true
            Part_11.CanCollide = false
            Part_11.CanTouch = false
            Part_11.CanQuery = false
            Part_11.CastShadow = false
            Part_11.TopSurface = Enum.SurfaceType.Smooth
            Part_11.BottomSurface = Enum.SurfaceType.Smooth
            Part_11.Parent = Model
            v20 = CFrame.new(0.6, 5.4, 0.6)
            Slate = Material.Slate
            Part_12 = Instance.new("Part")
            Part_12.Name = "Chimney"
            Part_12.Size = Vector3.new(1.100000023841858, 1.600000023841858, 1.100000023841858)
            Part_12.CFrame = v20
            Part_12.Color = v16
            Part_12.Material = Slate
            Part_12.Anchored = true
            Part_12.CanCollide = false
            Part_12.CanTouch = false
            Part_12.CanQuery = false
            Part_12.CastShadow = false
            Part_12.TopSurface = Enum.SurfaceType.Smooth
            Part_12.BottomSurface = Enum.SurfaceType.Smooth
            Part_12.Parent = Model
            v20 = CFrame.new(0, 1.3, -2)
            v1 = Color3.fromRGB(46, 30, 24)
            SmoothPlastic = Material.SmoothPlastic
            Part_13 = Instance.new("Part")
            Part_13.Name = "Opening"
            Part_13.Size = Vector3.new(1.7999999523162842, 1.399999976158142, 0.11999999731779099)
            Part_13.CFrame = v20
            Part_13.Color = v1
            Part_13.Material = SmoothPlastic
            Part_13.Anchored = true
            Part_13.CanCollide = false
            Part_13.CanTouch = false
            Part_13.CanQuery = false
            Part_13.CastShadow = false
            Part_13.TopSurface = Enum.SurfaceType.Smooth
            Part_13.BottomSurface = Enum.SurfaceType.Smooth
            Part_13.Parent = Model

            return Model
        end

        if a1 == "campfire" then
            v20 = (CFrame.new(0, 0.25, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
            Slate_2 = Material.Slate
            Cylinder = Enum.PartType.Cylinder
            Part_14 = Instance.new("Part")
            Part_14.Name = "Ring"

            if Cylinder then
                Part_14.Shape = Cylinder
            end

            Part_14.Size = Vector3.new(0.5, 4, 4)
            Part_14.CFrame = v20
            Part_14.Color = v16
            Part_14.Material = Slate_2
            Part_14.Anchored = true
            Part_14.CanCollide = false
            Part_14.CanTouch = false
            Part_14.CanQuery = false
            Part_14.CastShadow = false
            Part_14.TopSurface = Enum.SurfaceType.Smooth
            Part_14.BottomSurface = Enum.SurfaceType.Smooth
            Part_14.Parent = Model
            v20 = (CFrame.new(0, 0.8, 0)) * CFrame.Angles(0, 0.7853981633974483, 0.12)
            Wood = Material.Wood
            Cylinder_2 = Enum.PartType.Cylinder
            Part_15 = Instance.new("Part")
            Part_15.Name = "Log1"

            if Cylinder_2 then
                Part_15.Shape = Cylinder_2
            end

            Part_15.Size = Vector3.new(3.4000000953674316, 0.44999998807907104, 0.44999998807907104)
            Part_15.CFrame = v20
            Part_15.Color = v18
            Part_15.Material = Wood
            Part_15.Anchored = true
            Part_15.CanCollide = false
            Part_15.CanTouch = false
            Part_15.CanQuery = false
            Part_15.CastShadow = false
            Part_15.TopSurface = Enum.SurfaceType.Smooth
            Part_15.BottomSurface = Enum.SurfaceType.Smooth
            Part_15.Parent = Model
            v20 = (CFrame.new(0, 0.95, 0)) * CFrame.Angles(0, -0.7853981633974483, -0.12)
            Wood_2 = Material.Wood
            Cylinder_3 = Enum.PartType.Cylinder
            Part_16 = Instance.new("Part")
            Part_16.Name = "Log2"

            if Cylinder_3 then
                Part_16.Shape = Cylinder_3
            end

            Part_16.Size = Vector3.new(3.4000000953674316, 0.44999998807907104, 0.44999998807907104)
            Part_16.CFrame = v20
            Part_16.Color = v17
            Part_16.Material = Wood_2
            Part_16.Anchored = true
            Part_16.CanCollide = false
            Part_16.CanTouch = false
            Part_16.CanQuery = false
            Part_16.CastShadow = false
            Part_16.TopSurface = Enum.SurfaceType.Smooth
            Part_16.BottomSurface = Enum.SurfaceType.Smooth
            Part_16.Parent = Model

            return Model
        end

        if a1 == "wooden_box" then
            v20 = CFrame.new(0, 0.85, 0)
            WoodPlanks_5 = Material.WoodPlanks
            Part_17 = Instance.new("Part")
            Part_17.Name = "Crate"
            Part_17.Size = Vector3.new(3, 1.7000000476837158, 2)
            Part_17.CFrame = v20
            Part_17.Color = v17
            Part_17.Material = WoodPlanks_5
            Part_17.Anchored = true
            Part_17.CanCollide = false
            Part_17.CanTouch = false
            Part_17.CanQuery = false
            Part_17.CastShadow = false
            Part_17.TopSurface = Enum.SurfaceType.Smooth
            Part_17.BottomSurface = Enum.SurfaceType.Smooth
            Part_17.Parent = Model
            v20 = CFrame.new(0, 1.95, 0)
            WoodPlanks_6 = Material.WoodPlanks
            Part_18 = Instance.new("Part")
            Part_18.Name = "Lid"
            Part_18.Size = Vector3.new(3.0999999046325684, 0.5, 2.0999999046325684)
            Part_18.CFrame = v20
            Part_18.Color = v18
            Part_18.Material = WoodPlanks_6
            Part_18.Anchored = true
            Part_18.CanCollide = false
            Part_18.CanTouch = false
            Part_18.CanQuery = false
            Part_18.CastShadow = false
            Part_18.TopSurface = Enum.SurfaceType.Smooth
            Part_18.BottomSurface = Enum.SurfaceType.Smooth
            Part_18.Parent = Model
            v20 = CFrame.new(-0.9, 1.12, 0)
            Metal_6 = Material.Metal
            Part_19 = Instance.new("Part")
            Part_19.Name = "StrapL"
            Part_19.Size = Vector3.new(0.2199999988079071, 2.240000009536743, 2.1600000858306885)
            Part_19.CFrame = v20
            Part_19.Color = v19
            Part_19.Material = Metal_6
            Part_19.Anchored = true
            Part_19.CanCollide = false
            Part_19.CanTouch = false
            Part_19.CanQuery = false
            Part_19.CastShadow = false
            Part_19.TopSurface = Enum.SurfaceType.Smooth
            Part_19.BottomSurface = Enum.SurfaceType.Smooth
            Part_19.Parent = Model
            v20 = CFrame.new(0.9, 1.12, 0)
            Metal_7 = Material.Metal
            Part_20 = Instance.new("Part")
            Part_20.Name = "StrapR"
            Part_20.Size = Vector3.new(0.2199999988079071, 2.240000009536743, 2.1600000858306885)
            Part_20.CFrame = v20
            Part_20.Color = v19
            Part_20.Material = Metal_7
            Part_20.Anchored = true
            Part_20.CanCollide = false
            Part_20.CanTouch = false
            Part_20.CanQuery = false
            Part_20.CastShadow = false
            Part_20.TopSurface = Enum.SurfaceType.Smooth
            Part_20.BottomSurface = Enum.SurfaceType.Smooth
            Part_20.Parent = Model

            return Model
        end

        if a1 == "large_box" then
            v20 = CFrame.new(0, 1, 0)
            WoodPlanks_7 = Material.WoodPlanks
            Part_21 = Instance.new("Part")
            Part_21.Name = "Crate"
            Part_21.Size = Vector3.new(5, 2, 2.5999999046325684)
            Part_21.CFrame = v20
            Part_21.Color = v17
            Part_21.Material = WoodPlanks_7
            Part_21.Anchored = true
            Part_21.CanCollide = false
            Part_21.CanTouch = false
            Part_21.CanQuery = false
            Part_21.CastShadow = false
            Part_21.TopSurface = Enum.SurfaceType.Smooth
            Part_21.BottomSurface = Enum.SurfaceType.Smooth
            Part_21.Parent = Model
            v20 = CFrame.new(0, 2.3, 0)
            WoodPlanks_8 = Material.WoodPlanks
            Part_22 = Instance.new("Part")
            Part_22.Name = "Lid"
            Part_22.Size = Vector3.new(5.099999904632568, 0.6000000238418579, 2.700000047683716)
            Part_22.CFrame = v20
            Part_22.Color = v18
            Part_22.Material = WoodPlanks_8
            Part_22.Anchored = true
            Part_22.CanCollide = false
            Part_22.CanTouch = false
            Part_22.CanQuery = false
            Part_22.CastShadow = false
            Part_22.TopSurface = Enum.SurfaceType.Smooth
            Part_22.BottomSurface = Enum.SurfaceType.Smooth
            Part_22.Parent = Model
            v20 = CFrame.new(-2.45, 1.31, 0)
            Metal_8 = Material.Metal
            Part_23 = Instance.new("Part")
            Part_23.Name = "CornerL"
            Part_23.Size = Vector3.new(0.25, 2.619999885559082, 2.740000009536743)
            Part_23.CFrame = v20
            Part_23.Color = v19
            Part_23.Material = Metal_8
            Part_23.Anchored = true
            Part_23.CanCollide = false
            Part_23.CanTouch = false
            Part_23.CanQuery = false
            Part_23.CastShadow = false
            Part_23.TopSurface = Enum.SurfaceType.Smooth
            Part_23.BottomSurface = Enum.SurfaceType.Smooth
            Part_23.Parent = Model
            v20 = CFrame.new(2.45, 1.31, 0)
            Metal_9 = Material.Metal
            Part_24 = Instance.new("Part")
            Part_24.Name = "CornerR"
            Part_24.Size = Vector3.new(0.25, 2.619999885559082, 2.740000009536743)
            Part_24.CFrame = v20
            Part_24.Color = v19
            Part_24.Material = Metal_9
            Part_24.Anchored = true
            Part_24.CanCollide = false
            Part_24.CanTouch = false
            Part_24.CanQuery = false
            Part_24.CastShadow = false
            Part_24.TopSurface = Enum.SurfaceType.Smooth
            Part_24.BottomSurface = Enum.SurfaceType.Smooth
            Part_24.Parent = Model

            return Model
        end

        if a1 == "sleeping_bag" then
            v20 = Color3.fromRGB(88, 94, 60)
            v1 = Color3.fromRGB(178, 160, 122)
            v2 = CFrame.new(0, 0.225, 0)
            Fabric = Material.Fabric
            Part_25 = Instance.new("Part")
            Part_25.Name = "Bag"
            Part_25.Size = Vector3.new(2.5999999046325684, 0.44999998807907104, 6.5)
            Part_25.CFrame = v2
            Part_25.Color = v20
            Part_25.Material = Fabric
            Part_25.Anchored = true
            Part_25.CanCollide = false
            Part_25.CanTouch = false
            Part_25.CanQuery = false
            Part_25.CastShadow = false
            Part_25.TopSurface = Enum.SurfaceType.Smooth
            Part_25.BottomSurface = Enum.SurfaceType.Smooth
            Part_25.Parent = Model
            v2 = CFrame.new(0, 0.48, -1.9)
            Fabric_2 = Material.Fabric
            v20 = Instance.new("Part")
            v20.Name = "Flap"
            v20.Size = Vector3.new(2.640000104904175, 0.11999999731779099, 1.2999999523162842)
            v20.CFrame = v2
            v20.Color = v1
            v20.Material = Fabric_2
            v20.Anchored = true
            v20.CanCollide = false
            v20.CanTouch = false
            v20.CanQuery = false
            v20.CastShadow = false
            v20.TopSurface = Enum.SurfaceType.Smooth
            v20.BottomSurface = Enum.SurfaceType.Smooth
            v20.Parent = Model
            v2 = CFrame.new(0, 0.62, -2.7)
            v3 = Color3.fromRGB(197, 184, 155)
            Fabric_3 = Material.Fabric
            v1 = Instance.new("Part")
            v1.Name = "Pillow"
            v1.Size = Vector3.new(2, 0.41999998688697815, 0.949999988079071)
            v1.CFrame = v2
            v1.Color = v3
            v1.Material = Fabric_3
            v1.Anchored = true
            v1.CanCollide = false
            v1.CanTouch = false
            v1.CanQuery = false
            v1.CastShadow = false
            v1.TopSurface = Enum.SurfaceType.Smooth
            v1.BottomSurface = Enum.SurfaceType.Smooth
            v1.Parent = Model

            return Model
        end

        if a1 == "bed" then
            v20 = CFrame.new(0, 0.43, 0)
            WoodPlanks_9 = Material.WoodPlanks
            Part_26 = Instance.new("Part")
            Part_26.Name = "Frame"
            Part_26.Size = Vector3.new(3.5999999046325684, 0.8600000143051147, 7.099999904632568)
            Part_26.CFrame = v20
            Part_26.Color = v17
            Part_26.Material = WoodPlanks_9
            Part_26.Anchored = true
            Part_26.CanCollide = false
            Part_26.CanTouch = false
            Part_26.CanQuery = false
            Part_26.CastShadow = false
            Part_26.TopSurface = Enum.SurfaceType.Smooth
            Part_26.BottomSurface = Enum.SurfaceType.Smooth
            Part_26.Parent = Model
            v20 = CFrame.new(0, 1.45, -3.4)
            WoodPlanks_10 = Material.WoodPlanks
            Part_27 = Instance.new("Part")
            Part_27.Name = "Head"
            Part_27.Size = Vector3.new(3.5999999046325684, 1.2000000476837158, 0.30000001192092896)
            Part_27.CFrame = v20
            Part_27.Color = v18
            Part_27.Material = WoodPlanks_10
            Part_27.Anchored = true
            Part_27.CanCollide = false
            Part_27.CanTouch = false
            Part_27.CanQuery = false
            Part_27.CastShadow = false
            Part_27.TopSurface = Enum.SurfaceType.Smooth
            Part_27.BottomSurface = Enum.SurfaceType.Smooth
            Part_27.Parent = Model
            v20 = CFrame.new(0, 1.11, 0)
            v1 = Color3.fromRGB(150, 140, 112)
            Fabric_4 = Material.Fabric
            Part_28 = Instance.new("Part")
            Part_28.Name = "Mattress"
            Part_28.Size = Vector3.new(3.1600000858306885, 0.5, 6.800000190734863)
            Part_28.CFrame = v20
            Part_28.Color = v1
            Part_28.Material = Fabric_4
            Part_28.Anchored = true
            Part_28.CanCollide = false
            Part_28.CanTouch = false
            Part_28.CanQuery = false
            Part_28.CastShadow = false
            Part_28.TopSurface = Enum.SurfaceType.Smooth
            Part_28.BottomSurface = Enum.SurfaceType.Smooth
            Part_28.Parent = Model
            v20 = CFrame.new(0, 1.58, -2.8)
            v1 = Color3.fromRGB(200, 190, 160)
            Fabric_5 = Material.Fabric
            v3 = Instance.new("Part")
            v3.Name = "Pillow"
            v3.Size = Vector3.new(2.200000047683716, 0.44999998807907104, 0.8999999761581421)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = Fabric_5
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = CFrame.new(0, 1.47, 1.9)
            v1 = Color3.fromRGB(86, 102, 74)
            v2 = Material.Fabric
            v3 = Instance.new("Part")
            v3.Name = "Blanket"
            v3.Size = Vector3.new(3.299999952316284, 0.2199999988079071, 1.899999976158142)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model

            return Model
        end

        if a1 == "tool_cupboard" then
            v20 = CFrame.new(0, 2.8, 0)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Body"
            v2.Size = Vector3.new(3, 5.599999904632568, 2)
            v2.CFrame = v20
            v2.Color = v17
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 3.4, -1.02)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Doors"
            v2.Size = Vector3.new(2.5999999046325684, 3.200000047683716, 0.11999999731779099)
            v2.CFrame = v20
            v2.Color = v18
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 5.65, 0)
            v1 = Material.Metal
            v2 = Instance.new("Part")
            v2.Name = "Saw"
            v2.Size = Vector3.new(2, 0.05999999865889549, 0.6000000238418579)
            v2.CFrame = v20
            v2.Color = v19
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            return Model
        end

        if a1 == "dino_trophy" then
            v20 = Color3.fromRGB(214, 204, 178)
            v1 = CFrame.new(0, 0.2, 0)
            v2 = Material.WoodPlanks
            v3 = Instance.new("Part")
            v3.Name = "Base"
            v3.Size = Vector3.new(2.5999999046325684, 0.4000000059604645, 2.5999999046325684)
            v3.CFrame = v1
            v3.Color = v18
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(0, 1.5, 0.2)
            v2 = Material.WoodPlanks
            v3 = Instance.new("Part")
            v3.Name = "Post"
            v3.Size = Vector3.new(0.5, 2.200000047683716, 0.5)
            v3.CFrame = v1
            v3.Color = v17
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(0, 3.2, 0.35)
            v2 = Material.Limestone
            v3 = Instance.new("Part")
            v3.Name = "Skull"
            v3.Size = Vector3.new(1.7999999523162842, 1.2999999523162842, 1.899999976158142)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(0, 3.05, -1.3)
            v2 = Material.Limestone
            v3 = Instance.new("Part")
            v3.Name = "Snout"
            v3.Size = Vector3.new(1.25, 0.8999999761581421, 1.7000000476837158)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = (CFrame.new(0, 2.45, -0.85)) * CFrame.Angles(0.13962634015954636, 0, 0)
            v2 = Material.Limestone
            v3 = Instance.new("Part")
            v3.Name = "Jaw"
            v3.Size = Vector3.new(1.149999976158142, 0.3499999940395355, 2.299999952316284)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(0, 2.7, -1.35)
            v2 = Color3.fromRGB(240, 232, 210)
            v3 = Material.SmoothPlastic
            v20 = Instance.new("Part")
            v20.Name = "Teeth"
            v20.Size = Vector3.new(1.0499999523162842, 0.30000001192092896, 1.5)
            v20.CFrame = v1
            v20.Color = v2
            v20.Material = v3
            v20.Anchored = true
            v20.CanCollide = false
            v20.CanTouch = false
            v20.CanQuery = false
            v20.CastShadow = false
            v20.TopSurface = Enum.SurfaceType.Smooth
            v20.BottomSurface = Enum.SurfaceType.Smooth
            v20.Parent = Model

            return Model
        end

        if a1 == "large_furnace" then
            v20 = CFrame.new(0, 0.3, 0)
            v1 = Material.Cobblestone
            v2 = Instance.new("Part")
            v2.Name = "Base"
            v2.Size = Vector3.new(6, 0.6000000238418579, 6)
            v2.CFrame = v20
            v2.Color = v16
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 2.5, 0)
            v1 = Material.Cobblestone
            v2 = Instance.new("Part")
            v2.Name = "Body"
            v2.Size = Vector3.new(5.199999809265137, 3.799999952316284, 5.199999809265137)
            v2.CFrame = v20
            v2.Color = v15
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 4.1, 0)
            v1 = Color3.fromRGB(92, 72, 60)
            v2 = Material.CorrodedMetal
            v3 = Instance.new("Part")
            v3.Name = "Band"
            v3.Size = Vector3.new(5.400000095367432, 0.30000001192092896, 5.400000095367432)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = CFrame.new(0, 5.3, 0)
            v1 = Material.Cobblestone
            v2 = Instance.new("Part")
            v2.Name = "Upper"
            v2.Size = Vector3.new(4, 1.7999999523162842, 4)
            v2.CFrame = v20
            v2.Color = v15
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 7.4, 0.5)
            v1 = Material.Slate
            v2 = Instance.new("Part")
            v2.Name = "Chimney"
            v2.Size = Vector3.new(1.5, 2.4000000953674316, 1.5)
            v2.CFrame = v20
            v2.Color = v16
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 2.75, -2.7)
            v1 = Material.Metal
            v2 = Instance.new("Part")
            v2.Name = "Lintel"
            v2.Size = Vector3.new(3.200000047683716, 0.3499999940395355, 0.30000001192092896)
            v2.CFrame = v20
            v2.Color = v19
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 1.7, -2.62)
            v1 = Color3.fromRGB(255, 120, 40)
            v2 = Material.Neon
            v3 = Instance.new("Part")
            v3.Name = "Opening"
            v3.Size = Vector3.new(2.4000000953674316, 1.7999999523162842, 0.11999999731779099)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model

            return Model
        end

        if a1 == "barricade_wall" then
            v20 = CFrame.new(0, 0.9, 0)
            v1 = Material.Cobblestone
            v2 = Instance.new("Part")
            v2.Name = "Base"
            v2.Size = Vector3.new(6, 1.7999999523162842, 1)
            v2.CFrame = v20
            v2.Color = v15
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(-1.45, 3.1, -0.05)
            v1 = Color3.fromRGB(104, 84, 70)
            v2 = Material.CorrodedMetal
            v3 = Instance.new("Part")
            v3.Name = "PlateL"
            v3.Size = Vector3.new(3, 2.799999952316284, 0.25)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = CFrame.new(1.5, 3, 0.06)
            v1 = Color3.fromRGB(100, 102, 104)
            v2 = Material.Metal
            v3 = Instance.new("Part")
            v3.Name = "PlateR"
            v3.Size = Vector3.new(3, 2.5999999046325684, 0.25)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = CFrame.new(-2.7, 2.15, 0.3)
            v1 = Color3.fromRGB(62, 65, 68)
            v2 = Material.Metal
            v3 = Instance.new("Part")
            v3.Name = "PostL"
            v3.Size = Vector3.new(0.30000001192092896, 4.300000190734863, 0.30000001192092896)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = CFrame.new(2.7, 2.15, 0.3)
            v1 = Color3.fromRGB(62, 65, 68)
            v2 = Material.Metal
            v3 = Instance.new("Part")
            v3.Name = "PostR"
            v3.Size = Vector3.new(0.30000001192092896, 4.300000190734863, 0.30000001192092896)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = CFrame.new(0, 3.7, -0.22)
            v1 = Color3.fromRGB(62, 65, 68)
            v2 = Material.Metal
            v3 = Instance.new("Part")
            v3.Name = "Strap"
            v3.Size = Vector3.new(5.800000190734863, 0.20000000298023224, 0.20000000298023224)
            v3.CFrame = v20
            v3.Color = v1
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model

            return Model
        end

        if a1 == "wood_barricade" then
            v20 = CFrame.new(0, 0.35, 0)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Base"
            v2.Size = Vector3.new(7, 0.699999988079071, 1.100000023841858)
            v2.CFrame = v20
            v2.Color = v18
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            for i11, i92 in ipairs({1.45, 2.95, 4.45, 5.9}) do
                v5 = "Plank" .. i11
                v6 = CFrame.new(0, i92, -0.2)
                v7 = if i11 % 2 ~= 0 then v17 else Color3.fromRGB(112, 79, 48)
                v8 = Material.WoodPlanks
                v9 = Instance.new("Part")
                v9.Name = v5
                v9.Size = Vector3.new(7, 1.4500000476837158, 0.30000001192092896)
                v9.CFrame = v6
                v9.Color = v7
                v9.Material = v8
                v9.Anchored = true
                v9.CanCollide = false
                v9.CanTouch = false
                v9.CanQuery = false
                v9.CastShadow = false
                v9.TopSurface = Enum.SurfaceType.Smooth
                v9.BottomSurface = Enum.SurfaceType.Smooth
                v9.Parent = Model
            end

            v20 = CFrame.new(-3.1, 3.4, 0.2)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "PostL"
            v2.Size = Vector3.new(0.5, 6.800000190734863, 0.5)
            v2.CFrame = v20
            v2.Color = v18
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(3.1, 3.4, 0.2)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "PostR"
            v2.Size = Vector3.new(0.5, 6.800000190734863, 0.5)
            v2.CFrame = v20
            v2.Color = v18
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 3.6, -0.42)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Batten"
            v2.Size = Vector3.new(0.44999998807907104, 5.599999904632568, 0.14000000059604645)
            v2.CFrame = v20
            v2.Color = v18
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            return Model
        end

        if a1 == "workbench_t3" then
            v20 = Color3.fromRGB(84, 90, 98)
            v1 = Color3.fromRGB(52, 55, 60)
            v2 = Color3.fromRGB(70, 92, 120)
            v3 = CFrame.new(0, 3.2, 0)
            v4 = Material.DiamondPlate
            v5 = Instance.new("Part")
            v5.Name = "Top"
            v5.Size = Vector3.new(7, 0.4000000059604645, 3.4000000953674316)
            v5.CFrame = v3
            v5.Color = v20
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(-3.2, 1.5, 0)
            v4 = Material.Metal
            v5 = Instance.new("Part")
            v5.Name = "LegL"
            v5.Size = Vector3.new(0.44999998807907104, 3, 3)
            v5.CFrame = v3
            v5.Color = v1
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(3.2, 1.5, 0)
            v4 = Material.Metal
            v5 = Instance.new("Part")
            v5.Name = "LegR"
            v5.Size = Vector3.new(0.44999998807907104, 3, 3)
            v5.CFrame = v3
            v5.Color = v1
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(0, 0.7, 0)
            v4 = Material.Metal
            v5 = Instance.new("Part")
            v5.Name = "Shelf"
            v5.Size = Vector3.new(6, 0.25, 2.799999952316284)
            v5.CFrame = v3
            v5.Color = v1
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(2.6, 3.75, -1.2)
            v4 = Material.Metal
            v5 = Instance.new("Part")
            v5.Name = "Vise"
            v5.Size = Vector3.new(0.8999999761581421, 0.699999988079071, 0.800000011920929)
            v5.CFrame = v3
            v5.Color = v2
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(0, 4.6, 1.6)
            v4 = Material.Metal
            v5 = Instance.new("Part")
            v5.Name = "Rack"
            v5.Size = Vector3.new(6.199999809265137, 2.4000000953674316, 0.20000000298023224)
            v5.CFrame = v3
            v5.Color = v1
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(-2.6, 5, 1)
            v4 = Material.Metal
            v1 = Instance.new("Part")
            v1.Name = "DrillColumn"
            v1.Size = Vector3.new(0.3499999940395355, 3.200000047683716, 0.3499999940395355)
            v1.CFrame = v3
            v1.Color = v20
            v1.Material = v4
            v1.Anchored = true
            v1.CanCollide = false
            v1.CanTouch = false
            v1.CanQuery = false
            v1.CastShadow = false
            v1.TopSurface = Enum.SurfaceType.Smooth
            v1.BottomSurface = Enum.SurfaceType.Smooth
            v1.Parent = Model
            v3 = CFrame.new(-2.6, 6.2, 0.55)
            v4 = Material.Metal
            v20 = Instance.new("Part")
            v20.Name = "DrillHead"
            v20.Size = Vector3.new(1, 0.800000011920929, 1.2999999523162842)
            v20.CFrame = v3
            v20.Color = v2
            v20.Material = v4
            v20.Anchored = true
            v20.CanCollide = false
            v20.CanTouch = false
            v20.CanQuery = false
            v20.CastShadow = false
            v20.TopSurface = Enum.SurfaceType.Smooth
            v20.BottomSurface = Enum.SurfaceType.Smooth
            v20.Parent = Model
            v3 = CFrame.new(-2.6, 5.45, 0.2)
            v4 = Color3.fromRGB(176, 178, 182)
            v5 = Material.Metal
            v2 = Instance.new("Part")
            v2.Name = "DrillBit"
            v2.Size = Vector3.new(0.11999999731779099, 0.699999988079071, 0.11999999731779099)
            v2.CFrame = v3
            v2.Color = v4
            v2.Material = v5
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            return Model
        end

        if a1 == "mixing_table" then
            v20 = CFrame.new(0, 2.9, 0)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Top"
            v2.Size = Vector3.new(5, 0.30000001192092896, 2.5999999046325684)
            v2.CFrame = v20
            v2.Color = v17
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            for i10, i82 in ipairs({-2.2, 2.2}) do
                v5 = "LegF" .. i10
                v6 = CFrame.new(i82, 1.375, -1)
                v7 = Material.WoodPlanks
                v8 = Instance.new("Part")
                v8.Name = v5
                v8.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
                v8.CFrame = v6
                v8.Color = v18
                v8.Material = v7
                v8.Anchored = true
                v8.CanCollide = false
                v8.CanTouch = false
                v8.CanQuery = false
                v8.CastShadow = false
                v8.TopSurface = Enum.SurfaceType.Smooth
                v8.BottomSurface = Enum.SurfaceType.Smooth
                v8.Parent = Model
                v5 = "LegB" .. i10
                v6 = CFrame.new(i82, 1.375, 1)
                v7 = Material.WoodPlanks
                v8 = Instance.new("Part")
                v8.Name = v5
                v8.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
                v8.CFrame = v6
                v8.Color = v18
                v8.Material = v7
                v8.Anchored = true
                v8.CanCollide = false
                v8.CanTouch = false
                v8.CanQuery = false
                v8.CastShadow = false
                v8.TopSurface = Enum.SurfaceType.Smooth
                v8.BottomSurface = Enum.SurfaceType.Smooth
                v8.Parent = Model
            end

            v20 = (CFrame.new(-1.4, 3.35, -0.4)) * CFrame.Angles(0, 0, 1.5707963267948966)
            v1 = Material.Slate
            v2 = Enum.PartType.Cylinder
            v3 = Instance.new("Part")
            v3.Name = "Mortar"

            if v2 then
                v3.Shape = v2
            end

            v3.Size = Vector3.new(0.6000000238418579, 0.8999999761581421, 0.8999999761581421)
            v3.CFrame = v20
            v3.Color = v15
            v3.Material = v1
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v20 = (CFrame.new(0.9, 3.5, 0.3)) * CFrame.Angles(0, 0, 1.5707963267948966)
            v1 = Color3.fromRGB(150, 180, 170)
            v2 = Material.Glass
            v3 = Enum.PartType.Cylinder
            v4 = Instance.new("Part")
            v4.Name = "Jar1"

            if v3 then
                v4.Shape = v3
            end

            v4.Size = Vector3.new(0.8999999761581421, 0.5, 0.5)
            v4.CFrame = v20
            v4.Color = v1
            v4.Material = v2
            v4.Anchored = true
            v4.CanCollide = false
            v4.CanTouch = false
            v4.CanQuery = false
            v4.CastShadow = false
            v4.TopSurface = Enum.SurfaceType.Smooth
            v4.BottomSurface = Enum.SurfaceType.Smooth
            v4.Parent = Model
            v20 = (CFrame.new(1.6, 3.4, -0.3)) * CFrame.Angles(0, 0, 1.5707963267948966)
            v1 = Color3.fromRGB(120, 60, 50)
            v2 = Material.Glass
            v3 = Enum.PartType.Cylinder
            v4 = Instance.new("Part")
            v4.Name = "Jar2"

            if v3 then
                v4.Shape = v3
            end

            v4.Size = Vector3.new(0.699999988079071, 0.44999998807907104, 0.44999998807907104)
            v4.CFrame = v20
            v4.Color = v1
            v4.Material = v2
            v4.Anchored = true
            v4.CanCollide = false
            v4.CanTouch = false
            v4.CanQuery = false
            v4.CastShadow = false
            v4.TopSurface = Enum.SurfaceType.Smooth
            v4.BottomSurface = Enum.SurfaceType.Smooth
            v4.Parent = Model
            v20 = CFrame.new(-0.2, 3.1, -0.6)
            v1 = Material.Metal
            v2 = Instance.new("Part")
            v2.Name = "Scale"
            v2.Size = Vector3.new(0.8999999761581421, 0.10000000149011612, 0.6000000238418579)
            v2.CFrame = v20
            v2.Color = v19
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model
            v20 = CFrame.new(0, 3.85, 1.2)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Board"
            v2.Size = Vector3.new(5, 1.600000023841858, 0.20000000298023224)
            v2.CFrame = v20
            v2.Color = v18
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            return Model
        end

        if a1 == "skin_bench" then
            v20 = Color3.fromRGB(214, 124, 44)
            v1 = CFrame.new(0, 2.9, 0)
            v2 = Material.WoodPlanks
            v3 = Instance.new("Part")
            v3.Name = "Top"
            v3.Size = Vector3.new(5, 0.30000001192092896, 2.4000000953674316)
            v3.CFrame = v1
            v3.Color = v17
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model

            for i8, i62 in ipairs({-2.2, 2.2}) do
                v6 = "LegF" .. i8
                v7 = CFrame.new(i62, 1.375, -0.9)
                v8 = Material.WoodPlanks
                v9 = Instance.new("Part")
                v9.Name = v6
                v9.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
                v9.CFrame = v7
                v9.Color = v18
                v9.Material = v8
                v9.Anchored = true
                v9.CanCollide = false
                v9.CanTouch = false
                v9.CanQuery = false
                v9.CastShadow = false
                v9.TopSurface = Enum.SurfaceType.Smooth
                v9.BottomSurface = Enum.SurfaceType.Smooth
                v9.Parent = Model
                v6 = "LegB" .. i8
                v7 = CFrame.new(i62, 1.375, 0.9)
                v8 = Material.WoodPlanks
                v9 = Instance.new("Part")
                v9.Name = v6
                v9.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
                v9.CFrame = v7
                v9.Color = v18
                v9.Material = v8
                v9.Anchored = true
                v9.CanCollide = false
                v9.CanTouch = false
                v9.CanQuery = false
                v9.CastShadow = false
                v9.TopSurface = Enum.SurfaceType.Smooth
                v9.BottomSurface = Enum.SurfaceType.Smooth
                v9.Parent = Model
            end

            v1 = CFrame.new(0, 4.25, 1.1)
            v2 = Material.WoodPlanks
            v3 = Instance.new("Part")
            v3.Name = "Board"
            v3.Size = Vector3.new(5, 2.4000000953674316, 0.20000000298023224)
            v3.CFrame = v1
            v3.Color = v18
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(-0.5, 4.65, 0.98)
            v2 = Material.SmoothPlastic
            v3 = Instance.new("Part")
            v3.Name = "StencilBody"
            v3.Size = Vector3.new(2.200000047683716, 0.550000011920929, 0.05000000074505806)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = (CFrame.new(-1.95, 4.55, 0.98)) * CFrame.Angles(0, 0, 0.12)
            v2 = Material.SmoothPlastic
            v3 = Instance.new("Part")
            v3.Name = "StencilStock"
            v3.Size = Vector3.new(0.8999999761581421, 0.41999998688697815, 0.05000000074505806)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(1.25, 4.78, 0.98)
            v2 = Material.SmoothPlastic
            v3 = Instance.new("Part")
            v3.Name = "StencilBarrel"
            v3.Size = Vector3.new(1.2999999523162842, 0.1599999964237213, 0.05000000074505806)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = (CFrame.new(0.15, 4.15, 0.98)) * CFrame.Angles(0, 0, -0.25)
            v2 = Material.SmoothPlastic
            v3 = Instance.new("Part")
            v3.Name = "StencilGrip"
            v3.Size = Vector3.new(0.2800000011920929, 0.6000000238418579, 0.05000000074505806)
            v3.CFrame = v1
            v3.Color = v20
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model

            for i9, i72 in ipairs({
                {1, Color3.fromRGB(176, 40, 36)},
                {1.45, Color3.fromRGB(52, 96, 168)},
                {1.9, Color3.fromRGB(214, 180, 48)},
            }) do
                v6 = "Can" .. i9
                v7 = (CFrame.new(i72[1], 3.425, -0.45)) * CFrame.Angles(0, 0, 1.5707963267948966)
                v8 = i72[2]
                v9 = Material.Metal
                v10 = Enum.PartType.Cylinder
                v20 = Instance.new("Part")
                v20.Name = v6

                if v10 then
                    v20.Shape = v10
                end

                v20.Size = Vector3.new(0.75, 0.3199999928474426, 0.3199999928474426)
                v20.CFrame = v7
                v20.Color = v8
                v20.Material = v9
                v20.Anchored = true
                v20.CanCollide = false
                v20.CanTouch = false
                v20.CanQuery = false
                v20.CastShadow = false
                v20.TopSurface = Enum.SurfaceType.Smooth
                v20.BottomSurface = Enum.SurfaceType.Smooth
                v20.Parent = Model
            end

            v1 = CFrame.new(-1.3, 3.11, -0.3)
            v2 = Material.Metal
            v3 = Instance.new("Part")
            v3.Name = "Tray"
            v3.Size = Vector3.new(1.2999999523162842, 0.11999999731779099, 0.8999999761581421)
            v3.CFrame = v1
            v3.Color = v19
            v3.Material = v2
            v3.Anchored = true
            v3.CanCollide = false
            v3.CanTouch = false
            v3.CanQuery = false
            v3.CastShadow = false
            v3.TopSurface = Enum.SurfaceType.Smooth
            v3.BottomSurface = Enum.SurfaceType.Smooth
            v3.Parent = Model
            v1 = CFrame.new(-1.3, 3.18, -0.3)
            v2 = Color3.fromRGB(46, 150, 132)
            v3 = Material.SmoothPlastic
            v4 = Instance.new("Part")
            v4.Name = "Paint"
            v4.Size = Vector3.new(1.100000023841858, 0.03999999910593033, 0.699999988079071)
            v4.CFrame = v1
            v4.Color = v2
            v4.Material = v3
            v4.Anchored = true
            v4.CanCollide = false
            v4.CanTouch = false
            v4.CanQuery = false
            v4.CastShadow = false
            v4.TopSurface = Enum.SurfaceType.Smooth
            v4.BottomSurface = Enum.SurfaceType.Smooth
            v4.Parent = Model

            return Model
        end

        if a1 == "wardrobe" then
            v20 = Color3.fromRGB(134, 95, 58)
            v1 = Color3.fromRGB(110, 78, 48)
            v2 = Color3.fromRGB(176, 140, 72)
            v3 = CFrame.new(0, 3.5, 0.05)
            v4 = Material.WoodPlanks
            v5 = Instance.new("Part")
            v5.Name = "Body"
            v5.Size = Vector3.new(3.5999999046325684, 6.199999809265137, 1.899999976158142)
            v5.CFrame = v3
            v5.Color = v17
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(0, 0.2, 0.05)
            v4 = Material.WoodPlanks
            v5 = Instance.new("Part")
            v5.Name = "Plinth"
            v5.Size = Vector3.new(3.5, 0.4000000059604645, 1.7999999523162842)
            v5.CFrame = v3
            v5.Color = v18
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model
            v3 = CFrame.new(0, 6.8, 0)
            v4 = Material.WoodPlanks
            v5 = Instance.new("Part")
            v5.Name = "Crown"
            v5.Size = Vector3.new(3.799999952316284, 0.4000000059604645, 2.0999999046325684)
            v5.CFrame = v3
            v5.Color = v18
            v5.Material = v4
            v5.Anchored = true
            v5.CanCollide = false
            v5.CanTouch = false
            v5.CanQuery = false
            v5.CastShadow = false
            v5.TopSurface = Enum.SurfaceType.Smooth
            v5.BottomSurface = Enum.SurfaceType.Smooth
            v5.Parent = Model

            for i7, i52 in ipairs({-0.88, 0.88}) do
                v8 = "Door" .. i7
                v9 = CFrame.new(i52, 3.55, -0.96)
                v10 = Material.WoodPlanks
                v11 = Instance.new("Part")
                v11.Name = v8
                v11.Size = Vector3.new(1.7400000095367432, 5.800000190734863, 0.11999999731779099)
                v11.CFrame = v9
                v11.Color = v20
                v11.Material = v10
                v11.Anchored = true
                v11.CanCollide = false
                v11.CanTouch = false
                v11.CanQuery = false
                v11.CastShadow = false
                v11.TopSurface = Enum.SurfaceType.Smooth
                v11.BottomSurface = Enum.SurfaceType.Smooth
                v11.Parent = Model
                v8 = "PanelU" .. i7
                v9 = CFrame.new(i52, 4.85, -1.05)
                v10 = Material.WoodPlanks
                v11 = Instance.new("Part")
                v11.Name = v8
                v11.Size = Vector3.new(1.2999999523162842, 2.299999952316284, 0.05999999865889549)
                v11.CFrame = v9
                v11.Color = v1
                v11.Material = v10
                v11.Anchored = true
                v11.CanCollide = false
                v11.CanTouch = false
                v11.CanQuery = false
                v11.CastShadow = false
                v11.TopSurface = Enum.SurfaceType.Smooth
                v11.BottomSurface = Enum.SurfaceType.Smooth
                v11.Parent = Model
                v8 = "PanelL" .. i7
                v9 = CFrame.new(i52, 2.15, -1.05)
                v10 = Material.WoodPlanks
                v11 = Instance.new("Part")
                v11.Name = v8
                v11.Size = Vector3.new(1.2999999523162842, 2.299999952316284, 0.05999999865889549)
                v11.CFrame = v9
                v11.Color = v1
                v11.Material = v10
                v11.Anchored = true
                v11.CanCollide = false
                v11.CanTouch = false
                v11.CanQuery = false
                v11.CastShadow = false
                v11.TopSurface = Enum.SurfaceType.Smooth
                v11.BottomSurface = Enum.SurfaceType.Smooth
                v11.Parent = Model
                v8 = CFrame.new(i52 * 0.18, 3.6, -1.1)
                v9 = Material.Metal
                v10 = Enum.PartType.Ball
                v11 = Instance.new("Part")
                v11.Name = "Knob"

                if v10 then
                    v11.Shape = v10
                end

                v11.Size = Vector3.new(0.20000000298023224, 0.20000000298023224, 0.20000000298023224)
                v11.CFrame = v8
                v11.Color = v2
                v11.Material = v9
                v11.Anchored = true
                v11.CanCollide = false
                v11.CanTouch = false
                v11.CanQuery = false
                v11.CastShadow = false
                v11.TopSurface = Enum.SurfaceType.Smooth
                v11.BottomSurface = Enum.SurfaceType.Smooth
                v11.Parent = Model
            end

            return Model
        end

        if a1 == "locker" then
            v20 = Color3.fromRGB(78, 98, 88)
            v1 = Color3.fromRGB(90, 112, 100)
            v2 = Color3.fromRGB(44, 48, 46)
            v3 = Color3.fromRGB(170, 174, 178)
            v4 = CFrame.new(0, 3.6, 0.05)
            v5 = Material.Metal
            v6 = Instance.new("Part")
            v6.Name = "Body"
            v6.Size = Vector3.new(4.5, 6.599999904632568, 1.7999999523162842)
            v6.CFrame = v4
            v6.Color = v20
            v6.Material = v5
            v6.Anchored = true
            v6.CanCollide = false
            v6.CanTouch = false
            v6.CanQuery = false
            v6.CastShadow = false
            v6.TopSurface = Enum.SurfaceType.Smooth
            v6.BottomSurface = Enum.SurfaceType.Smooth
            v6.Parent = Model
            v4 = CFrame.new(0, 0.15, 0.05)
            v5 = Material.Metal
            v20 = Instance.new("Part")
            v20.Name = "Base"
            v20.Size = Vector3.new(4.400000095367432, 0.30000001192092896, 1.7000000476837158)
            v20.CFrame = v4
            v20.Color = v2
            v20.Material = v5
            v20.Anchored = true
            v20.CanCollide = false
            v20.CanTouch = false
            v20.CanQuery = false
            v20.CastShadow = false
            v20.TopSurface = Enum.SurfaceType.Smooth
            v20.BottomSurface = Enum.SurfaceType.Smooth
            v20.Parent = Model
            v4 = CFrame.new(0, 6.96, 0.05)
            v5 = Material.Metal
            v6 = Instance.new("Part")
            v6.Name = "Top"
            v6.Size = Vector3.new(4.599999904632568, 0.11999999731779099, 1.899999976158142)
            v6.CFrame = v4
            v6.Color = v2
            v6.Material = v5
            v6.Anchored = true
            v6.CanCollide = false
            v6.CanTouch = false
            v6.CanQuery = false
            v6.CastShadow = false
            v6.TopSurface = Enum.SurfaceType.Smooth
            v6.BottomSurface = Enum.SurfaceType.Smooth
            v6.Parent = Model

            for i6, n in ipairs({-1.47, 0, 1.47}) do
                v9 = "Door" .. i6
                v10 = CFrame.new(n, 3.6, -0.89)
                v11 = Material.Metal
                v12 = Instance.new("Part")
                v12.Name = v9
                v12.Size = Vector3.new(1.399999976158142, 6.199999809265137, 0.07999999821186066)
                v12.CFrame = v10
                v12.Color = v1
                v12.Material = v11
                v12.Anchored = true
                v12.CanCollide = false
                v12.CanTouch = false
                v12.CanQuery = false
                v12.CastShadow = false
                v12.TopSurface = Enum.SurfaceType.Smooth
                v12.BottomSurface = Enum.SurfaceType.Smooth
                v12.Parent = Model

                for m = 0, 2 do
                    v12 = CFrame.new
                    v14 = 5.9 + m * 0.22
                    v12 = v12(n, v14, -0.945)
                    v13 = Material.Metal
                    v14 = Instance.new("Part")
                    v14.Name = "Vent"
                    v14.Size = Vector3.new(0.8999999761581421, 0.07999999821186066, 0.03999999910593033)
                    v14.CFrame = v12
                    v14.Color = v2
                    v14.Material = v13
                    v14.Anchored = true
                    v14.CanCollide = false
                    v14.CanTouch = false
                    v14.CanQuery = false
                    v14.CastShadow = false
                    v14.TopSurface = Enum.SurfaceType.Smooth
                    v14.BottomSurface = Enum.SurfaceType.Smooth
                    v14.Parent = Model
                end

                v9 = CFrame.new(n - 0.5, 3.7, -0.99)
                v10 = Material.Metal
                v11 = Instance.new("Part")
                v11.Name = "Handle"
                v11.Size = Vector3.new(0.10000000149011612, 0.5, 0.11999999731779099)
                v11.CFrame = v9
                v11.Color = v3
                v11.Material = v10
                v11.Anchored = true
                v11.CanCollide = false
                v11.CanTouch = false
                v11.CanQuery = false
                v11.CastShadow = false
                v11.TopSurface = Enum.SurfaceType.Smooth
                v11.BottomSurface = Enum.SurfaceType.Smooth
                v11.Parent = Model
            end

            return Model
        end

        if a1 ~= "toilet" then
            if a1 == "shelves" then
                for i2, i3 in ipairs({0.225, 3.125, 6.025}) do
                    v5 = "Plank" .. i2
                    v6 = CFrame.new(0, i3, 0)
                    v7 = if i2 ~= 3 then v17 else v18
                    v8 = Material.WoodPlanks
                    v9 = Instance.new("Part")
                    v9.Name = v5
                    v9.Size = Vector3.new(7.099999904632568, 0.25, 2.700000047683716)
                    v9.CFrame = v6
                    v9.Color = v7
                    v9.Material = v8
                    v9.Anchored = true
                    v9.CanCollide = false
                    v9.CanTouch = false
                    v9.CanQuery = false
                    v9.CastShadow = false
                    v9.TopSurface = Enum.SurfaceType.Smooth
                    v9.BottomSurface = Enum.SurfaceType.Smooth
                    v9.Parent = Model
                end

                for i4, j in ipairs({-3.55, 3.55}) do
                    for i5, k in ipairs({-1.25, 1.25}) do
                        v10 = CFrame.new(j, 3.2, k)
                        v11 = Material.Metal
                        v12 = Instance.new("Part")
                        v12.Name = "Post"
                        v12.Size = Vector3.new(0.30000001192092896, 6.400000095367432, 0.30000001192092896)
                        v12.CFrame = v10
                        v12.Color = v19
                        v12.Material = v11
                        v12.Anchored = true
                        v12.CanCollide = false
                        v12.CanTouch = false
                        v12.CanQuery = false
                        v12.CastShadow = false
                        v12.TopSurface = Enum.SurfaceType.Smooth
                        v12.BottomSurface = Enum.SurfaceType.Smooth
                        v12.Parent = Model
                    end
                end

                v20 = CFrame.new(-1.75, 1.35, 0)
                v1 = Material.WoodPlanks
                v2 = Instance.new("Part")
                v2.Name = "Box"
                v2.Size = Vector3.new(3, 2, 2)
                v2.CFrame = v20
                v2.Color = v17
                v2.Material = v1
                v2.Anchored = true
                v2.CanCollide = false
                v2.CanTouch = false
                v2.CanQuery = false
                v2.CastShadow = false
                v2.TopSurface = Enum.SurfaceType.Smooth
                v2.BottomSurface = Enum.SurfaceType.Smooth
                v2.Parent = Model

                return Model
            end

            Model:Destroy()

            return nil
        end

        v20 = Color3.fromRGB(238, 238, 232)
        v1 = Color3.fromRGB(214, 216, 212)
        v2 = Color3.fromRGB(184, 186, 190)
        v3 = Color3.fromRGB(104, 158, 186)
        v4 = CFrame.Angles(0, 0, 1.5707963267948966)
        v5 = Enum.PartType.Cylinder
        v6 = CFrame.new(0, 0.08, -0.15)
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "Foot"
        v8.Size = Vector3.new(1.399999976158142, 0.1599999964237213, 1.899999976158142)
        v8.CFrame = v6
        v8.Color = v1
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 0.61, -0.15)
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "Pedestal"
        v8.Size = Vector3.new(1.0499999523162842, 0.8999999761581421, 1.7000000476837158)
        v8.CFrame = v6
        v8.Color = v20
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 1.2, -0.45) * v4
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "Bowl"

        if v5 then
            v8.Shape = v5
        end

        v8.Size = Vector3.new(0.7200000286102295, 2, 2)
        v8.CFrame = v6
        v8.Color = v20
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 1.2, -0.8) * v4
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "BowlFront"

        if v5 then
            v8.Shape = v5
        end

        v8.Size = Vector3.new(0.7200000286102295, 1.7000000476837158, 1.7000000476837158)
        v8.CFrame = v6
        v8.Color = v20
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 1.62, -0.45) * v4
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "SeatRing"

        if v5 then
            v8.Shape = v5
        end

        v8.Size = Vector3.new(0.11999999731779099, 2.059999942779541, 2.059999942779541)
        v8.CFrame = v6
        v8.Color = v1
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 1.62, -0.8) * v4
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "SeatFront"

        if v5 then
            v8.Shape = v5
        end

        v8.Size = Vector3.new(0.11999999731779099, 1.7599999904632568, 1.7599999904632568)
        v8.CFrame = v6
        v8.Color = v1
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 1.69, -0.62) * v4
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "Water"

        if v5 then
            v8.Shape = v5
        end

        v8.Size = Vector3.new(0.019999999552965164, 1.2999999523162842, 1.2999999523162842)
        v8.CFrame = v6
        v8.Color = v3
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = CFrame.new(0, 1.2, 0.75)
        v7 = Material.SmoothPlastic
        v4 = Instance.new("Part")
        v4.Name = "Neck"
        v4.Size = Vector3.new(1.2000000476837158, 0.699999988079071, 0.800000011920929)
        v4.CFrame = v6
        v4.Color = v20
        v4.Material = v7
        v4.Anchored = true
        v4.CanCollide = false
        v4.CanTouch = false
        v4.CanQuery = false
        v4.CastShadow = false
        v4.TopSurface = Enum.SurfaceType.Smooth
        v4.BottomSurface = Enum.SurfaceType.Smooth
        v4.Parent = Model
        v6 = CFrame.new(0, 2.43, 0.96)
        v7 = Material.SmoothPlastic
        v3 = Instance.new("Part")
        v3.Name = "Tank"
        v3.Size = Vector3.new(2, 1.75, 0.7799999713897705)
        v3.CFrame = v6
        v3.Color = v20
        v3.Material = v7
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v6 = CFrame.new(0, 3.385, 0.96)
        v7 = Material.SmoothPlastic
        v8 = Instance.new("Part")
        v8.Name = "TankLid"
        v8.Size = Vector3.new(2.140000104904175, 0.1599999964237213, 0.9200000166893005)
        v8.CFrame = v6
        v8.Color = v1
        v8.Material = v7
        v8.Anchored = true
        v8.CanCollide = false
        v8.CanTouch = false
        v8.CanQuery = false
        v8.CastShadow = false
        v8.TopSurface = Enum.SurfaceType.Smooth
        v8.BottomSurface = Enum.SurfaceType.Smooth
        v8.Parent = Model
        v6 = (CFrame.new(0, 2.54, 0.5)) * CFrame.Angles(0, 1.5707963267948966, 0)
        v7 = Material.SmoothPlastic
        v1 = Instance.new("Part")
        v1.Name = "Lid"

        if v5 then
            v1.Shape = v5
        end

        v1.Size = Vector3.new(0.10000000149011612, 1.840000033378601, 1.840000033378601)
        v1.CFrame = v6
        v1.Color = v20
        v1.Material = v7
        v1.Anchored = true
        v1.CanCollide = false
        v1.CanTouch = false
        v1.CanQuery = false
        v1.CastShadow = false
        v1.TopSurface = Enum.SurfaceType.Smooth
        v1.BottomSurface = Enum.SurfaceType.Smooth
        v1.Parent = Model
        v6 = CFrame.new(-0.9, 3.05, 0.51)
        v7 = Material.Metal
        v5 = Instance.new("Part")
        v5.Name = "Handle"
        v5.Size = Vector3.new(0.18000000715255737, 0.09000000357627869, 0.11999999731779099)
        v5.CFrame = v6
        v5.Color = v2
        v5.Material = v7
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model

        return Model
    end

    local Storage558 = Fust:FindFirstChild("Storage558")

    if Storage558 and Storage558:IsA("ModuleScript") then
        local success_7, err_6 = pcall(require, Storage558)

        if success_7 and type(err_6) == "table" and type(err_6.BuildFallback) == "function" then
            local success_8, err_7 = pcall(err_6.BuildFallback, a1)

            if success_8 and err_7 then
                return err_7
            end
        end
    end

    if a1 == "atv_wagon" then
        WagonShared = Fust:FindFirstChild("WagonShared")

        if WagonShared and WagonShared:IsA("ModuleScript") then
            success_9, err_8 = pcall(require, WagonShared)

            if success_9 and type(err_8) == "table" and type(err_8.BuildFallback) == "function" then
                success_10, err_9 = pcall(err_8.BuildFallback)

                if success_10 and err_9 then
                    return err_9
                end
            end
        end
    end

    if a1 == "ladder" then
        Ladders = Fust:FindFirstChild("Ladders")

        if Ladders and Ladders:IsA("ModuleScript") then
            success_11, err_10 = pcall(require, Ladders)

            if success_11 and type(err_10) == "table" and type(err_10.Build) == "function" then
                success_12, err_11 = pcall(err_10.Build)

                if success_12 and err_11 then
                    Truss = err_11:FindFirstChild("Truss")

                    if Truss then
                        Truss:Destroy()
                    end

                    return err_11
                end
            end
        end

        return nil
    end

    Electric = Fust:FindFirstChild("Electric")

    if Electric and Electric:IsA("ModuleScript") then
        success_13, err_12 = pcall(require, Electric)

        if success_13
            and type(err_12) == "table"
            and type(err_12.HasFallback) == "function"
            and err_12.HasFallback(a1) then
            v16 = err_12.BuildFallback(a1)
            Lamp = v16:FindFirstChild("Lamp", true)

            if Lamp and Lamp:IsA("BasePart") then
                Lamp.Material = Enum.Material.Neon
                Lamp.Color = err_12.LAMP_ON
            end

            return v16
        end
    end

    DefenseKinds = Fust:FindFirstChild("DefenseKinds")

    if DefenseKinds then
        success_14, err_13 = pcall(require, DefenseKinds)

        if success_14 and type(err_13) == "table" and err_13.KINDS and err_13.KINDS[a1] then
            v16 = err_13.BuildFallback(a1)
            Light = v16:FindFirstChild("Light")

            if Light and Light:IsA("BasePart") then
                Light.Material = Enum.Material.Neon
                Light.Color = err_13.LIGHT_ON
            end

            return v16
        end
    end

    if a1 == "repair_bench" then
        Durability = Fust:FindFirstChild("Durability")

        if Durability and Durability:IsA("ModuleScript") then
            success_15, err_14 = pcall(require, Durability)

            if success_15 and type(err_14) == "table" and type(err_14.BuildBench) == "function" then
                success_16, err_15 = pcall(err_14.BuildBench)

                if success_16 and err_15 then
                    return err_15
                end
            end
        end

        return nil
    end

    Model = Instance.new("Model")
    Model.Name = a1
    v15 = Color3.fromRGB(118, 116, 110)
    v16 = Color3.fromRGB(84, 82, 78)
    v17 = u210
    v18 = u215
    v19 = Color3.fromRGB(110, 113, 118)

    if a1 == "workbench_t1" then
        v20 = CFrame.new(0, 3, 0)
        WoodPlanks = Material.WoodPlanks
        Part = Instance.new("Part")
        Part.Name = "Top"
        Part.Size = Vector3.new(6, 0.4000000059604645, 3)
        Part.CFrame = v20
        Part.Color = v17
        Part.Material = WoodPlanks
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanTouch = false
        Part.CanQuery = false
        Part.CastShadow = false
        Part.TopSurface = Enum.SurfaceType.Smooth
        Part.BottomSurface = Enum.SurfaceType.Smooth
        Part.Parent = Model
        v20 = CFrame.new(-2.6, 1.4, 0)
        WoodPlanks_2 = Material.WoodPlanks
        Part_2 = Instance.new("Part")
        Part_2.Name = "LegL"
        Part_2.Size = Vector3.new(0.5, 2.799999952316284, 2.5999999046325684)
        Part_2.CFrame = v20
        Part_2.Color = v18
        Part_2.Material = WoodPlanks_2
        Part_2.Anchored = true
        Part_2.CanCollide = false
        Part_2.CanTouch = false
        Part_2.CanQuery = false
        Part_2.CastShadow = false
        Part_2.TopSurface = Enum.SurfaceType.Smooth
        Part_2.BottomSurface = Enum.SurfaceType.Smooth
        Part_2.Parent = Model
        v20 = CFrame.new(2.6, 1.4, 0)
        WoodPlanks_3 = Material.WoodPlanks
        Part_3 = Instance.new("Part")
        Part_3.Name = "LegR"
        Part_3.Size = Vector3.new(0.5, 2.799999952316284, 2.5999999046325684)
        Part_3.CFrame = v20
        Part_3.Color = v18
        Part_3.Material = WoodPlanks_3
        Part_3.Anchored = true
        Part_3.CanCollide = false
        Part_3.CanTouch = false
        Part_3.CanQuery = false
        Part_3.CastShadow = false
        Part_3.TopSurface = Enum.SurfaceType.Smooth
        Part_3.BottomSurface = Enum.SurfaceType.Smooth
        Part_3.Parent = Model
        v20 = CFrame.new(0, 0.8, 0)
        WoodPlanks_4 = Material.WoodPlanks
        Part_4 = Instance.new("Part")
        Part_4.Name = "Shelf"
        Part_4.Size = Vector3.new(4.699999809265137, 0.30000001192092896, 2.4000000953674316)
        Part_4.CFrame = v20
        Part_4.Color = v18
        Part_4.Material = WoodPlanks_4
        Part_4.Anchored = true
        Part_4.CanCollide = false
        Part_4.CanTouch = false
        Part_4.CanQuery = false
        Part_4.CastShadow = false
        Part_4.TopSurface = Enum.SurfaceType.Smooth
        Part_4.BottomSurface = Enum.SurfaceType.Smooth
        Part_4.Parent = Model
        v20 = CFrame.new(2.2, 3.5, -0.9)
        Metal = Material.Metal
        Part_5 = Instance.new("Part")
        Part_5.Name = "Vise"
        Part_5.Size = Vector3.new(0.800000011920929, 0.6000000238418579, 0.699999988079071)
        Part_5.CFrame = v20
        Part_5.Color = v19
        Part_5.Material = Metal
        Part_5.Anchored = true
        Part_5.CanCollide = false
        Part_5.CanTouch = false
        Part_5.CanQuery = false
        Part_5.CastShadow = false
        Part_5.TopSurface = Enum.SurfaceType.Smooth
        Part_5.BottomSurface = Enum.SurfaceType.Smooth
        Part_5.Parent = Model

        return Model
    end

    if a1 == "workbench_t2" then
        v20 = Color3.fromRGB(96, 100, 104)
        v1 = Color3.fromRGB(62, 65, 68)
        v2 = CFrame.new(0, 3.1, 0)
        DiamondPlate = Material.DiamondPlate
        Part_6 = Instance.new("Part")
        Part_6.Name = "Top"
        Part_6.Size = Vector3.new(6.400000095367432, 0.3499999940395355, 3.200000047683716)
        Part_6.CFrame = v2
        Part_6.Color = v20
        Part_6.Material = DiamondPlate
        Part_6.Anchored = true
        Part_6.CanCollide = false
        Part_6.CanTouch = false
        Part_6.CanQuery = false
        Part_6.CastShadow = false
        Part_6.TopSurface = Enum.SurfaceType.Smooth
        Part_6.BottomSurface = Enum.SurfaceType.Smooth
        Part_6.Parent = Model
        v2 = CFrame.new(-2.9, 1.47, 0)
        Metal_2 = Material.Metal
        v20 = Instance.new("Part")
        v20.Name = "LegL"
        v20.Size = Vector3.new(0.4000000059604645, 2.950000047683716, 2.799999952316284)
        v20.CFrame = v2
        v20.Color = v1
        v20.Material = Metal_2
        v20.Anchored = true
        v20.CanCollide = false
        v20.CanTouch = false
        v20.CanQuery = false
        v20.CastShadow = false
        v20.TopSurface = Enum.SurfaceType.Smooth
        v20.BottomSurface = Enum.SurfaceType.Smooth
        v20.Parent = Model
        v2 = CFrame.new(2.9, 1.47, 0)
        Metal_3 = Material.Metal
        Part_7 = Instance.new("Part")
        Part_7.Name = "LegR"
        Part_7.Size = Vector3.new(0.4000000059604645, 2.950000047683716, 2.799999952316284)
        Part_7.CFrame = v2
        Part_7.Color = v1
        Part_7.Material = Metal_3
        Part_7.Anchored = true
        Part_7.CanCollide = false
        Part_7.CanTouch = false
        Part_7.CanQuery = false
        Part_7.CastShadow = false
        Part_7.TopSurface = Enum.SurfaceType.Smooth
        Part_7.BottomSurface = Enum.SurfaceType.Smooth
        Part_7.Parent = Model
        v2 = CFrame.new(2.3, 3.6, -1.1)
        v3 = Color3.fromRGB(70, 92, 120)
        Metal_4 = Material.Metal
        Part_8 = Instance.new("Part")
        Part_8.Name = "Vise"
        Part_8.Size = Vector3.new(0.8999999761581421, 0.699999988079071, 0.800000011920929)
        Part_8.CFrame = v2
        Part_8.Color = v3
        Part_8.Material = Metal_4
        Part_8.Anchored = true
        Part_8.CanCollide = false
        Part_8.CanTouch = false
        Part_8.CanQuery = false
        Part_8.CastShadow = false
        Part_8.TopSurface = Enum.SurfaceType.Smooth
        Part_8.BottomSurface = Enum.SurfaceType.Smooth
        Part_8.Parent = Model
        v2 = CFrame.new(0, 4.4, 1.5)
        Metal_5 = Material.Metal
        Part_9 = Instance.new("Part")
        Part_9.Name = "Rack"
        Part_9.Size = Vector3.new(5.599999904632568, 2.200000047683716, 0.20000000298023224)
        Part_9.CFrame = v2
        Part_9.Color = v1
        Part_9.Material = Metal_5
        Part_9.Anchored = true
        Part_9.CanCollide = false
        Part_9.CanTouch = false
        Part_9.CanQuery = false
        Part_9.CastShadow = false
        Part_9.TopSurface = Enum.SurfaceType.Smooth
        Part_9.BottomSurface = Enum.SurfaceType.Smooth
        Part_9.Parent = Model

        return Model
    end

    if a1 == "furnace" then
        v20 = CFrame.new(0, 1.7, 0)
        Cobblestone = Material.Cobblestone
        Part_10 = Instance.new("Part")
        Part_10.Name = "Body"
        Part_10.Size = Vector3.new(4, 3.4000000953674316, 4)
        Part_10.CFrame = v20
        Part_10.Color = v15
        Part_10.Material = Cobblestone
        Part_10.Anchored = true
        Part_10.CanCollide = false
        Part_10.CanTouch = false
        Part_10.CanQuery = false
        Part_10.CastShadow = false
        Part_10.TopSurface = Enum.SurfaceType.Smooth
        Part_10.BottomSurface = Enum.SurfaceType.Smooth
        Part_10.Parent = Model
        v20 = CFrame.new(0, 4, 0)
        Cobblestone_2 = Material.Cobblestone
        Part_11 = Instance.new("Part")
        Part_11.Name = "Top"
        Part_11.Size = Vector3.new(3.200000047683716, 1.2000000476837158, 3.200000047683716)
        Part_11.CFrame = v20
        Part_11.Color = v15
        Part_11.Material = Cobblestone_2
        Part_11.Anchored = true
        Part_11.CanCollide = false
        Part_11.CanTouch = false
        Part_11.CanQuery = false
        Part_11.CastShadow = false
        Part_11.TopSurface = Enum.SurfaceType.Smooth
        Part_11.BottomSurface = Enum.SurfaceType.Smooth
        Part_11.Parent = Model
        v20 = CFrame.new(0.6, 5.4, 0.6)
        Slate = Material.Slate
        Part_12 = Instance.new("Part")
        Part_12.Name = "Chimney"
        Part_12.Size = Vector3.new(1.100000023841858, 1.600000023841858, 1.100000023841858)
        Part_12.CFrame = v20
        Part_12.Color = v16
        Part_12.Material = Slate
        Part_12.Anchored = true
        Part_12.CanCollide = false
        Part_12.CanTouch = false
        Part_12.CanQuery = false
        Part_12.CastShadow = false
        Part_12.TopSurface = Enum.SurfaceType.Smooth
        Part_12.BottomSurface = Enum.SurfaceType.Smooth
        Part_12.Parent = Model
        v20 = CFrame.new(0, 1.3, -2)
        v1 = Color3.fromRGB(46, 30, 24)
        SmoothPlastic = Material.SmoothPlastic
        Part_13 = Instance.new("Part")
        Part_13.Name = "Opening"
        Part_13.Size = Vector3.new(1.7999999523162842, 1.399999976158142, 0.11999999731779099)
        Part_13.CFrame = v20
        Part_13.Color = v1
        Part_13.Material = SmoothPlastic
        Part_13.Anchored = true
        Part_13.CanCollide = false
        Part_13.CanTouch = false
        Part_13.CanQuery = false
        Part_13.CastShadow = false
        Part_13.TopSurface = Enum.SurfaceType.Smooth
        Part_13.BottomSurface = Enum.SurfaceType.Smooth
        Part_13.Parent = Model

        return Model
    end

    if a1 == "campfire" then
        v20 = (CFrame.new(0, 0.25, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
        Slate_2 = Material.Slate
        Cylinder = Enum.PartType.Cylinder
        Part_14 = Instance.new("Part")
        Part_14.Name = "Ring"

        if Cylinder then
            Part_14.Shape = Cylinder
        end

        Part_14.Size = Vector3.new(0.5, 4, 4)
        Part_14.CFrame = v20
        Part_14.Color = v16
        Part_14.Material = Slate_2
        Part_14.Anchored = true
        Part_14.CanCollide = false
        Part_14.CanTouch = false
        Part_14.CanQuery = false
        Part_14.CastShadow = false
        Part_14.TopSurface = Enum.SurfaceType.Smooth
        Part_14.BottomSurface = Enum.SurfaceType.Smooth
        Part_14.Parent = Model
        v20 = (CFrame.new(0, 0.8, 0)) * CFrame.Angles(0, 0.7853981633974483, 0.12)
        Wood = Material.Wood
        Cylinder_2 = Enum.PartType.Cylinder
        Part_15 = Instance.new("Part")
        Part_15.Name = "Log1"

        if Cylinder_2 then
            Part_15.Shape = Cylinder_2
        end

        Part_15.Size = Vector3.new(3.4000000953674316, 0.44999998807907104, 0.44999998807907104)
        Part_15.CFrame = v20
        Part_15.Color = v18
        Part_15.Material = Wood
        Part_15.Anchored = true
        Part_15.CanCollide = false
        Part_15.CanTouch = false
        Part_15.CanQuery = false
        Part_15.CastShadow = false
        Part_15.TopSurface = Enum.SurfaceType.Smooth
        Part_15.BottomSurface = Enum.SurfaceType.Smooth
        Part_15.Parent = Model
        v20 = (CFrame.new(0, 0.95, 0)) * CFrame.Angles(0, -0.7853981633974483, -0.12)
        Wood_2 = Material.Wood
        Cylinder_3 = Enum.PartType.Cylinder
        Part_16 = Instance.new("Part")
        Part_16.Name = "Log2"

        if Cylinder_3 then
            Part_16.Shape = Cylinder_3
        end

        Part_16.Size = Vector3.new(3.4000000953674316, 0.44999998807907104, 0.44999998807907104)
        Part_16.CFrame = v20
        Part_16.Color = v17
        Part_16.Material = Wood_2
        Part_16.Anchored = true
        Part_16.CanCollide = false
        Part_16.CanTouch = false
        Part_16.CanQuery = false
        Part_16.CastShadow = false
        Part_16.TopSurface = Enum.SurfaceType.Smooth
        Part_16.BottomSurface = Enum.SurfaceType.Smooth
        Part_16.Parent = Model

        return Model
    end

    if a1 == "wooden_box" then
        v20 = CFrame.new(0, 0.85, 0)
        WoodPlanks_5 = Material.WoodPlanks
        Part_17 = Instance.new("Part")
        Part_17.Name = "Crate"
        Part_17.Size = Vector3.new(3, 1.7000000476837158, 2)
        Part_17.CFrame = v20
        Part_17.Color = v17
        Part_17.Material = WoodPlanks_5
        Part_17.Anchored = true
        Part_17.CanCollide = false
        Part_17.CanTouch = false
        Part_17.CanQuery = false
        Part_17.CastShadow = false
        Part_17.TopSurface = Enum.SurfaceType.Smooth
        Part_17.BottomSurface = Enum.SurfaceType.Smooth
        Part_17.Parent = Model
        v20 = CFrame.new(0, 1.95, 0)
        WoodPlanks_6 = Material.WoodPlanks
        Part_18 = Instance.new("Part")
        Part_18.Name = "Lid"
        Part_18.Size = Vector3.new(3.0999999046325684, 0.5, 2.0999999046325684)
        Part_18.CFrame = v20
        Part_18.Color = v18
        Part_18.Material = WoodPlanks_6
        Part_18.Anchored = true
        Part_18.CanCollide = false
        Part_18.CanTouch = false
        Part_18.CanQuery = false
        Part_18.CastShadow = false
        Part_18.TopSurface = Enum.SurfaceType.Smooth
        Part_18.BottomSurface = Enum.SurfaceType.Smooth
        Part_18.Parent = Model
        v20 = CFrame.new(-0.9, 1.12, 0)
        Metal_6 = Material.Metal
        Part_19 = Instance.new("Part")
        Part_19.Name = "StrapL"
        Part_19.Size = Vector3.new(0.2199999988079071, 2.240000009536743, 2.1600000858306885)
        Part_19.CFrame = v20
        Part_19.Color = v19
        Part_19.Material = Metal_6
        Part_19.Anchored = true
        Part_19.CanCollide = false
        Part_19.CanTouch = false
        Part_19.CanQuery = false
        Part_19.CastShadow = false
        Part_19.TopSurface = Enum.SurfaceType.Smooth
        Part_19.BottomSurface = Enum.SurfaceType.Smooth
        Part_19.Parent = Model
        v20 = CFrame.new(0.9, 1.12, 0)
        Metal_7 = Material.Metal
        Part_20 = Instance.new("Part")
        Part_20.Name = "StrapR"
        Part_20.Size = Vector3.new(0.2199999988079071, 2.240000009536743, 2.1600000858306885)
        Part_20.CFrame = v20
        Part_20.Color = v19
        Part_20.Material = Metal_7
        Part_20.Anchored = true
        Part_20.CanCollide = false
        Part_20.CanTouch = false
        Part_20.CanQuery = false
        Part_20.CastShadow = false
        Part_20.TopSurface = Enum.SurfaceType.Smooth
        Part_20.BottomSurface = Enum.SurfaceType.Smooth
        Part_20.Parent = Model

        return Model
    end

    if a1 == "large_box" then
        v20 = CFrame.new(0, 1, 0)
        WoodPlanks_7 = Material.WoodPlanks
        Part_21 = Instance.new("Part")
        Part_21.Name = "Crate"
        Part_21.Size = Vector3.new(5, 2, 2.5999999046325684)
        Part_21.CFrame = v20
        Part_21.Color = v17
        Part_21.Material = WoodPlanks_7
        Part_21.Anchored = true
        Part_21.CanCollide = false
        Part_21.CanTouch = false
        Part_21.CanQuery = false
        Part_21.CastShadow = false
        Part_21.TopSurface = Enum.SurfaceType.Smooth
        Part_21.BottomSurface = Enum.SurfaceType.Smooth
        Part_21.Parent = Model
        v20 = CFrame.new(0, 2.3, 0)
        WoodPlanks_8 = Material.WoodPlanks
        Part_22 = Instance.new("Part")
        Part_22.Name = "Lid"
        Part_22.Size = Vector3.new(5.099999904632568, 0.6000000238418579, 2.700000047683716)
        Part_22.CFrame = v20
        Part_22.Color = v18
        Part_22.Material = WoodPlanks_8
        Part_22.Anchored = true
        Part_22.CanCollide = false
        Part_22.CanTouch = false
        Part_22.CanQuery = false
        Part_22.CastShadow = false
        Part_22.TopSurface = Enum.SurfaceType.Smooth
        Part_22.BottomSurface = Enum.SurfaceType.Smooth
        Part_22.Parent = Model
        v20 = CFrame.new(-2.45, 1.31, 0)
        Metal_8 = Material.Metal
        Part_23 = Instance.new("Part")
        Part_23.Name = "CornerL"
        Part_23.Size = Vector3.new(0.25, 2.619999885559082, 2.740000009536743)
        Part_23.CFrame = v20
        Part_23.Color = v19
        Part_23.Material = Metal_8
        Part_23.Anchored = true
        Part_23.CanCollide = false
        Part_23.CanTouch = false
        Part_23.CanQuery = false
        Part_23.CastShadow = false
        Part_23.TopSurface = Enum.SurfaceType.Smooth
        Part_23.BottomSurface = Enum.SurfaceType.Smooth
        Part_23.Parent = Model
        v20 = CFrame.new(2.45, 1.31, 0)
        Metal_9 = Material.Metal
        Part_24 = Instance.new("Part")
        Part_24.Name = "CornerR"
        Part_24.Size = Vector3.new(0.25, 2.619999885559082, 2.740000009536743)
        Part_24.CFrame = v20
        Part_24.Color = v19
        Part_24.Material = Metal_9
        Part_24.Anchored = true
        Part_24.CanCollide = false
        Part_24.CanTouch = false
        Part_24.CanQuery = false
        Part_24.CastShadow = false
        Part_24.TopSurface = Enum.SurfaceType.Smooth
        Part_24.BottomSurface = Enum.SurfaceType.Smooth
        Part_24.Parent = Model

        return Model
    end

    if a1 == "sleeping_bag" then
        v20 = Color3.fromRGB(88, 94, 60)
        v1 = Color3.fromRGB(178, 160, 122)
        v2 = CFrame.new(0, 0.225, 0)
        Fabric = Material.Fabric
        Part_25 = Instance.new("Part")
        Part_25.Name = "Bag"
        Part_25.Size = Vector3.new(2.5999999046325684, 0.44999998807907104, 6.5)
        Part_25.CFrame = v2
        Part_25.Color = v20
        Part_25.Material = Fabric
        Part_25.Anchored = true
        Part_25.CanCollide = false
        Part_25.CanTouch = false
        Part_25.CanQuery = false
        Part_25.CastShadow = false
        Part_25.TopSurface = Enum.SurfaceType.Smooth
        Part_25.BottomSurface = Enum.SurfaceType.Smooth
        Part_25.Parent = Model
        v2 = CFrame.new(0, 0.48, -1.9)
        Fabric_2 = Material.Fabric
        v20 = Instance.new("Part")
        v20.Name = "Flap"
        v20.Size = Vector3.new(2.640000104904175, 0.11999999731779099, 1.2999999523162842)
        v20.CFrame = v2
        v20.Color = v1
        v20.Material = Fabric_2
        v20.Anchored = true
        v20.CanCollide = false
        v20.CanTouch = false
        v20.CanQuery = false
        v20.CastShadow = false
        v20.TopSurface = Enum.SurfaceType.Smooth
        v20.BottomSurface = Enum.SurfaceType.Smooth
        v20.Parent = Model
        v2 = CFrame.new(0, 0.62, -2.7)
        v3 = Color3.fromRGB(197, 184, 155)
        Fabric_3 = Material.Fabric
        v1 = Instance.new("Part")
        v1.Name = "Pillow"
        v1.Size = Vector3.new(2, 0.41999998688697815, 0.949999988079071)
        v1.CFrame = v2
        v1.Color = v3
        v1.Material = Fabric_3
        v1.Anchored = true
        v1.CanCollide = false
        v1.CanTouch = false
        v1.CanQuery = false
        v1.CastShadow = false
        v1.TopSurface = Enum.SurfaceType.Smooth
        v1.BottomSurface = Enum.SurfaceType.Smooth
        v1.Parent = Model

        return Model
    end

    if a1 == "bed" then
        v20 = CFrame.new(0, 0.43, 0)
        WoodPlanks_9 = Material.WoodPlanks
        Part_26 = Instance.new("Part")
        Part_26.Name = "Frame"
        Part_26.Size = Vector3.new(3.5999999046325684, 0.8600000143051147, 7.099999904632568)
        Part_26.CFrame = v20
        Part_26.Color = v17
        Part_26.Material = WoodPlanks_9
        Part_26.Anchored = true
        Part_26.CanCollide = false
        Part_26.CanTouch = false
        Part_26.CanQuery = false
        Part_26.CastShadow = false
        Part_26.TopSurface = Enum.SurfaceType.Smooth
        Part_26.BottomSurface = Enum.SurfaceType.Smooth
        Part_26.Parent = Model
        v20 = CFrame.new(0, 1.45, -3.4)
        WoodPlanks_10 = Material.WoodPlanks
        Part_27 = Instance.new("Part")
        Part_27.Name = "Head"
        Part_27.Size = Vector3.new(3.5999999046325684, 1.2000000476837158, 0.30000001192092896)
        Part_27.CFrame = v20
        Part_27.Color = v18
        Part_27.Material = WoodPlanks_10
        Part_27.Anchored = true
        Part_27.CanCollide = false
        Part_27.CanTouch = false
        Part_27.CanQuery = false
        Part_27.CastShadow = false
        Part_27.TopSurface = Enum.SurfaceType.Smooth
        Part_27.BottomSurface = Enum.SurfaceType.Smooth
        Part_27.Parent = Model
        v20 = CFrame.new(0, 1.11, 0)
        v1 = Color3.fromRGB(150, 140, 112)
        Fabric_4 = Material.Fabric
        Part_28 = Instance.new("Part")
        Part_28.Name = "Mattress"
        Part_28.Size = Vector3.new(3.1600000858306885, 0.5, 6.800000190734863)
        Part_28.CFrame = v20
        Part_28.Color = v1
        Part_28.Material = Fabric_4
        Part_28.Anchored = true
        Part_28.CanCollide = false
        Part_28.CanTouch = false
        Part_28.CanQuery = false
        Part_28.CastShadow = false
        Part_28.TopSurface = Enum.SurfaceType.Smooth
        Part_28.BottomSurface = Enum.SurfaceType.Smooth
        Part_28.Parent = Model
        v20 = CFrame.new(0, 1.58, -2.8)
        v1 = Color3.fromRGB(200, 190, 160)
        Fabric_5 = Material.Fabric
        v3 = Instance.new("Part")
        v3.Name = "Pillow"
        v3.Size = Vector3.new(2.200000047683716, 0.44999998807907104, 0.8999999761581421)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = Fabric_5
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = CFrame.new(0, 1.47, 1.9)
        v1 = Color3.fromRGB(86, 102, 74)
        v2 = Material.Fabric
        v3 = Instance.new("Part")
        v3.Name = "Blanket"
        v3.Size = Vector3.new(3.299999952316284, 0.2199999988079071, 1.899999976158142)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model

        return Model
    end

    if a1 == "tool_cupboard" then
        v20 = CFrame.new(0, 2.8, 0)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "Body"
        v2.Size = Vector3.new(3, 5.599999904632568, 2)
        v2.CFrame = v20
        v2.Color = v17
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 3.4, -1.02)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "Doors"
        v2.Size = Vector3.new(2.5999999046325684, 3.200000047683716, 0.11999999731779099)
        v2.CFrame = v20
        v2.Color = v18
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 5.65, 0)
        v1 = Material.Metal
        v2 = Instance.new("Part")
        v2.Name = "Saw"
        v2.Size = Vector3.new(2, 0.05999999865889549, 0.6000000238418579)
        v2.CFrame = v20
        v2.Color = v19
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model

        return Model
    end

    if a1 == "dino_trophy" then
        v20 = Color3.fromRGB(214, 204, 178)
        v1 = CFrame.new(0, 0.2, 0)
        v2 = Material.WoodPlanks
        v3 = Instance.new("Part")
        v3.Name = "Base"
        v3.Size = Vector3.new(2.5999999046325684, 0.4000000059604645, 2.5999999046325684)
        v3.CFrame = v1
        v3.Color = v18
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(0, 1.5, 0.2)
        v2 = Material.WoodPlanks
        v3 = Instance.new("Part")
        v3.Name = "Post"
        v3.Size = Vector3.new(0.5, 2.200000047683716, 0.5)
        v3.CFrame = v1
        v3.Color = v17
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(0, 3.2, 0.35)
        v2 = Material.Limestone
        v3 = Instance.new("Part")
        v3.Name = "Skull"
        v3.Size = Vector3.new(1.7999999523162842, 1.2999999523162842, 1.899999976158142)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(0, 3.05, -1.3)
        v2 = Material.Limestone
        v3 = Instance.new("Part")
        v3.Name = "Snout"
        v3.Size = Vector3.new(1.25, 0.8999999761581421, 1.7000000476837158)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = (CFrame.new(0, 2.45, -0.85)) * CFrame.Angles(0.13962634015954636, 0, 0)
        v2 = Material.Limestone
        v3 = Instance.new("Part")
        v3.Name = "Jaw"
        v3.Size = Vector3.new(1.149999976158142, 0.3499999940395355, 2.299999952316284)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(0, 2.7, -1.35)
        v2 = Color3.fromRGB(240, 232, 210)
        v3 = Material.SmoothPlastic
        v20 = Instance.new("Part")
        v20.Name = "Teeth"
        v20.Size = Vector3.new(1.0499999523162842, 0.30000001192092896, 1.5)
        v20.CFrame = v1
        v20.Color = v2
        v20.Material = v3
        v20.Anchored = true
        v20.CanCollide = false
        v20.CanTouch = false
        v20.CanQuery = false
        v20.CastShadow = false
        v20.TopSurface = Enum.SurfaceType.Smooth
        v20.BottomSurface = Enum.SurfaceType.Smooth
        v20.Parent = Model

        return Model
    end

    if a1 == "large_furnace" then
        v20 = CFrame.new(0, 0.3, 0)
        v1 = Material.Cobblestone
        v2 = Instance.new("Part")
        v2.Name = "Base"
        v2.Size = Vector3.new(6, 0.6000000238418579, 6)
        v2.CFrame = v20
        v2.Color = v16
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 2.5, 0)
        v1 = Material.Cobblestone
        v2 = Instance.new("Part")
        v2.Name = "Body"
        v2.Size = Vector3.new(5.199999809265137, 3.799999952316284, 5.199999809265137)
        v2.CFrame = v20
        v2.Color = v15
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 4.1, 0)
        v1 = Color3.fromRGB(92, 72, 60)
        v2 = Material.CorrodedMetal
        v3 = Instance.new("Part")
        v3.Name = "Band"
        v3.Size = Vector3.new(5.400000095367432, 0.30000001192092896, 5.400000095367432)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = CFrame.new(0, 5.3, 0)
        v1 = Material.Cobblestone
        v2 = Instance.new("Part")
        v2.Name = "Upper"
        v2.Size = Vector3.new(4, 1.7999999523162842, 4)
        v2.CFrame = v20
        v2.Color = v15
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 7.4, 0.5)
        v1 = Material.Slate
        v2 = Instance.new("Part")
        v2.Name = "Chimney"
        v2.Size = Vector3.new(1.5, 2.4000000953674316, 1.5)
        v2.CFrame = v20
        v2.Color = v16
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 2.75, -2.7)
        v1 = Material.Metal
        v2 = Instance.new("Part")
        v2.Name = "Lintel"
        v2.Size = Vector3.new(3.200000047683716, 0.3499999940395355, 0.30000001192092896)
        v2.CFrame = v20
        v2.Color = v19
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 1.7, -2.62)
        v1 = Color3.fromRGB(255, 120, 40)
        v2 = Material.Neon
        v3 = Instance.new("Part")
        v3.Name = "Opening"
        v3.Size = Vector3.new(2.4000000953674316, 1.7999999523162842, 0.11999999731779099)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model

        return Model
    end

    if a1 == "barricade_wall" then
        v20 = CFrame.new(0, 0.9, 0)
        v1 = Material.Cobblestone
        v2 = Instance.new("Part")
        v2.Name = "Base"
        v2.Size = Vector3.new(6, 1.7999999523162842, 1)
        v2.CFrame = v20
        v2.Color = v15
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(-1.45, 3.1, -0.05)
        v1 = Color3.fromRGB(104, 84, 70)
        v2 = Material.CorrodedMetal
        v3 = Instance.new("Part")
        v3.Name = "PlateL"
        v3.Size = Vector3.new(3, 2.799999952316284, 0.25)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = CFrame.new(1.5, 3, 0.06)
        v1 = Color3.fromRGB(100, 102, 104)
        v2 = Material.Metal
        v3 = Instance.new("Part")
        v3.Name = "PlateR"
        v3.Size = Vector3.new(3, 2.5999999046325684, 0.25)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = CFrame.new(-2.7, 2.15, 0.3)
        v1 = Color3.fromRGB(62, 65, 68)
        v2 = Material.Metal
        v3 = Instance.new("Part")
        v3.Name = "PostL"
        v3.Size = Vector3.new(0.30000001192092896, 4.300000190734863, 0.30000001192092896)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = CFrame.new(2.7, 2.15, 0.3)
        v1 = Color3.fromRGB(62, 65, 68)
        v2 = Material.Metal
        v3 = Instance.new("Part")
        v3.Name = "PostR"
        v3.Size = Vector3.new(0.30000001192092896, 4.300000190734863, 0.30000001192092896)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = CFrame.new(0, 3.7, -0.22)
        v1 = Color3.fromRGB(62, 65, 68)
        v2 = Material.Metal
        v3 = Instance.new("Part")
        v3.Name = "Strap"
        v3.Size = Vector3.new(5.800000190734863, 0.20000000298023224, 0.20000000298023224)
        v3.CFrame = v20
        v3.Color = v1
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model

        return Model
    end

    if a1 == "wood_barricade" then
        v20 = CFrame.new(0, 0.35, 0)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "Base"
        v2.Size = Vector3.new(7, 0.699999988079071, 1.100000023841858)
        v2.CFrame = v20
        v2.Color = v18
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model

        for i20, i192 in ipairs({1.45, 2.95, 4.45, 5.9}) do
            v5 = "Plank" .. i20
            v6 = CFrame.new(0, i192, -0.2)
            v7 = if i20 % 2 ~= 0 then v17 else Color3.fromRGB(112, 79, 48)
            v8 = Material.WoodPlanks
            v9 = Instance.new("Part")
            v9.Name = v5
            v9.Size = Vector3.new(7, 1.4500000476837158, 0.30000001192092896)
            v9.CFrame = v6
            v9.Color = v7
            v9.Material = v8
            v9.Anchored = true
            v9.CanCollide = false
            v9.CanTouch = false
            v9.CanQuery = false
            v9.CastShadow = false
            v9.TopSurface = Enum.SurfaceType.Smooth
            v9.BottomSurface = Enum.SurfaceType.Smooth
            v9.Parent = Model
        end

        v20 = CFrame.new(-3.1, 3.4, 0.2)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "PostL"
        v2.Size = Vector3.new(0.5, 6.800000190734863, 0.5)
        v2.CFrame = v20
        v2.Color = v18
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(3.1, 3.4, 0.2)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "PostR"
        v2.Size = Vector3.new(0.5, 6.800000190734863, 0.5)
        v2.CFrame = v20
        v2.Color = v18
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 3.6, -0.42)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "Batten"
        v2.Size = Vector3.new(0.44999998807907104, 5.599999904632568, 0.14000000059604645)
        v2.CFrame = v20
        v2.Color = v18
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model

        return Model
    end

    if a1 == "workbench_t3" then
        v20 = Color3.fromRGB(84, 90, 98)
        v1 = Color3.fromRGB(52, 55, 60)
        v2 = Color3.fromRGB(70, 92, 120)
        v3 = CFrame.new(0, 3.2, 0)
        v4 = Material.DiamondPlate
        v5 = Instance.new("Part")
        v5.Name = "Top"
        v5.Size = Vector3.new(7, 0.4000000059604645, 3.4000000953674316)
        v5.CFrame = v3
        v5.Color = v20
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(-3.2, 1.5, 0)
        v4 = Material.Metal
        v5 = Instance.new("Part")
        v5.Name = "LegL"
        v5.Size = Vector3.new(0.44999998807907104, 3, 3)
        v5.CFrame = v3
        v5.Color = v1
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(3.2, 1.5, 0)
        v4 = Material.Metal
        v5 = Instance.new("Part")
        v5.Name = "LegR"
        v5.Size = Vector3.new(0.44999998807907104, 3, 3)
        v5.CFrame = v3
        v5.Color = v1
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(0, 0.7, 0)
        v4 = Material.Metal
        v5 = Instance.new("Part")
        v5.Name = "Shelf"
        v5.Size = Vector3.new(6, 0.25, 2.799999952316284)
        v5.CFrame = v3
        v5.Color = v1
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(2.6, 3.75, -1.2)
        v4 = Material.Metal
        v5 = Instance.new("Part")
        v5.Name = "Vise"
        v5.Size = Vector3.new(0.8999999761581421, 0.699999988079071, 0.800000011920929)
        v5.CFrame = v3
        v5.Color = v2
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(0, 4.6, 1.6)
        v4 = Material.Metal
        v5 = Instance.new("Part")
        v5.Name = "Rack"
        v5.Size = Vector3.new(6.199999809265137, 2.4000000953674316, 0.20000000298023224)
        v5.CFrame = v3
        v5.Color = v1
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(-2.6, 5, 1)
        v4 = Material.Metal
        v1 = Instance.new("Part")
        v1.Name = "DrillColumn"
        v1.Size = Vector3.new(0.3499999940395355, 3.200000047683716, 0.3499999940395355)
        v1.CFrame = v3
        v1.Color = v20
        v1.Material = v4
        v1.Anchored = true
        v1.CanCollide = false
        v1.CanTouch = false
        v1.CanQuery = false
        v1.CastShadow = false
        v1.TopSurface = Enum.SurfaceType.Smooth
        v1.BottomSurface = Enum.SurfaceType.Smooth
        v1.Parent = Model
        v3 = CFrame.new(-2.6, 6.2, 0.55)
        v4 = Material.Metal
        v20 = Instance.new("Part")
        v20.Name = "DrillHead"
        v20.Size = Vector3.new(1, 0.800000011920929, 1.2999999523162842)
        v20.CFrame = v3
        v20.Color = v2
        v20.Material = v4
        v20.Anchored = true
        v20.CanCollide = false
        v20.CanTouch = false
        v20.CanQuery = false
        v20.CastShadow = false
        v20.TopSurface = Enum.SurfaceType.Smooth
        v20.BottomSurface = Enum.SurfaceType.Smooth
        v20.Parent = Model
        v3 = CFrame.new(-2.6, 5.45, 0.2)
        v4 = Color3.fromRGB(176, 178, 182)
        v5 = Material.Metal
        v2 = Instance.new("Part")
        v2.Name = "DrillBit"
        v2.Size = Vector3.new(0.11999999731779099, 0.699999988079071, 0.11999999731779099)
        v2.CFrame = v3
        v2.Color = v4
        v2.Material = v5
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model

        return Model
    end

    if a1 == "mixing_table" then
        v20 = CFrame.new(0, 2.9, 0)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "Top"
        v2.Size = Vector3.new(5, 0.30000001192092896, 2.5999999046325684)
        v2.CFrame = v20
        v2.Color = v17
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model

        for i19, i182 in ipairs({-2.2, 2.2}) do
            v5 = "LegF" .. i19
            v6 = CFrame.new(i182, 1.375, -1)
            v7 = Material.WoodPlanks
            v8 = Instance.new("Part")
            v8.Name = v5
            v8.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
            v8.CFrame = v6
            v8.Color = v18
            v8.Material = v7
            v8.Anchored = true
            v8.CanCollide = false
            v8.CanTouch = false
            v8.CanQuery = false
            v8.CastShadow = false
            v8.TopSurface = Enum.SurfaceType.Smooth
            v8.BottomSurface = Enum.SurfaceType.Smooth
            v8.Parent = Model
            v5 = "LegB" .. i19
            v6 = CFrame.new(i182, 1.375, 1)
            v7 = Material.WoodPlanks
            v8 = Instance.new("Part")
            v8.Name = v5
            v8.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
            v8.CFrame = v6
            v8.Color = v18
            v8.Material = v7
            v8.Anchored = true
            v8.CanCollide = false
            v8.CanTouch = false
            v8.CanQuery = false
            v8.CastShadow = false
            v8.TopSurface = Enum.SurfaceType.Smooth
            v8.BottomSurface = Enum.SurfaceType.Smooth
            v8.Parent = Model
        end

        v20 = (CFrame.new(-1.4, 3.35, -0.4)) * CFrame.Angles(0, 0, 1.5707963267948966)
        v1 = Material.Slate
        v2 = Enum.PartType.Cylinder
        v3 = Instance.new("Part")
        v3.Name = "Mortar"

        if v2 then
            v3.Shape = v2
        end

        v3.Size = Vector3.new(0.6000000238418579, 0.8999999761581421, 0.8999999761581421)
        v3.CFrame = v20
        v3.Color = v15
        v3.Material = v1
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v20 = (CFrame.new(0.9, 3.5, 0.3)) * CFrame.Angles(0, 0, 1.5707963267948966)
        v1 = Color3.fromRGB(150, 180, 170)
        v2 = Material.Glass
        v3 = Enum.PartType.Cylinder
        v4 = Instance.new("Part")
        v4.Name = "Jar1"

        if v3 then
            v4.Shape = v3
        end

        v4.Size = Vector3.new(0.8999999761581421, 0.5, 0.5)
        v4.CFrame = v20
        v4.Color = v1
        v4.Material = v2
        v4.Anchored = true
        v4.CanCollide = false
        v4.CanTouch = false
        v4.CanQuery = false
        v4.CastShadow = false
        v4.TopSurface = Enum.SurfaceType.Smooth
        v4.BottomSurface = Enum.SurfaceType.Smooth
        v4.Parent = Model
        v20 = (CFrame.new(1.6, 3.4, -0.3)) * CFrame.Angles(0, 0, 1.5707963267948966)
        v1 = Color3.fromRGB(120, 60, 50)
        v2 = Material.Glass
        v3 = Enum.PartType.Cylinder
        v4 = Instance.new("Part")
        v4.Name = "Jar2"

        if v3 then
            v4.Shape = v3
        end

        v4.Size = Vector3.new(0.699999988079071, 0.44999998807907104, 0.44999998807907104)
        v4.CFrame = v20
        v4.Color = v1
        v4.Material = v2
        v4.Anchored = true
        v4.CanCollide = false
        v4.CanTouch = false
        v4.CanQuery = false
        v4.CastShadow = false
        v4.TopSurface = Enum.SurfaceType.Smooth
        v4.BottomSurface = Enum.SurfaceType.Smooth
        v4.Parent = Model
        v20 = CFrame.new(-0.2, 3.1, -0.6)
        v1 = Material.Metal
        v2 = Instance.new("Part")
        v2.Name = "Scale"
        v2.Size = Vector3.new(0.8999999761581421, 0.10000000149011612, 0.6000000238418579)
        v2.CFrame = v20
        v2.Color = v19
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model
        v20 = CFrame.new(0, 3.85, 1.2)
        v1 = Material.WoodPlanks
        v2 = Instance.new("Part")
        v2.Name = "Board"
        v2.Size = Vector3.new(5, 1.600000023841858, 0.20000000298023224)
        v2.CFrame = v20
        v2.Color = v18
        v2.Material = v1
        v2.Anchored = true
        v2.CanCollide = false
        v2.CanTouch = false
        v2.CanQuery = false
        v2.CastShadow = false
        v2.TopSurface = Enum.SurfaceType.Smooth
        v2.BottomSurface = Enum.SurfaceType.Smooth
        v2.Parent = Model

        return Model
    end

    if a1 == "skin_bench" then
        v20 = Color3.fromRGB(214, 124, 44)
        v1 = CFrame.new(0, 2.9, 0)
        v2 = Material.WoodPlanks
        v3 = Instance.new("Part")
        v3.Name = "Top"
        v3.Size = Vector3.new(5, 0.30000001192092896, 2.4000000953674316)
        v3.CFrame = v1
        v3.Color = v17
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model

        for i17, i162 in ipairs({-2.2, 2.2}) do
            v6 = "LegF" .. i17
            v7 = CFrame.new(i162, 1.375, -0.9)
            v8 = Material.WoodPlanks
            v9 = Instance.new("Part")
            v9.Name = v6
            v9.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
            v9.CFrame = v7
            v9.Color = v18
            v9.Material = v8
            v9.Anchored = true
            v9.CanCollide = false
            v9.CanTouch = false
            v9.CanQuery = false
            v9.CastShadow = false
            v9.TopSurface = Enum.SurfaceType.Smooth
            v9.BottomSurface = Enum.SurfaceType.Smooth
            v9.Parent = Model
            v6 = "LegB" .. i17
            v7 = CFrame.new(i162, 1.375, 0.9)
            v8 = Material.WoodPlanks
            v9 = Instance.new("Part")
            v9.Name = v6
            v9.Size = Vector3.new(0.30000001192092896, 2.75, 0.30000001192092896)
            v9.CFrame = v7
            v9.Color = v18
            v9.Material = v8
            v9.Anchored = true
            v9.CanCollide = false
            v9.CanTouch = false
            v9.CanQuery = false
            v9.CastShadow = false
            v9.TopSurface = Enum.SurfaceType.Smooth
            v9.BottomSurface = Enum.SurfaceType.Smooth
            v9.Parent = Model
        end

        v1 = CFrame.new(0, 4.25, 1.1)
        v2 = Material.WoodPlanks
        v3 = Instance.new("Part")
        v3.Name = "Board"
        v3.Size = Vector3.new(5, 2.4000000953674316, 0.20000000298023224)
        v3.CFrame = v1
        v3.Color = v18
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(-0.5, 4.65, 0.98)
        v2 = Material.SmoothPlastic
        v3 = Instance.new("Part")
        v3.Name = "StencilBody"
        v3.Size = Vector3.new(2.200000047683716, 0.550000011920929, 0.05000000074505806)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = (CFrame.new(-1.95, 4.55, 0.98)) * CFrame.Angles(0, 0, 0.12)
        v2 = Material.SmoothPlastic
        v3 = Instance.new("Part")
        v3.Name = "StencilStock"
        v3.Size = Vector3.new(0.8999999761581421, 0.41999998688697815, 0.05000000074505806)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(1.25, 4.78, 0.98)
        v2 = Material.SmoothPlastic
        v3 = Instance.new("Part")
        v3.Name = "StencilBarrel"
        v3.Size = Vector3.new(1.2999999523162842, 0.1599999964237213, 0.05000000074505806)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = (CFrame.new(0.15, 4.15, 0.98)) * CFrame.Angles(0, 0, -0.25)
        v2 = Material.SmoothPlastic
        v3 = Instance.new("Part")
        v3.Name = "StencilGrip"
        v3.Size = Vector3.new(0.2800000011920929, 0.6000000238418579, 0.05000000074505806)
        v3.CFrame = v1
        v3.Color = v20
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model

        for i18, i172 in ipairs({
            {1, Color3.fromRGB(176, 40, 36)},
            {1.45, Color3.fromRGB(52, 96, 168)},
            {1.9, Color3.fromRGB(214, 180, 48)},
        }) do
            v6 = "Can" .. i18
            v7 = (CFrame.new(i172[1], 3.425, -0.45)) * CFrame.Angles(0, 0, 1.5707963267948966)
            v8 = i172[2]
            v9 = Material.Metal
            v10 = Enum.PartType.Cylinder
            v20 = Instance.new("Part")
            v20.Name = v6

            if v10 then
                v20.Shape = v10
            end

            v20.Size = Vector3.new(0.75, 0.3199999928474426, 0.3199999928474426)
            v20.CFrame = v7
            v20.Color = v8
            v20.Material = v9
            v20.Anchored = true
            v20.CanCollide = false
            v20.CanTouch = false
            v20.CanQuery = false
            v20.CastShadow = false
            v20.TopSurface = Enum.SurfaceType.Smooth
            v20.BottomSurface = Enum.SurfaceType.Smooth
            v20.Parent = Model
        end

        v1 = CFrame.new(-1.3, 3.11, -0.3)
        v2 = Material.Metal
        v3 = Instance.new("Part")
        v3.Name = "Tray"
        v3.Size = Vector3.new(1.2999999523162842, 0.11999999731779099, 0.8999999761581421)
        v3.CFrame = v1
        v3.Color = v19
        v3.Material = v2
        v3.Anchored = true
        v3.CanCollide = false
        v3.CanTouch = false
        v3.CanQuery = false
        v3.CastShadow = false
        v3.TopSurface = Enum.SurfaceType.Smooth
        v3.BottomSurface = Enum.SurfaceType.Smooth
        v3.Parent = Model
        v1 = CFrame.new(-1.3, 3.18, -0.3)
        v2 = Color3.fromRGB(46, 150, 132)
        v3 = Material.SmoothPlastic
        v4 = Instance.new("Part")
        v4.Name = "Paint"
        v4.Size = Vector3.new(1.100000023841858, 0.03999999910593033, 0.699999988079071)
        v4.CFrame = v1
        v4.Color = v2
        v4.Material = v3
        v4.Anchored = true
        v4.CanCollide = false
        v4.CanTouch = false
        v4.CanQuery = false
        v4.CastShadow = false
        v4.TopSurface = Enum.SurfaceType.Smooth
        v4.BottomSurface = Enum.SurfaceType.Smooth
        v4.Parent = Model

        return Model
    end

    if a1 == "wardrobe" then
        v20 = Color3.fromRGB(134, 95, 58)
        v1 = Color3.fromRGB(110, 78, 48)
        v2 = Color3.fromRGB(176, 140, 72)
        v3 = CFrame.new(0, 3.5, 0.05)
        v4 = Material.WoodPlanks
        v5 = Instance.new("Part")
        v5.Name = "Body"
        v5.Size = Vector3.new(3.5999999046325684, 6.199999809265137, 1.899999976158142)
        v5.CFrame = v3
        v5.Color = v17
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(0, 0.2, 0.05)
        v4 = Material.WoodPlanks
        v5 = Instance.new("Part")
        v5.Name = "Plinth"
        v5.Size = Vector3.new(3.5, 0.4000000059604645, 1.7999999523162842)
        v5.CFrame = v3
        v5.Color = v18
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model
        v3 = CFrame.new(0, 6.8, 0)
        v4 = Material.WoodPlanks
        v5 = Instance.new("Part")
        v5.Name = "Crown"
        v5.Size = Vector3.new(3.799999952316284, 0.4000000059604645, 2.0999999046325684)
        v5.CFrame = v3
        v5.Color = v18
        v5.Material = v4
        v5.Anchored = true
        v5.CanCollide = false
        v5.CanTouch = false
        v5.CanQuery = false
        v5.CastShadow = false
        v5.TopSurface = Enum.SurfaceType.Smooth
        v5.BottomSurface = Enum.SurfaceType.Smooth
        v5.Parent = Model

        for i16, i152 in ipairs({-0.88, 0.88}) do
            v8 = "Door" .. i16
            v9 = CFrame.new(i152, 3.55, -0.96)
            v10 = Material.WoodPlanks
            v11 = Instance.new("Part")
            v11.Name = v8
            v11.Size = Vector3.new(1.7400000095367432, 5.800000190734863, 0.11999999731779099)
            v11.CFrame = v9
            v11.Color = v20
            v11.Material = v10
            v11.Anchored = true
            v11.CanCollide = false
            v11.CanTouch = false
            v11.CanQuery = false
            v11.CastShadow = false
            v11.TopSurface = Enum.SurfaceType.Smooth
            v11.BottomSurface = Enum.SurfaceType.Smooth
            v11.Parent = Model
            v8 = "PanelU" .. i16
            v9 = CFrame.new(i152, 4.85, -1.05)
            v10 = Material.WoodPlanks
            v11 = Instance.new("Part")
            v11.Name = v8
            v11.Size = Vector3.new(1.2999999523162842, 2.299999952316284, 0.05999999865889549)
            v11.CFrame = v9
            v11.Color = v1
            v11.Material = v10
            v11.Anchored = true
            v11.CanCollide = false
            v11.CanTouch = false
            v11.CanQuery = false
            v11.CastShadow = false
            v11.TopSurface = Enum.SurfaceType.Smooth
            v11.BottomSurface = Enum.SurfaceType.Smooth
            v11.Parent = Model
            v8 = "PanelL" .. i16
            v9 = CFrame.new(i152, 2.15, -1.05)
            v10 = Material.WoodPlanks
            v11 = Instance.new("Part")
            v11.Name = v8
            v11.Size = Vector3.new(1.2999999523162842, 2.299999952316284, 0.05999999865889549)
            v11.CFrame = v9
            v11.Color = v1
            v11.Material = v10
            v11.Anchored = true
            v11.CanCollide = false
            v11.CanTouch = false
            v11.CanQuery = false
            v11.CastShadow = false
            v11.TopSurface = Enum.SurfaceType.Smooth
            v11.BottomSurface = Enum.SurfaceType.Smooth
            v11.Parent = Model
            v8 = CFrame.new(i152 * 0.18, 3.6, -1.1)
            v9 = Material.Metal
            v10 = Enum.PartType.Ball
            v11 = Instance.new("Part")
            v11.Name = "Knob"

            if v10 then
                v11.Shape = v10
            end

            v11.Size = Vector3.new(0.20000000298023224, 0.20000000298023224, 0.20000000298023224)
            v11.CFrame = v8
            v11.Color = v2
            v11.Material = v9
            v11.Anchored = true
            v11.CanCollide = false
            v11.CanTouch = false
            v11.CanQuery = false
            v11.CastShadow = false
            v11.TopSurface = Enum.SurfaceType.Smooth
            v11.BottomSurface = Enum.SurfaceType.Smooth
            v11.Parent = Model
        end

        return Model
    end

    if a1 == "locker" then
        v20 = Color3.fromRGB(78, 98, 88)
        v1 = Color3.fromRGB(90, 112, 100)
        v2 = Color3.fromRGB(44, 48, 46)
        v3 = Color3.fromRGB(170, 174, 178)
        v4 = CFrame.new(0, 3.6, 0.05)
        v5 = Material.Metal
        v6 = Instance.new("Part")
        v6.Name = "Body"
        v6.Size = Vector3.new(4.5, 6.599999904632568, 1.7999999523162842)
        v6.CFrame = v4
        v6.Color = v20
        v6.Material = v5
        v6.Anchored = true
        v6.CanCollide = false
        v6.CanTouch = false
        v6.CanQuery = false
        v6.CastShadow = false
        v6.TopSurface = Enum.SurfaceType.Smooth
        v6.BottomSurface = Enum.SurfaceType.Smooth
        v6.Parent = Model
        v4 = CFrame.new(0, 0.15, 0.05)
        v5 = Material.Metal
        v20 = Instance.new("Part")
        v20.Name = "Base"
        v20.Size = Vector3.new(4.400000095367432, 0.30000001192092896, 1.7000000476837158)
        v20.CFrame = v4
        v20.Color = v2
        v20.Material = v5
        v20.Anchored = true
        v20.CanCollide = false
        v20.CanTouch = false
        v20.CanQuery = false
        v20.CastShadow = false
        v20.TopSurface = Enum.SurfaceType.Smooth
        v20.BottomSurface = Enum.SurfaceType.Smooth
        v20.Parent = Model
        v4 = CFrame.new(0, 6.96, 0.05)
        v5 = Material.Metal
        v6 = Instance.new("Part")
        v6.Name = "Top"
        v6.Size = Vector3.new(4.599999904632568, 0.11999999731779099, 1.899999976158142)
        v6.CFrame = v4
        v6.Color = v2
        v6.Material = v5
        v6.Anchored = true
        v6.CanCollide = false
        v6.CanTouch = false
        v6.CanQuery = false
        v6.CastShadow = false
        v6.TopSurface = Enum.SurfaceType.Smooth
        v6.BottomSurface = Enum.SurfaceType.Smooth
        v6.Parent = Model

        for i15, i132 in ipairs({-1.47, 0, 1.47}) do
            v9 = "Door" .. i15
            v10 = CFrame.new(i132, 3.6, -0.89)
            v11 = Material.Metal
            v12 = Instance.new("Part")
            v12.Name = v9
            v12.Size = Vector3.new(1.399999976158142, 6.199999809265137, 0.07999999821186066)
            v12.CFrame = v10
            v12.Color = v1
            v12.Material = v11
            v12.Anchored = true
            v12.CanCollide = false
            v12.CanTouch = false
            v12.CanQuery = false
            v12.CastShadow = false
            v12.TopSurface = Enum.SurfaceType.Smooth
            v12.BottomSurface = Enum.SurfaceType.Smooth
            v12.Parent = Model

            for i142 = 0, 2 do
                v12 = CFrame.new
                v14 = 5.9 + i142 * 0.22
                v12 = v12(i132, v14, -0.945)
                v13 = Material.Metal
                v14 = Instance.new("Part")
                v14.Name = "Vent"
                v14.Size = Vector3.new(0.8999999761581421, 0.07999999821186066, 0.03999999910593033)
                v14.CFrame = v12
                v14.Color = v2
                v14.Material = v13
                v14.Anchored = true
                v14.CanCollide = false
                v14.CanTouch = false
                v14.CanQuery = false
                v14.CastShadow = false
                v14.TopSurface = Enum.SurfaceType.Smooth
                v14.BottomSurface = Enum.SurfaceType.Smooth
                v14.Parent = Model
            end

            v9 = CFrame.new(i132 - 0.5, 3.7, -0.99)
            v10 = Material.Metal
            v11 = Instance.new("Part")
            v11.Name = "Handle"
            v11.Size = Vector3.new(0.10000000149011612, 0.5, 0.11999999731779099)
            v11.CFrame = v9
            v11.Color = v3
            v11.Material = v10
            v11.Anchored = true
            v11.CanCollide = false
            v11.CanTouch = false
            v11.CanQuery = false
            v11.CastShadow = false
            v11.TopSurface = Enum.SurfaceType.Smooth
            v11.BottomSurface = Enum.SurfaceType.Smooth
            v11.Parent = Model
        end

        return Model
    end

    if a1 ~= "toilet" then
        if a1 == "shelves" then
            for i12, i102 in ipairs({0.225, 3.125, 6.025}) do
                v5 = "Plank" .. i12
                v6 = CFrame.new(0, i102, 0)
                v7 = if i12 ~= 3 then v17 else v18
                v8 = Material.WoodPlanks
                v9 = Instance.new("Part")
                v9.Name = v5
                v9.Size = Vector3.new(7.099999904632568, 0.25, 2.700000047683716)
                v9.CFrame = v6
                v9.Color = v7
                v9.Material = v8
                v9.Anchored = true
                v9.CanCollide = false
                v9.CanTouch = false
                v9.CanQuery = false
                v9.CastShadow = false
                v9.TopSurface = Enum.SurfaceType.Smooth
                v9.BottomSurface = Enum.SurfaceType.Smooth
                v9.Parent = Model
            end

            for i13, i112 in ipairs({-3.55, 3.55}) do
                for i14, i122 in ipairs({-1.25, 1.25}) do
                    v10 = CFrame.new(i112, 3.2, i122)
                    v11 = Material.Metal
                    v12 = Instance.new("Part")
                    v12.Name = "Post"
                    v12.Size = Vector3.new(0.30000001192092896, 6.400000095367432, 0.30000001192092896)
                    v12.CFrame = v10
                    v12.Color = v19
                    v12.Material = v11
                    v12.Anchored = true
                    v12.CanCollide = false
                    v12.CanTouch = false
                    v12.CanQuery = false
                    v12.CastShadow = false
                    v12.TopSurface = Enum.SurfaceType.Smooth
                    v12.BottomSurface = Enum.SurfaceType.Smooth
                    v12.Parent = Model
                end
            end

            v20 = CFrame.new(-1.75, 1.35, 0)
            v1 = Material.WoodPlanks
            v2 = Instance.new("Part")
            v2.Name = "Box"
            v2.Size = Vector3.new(3, 2, 2)
            v2.CFrame = v20
            v2.Color = v17
            v2.Material = v1
            v2.Anchored = true
            v2.CanCollide = false
            v2.CanTouch = false
            v2.CanQuery = false
            v2.CastShadow = false
            v2.TopSurface = Enum.SurfaceType.Smooth
            v2.BottomSurface = Enum.SurfaceType.Smooth
            v2.Parent = Model

            return Model
        end

        Model:Destroy()

        return nil
    end

    v20 = Color3.fromRGB(238, 238, 232)
    v1 = Color3.fromRGB(214, 216, 212)
    v2 = Color3.fromRGB(184, 186, 190)
    v3 = Color3.fromRGB(104, 158, 186)
    v4 = CFrame.Angles(0, 0, 1.5707963267948966)
    v5 = Enum.PartType.Cylinder
    v6 = CFrame.new(0, 0.08, -0.15)
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "Foot"
    v8.Size = Vector3.new(1.399999976158142, 0.1599999964237213, 1.899999976158142)
    v8.CFrame = v6
    v8.Color = v1
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 0.61, -0.15)
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "Pedestal"
    v8.Size = Vector3.new(1.0499999523162842, 0.8999999761581421, 1.7000000476837158)
    v8.CFrame = v6
    v8.Color = v20
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 1.2, -0.45) * v4
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "Bowl"

    if v5 then
        v8.Shape = v5
    end

    v8.Size = Vector3.new(0.7200000286102295, 2, 2)
    v8.CFrame = v6
    v8.Color = v20
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 1.2, -0.8) * v4
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "BowlFront"

    if v5 then
        v8.Shape = v5
    end

    v8.Size = Vector3.new(0.7200000286102295, 1.7000000476837158, 1.7000000476837158)
    v8.CFrame = v6
    v8.Color = v20
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 1.62, -0.45) * v4
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "SeatRing"

    if v5 then
        v8.Shape = v5
    end

    v8.Size = Vector3.new(0.11999999731779099, 2.059999942779541, 2.059999942779541)
    v8.CFrame = v6
    v8.Color = v1
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 1.62, -0.8) * v4
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "SeatFront"

    if v5 then
        v8.Shape = v5
    end

    v8.Size = Vector3.new(0.11999999731779099, 1.7599999904632568, 1.7599999904632568)
    v8.CFrame = v6
    v8.Color = v1
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 1.69, -0.62) * v4
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "Water"

    if v5 then
        v8.Shape = v5
    end

    v8.Size = Vector3.new(0.019999999552965164, 1.2999999523162842, 1.2999999523162842)
    v8.CFrame = v6
    v8.Color = v3
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = CFrame.new(0, 1.2, 0.75)
    v7 = Material.SmoothPlastic
    v4 = Instance.new("Part")
    v4.Name = "Neck"
    v4.Size = Vector3.new(1.2000000476837158, 0.699999988079071, 0.800000011920929)
    v4.CFrame = v6
    v4.Color = v20
    v4.Material = v7
    v4.Anchored = true
    v4.CanCollide = false
    v4.CanTouch = false
    v4.CanQuery = false
    v4.CastShadow = false
    v4.TopSurface = Enum.SurfaceType.Smooth
    v4.BottomSurface = Enum.SurfaceType.Smooth
    v4.Parent = Model
    v6 = CFrame.new(0, 2.43, 0.96)
    v7 = Material.SmoothPlastic
    v3 = Instance.new("Part")
    v3.Name = "Tank"
    v3.Size = Vector3.new(2, 1.75, 0.7799999713897705)
    v3.CFrame = v6
    v3.Color = v20
    v3.Material = v7
    v3.Anchored = true
    v3.CanCollide = false
    v3.CanTouch = false
    v3.CanQuery = false
    v3.CastShadow = false
    v3.TopSurface = Enum.SurfaceType.Smooth
    v3.BottomSurface = Enum.SurfaceType.Smooth
    v3.Parent = Model
    v6 = CFrame.new(0, 3.385, 0.96)
    v7 = Material.SmoothPlastic
    v8 = Instance.new("Part")
    v8.Name = "TankLid"
    v8.Size = Vector3.new(2.140000104904175, 0.1599999964237213, 0.9200000166893005)
    v8.CFrame = v6
    v8.Color = v1
    v8.Material = v7
    v8.Anchored = true
    v8.CanCollide = false
    v8.CanTouch = false
    v8.CanQuery = false
    v8.CastShadow = false
    v8.TopSurface = Enum.SurfaceType.Smooth
    v8.BottomSurface = Enum.SurfaceType.Smooth
    v8.Parent = Model
    v6 = (CFrame.new(0, 2.54, 0.5)) * CFrame.Angles(0, 1.5707963267948966, 0)
    v7 = Material.SmoothPlastic
    v1 = Instance.new("Part")
    v1.Name = "Lid"

    if v5 then
        v1.Shape = v5
    end

    v1.Size = Vector3.new(0.10000000149011612, 1.840000033378601, 1.840000033378601)
    v1.CFrame = v6
    v1.Color = v20
    v1.Material = v7
    v1.Anchored = true
    v1.CanCollide = false
    v1.CanTouch = false
    v1.CanQuery = false
    v1.CastShadow = false
    v1.TopSurface = Enum.SurfaceType.Smooth
    v1.BottomSurface = Enum.SurfaceType.Smooth
    v1.Parent = Model
    v6 = CFrame.new(-0.9, 3.05, 0.51)
    v7 = Material.Metal
    v5 = Instance.new("Part")
    v5.Name = "Handle"
    v5.Size = Vector3.new(0.18000000715255737, 0.09000000357627869, 0.11999999731779099)
    v5.CFrame = v6
    v5.Color = v2
    v5.Material = v7
    v5.Anchored = true
    v5.CanCollide = false
    v5.CanTouch = false
    v5.CanQuery = false
    v5.CastShadow = false
    v5.TopSurface = Enum.SurfaceType.Smooth
    v5.BottomSurface = Enum.SurfaceType.Smooth
    v5.Parent = Model

    return Model
end

v10 = CFrame.Angles(0, 0, 1.5707963267948966)
v11 = Color3.fromRGB(170, 174, 178)
v12 = Color3.fromRGB(84, 132, 52)
v14 = Color3.fromRGB(170, 128, 80)
v16 = {}
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.28, 0)
v20 = Color3.fromRGB(176, 30, 48)
v13[1] = "Berry"
v13[2] = (Vector3.new(0.550000011920929, 0.550000011920929, 0.550000011920929))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v13[6] = Enum.PartType.Ball
v15 = {}
v20 = CFrame.new(0.5, 0.25, 0.15)
v21 = Color3.fromRGB(150, 24, 44)
v15[1] = "Berry2"
v15[2] = (Vector3.new(0.5, 0.5, 0.5))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v15[6] = Enum.PartType.Ball
v17 = {}
v21 = CFrame.new(0.2, 0.25, -0.45)
v22 = Color3.fromRGB(196, 44, 60)
v17[1] = "Berry3"
v17[2] = (Vector3.new(0.5, 0.5, 0.5))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v17[6] = Enum.PartType.Ball
v19 = {}
v22 = CFrame.new(0.3, 0.62, -0.1)
v23 = Color3.fromRGB(168, 32, 52)
v19[1] = "Berry4"
v19[2] = (Vector3.new(0.44999998807907104, 0.44999998807907104, 0.44999998807907104))
v19[3] = v22
v19[4] = v23
v19[5] = Material.SmoothPlastic
v19[6] = Enum.PartType.Ball
v20 = {}
v23 = (CFrame.new(-0.4, 0.5, 0.1)) * CFrame.Angles(0, 0.5, 0.3)
v20[1] = "Leaf"
v20[2] = (Vector3.new(0.6000000238418579, 0.05000000074505806, 0.3199999928474426))
v20[3] = v23
v20[4] = v12
v20[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v16.berries = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.55, 0)
v20 = Color3.fromRGB(190, 36, 34)
v13[1] = "Apple"
v13[2] = (Vector3.new(1.100000023841858, 1.100000023841858, 1.100000023841858))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v13[6] = Enum.PartType.Ball
v15 = {}
v20 = (CFrame.new(0.02, 1.18, 0)) * CFrame.Angles(0, 0, 0.2)
v21 = Color3.fromRGB(92, 66, 40)
v15[1] = "Stem"
v15[2] = (Vector3.new(0.07999999821186066, 0.3199999928474426, 0.07999999821186066))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Wood
v17 = {}
v21 = (CFrame.new(0.22, 1.24, 0)) * CFrame.Angles(0, 0.4, -0.35)
v17[1] = "Leaf"
v17[2] = (Vector3.new(0.41999998688697815, 0.03999999910593033, 0.2199999988079071))
v17[3] = v21
v17[4] = v12
v17[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v16.apple = v18
v18 = {}
v13 = {}
v19 = (CFrame.new(0, 0.4, 0)) * CFrame.Angles(0, 0.3, 0)
v13[1] = "Potato"
v13[2] = (Vector3.new(1.2999999523162842, 0.800000011920929, 0.800000011920929))
v13[3] = v19
v13[4] = v14
v13[5] = Material.Sand
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = (CFrame.new(0.35, 0.28, -0.75)) * CFrame.Angles(0, -0.6, 0)
v21 = Color3.fromRGB(156, 118, 74)
v15[1] = "Potato2"
v15[2] = (Vector3.new(0.800000011920929, 0.550000011920929, 0.550000011920929))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Sand
v15[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v16.potato = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.42, 0)
v20 = Color3.fromRGB(128, 86, 52)
v13[1] = "Skin"
v13[2] = (Vector3.new(1.399999976158142, 0.8500000238418579, 0.8500000238418579))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Sand
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = CFrame.new(0, 0.82, 0)
v21 = Color3.fromRGB(236, 206, 112)
v15[1] = "Inside"
v15[2] = (Vector3.new(1.100000023841858, 0.11999999731779099, 0.550000011920929))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v17 = {}
v21 = (CFrame.new(0.1, 0.94, 0)) * CFrame.Angles(0, 0.5, 0)
v22 = Color3.fromRGB(250, 228, 120)
v17[1] = "Butter"
v17[2] = (Vector3.new(0.30000001192092896, 0.14000000059604645, 0.30000001192092896))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v16.baked_potato = v18
v18 = {}
v13 = {}
v19 = (CFrame.new(0, 0.38, 0)) * CFrame.Angles(0, 0.3, 0)
v20 = Color3.fromRGB(44, 34, 28)
v13[1] = "Potato"
v13[2] = (Vector3.new(1.25, 0.75, 0.75))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Slate
v13[6] = Enum.PartType.Cylinder
v18[1] = v13
v16.burnt_potato = v18
v18 = {}
v13 = {}
v19 = (CFrame.new(0, 0.21, 0)) * CFrame.Angles(0, 0.5, 0)
v20 = Color3.fromRGB(232, 120, 34)
v13[1] = "Root"
v13[2] = (Vector3.new(1.7000000476837158, 0.41999998688697815, 0.41999998688697815))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = (CFrame.new(0.95, 0.15, -0.5)) * CFrame.Angles(0, 0.5, 0)
v21 = Color3.fromRGB(214, 106, 30)
v15[1] = "Tip"
v15[2] = (Vector3.new(0.5, 0.23999999463558197, 0.23999999463558197))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v15[6] = Enum.PartType.Cylinder
v17 = {}
v21 = (CFrame.new(-1.15, 0.3, 0.6)) * CFrame.Angles(0, 0.5, 0.15)
v17[1] = "Tops"
v17[2] = (Vector3.new(0.8999999761581421, 0.05000000074505806, 0.4000000059604645))
v17[3] = v21
v17[4] = v12
v17[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v16.carrot = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.65, 0) * v10
v13[1] = "Can"
v13[2] = (Vector3.new(1.2999999523162842, 0.949999988079071, 0.949999988079071))
v13[3] = v19
v13[4] = v11
v13[5] = Material.Metal
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = CFrame.new(0, 0.62, 0) * v10
v21 = Color3.fromRGB(172, 66, 48)
v15[1] = "Label"
v15[2] = (Vector3.new(0.75, 0.9700000286102295, 0.9700000286102295))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v15[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v16.can_of_beans = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.25, 0) * v10
v13[1] = "Can"
v13[2] = (Vector3.new(0.5, 1.25, 1.25))
v13[3] = v19
v13[4] = v11
v13[5] = Material.Metal
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = CFrame.new(0, 0.24, 0) * v10
v21 = Color3.fromRGB(64, 104, 158)
v15[1] = "Label"
v15[2] = (Vector3.new(0.2800000011920929, 1.2699999809265137, 1.2699999809265137))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v15[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v16.can_of_tuna = v18
v18 = {}
v13 = {}
v19 = (CFrame.new(0, 0.55, 0)) * CFrame.Angles(0, 0.35, 0)
v20 = Color3.fromRGB(178, 52, 58)
v13[1] = "Meat"
v13[2] = (Vector3.new(2, 1.100000023841858, 1.399999976158142))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v15 = {}
v20 = (CFrame.new(0, 1, 0)) * CFrame.Angles(0, 0.35, 0)
v21 = Color3.fromRGB(236, 214, 196)
v15[1] = "Fat"
v15[2] = (Vector3.new(2.049999952316284, 0.25, 1.4500000476837158))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v17 = {}
v21 = (CFrame.new(1.35, 0.6, -0.48)) * CFrame.Angles(0, 0.35, 0)
v22 = Color3.fromRGB(232, 222, 196)
v17[1] = "Bone"
v17[2] = (Vector3.new(1.399999976158142, 0.3199999928474426, 0.3199999928474426))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v17[6] = Enum.PartType.Cylinder
v19 = {}
v22 = CFrame.new(1.95, 0.6, -0.7)
v23 = Color3.fromRGB(232, 222, 196)
v19[1] = "Knob"
v19[2] = (Vector3.new(0.550000011920929, 0.550000011920929, 0.550000011920929))
v19[3] = v22
v19[4] = v23
v19[5] = Material.SmoothPlastic
v19[6] = Enum.PartType.Ball
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.dino_meat = v18
v18 = {}
v13 = {}
v19 = (CFrame.new(0, 0.3, 0)) * CFrame.Angles(0, 0.35, 0)
v20 = Color3.fromRGB(122, 64, 36)
v13[1] = "Steak"
v13[2] = (Vector3.new(2, 0.6000000238418579, 1.5))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v15 = {}
v20 = (CFrame.new(0, 0.62, -0.25)) * CFrame.Angles(0, 0.35, 0)
v21 = Color3.fromRGB(58, 32, 20)
v15[1] = "Sear"
v15[2] = (Vector3.new(1.600000023841858, 0.05999999865889549, 0.11999999731779099))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v17 = {}
v21 = (CFrame.new(0.1, 0.62, 0.25)) * CFrame.Angles(0, 0.35, 0)
v22 = Color3.fromRGB(58, 32, 20)
v17[1] = "Sear2"
v17[2] = (Vector3.new(1.600000023841858, 0.05999999865889549, 0.11999999731779099))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v19 = {}
v22 = (CFrame.new(1.3, 0.35, -0.45)) * CFrame.Angles(0, 0.35, 0)
v23 = Color3.fromRGB(226, 214, 186)
v19[1] = "Bone"
v19[2] = (Vector3.new(1.2999999523162842, 0.30000001192092896, 0.30000001192092896))
v19[3] = v22
v19[4] = v23
v19[5] = Material.SmoothPlastic
v19[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.dino_steak = v18
u6254.FOOD = v16
v16 = {}
v18 = {}
v13 = {}
local identity_3 = CFrame.identity
v20 = Color3.fromRGB(148, 152, 154)
v13[1] = "Curtain"
v13[2] = (Vector3.new(1.600000023841858, 1.399999976158142, 0.10000000149011612))
v13[3] = identity_3
v13[4] = v20
v13[5] = Material.DiamondPlate
v15 = {}
v20 = CFrame.new(0, 0.23, 0)
v21 = Color3.fromRGB(112, 116, 118)
v15[1] = "Seam1"
v15[2] = (Vector3.new(1.559999942779541, 0.05000000074505806, 0.12999999523162842))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = CFrame.new(0, -0.23, 0)
v22 = Color3.fromRGB(112, 116, 118)
v17[1] = "Seam2"
v17[2] = (Vector3.new(1.559999942779541, 0.05000000074505806, 0.12999999523162842))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(-0.84, -0.05, 0)
v23 = Color3.fromRGB(88, 90, 92)
v19[1] = "RailL"
v19[2] = (Vector3.new(0.10000000149011612, 1.5, 0.18000000715255737))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(0.84, -0.05, 0)
v24 = Color3.fromRGB(88, 90, 92)
v20[1] = "RailR"
v20[2] = (Vector3.new(0.10000000149011612, 1.5, 0.18000000715255737))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0, 0.82, 0.06)
v25 = Color3.fromRGB(88, 90, 92)
v21[1] = "Housing"
v21[2] = (Vector3.new(1.7999999523162842, 0.23999999463558197, 0.25999999046325684))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v16.garage_door = v18
v18 = {}
v13 = {}
v19 = CFrame.new(-0.41, 0, 0)
v20 = Color3.fromRGB(116, 82, 52)
v13[1] = "LeafL"
v13[2] = (Vector3.new(0.800000011920929, 1.5, 0.10000000149011612))
v13[3] = v19
v13[4] = v20
v13[5] = Material.WoodPlanks
v15 = {}
v20 = CFrame.new(0.41, 0, 0)
v21 = Color3.fromRGB(116, 82, 52)
v15[1] = "LeafR"
v15[2] = (Vector3.new(0.800000011920929, 1.5, 0.09000000357627869))
v15[3] = v20
v15[4] = v21
v15[5] = Material.WoodPlanks
v17 = {}
v21 = CFrame.new(-0.41, 0.45, 0)
v22 = Color3.fromRGB(81, 57, 36)
v17[1] = "BattenL"
v17[2] = (Vector3.new(0.7400000095367432, 0.07999999821186066, 0.12999999523162842))
v17[3] = v21
v17[4] = v22
v17[5] = Material.WoodPlanks
v19 = {}
v22 = CFrame.new(0.41, 0.45, 0)
v23 = Color3.fromRGB(81, 57, 36)
v19[1] = "BattenR"
v19[2] = (Vector3.new(0.7400000095367432, 0.07999999821186066, 0.12999999523162842))
v19[3] = v22
v19[4] = v23
v19[5] = Material.WoodPlanks
v20 = {}
v23 = CFrame.new(-0.1, 0, 0)
v24 = Color3.fromRGB(60, 58, 56)
v20[1] = "HandleL"
v20[2] = (Vector3.new(0.05000000074505806, 0.20000000298023224, 0.18000000715255737))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0.1, 0, 0)
v25 = Color3.fromRGB(60, 58, 56)
v21[1] = "HandleR"
v21[2] = (Vector3.new(0.05000000074505806, 0.20000000298023224, 0.18000000715255737))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v16.wood_double_door = v18
v18 = {}
v13 = {}
v19 = CFrame.new(-0.41, 0, 0)
v20 = Color3.fromRGB(96, 98, 100)
v13[1] = "LeafL"
v13[2] = (Vector3.new(0.800000011920929, 1.5, 0.10000000149011612))
v13[3] = v19
v13[4] = v20
v13[5] = Material.DiamondPlate
v15 = {}
v20 = CFrame.new(0.41, 0, 0)
v21 = Color3.fromRGB(96, 98, 100)
v15[1] = "LeafR"
v15[2] = (Vector3.new(0.800000011920929, 1.5, 0.09000000357627869))
v15[3] = v20
v15[4] = v21
v15[5] = Material.DiamondPlate
v17 = {}
v21 = CFrame.new(-0.41, 0, 0)
v22 = Color3.fromRGB(67, 69, 70)
v17[1] = "PlateL"
v17[2] = (Vector3.new(0.6000000238418579, 1.2000000476837158, 0.11999999731779099))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0.41, 0, 0)
v23 = Color3.fromRGB(67, 69, 70)
v19[1] = "PlateR"
v19[2] = (Vector3.new(0.6000000238418579, 1.2000000476837158, 0.10999999940395355))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(-0.1, 0, 0)
v24 = Color3.fromRGB(46, 46, 48)
v20[1] = "HandleL"
v20[2] = (Vector3.new(0.05000000074505806, 0.20000000298023224, 0.18000000715255737))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0.1, 0, 0)
v25 = Color3.fromRGB(46, 46, 48)
v21[1] = "HandleR"
v21[2] = (Vector3.new(0.05000000074505806, 0.20000000298023224, 0.18000000715255737))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v16.metal_double_door = v18
v18 = {}
v13 = {}
v19 = CFrame.new(-0.41, 0, 0)
v20 = Color3.fromRGB(54, 58, 64)
v13[1] = "LeafL"
v13[2] = (Vector3.new(0.800000011920929, 1.5, 0.11999999731779099))
v13[3] = v19
v13[4] = v20
v13[5] = Material.DiamondPlate
v15 = {}
v20 = CFrame.new(0.41, 0, 0)
v21 = Color3.fromRGB(54, 58, 64)
v15[1] = "LeafR"
v15[2] = (Vector3.new(0.800000011920929, 1.5, 0.10999999940395355))
v15[3] = v20
v15[4] = v21
v15[5] = Material.DiamondPlate
v17 = {}
v21 = CFrame.new(-0.43, -0.02, 0)
v22 = Color3.fromRGB(68, 74, 84)
v17[1] = "PlateL"
v17[2] = (Vector3.new(0.5799999833106995, 1.0800000429153442, 0.14000000059604645))
v17[3] = v21
v17[4] = v22
v17[5] = Material.DiamondPlate
v19 = {}
v22 = CFrame.new(0.43, -0.02, 0)
v23 = Color3.fromRGB(68, 74, 84)
v19[1] = "PlateR"
v19[2] = (Vector3.new(0.5799999833106995, 1.0800000429153442, 0.12999999523162842))
v19[3] = v22
v19[4] = v23
v19[5] = Material.DiamondPlate
v20 = {}
v23 = CFrame.new(0, 0.685, 0)
v24 = Color3.fromRGB(35, 38, 42)
v20[1] = "RailTop"
v20[2] = (Vector3.new(1.6399999856948853, 0.12999999523162842, 0.1599999964237213))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0, -0.685, 0)
v25 = Color3.fromRGB(35, 38, 42)
v21[1] = "RailBottom"
v21[2] = (Vector3.new(1.6399999856948853, 0.12999999523162842, 0.1599999964237213))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Metal
v22 = {}
v25 = CFrame.new(-0.42, 0.42, 0)
v26 = Color3.fromRGB(14, 14, 16)
v22[1] = "SlotL"
v22[2] = (Vector3.new(0.3400000035762787, 0.07000000029802322, 0.17000000178813934))
v22[3] = v25
v22[4] = v26
v22[5] = Material.SmoothPlastic
v23 = {}
v26 = CFrame.new(0.42, 0.42, 0)
v27 = Color3.fromRGB(14, 14, 16)
v23[1] = "SlotR"
v23[2] = (Vector3.new(0.3400000035762787, 0.07000000029802322, 0.1599999964237213))
v23[3] = v26
v23[4] = v27
v23[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v18[7] = v22
v18[8] = v23
v16.armored_double_door = v18
v18 = {}
v13 = {}
local identity_4 = CFrame.identity
v20 = Color3.fromRGB(96, 98, 100)
v13[1] = "Lid"
v13[2] = (Vector3.new(1.5, 0.10000000149011612, 1.5))
v13[3] = identity_4
v13[4] = v20
v13[5] = Material.DiamondPlate
v15 = {}
v20 = CFrame.new(0, 0.07, -0.42)
v21 = Color3.fromRGB(62, 64, 65)
v15[1] = "Strap1"
v15[2] = (Vector3.new(1.399999976158142, 0.03999999910593033, 0.14000000059604645))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = CFrame.new(0, 0.07, 0.42)
v22 = Color3.fromRGB(62, 64, 65)
v17[1] = "Strap2"
v17[2] = (Vector3.new(1.399999976158142, 0.03999999910593033, 0.14000000059604645))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0.58, 0.09, 0)
v23 = Color3.fromRGB(46, 46, 48)
v19[1] = "Handle"
v19[2] = (Vector3.new(0.10000000149011612, 0.05999999865889549, 0.4000000059604645))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(-0.32, -0.6, 0.6)
v24 = Color3.fromRGB(122, 86, 52)
v20[1] = "RailL"
v20[2] = (Vector3.new(0.09000000357627869, 1.100000023841858, 0.11999999731779099))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Wood
v21 = {}
v24 = CFrame.new(0.32, -0.6, 0.6)
v25 = Color3.fromRGB(122, 86, 52)
v21[1] = "RailR"
v21[2] = (Vector3.new(0.09000000357627869, 1.100000023841858, 0.11999999731779099))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Wood
v22 = {}
v25 = CFrame.new(0, -0.35, 0.6)
v26 = Color3.fromRGB(146, 106, 66)
v22[1] = "Rung1"
v22[2] = (Vector3.new(0.5600000023841858, 0.07000000029802322, 0.07000000029802322))
v22[3] = v25
v22[4] = v26
v22[5] = Material.Wood
v23 = {}
v26 = CFrame.new(0, -0.75, 0.6)
v27 = Color3.fromRGB(146, 106, 66)
v23[1] = "Rung2"
v23[2] = (Vector3.new(0.5600000023841858, 0.07000000029802322, 0.07000000029802322))
v23[3] = v26
v23[4] = v27
v23[5] = Material.Wood
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v18[7] = v22
v18[8] = v23
v16.ladder_hatch = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0.4, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1, 0)
v20 = Color3.fromRGB(96, 98, 100)
v13[1] = "Lid"
v13[2] = (Vector3.new(0.10000000149011612, 1.3860000371932983, 0.800000011920929))
v13[3] = v19
v13[4] = v20
v13[5] = Material.DiamondPlate
v13[6] = Enum.PartType.Wedge
v15 = {}
v20 = CFrame.new(-0.4, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0)
v21 = Color3.fromRGB(96, 98, 100)
v15[1] = "Lid2"
v15[2] = (Vector3.new(0.10000000149011612, 1.3860000371932983, 0.800000011920929))
v15[3] = v20
v15[4] = v21
v15[5] = Material.DiamondPlate
v15[6] = Enum.PartType.Wedge
v17 = {}
v21 = CFrame.new(0, 0.07, -0.3)
v22 = Color3.fromRGB(62, 64, 65)
v17[1] = "Strap"
v17[2] = (Vector3.new(1, 0.03999999910593033, 0.14000000059604645))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0, 0.09, 0.22)
v23 = Color3.fromRGB(46, 46, 48)
v19[1] = "Handle"
v19[2] = (Vector3.new(0.10000000149011612, 0.05999999865889549, 0.30000001192092896))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(-0.32, -0.6, -0.45)
v24 = Color3.fromRGB(122, 86, 52)
v20[1] = "RailL"
v20[2] = (Vector3.new(0.09000000357627869, 1.100000023841858, 0.11999999731779099))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Wood
v21 = {}
v24 = CFrame.new(0.32, -0.6, -0.45)
v25 = Color3.fromRGB(122, 86, 52)
v21[1] = "RailR"
v21[2] = (Vector3.new(0.09000000357627869, 1.100000023841858, 0.11999999731779099))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Wood
v22 = {}
v25 = CFrame.new(0, -0.35, -0.45)
v26 = Color3.fromRGB(146, 106, 66)
v22[1] = "Rung1"
v22[2] = (Vector3.new(0.5600000023841858, 0.07000000029802322, 0.07000000029802322))
v22[3] = v25
v22[4] = v26
v22[5] = Material.Wood
v23 = {}
v26 = CFrame.new(0, -0.75, -0.45)
v27 = Color3.fromRGB(146, 106, 66)
v23[1] = "Rung2"
v23[2] = (Vector3.new(0.5600000023841858, 0.07000000029802322, 0.07000000029802322))
v23[3] = v26
v23[4] = v27
v23[5] = Material.Wood
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v18[7] = v22
v18[8] = v23
v16.tri_ladder_hatch = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0, -0.6)
v20 = Color3.fromRGB(66, 68, 70)
v13[1] = "Bar1"
v13[2] = (Vector3.new(1.5, 0.07999999821186066, 0.07999999821186066))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Metal
v15 = {}
v20 = CFrame.new(0, 0, -0.3)
v21 = Color3.fromRGB(66, 68, 70)
v15[1] = "Bar2"
v15[2] = (Vector3.new(1.5, 0.07999999821186066, 0.07999999821186066))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = CFrame.new(0, 0, 0)
v22 = Color3.fromRGB(66, 68, 70)
v17[1] = "Bar3"
v17[2] = (Vector3.new(1.5, 0.07999999821186066, 0.07999999821186066))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0, 0, 0.3)
v23 = Color3.fromRGB(66, 68, 70)
v19[1] = "Bar4"
v19[2] = (Vector3.new(1.5, 0.07999999821186066, 0.07999999821186066))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(0, 0, 0.6)
v24 = Color3.fromRGB(66, 68, 70)
v20[1] = "Bar5"
v20[2] = (Vector3.new(1.5, 0.07999999821186066, 0.07999999821186066))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(-0.4, -0.07, 0)
v25 = Color3.fromRGB(50, 51, 52)
v21[1] = "CrossL"
v21[2] = (Vector3.new(0.07999999821186066, 0.07000000029802322, 1.399999976158142))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Metal
v22 = {}
v25 = CFrame.new(0.4, -0.07, 0)
v26 = Color3.fromRGB(50, 51, 52)
v22[1] = "CrossR"
v22[2] = (Vector3.new(0.07999999821186066, 0.07000000029802322, 1.399999976158142))
v22[3] = v25
v22[4] = v26
v22[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v18[7] = v22
v16.floor_grill = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0, -0.6)
v20 = Color3.fromRGB(66, 68, 70)
v13[1] = "Bar1"
v13[2] = (Vector3.new(1.600000023841858, 0.07999999821186066, 0.07999999821186066))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Metal
v15 = {}
v20 = CFrame.new(0, 0, -0.3)
v21 = Color3.fromRGB(66, 68, 70)
v15[1] = "Bar2"
v15[2] = (Vector3.new(1.25, 0.07999999821186066, 0.07999999821186066))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = CFrame.new(0, 0, 0)
v22 = Color3.fromRGB(66, 68, 70)
v17[1] = "Bar3"
v17[2] = (Vector3.new(0.8999999761581421, 0.07999999821186066, 0.07999999821186066))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0, 0, 0.3)
v23 = Color3.fromRGB(66, 68, 70)
v19[1] = "Bar4"
v19[2] = (Vector3.new(0.550000011920929, 0.07999999821186066, 0.07999999821186066))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v20 = {}
v23 = CFrame.new(0, 0, 0.6)
v24 = Color3.fromRGB(66, 68, 70)
v20[1] = "Bar5"
v20[2] = (Vector3.new(0.20000000298023224, 0.07999999821186066, 0.07999999821186066))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v21 = {}
v24 = CFrame.new(0, -0.07, 0)
v25 = Color3.fromRGB(50, 51, 52)
v21[1] = "Cross"
v21[2] = (Vector3.new(0.07999999821186066, 0.07000000029802322, 1.2999999523162842))
v21[3] = v24
v21[4] = v25
v21[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v18[6] = v21
v16.tri_floor_grill = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.6, 0)
v20 = Color3.fromRGB(50, 51, 52)
v13[1] = "Top"
v13[2] = (Vector3.new(1.5, 0.10000000149011612, 0.07999999821186066))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Metal
v15 = {}
v20 = CFrame.new(0, -0.6, 0)
v21 = Color3.fromRGB(50, 51, 52)
v15[1] = "Bottom"
v15[2] = (Vector3.new(1.5, 0.10000000149011612, 0.07999999821186066))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = (CFrame.new(-0.5, 0, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
v22 = Color3.fromRGB(66, 68, 70)
v17[1] = "Rod1"
v17[2] = (Vector3.new(1.2999999523162842, 0.09000000357627869, 0.09000000357627869))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v17[6] = Enum.PartType.Cylinder
v19 = {}
v22 = (CFrame.new(0, 0, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
v23 = Color3.fromRGB(66, 68, 70)
v19[1] = "Rod2"
v19[2] = (Vector3.new(1.2999999523162842, 0.09000000357627869, 0.09000000357627869))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v19[6] = Enum.PartType.Cylinder
v20 = {}
v23 = (CFrame.new(0.5, 0, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
v24 = Color3.fromRGB(66, 68, 70)
v20[1] = "Rod3"
v20[2] = (Vector3.new(1.2999999523162842, 0.09000000357627869, 0.09000000357627869))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Metal
v20[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v16.window_bars = v18
v18 = {}
v13 = {}
local identity_5 = CFrame.identity
v20 = Color3.fromRGB(58, 60, 62)
v13[1] = "Body"
v13[2] = (Vector3.new(0.6000000238418579, 0.800000011920929, 0.30000001192092896))
v13[3] = identity_5
v13[4] = v20
v13[5] = Material.Metal
v15 = {}
v20 = CFrame.new(0, -0.04, -0.17)
v21 = Color3.fromRGB(196, 158, 72)
v15[1] = "Plate"
v15[2] = (Vector3.new(0.4399999976158142, 0.5600000023841858, 0.05000000074505806))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v17 = {}
v21 = (CFrame.new(0, 0.02, -0.2)) * CFrame.Angles(0, 1.5707963267948966, 0)
v22 = Color3.fromRGB(22, 20, 18)
v17[1] = "Hole"
v17[2] = (Vector3.new(0.05999999865889549, 0.12999999523162842, 0.12999999523162842))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v17[6] = Enum.PartType.Cylinder
v19 = {}
v22 = CFrame.new(0, -0.1, -0.2)
v23 = Color3.fromRGB(22, 20, 18)
v19[1] = "Slot"
v19[2] = (Vector3.new(0.05000000074505806, 0.1599999964237213, 0.03999999910593033))
v19[3] = v22
v19[4] = v23
v19[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.key_lock = v18
v18 = {}
v13 = {}
v19 = (CFrame.new(-0.75, 0.06, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
v20 = Color3.fromRGB(196, 158, 72)
v13[1] = "Bow"
v13[2] = (Vector3.new(0.11999999731779099, 0.8999999761581421, 0.8999999761581421))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Metal
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = (CFrame.new(-0.75, 0.06, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
v21 = Color3.fromRGB(22, 20, 18)
v15[1] = "Hole"
v15[2] = (Vector3.new(0.14000000059604645, 0.3199999928474426, 0.3199999928474426))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v15[6] = Enum.PartType.Cylinder
v17 = {}
v21 = CFrame.new(0.3, 0.05, 0)
v22 = Color3.fromRGB(182, 146, 64)
v17[1] = "Shaft"
v17[2] = (Vector3.new(1.2999999523162842, 0.10000000149011612, 0.18000000715255737))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0.66, 0.05, 0.2)
v23 = Color3.fromRGB(182, 146, 64)
v19[1] = "Bit"
v19[2] = (Vector3.new(0.41999998688697815, 0.10000000149011612, 0.30000001192092896))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.lock_key = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.04, 0)
v20 = Color3.fromRGB(52, 104, 178)
v13[1] = "Card"
v13[2] = (Vector3.new(1.7000000476837158, 0.07999999821186066, 1.0800000429153442))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v15 = {}
v20 = CFrame.new(0, 0.045, -0.3)
v21 = Color3.fromRGB(226, 222, 210)
v15[1] = "Stripe"
v15[2] = (Vector3.new(1.7000000476837158, 0.09000000357627869, 0.20000000298023224))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v17 = {}
v21 = CFrame.new(-0.5, 0.05, 0.12)
v22 = Color3.fromRGB(212, 170, 70)
v17[1] = "Chip"
v17[2] = (Vector3.new(0.3400000035762787, 0.10000000149011612, 0.25999999046325684))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v19 = {}
v22 = CFrame.new(0, 0.045, 0.4)
v23 = Color3.fromRGB(24, 24, 24)
v19[1] = "Mag"
v19[2] = (Vector3.new(1.7000000476837158, 0.09000000357627869, 0.14000000059604645))
v19[3] = v22
v19[4] = v23
v19[5] = Material.SmoothPlastic
v20 = {}
v23 = (CFrame.new(0.72, 0.05, -0.36)) * CFrame.Angles(0, 0, 1.5707963267948966)
v24 = Color3.fromRGB(30, 30, 30)
v20[1] = "Hole"
v20[2] = (Vector3.new(0.10000000149011612, 0.11999999731779099, 0.11999999731779099))
v20[3] = v23
v20[4] = v24
v20[5] = Material.SmoothPlastic
v20[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v16.bunker_keycard = v18
v18 = {}
v13 = {}
v19 = CFrame.new(-0.5, 0, 0)
v20 = Color3.fromRGB(128, 92, 58)
v13[1] = "LeafL"
v13[2] = (Vector3.new(0.949999988079071, 1.399999976158142, 0.14000000059604645))
v13[3] = v19
v13[4] = v20
v13[5] = Material.WoodPlanks
v15 = {}
v20 = CFrame.new(0.5, 0, 0)
v21 = Color3.fromRGB(118, 84, 52)
v15[1] = "LeafR"
v15[2] = (Vector3.new(0.949999988079071, 1.399999976158142, 0.11999999731779099))
v15[3] = v20
v15[4] = v21
v15[5] = Material.WoodPlanks
v17 = {}
v21 = CFrame.new(-0.5, 0.35, 0)
v22 = Color3.fromRGB(86, 60, 38)
v17[1] = "SlatL"
v17[2] = (Vector3.new(0.8500000238418579, 0.11999999731779099, 0.20000000298023224))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Wood
v19 = {}
v22 = CFrame.new(0.5, -0.35, 0)
v23 = Color3.fromRGB(86, 60, 38)
v19[1] = "SlatR"
v19[2] = (Vector3.new(0.8500000238418579, 0.11999999731779099, 0.20000000298023224))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Wood
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.wooden_shutters = v18
v18 = {}
v13 = {}
v19 = CFrame.new(-0.5, 0, 0)
v20 = Color3.fromRGB(100, 102, 104)
v13[1] = "LeafL"
v13[2] = (Vector3.new(0.949999988079071, 1.399999976158142, 0.14000000059604645))
v13[3] = v19
v13[4] = v20
v13[5] = Material.DiamondPlate
v15 = {}
v20 = CFrame.new(0.5, 0, 0)
v21 = Color3.fromRGB(92, 94, 96)
v15[1] = "LeafR"
v15[2] = (Vector3.new(0.949999988079071, 1.399999976158142, 0.11999999731779099))
v15[3] = v20
v15[4] = v21
v15[5] = Material.DiamondPlate
v17 = {}
v21 = CFrame.new(-0.5, 0.3, 0)
v22 = Color3.fromRGB(20, 20, 22)
v17[1] = "SlotL"
v17[2] = (Vector3.new(0.6000000238418579, 0.10000000149011612, 0.18000000715255737))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v19 = {}
v22 = CFrame.new(0.5, 0.3, 0)
v23 = Color3.fromRGB(20, 20, 22)
v19[1] = "SlotR"
v19[2] = (Vector3.new(0.6000000238418579, 0.10000000149011612, 0.18000000715255737))
v19[3] = v22
v19[4] = v23
v19[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.metal_shutters = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.28, 0)
v20 = Color3.fromRGB(150, 80, 200)
v13[1] = "Body"
v13[2] = (Vector3.new(1.2999999523162842, 0.550000011920929, 0.550000011920929))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = CFrame.new(-0.3, 0.28, 0)
v21 = Color3.fromRGB(40, 38, 42)
v15[1] = "Band"
v15[2] = (Vector3.new(0.14000000059604645, 0.5699999928474426, 0.5699999928474426))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v15[6] = Enum.PartType.Cylinder
v17 = {}
v21 = CFrame.new(0.75, 0.28, 0)
v22 = Color3.fromRGB(70, 72, 76)
v17[1] = "Cap"
v17[2] = (Vector3.new(0.20000000298023224, 0.5799999833106995, 0.5799999833106995))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v17[6] = Enum.PartType.Cylinder
v19 = {}
v22 = (CFrame.new(0.9, 0.5, 0)) * CFrame.Angles(0, 0, 1.0471975511965976)
v23 = Color3.fromRGB(190, 190, 194)
v19[1] = "Ring"
v19[2] = (Vector3.new(0.05000000074505806, 0.30000001192092896, 0.30000001192092896))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Metal
v19[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v16.supply_signal = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.27, 0)
v20 = Color3.fromRGB(104, 106, 110)
v13[1] = "Pipe"
v13[2] = (Vector3.new(1.2999999523162842, 0.5, 0.5))
v13[3] = v19
v13[4] = v20
v13[5] = Material.Metal
v13[6] = Enum.PartType.Cylinder
v15 = {}
v20 = CFrame.new(-0.72, 0.27, 0)
v21 = Color3.fromRGB(62, 64, 68)
v15[1] = "CapL"
v15[2] = (Vector3.new(0.18000000715255737, 0.6000000238418579, 0.6000000238418579))
v15[3] = v20
v15[4] = v21
v15[5] = Material.Metal
v15[6] = Enum.PartType.Cylinder
v17 = {}
v21 = CFrame.new(0.72, 0.27, 0)
v22 = Color3.fromRGB(62, 64, 68)
v17[1] = "CapR"
v17[2] = (Vector3.new(0.18000000715255737, 0.6000000238418579, 0.6000000238418579))
v17[3] = v21
v17[4] = v22
v17[5] = Material.Metal
v17[6] = Enum.PartType.Cylinder
v19 = {}
v22 = CFrame.new(-0.1, 0.27, 0)
v23 = Color3.fromRGB(40, 40, 42)
v19[1] = "Tape"
v19[2] = (Vector3.new(0.2199999988079071, 0.5199999809265137, 0.5199999809265137))
v19[3] = v22
v19[4] = v23
v19[5] = Material.Fabric
v19[6] = Enum.PartType.Cylinder
v20 = {}
v23 = (CFrame.new(0.98, 0.36, 0)) * CFrame.Angles(0, 0, 0.4363323129985824)
v24 = Color3.fromRGB(205, 187, 138)
v20[1] = "Fuse"
v20[2] = (Vector3.new(0.44999998807907104, 0.05999999865889549, 0.05999999865889549))
v20[3] = v23
v20[4] = v24
v20[5] = Material.Fabric
v20[6] = Enum.PartType.Cylinder
v18[1] = v13
v18[2] = v15
v18[3] = v17
v18[4] = v19
v18[5] = v20
v16.grenade = v18
v18 = {}
v13 = Color3.fromRGB(205, 165, 85)
v15 = Color3.fromRGB(196, 60, 40)
local Cylinder_6 = Enum.PartType.Cylinder
local Ball_3 = Enum.PartType.Ball

for i, v in ipairs({-0.3, 0, 0.3}) do
    v27 = {}
    v28 = "Case" .. i
    v30 = CFrame.new(if i ~= 2 then 0 else 0.12, 0.11, v)
    v27[1] = v28
    v27[2] = (Vector3.new(0.8999999761581421, 0.2199999988079071, 0.2199999988079071))
    v27[3] = v30
    v27[4] = v13
    v27[5] = Material.Metal
    v27[6] = Cylinder_6

    table.insert(v18, v27)

    v27 = {}
    v28 = "Neck" .. i
    v30 = CFrame.new(v14 + 0.54, 0.11, v)
    v27[1] = v28
    v27[2] = (Vector3.new(0.18000000715255737, 0.17000000178813934, 0.17000000178813934))
    v27[3] = v30
    v27[4] = v13
    v27[5] = Material.Metal
    v27[6] = Cylinder_6

    table.insert(v18, v27)

    v27 = {}
    v28 = "Tip" .. i
    v30 = CFrame.new(v14 + 0.74, 0.11, v)
    v27[1] = v28
    v27[2] = (Vector3.new(0.25999999046325684, 0.15000000596046448, 0.15000000596046448))
    v27[3] = v30
    v27[4] = v15
    v27[5] = Material.SmoothPlastic
    v27[6] = Cylinder_6

    table.insert(v18, v27)

    v27 = {}
    v28 = "Nose" .. i
    v30 = CFrame.new(v14 + 0.87, 0.11, v)
    v27[1] = v28
    v27[2] = (Vector3.new(0.15000000596046448, 0.15000000596046448, 0.15000000596046448))
    v27[3] = v30
    v27[4] = v15
    v27[5] = Material.SmoothPlastic
    v27[6] = Ball_3

    table.insert(v18, v27)
end

v16.explosive_rifle_ammo = v18
v13 = Color3.fromRGB(150, 140, 96)
v15 = Color3.fromRGB(62, 70, 54)
v17 = Color3.fromRGB(92, 118, 150)
local Cylinder_7 = Enum.PartType.Cylinder
local Ball_4 = Enum.PartType.Ball
v18 = {}
v21 = {}
v24 = CFrame.new(0, 0.3, 0)
v21[1] = "Body"
v21[2] = (Vector3.new(1.600000023841858, 0.36000001430511475, 0.36000001430511475))
v21[3] = v24
v21[4] = v13
v21[5] = Material.Metal
v21[6] = Cylinder_7
v22 = {}
v25 = CFrame.new(0.4, 0.3, 0)
v22[1] = "Band"
v22[2] = (Vector3.new(0.11999999731779099, 0.3799999952316284, 0.3799999952316284))
v22[3] = v25
v22[4] = v17
v22[5] = Material.SmoothPlastic
v22[6] = Cylinder_7
v23 = {}
v26 = CFrame.new(0.93, 0.3, 0)
v23[1] = "Cone"
v23[2] = (Vector3.new(0.30000001192092896, 0.30000001192092896, 0.30000001192092896))
v23[3] = v26
v23[4] = v17
v23[5] = Material.SmoothPlastic
v23[6] = Cylinder_7
v24 = {}
v27 = CFrame.new(1.08, 0.3, 0)
v24[1] = "Tip"
v24[2] = (Vector3.new(0.25999999046325684, 0.25999999046325684, 0.25999999046325684))
v24[3] = v27
v24[4] = v17
v24[5] = Material.SmoothPlastic
v24[6] = Ball_4
v25 = {}
v28 = CFrame.new(-0.9, 0.3, 0)
v25[1] = "Tail"
v25[2] = (Vector3.new(0.25, 0.41999998688697815, 0.41999998688697815))
v25[3] = v28
v25[4] = v15
v25[5] = Material.Metal
v25[6] = Cylinder_7
v26 = {}
v29 = CFrame.new(-0.86, 0.3, 0)
v26[1] = "FinA"
v26[2] = (Vector3.new(0.36000001430511475, 0.699999988079071, 0.05000000074505806))
v26[3] = v29
v26[4] = v15
v26[5] = Material.Metal
v27 = {}
v30 = CFrame.new(-0.86, 0.3, 0)
v27[1] = "FinB"
v27[2] = (Vector3.new(0.36000001430511475, 0.05000000074505806, 0.699999988079071))
v27[3] = v30
v27[4] = v15
v27[5] = Material.Metal
v18[1] = v21
v18[2] = v22
v18[3] = v23
v18[4] = v24
v18[5] = v25
v18[6] = v26
v18[7] = v27
v16.hv_rocket = v18
v13 = Color3.fromRGB(150, 140, 96)
v15 = Color3.fromRGB(62, 70, 54)
v17 = Color3.fromRGB(206, 92, 40)
local Cylinder_8 = Enum.PartType.Cylinder
local Ball_5 = Enum.PartType.Ball
v18 = {}
v21 = {}
v24 = CFrame.new(0, 0.3, 0)
v21[1] = "Body"
v21[2] = (Vector3.new(1.600000023841858, 0.36000001430511475, 0.36000001430511475))
v21[3] = v24
v21[4] = v13
v21[5] = Material.Metal
v21[6] = Cylinder_8
v22 = {}
v25 = CFrame.new(0.4, 0.3, 0)
v22[1] = "Band"
v22[2] = (Vector3.new(0.11999999731779099, 0.3799999952316284, 0.3799999952316284))
v22[3] = v25
v22[4] = v17
v22[5] = Material.SmoothPlastic
v22[6] = Cylinder_8
v23 = {}
v26 = CFrame.new(0.2, 0.3, 0)
v27 = Color3.fromRGB(240, 190, 60)
v23[1] = "Band2"
v23[2] = (Vector3.new(0.07999999821186066, 0.3799999952316284, 0.3799999952316284))
v23[3] = v26
v23[4] = v27
v23[5] = Material.SmoothPlastic
v23[6] = Cylinder_8
v24 = {}
v27 = CFrame.new(0.93, 0.3, 0)
v24[1] = "Cone"
v24[2] = (Vector3.new(0.30000001192092896, 0.30000001192092896, 0.30000001192092896))
v24[3] = v27
v24[4] = v17
v24[5] = Material.SmoothPlastic
v24[6] = Cylinder_8
v25 = {}
v28 = CFrame.new(1.08, 0.3, 0)
v25[1] = "Tip"
v25[2] = (Vector3.new(0.25999999046325684, 0.25999999046325684, 0.25999999046325684))
v25[3] = v28
v25[4] = v17
v25[5] = Material.SmoothPlastic
v25[6] = Ball_5
v26 = {}
v29 = CFrame.new(-0.9, 0.3, 0)
v26[1] = "Tail"
v26[2] = (Vector3.new(0.25, 0.41999998688697815, 0.41999998688697815))
v26[3] = v29
v26[4] = v15
v26[5] = Material.Metal
v26[6] = Cylinder_8
v27 = {}
v30 = CFrame.new(-0.86, 0.3, 0)
v27[1] = "FinA"
v27[2] = (Vector3.new(0.36000001430511475, 0.699999988079071, 0.05000000074505806))
v27[3] = v30
v27[4] = v15
v27[5] = Material.Metal
v28 = {}
v31 = CFrame.new(-0.86, 0.3, 0)
v28[1] = "FinB"
v28[2] = (Vector3.new(0.36000001430511475, 0.05000000074505806, 0.699999988079071))
v28[3] = v31
v28[4] = v15
v28[5] = Material.Metal
v18[1] = v21
v18[2] = v22
v18[3] = v23
v18[4] = v24
v18[5] = v25
v18[6] = v26
v18[7] = v27
v18[8] = v28
v16.incendiary_rocket = v18
v18 = {}
v13 = {}
v19 = CFrame.new(0, 0.35, 0)
v20 = Color3.fromRGB(196, 170, 130)
v13[1] = "Root"
v13[2] = (Vector3.new(0.699999988079071, 0.699999988079071, 0.5))
v13[3] = v19
v13[4] = v20
v13[5] = Material.SmoothPlastic
v15 = {}
v20 = (CFrame.new(0.08, 1.15, 0)) * CFrame.Angles(0, 0, -0.18)
v21 = Color3.fromRGB(236, 228, 204)
v15[1] = "Crown"
v15[2] = (Vector3.new(0.6000000238418579, 1.100000023841858, 0.41999998688697815))
v15[3] = v20
v15[4] = v21
v15[5] = Material.SmoothPlastic
v17 = {}
v21 = (CFrame.new(0.26, 1.95, 0)) * CFrame.Angles(0, 0, -0.35)
v22 = Color3.fromRGB(244, 238, 220)
v17[1] = "Tip"
v17[2] = (Vector3.new(0.3799999952316284, 0.6000000238418579, 0.30000001192092896))
v17[3] = v21
v17[4] = v22
v17[5] = Material.SmoothPlastic
v18[1] = v13
v18[2] = v15
v18[3] = v17
v16.trex_tooth = v18
u6254.EXTRA = v16
local u5943 = (Color3.fromRGB(196, 160, 82))
local Cylinder = Enum.PartType.Cylinder
local Ball = Enum.PartType.Ball

local function shells(a1, a2)
    -- Line: 1173
    -- upvalues: Material (val), Cylinder (val), u5943 (val), Ball (val)
    -- types: a1: CFrame, a2: boolean
    local v1, v2, v3, v4, v5
    local v6 = {}

    for i, v in ipairs({-0.36, 0, 0.36}) do
        v1 = {}
        v2 = "Hull" .. i
        v3 = CFrame.new(if i ~= 2 then 0 else 0.1, 0.16, v)
        v1[1] = v2
        v1[2] = (Vector3.new(0.7200000286102295, 0.3199999928474426, 0.3199999928474426))
        v1[3] = v3
        v1[4] = v7
        v1[5] = Material.SmoothPlastic
        v1[6] = Cylinder

        table.insert(v6, v1)

        v1 = {}
        v2 = "Head" .. i
        v3 = CFrame.new(v5 - 0.44, 0.16, v)
        v1[1] = v2
        v1[2] = (Vector3.new(0.18000000715255737, 0.3400000035762787, 0.3400000035762787))
        v1[3] = v3
        v1[4] = u5943
        v1[5] = Material.Metal
        v1[6] = Cylinder

        table.insert(v6, v1)

        if not v8 then
            v1 = {}
            v2 = "Crimp" .. i
            v3 = CFrame.new(v5 + 0.37, 0.16, v)
            v4 = Color3.fromRGB(110, 30, 28)
            v1[1] = v2
            v1[2] = (Vector3.new(0.03999999910593033, 0.30000001192092896, 0.30000001192092896))
            v1[3] = v3
            v1[4] = v4
            v1[5] = Material.SmoothPlastic
            v1[6] = Cylinder
        else
            v1 = {}
            v2 = "Slug" .. i
            v3 = CFrame.new(v5 + 0.36, 0.16, v)
            v4 = Color3.fromRGB(128, 130, 134)
            v1[1] = v2
            v1[2] = (Vector3.new(0.23999999463558197, 0.23999999463558197, 0.23999999463558197))
            v1[3] = v3
            v1[4] = v4
            v1[5] = Material.Metal
            v1[6] = Ball
        end

        table.insert(v6, v1)
    end

    return v6
end

u6254.EXTRA.buckshot_shell = shells(Color3.fromRGB(150, 44, 40), false)
u6254.EXTRA.slug_shell = shells(Color3.fromRGB(56, 74, 110), true)
v11 = {}
v16 = Color3.fromRGB(205, 165, 85)
v18 = Color3.fromRGB(86, 126, 168)
v13 = Color3.fromRGB(60, 46, 26)
local Cylinder_9 = Enum.PartType.Cylinder
local Ball_6 = Enum.PartType.Ball

for i2, i3 in ipairs({-0.3, 0, 0.3}) do
    v26 = {}
    v27 = "Case" .. i2
    v29 = CFrame.new(if i2 ~= 2 then -0.04 else 0.12, 0.11, i3)
    v26[1] = v27
    v26[2] = (Vector3.new(0.8999999761581421, 0.2199999988079071, 0.2199999988079071))
    v26[3] = v29
    v26[4] = v16
    v26[5] = Material.Metal
    v26[6] = Cylinder_9

    table.insert(v11, v26)

    v26 = {}
    v27 = "Ring" .. i2
    v29 = CFrame.new(v10 + 0.3, 0.11, i3)
    v26[1] = v27
    v26[2] = (Vector3.new(0.05000000074505806, 0.22499999403953552, 0.22499999403953552))
    v26[3] = v29
    v26[4] = v13
    v26[5] = Material.SmoothPlastic
    v26[6] = Cylinder_9

    table.insert(v11, v26)

    v26 = {}
    v27 = "Neck" .. i2
    v29 = CFrame.new(v10 + 0.54, 0.11, i3)
    v26[1] = v27
    v26[2] = (Vector3.new(0.18000000715255737, 0.17000000178813934, 0.17000000178813934))
    v26[3] = v29
    v26[4] = v16
    v26[5] = Material.Metal
    v26[6] = Cylinder_9

    table.insert(v11, v26)

    v26 = {}
    v27 = "Tip" .. i2
    v29 = CFrame.new(v10 + 0.78, 0.11, i3)
    v26[1] = v27
    v26[2] = (Vector3.new(0.3199999928474426, 0.12999999523162842, 0.12999999523162842))
    v26[3] = v29
    v26[4] = v18
    v26[5] = Material.Metal
    v26[6] = Cylinder_9

    table.insert(v11, v26)

    v26 = {}
    v27 = "Point" .. i2
    v29 = CFrame.new(v10 + 0.97, 0.11, i3)
    v26[1] = v27
    v26[2] = (Vector3.new(0.10000000149011612, 0.09000000357627869, 0.09000000357627869))
    v26[3] = v29
    v26[4] = v18
    v26[5] = Material.Metal
    v26[6] = Cylinder_9

    table.insert(v11, v26)

    v26 = {}
    v27 = "Nose" .. i2
    v29 = CFrame.new(v10 + 1.02, 0.11, i3)
    v26[1] = v27
    v26[2] = (Vector3.new(0.09000000357627869, 0.09000000357627869, 0.09000000357627869))
    v26[3] = v29
    v26[4] = v18
    v26[5] = Material.Metal
    v26[6] = Ball_6

    table.insert(v11, v26)
end

u6254.EXTRA.hv_rifle_ammo = v11

function u6254.food(a1) -- Line: 1208; upvalues: u6254 (val); types: a1: string
    local Part, v1, v2, v3, v4, v5, v6
    local v7 = u6254.FOOD[a1] or u6254.EXTRA[a1]

    if not v7 then
        return nil
    end

    local Model = Instance.new("Model")
    Model.Name = a1

    for i, v in ipairs(v7) do
        v5 = v[1]
        v6 = v[2]
        v1 = v[3]
        v2 = v[4]
        v3 = v[5]
        v4 = v[6]
        Part = Instance.new("Part")
        Part.Name = v5

        if v4 then
            Part.Shape = v4
        end

        Part.Size = v6
        Part.CFrame = v1
        Part.Color = v2
        Part.Material = v3
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanTouch = false
        Part.CanQuery = false
        Part.CastShadow = false
        Part.TopSurface = Enum.SurfaceType.Smooth
        Part.BottomSurface = Enum.SurfaceType.Smooth
        Part.Parent = Model
    end

    return Model
end

function u6346._fit(a1, a2, a3, a4, a5, a6)
    -- Line: 1227
    -- types: a1: table, a2: vector, a3: vector, a4: vector, a5: number, a6: number
    local v1, v2
    local v3 = #a1

    if v3 == 0 then
        return Vector3.new(0, 0, 0), 10
    end

    local v4 = Vector3.new(0, 0, 0)

    for i, v in ipairs(a1) do
        v4 = v4 + v
    end

    local v5 = v4 / v3
    local v6 = (1 / 0)
    local v7 = (-1 / 0)
    local v8 = (1 / 0)
    local v9 = (-1 / 0)

    for i2, i3 in ipairs(a1) do
        v4 = i3 - v5
        v1 = v4:Dot(a3)
        v2 = v4:Dot(a4)
        v6 = math.min(v6, v1)
        v7 = math.max(v7, v1)
        v8 = math.min(v8, v2)
        v9 = math.max(v9, v2)
    end

    local v10 = (v6 + v7) / 2
    local v11 = (v8 + v9) / 2
    v9 = v5 + a3 * v10 + a4 * v11
    v11 = a5 * math.tan((math.rad(a6 / 2)))
    local v12 = 0
    local v13 = (-1 / 0)

    for i4, j in ipairs(a1) do
        v10 = j - v9
        v8 = v10:Dot(a2)
        v12 = math.max(v12, v8 + (math.max(math.abs((v10:Dot(a3))), (math.abs((v10:Dot(a4)))))) / v11)
        v13 = math.max(v13, v8)
    end

    v12 = math.max(v12, v13 + 0.05, 0.1)

    return v9, v12
end

local function isMarker(a1) -- Line: 1259; upvalues: u6347 (val); types: a1: userdata
    local v1 = true

    if u6347[a1.Name] ~= true then
        v1 = 0.98 <= a1.Transparency
    end

    return v1
end

local function clean(a1) -- Line: 1264; upvalues: u6348 (val), u6347 (val); types: a1: userdata
    local v1, v2
    local v3 = {}

    for i, v in ipairs(a1:GetDescendants()) do
        v1 = false

        for i2, i3 in ipairs(u6348) do
            if v:IsA(i3) then
                v1 = true
                break
            end
        end

        if v1 and v:IsA("BasePart") then
            v2 = true

            if u6347[v.Name] ~= true then
                v2 = 0.98 <= v.Transparency
            end

            if v2 then
                v1 = false
            end
        end

        if not v1 then
            v:Destroy()
        elseif v:IsA("BasePart") then
            v.Anchored = true
            v.CanCollide = false
            v.CanTouch = false
            v.CanQuery = false
            v.CastShadow = false

            table.insert(v3, v)
        end
    end

    return v3
end

local function liveParts(a1) -- Line: 1291; types: a1: userdata
    local v1 = {}

    for i, v in ipairs(a1:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent ~= nil then
            table.insert(v1, v)
        end
    end

    return v1
end

local function corners(a1) -- Line: 1301; types: a1: table
    local CFrame_2, v1
    local v2 = {}

    for i, v in ipairs(a1) do
        CFrame_2 = v.CFrame
        v1 = v.Size / 2

        for i2 = -1, 1, 2 do
            for j = -1, 1, 2 do
                for k = -1, 1, 2 do
                    table.insert(v2, (CFrame_2:PointToWorldSpace((Vector3.new(v1.X * i2, v1.Y * j, v1.Z * k)))))
                end
            end
        end
    end

    return v2
end

local function modelName(a1) -- Line: 1316
    local icon = a1.icon

    if type(icon) == "string" and icon ~= "" and not string.find(icon, "rbxasset", 1, true) then
        return icon
    end

    if type(a1.model) == "string" then
        return a1.model
    end

    return nil
end

local function imported(a1) -- Line: 1325; upvalues: Fust (val), clean (val); types: a1: string?
    local v1

    if not a1 then
        return nil
    end

    local Models = Fust:FindFirstChild("Models")
    local v2 = Models and Models:FindFirstChild(a1)

    if not v2 then
        return nil
    end

    if not v2:IsA("Model") and not v2:IsA("BasePart") then
        return nil
    end

    local v3 = v2:Clone()

    if not v3:IsA("Model") then
        v3.Parent = (Instance.new("Model"))
    else
        v1 = v3
    end

    v1.Name = a1

    if #clean(v1) ~= 0 then
        return v1
    end

    v1:Destroy()

    return nil
end

local u6015 = nil

local function getWear() -- Line: 1351; upvalues: u6015 (ref), Fust (val)
    if u6015 == nil then
        local Wear = Fust:FindFirstChild("Wear")

        if Wear and Wear:IsA("ModuleScript") then
            local success, err = pcall(require, Wear)
            u6015 = if not success then false else if type(err) ~= "table" then false else err
        end
    end

    return u6015 or nil
end

local function styleOf(a1, a2) -- Line: 1362; upvalues: u6350 (val); types: a1: string
    if a2.kind == "backpack" then
        return "pack"
    end

    if a2.kind == "wear" then
        return "wear"
    end

    if a2.kind == "deployable" then
        return "deploy"
    end

    if a2.kind == "tool" then
        if a2.weapon == "gun" then
            return "gun"
        end

        if a2.weapon == "throw" then
            return "pile"
        end

        return "tool"
    end

    if a2.kind == "ammo" then
        if u6350[a1] then
            return "rounds"
        end

        return "arrow"
    end

    if a2.kind == "building" then
        return "upright"
    end

    return "pile"
end

local function rotateAll(a1, a2) -- Line: 1385; upvalues: liveParts (val); types: a1: userdata, a2: userdata
    if a2 == CFrame.identity then
        return
    end

    for i, v in ipairs((liveParts(a1))) do
        v.CFrame = a2 * v.CFrame
    end
end

local function cluster(a1, a2)
    -- Line: 1395
    -- upvalues: liveParts (val), corners (val)
    -- types: a1: userdata, a2: number
    local v1
    local v2 = (1 / 0)
    local v3 = (-1 / 0)
    local v4 = (1 / 0)
    local v5 = (-1 / 0)

    for i, v in ipairs((corners((liveParts(a1))))) do
        v2 = math.min(v2, v.X)
        v3 = math.max(v3, v.X)
        v4 = math.min(v4, v.Z)
        v5 = math.max(v5, v.Z)
    end

    local v6 = math.max(v3 - v2, v5 - v4, 0.01) * 1.15
    v5 = {
        Vector3.new(-v6 * 0.55, 0, v6 * 0.25),
        Vector3.new(v6 * 0.55, 0, v6 * 0.25),
        (Vector3.new(0, 0, -v6 * 0.7)),
    }
    v4 = Instance.new("Model")
    v4.Name = a1.Name
    local v7 = a1

    for i2 = 1, (math.min(a2, #v5)) do
        for i3, j in ipairs((liveParts(if i2 ~= 1 then v7:Clone() else v7))) do
            v1 = CFrame.new(v5[i2])
            j.CFrame = v1 * j.CFrame
        end

        v3.Parent = v4
    end

    return v4
end

local function build(a1, a2)
    -- Line: 1416
    -- upvalues: u6350 (val), imported (val), u6015 (ref), Fust (val), u6344 (val), clean (val), u6254 (val)
    -- upvalues: u6349 (val), liveParts (val), cluster (val)
    -- types: a1: string
    local v1 = if a2.kind ~= "backpack" then
        if a2.kind ~= "wear" then
            if a2.kind ~= "deployable" then
                if a2.kind ~= "tool" then
                    if a2.kind ~= "ammo" then
                        if a2.kind ~= "building" then "pile" else "upright"
                    else
                        if not u6350[a1] then "arrow" else "rounds"
                else
                    if a2.weapon ~= "gun" then
                        if a2.weapon ~= "throw" then "tool" else "pile"
                    else
                        "gun"
            else
                "deploy"
        else
            "wear"
    else
        "pack"
    local icon = a2.icon
    local v2 = imported(if type(icon) ~= "string" or icon == "" or string.find(icon, "rbxasset", 1, true) then if type(a2.model) ~= "string" then nil else a2.model else icon)

    if not v2 then
        if v1 == "wear" then
            if u6015 == nil then
                local Wear = Fust:FindFirstChild("Wear")

                if Wear and Wear:IsA("ModuleScript") then
                    local success, err = pcall(require, Wear)
                    u6015 = if not success then false else if type(err) ~= "table" then false else err
                end
            end

            local v3 = u6015 or nil
            v2 = if not v3 then
                nil
            else
                if type(v3.BuildPreview) ~= "function" then
                    nil
                else
                    v3.BuildPreview(a1, u6344.Defs)

            if v2 then
                clean(v2)
            end
        elseif v1 == "deploy" then
            v2 = u6254.deploy(if type(a2.deploy) ~= "string" then a1 else a2.deploy)
        elseif v1 == "tool" then
            v2 = u6254.tool(a1)
        elseif v1 == "gun" then
            v2 = u6254.gun(a1)
        end

        if not v2 then
            if a2.kind == "food" or u6254.EXTRA[a1] then
                v2 = u6254.food(a1)
            end
        end

        if not v2 and a2.kind == "attachment" and type(a2.model) == "string" then
            local success_2, err_2 = pcall(function() -- Line: 1438; upvalues: Fust (upval), a2 (val)
                local Attachments = Fust:FindFirstChild("Attachments")
                local v1 = if not Attachments then
                    nil
                else
                    if not Attachments:IsA("ModuleScript") then nil else require(Attachments)

                if v1 and type(v1.Template) == "function" then
                    return (v1.Template(a2.model))
                end

                return nil
            end)

            if success_2 and typeof(err_2) == "Instance" and err_2:IsA("Model") then
                local v4 = err_2:Clone()
                v2 = if not (#clean(v4) > 0) then nil else v4
            end
        end
    end

    if not v2 then
        return nil, v1
    end

    if v1 == "pack" then
        local Harness = v2:FindFirstChild("Harness", true)

        if Harness then
            Harness:Destroy()
        end
    end

    local rot = u6349[v1].rot

    if rot ~= CFrame.identity then
        for i, v in ipairs((liveParts(v2))) do
            v.CFrame = rot * v.CFrame
        end
    end

    if v1 == "rounds" then
        v2 = cluster(v2, u6350[a1] or 1)
    end

    return v2, v1
end

local u6024 = {}

function u6346.Get(a1)
    -- Line: 1469
    -- upvalues: u6024 (val), u6344 (val), build (val), liveParts (val), u6349 (val), u6346 (val), corners (val)
    -- types: a1: string?
    if type(a1) ~= "string" then
        return nil
    end

    local v1 = u6024[a1]

    if v1 ~= nil then
        return v1 or nil
    end

    v1 = u6344.Defs[a1]

    if not v1 then
        return nil
    end

    local success, err, v2 = pcall(build, a1, v1)

    if success and err then
        local v3 = liveParts(err)

        if #v3 == 0 then
            err:Destroy()

            u6024[a1] = false

            return nil
        end

        local pile = u6349[v2] or u6349.pile
        local Unit = pile.dir.Unit
        local v4 = CFrame.lookAt(Vector3.new(0, 0, 0), -Unit)
        local v5, v6 = u6346._fit(corners(v3), Unit, v4.RightVector, v4.UpVector, 0.85, u6346.FOV)
        v4 = {model = err, camCF = CFrame.lookAt(v5 + Unit * v6, v5), style = v2}
        u6024[a1] = v4

        return v4
    end

    if not success then
        warn("[Fust] ItemIcons: icon for", a1, "failed:", err)
    end

    if game:IsLoaded() then
        u6024[a1] = false
    end

    return nil
end

function u6346.WorldModel(a1) -- Line: 1507; upvalues: u6346 (val), u6349 (val), liveParts (val); types: a1: string?
    local v1 = u6346.Get(a1)

    if not v1 then
        return nil, nil
    end

    local style = v1.style
    local v2 = v1.model:Clone()
    v1 = if type(style) ~= "string" then nil else u6349[style]

    if v1 and style ~= "rounds" then
        local v3 = v1.rot:Inverse()

        if v3 ~= CFrame.identity then
            for i, v in ipairs((liveParts(v2))) do
                v.CFrame = v3 * v.CFrame
            end
        end
    end

    return v2, style
end

local u6066 = false

if game:GetService("RunService"):IsClient() then
    local Config = Fust:FindFirstChild("Config")

    if not Config then
        Config = Fust:WaitForChild("Config", 10)
    end

    local success, err = pcall(function() -- Line: 1543; upvalues: Config (val)
        if Config and Config:IsA("ModuleScript") then
            return (require(Config))
        end

        return nil
    end)

    if success then
        v19 = err

        if type(v19) == "table" then
            local P134_2 = if type(err.P134) ~= "table" then {} else err.P134
            v19 = false

            if err.POLISH_134 ~= false then
                v19 = P134_2.lazyIcons ~= false
            end

            u6066 = v19
        end
    end
end

local u6067 = {}
local u6068 = {}
local u6069 = false
local u6070 = 0
local u6071 = nil

local function lazyMarkDirty() -- Line: 1570; upvalues: u6069 (ref)
    u6069 = true
end

local function lazyWatchAdd(a1) -- Line: 1576; upvalues: u6068 (val), lazyMarkDirty (val); types: a1: userdata
    local v1 = u6068[a1]

    if v1 then
        v1.n = v1.n + 1
        return
    end

    v1 = {}

    if not a1:IsA("LayerCollector") then
        table.insert(v1, ((a1:GetPropertyChangedSignal("Visible")):Connect(lazyMarkDirty)))

        if a1:IsA("ScrollingFrame") then
            table.insert(v1, ((a1:GetPropertyChangedSignal("CanvasPosition")):Connect(lazyMarkDirty)))
        end
    else
        table.insert(v1, ((a1:GetPropertyChangedSignal("Enabled")):Connect(lazyMarkDirty)))
    end

    u6068[a1] = {n = 1, conns = v1}
end

local function lazyWatchRemove(a1) -- Line: 1594; upvalues: u6068 (val); types: a1: userdata
    local v1 = u6068[a1]

    if not v1 then
        return
    end

    v1.n = v1.n - 1

    if v1.n <= 0 then
        for i, v in ipairs(v1.conns) do
            v:Disconnect()
        end

        u6068[a1] = nil
    end
end

local function lazyChainOf(a1) -- Line: 1608; types: a1: userdata
    local v1 = {}
    local v2 = {}
    local Parent = a1

    while Parent do
        if Parent == game then
            break
        end

        if Parent:IsA("LayerCollector") then
            table.insert(v1, Parent)
            return v1, v2
        end

        if Parent:IsA("GuiObject") then
            table.insert(v1, Parent)

            if Parent ~= a1 and Parent:IsA("ScrollingFrame") then
                table.insert(v2, Parent)
            end
        end

        Parent = Parent.Parent
    end

    return v1, v2
end

local function lazySetWatching(a1, a2)
    -- Line: 1626
    -- upvalues: lazyWatchAdd (val), lazyWatchRemove (val)
    -- types: a1: table, a2: boolean
    if a1.watching == a2 then
        return
    end

    a1.watching = a2

    for i, v in ipairs(a1.chain) do
        if not a2 then
            lazyWatchRemove(v)
        else
            lazyWatchAdd(v)
        end
    end
end

local function lazyRechain(a1)
    -- Line: 1640
    -- upvalues: lazyWatchRemove (val), lazyChainOf (val), lazySetWatching (val)
    -- types: a1: table
    local watching = a1.watching

    if a1.watching ~= false then
        a1.watching = false

        for i, v in ipairs(a1.chain) do
            lazyWatchRemove(v)
        end
    end

    local v1, v2 = lazyChainOf(a1.view)
    a1.chain = v1
    a1.clips = v2

    lazySetWatching(a1, watching)
end

function lazyShown(a1, a2) -- Line: 1648; upvalues: lazyShown (val); types: a1: userdata?, a2: table
    if a1 ~= nil and a1 ~= game then
        local v1
        local v2 = a2[a1]

        if v2 ~= nil then
            return v2
        end

        if a1:IsA("GuiObject") then
            v1 = a1.Visible and lazyShown(a1.Parent, a2)
        elseif not a1:IsA("LayerCollector") then
            v1 = lazyShown(a1.Parent, a2)
        else
            local Enabled = a1.Enabled

            if Enabled then
                Enabled = true

                if a1:FindFirstAncestorWhichIsA("PlayerGui") == nil then
                    Enabled = a1:IsDescendantOf(workspace)
                end
            end

            v1 = Enabled
        end

        a2[a1] = v1

        return v1
    end

    return false
end

local function lazyInView(a1, a2) -- Line: 1668; upvalues: lazyShown (val); types: a1: table, a2: table
    local AbsolutePosition, AbsoluteSize, X, Y, v1, v2
    local view = a1.view

    if not lazyShown(view, a2) then
        return false
    end

    if #a1.clips == 0 then
        return true
    end

    local AbsolutePosition_2 = view.AbsolutePosition
    local AbsoluteSize_2 = view.AbsoluteSize

    for i, v in ipairs(a1.clips) do
        AbsolutePosition = v.AbsolutePosition
        AbsoluteSize = v.AbsoluteSize
        v1 = AbsoluteSize.X * 0.5
        v2 = AbsoluteSize.Y * 0.5

        if not (AbsolutePosition_2.X + AbsoluteSize_2.X < AbsolutePosition.X - v1) then
            X = AbsolutePosition_2.X

            if not (AbsolutePosition.X + AbsoluteSize.X + v1 < X)
                and not (AbsolutePosition_2.Y + AbsoluteSize_2.Y < AbsolutePosition.Y - v2) then
                Y = AbsolutePosition_2.Y

                if not (AbsolutePosition.Y + AbsoluteSize.Y + v2 < Y) then
                    continue
                end
            end
        end

        return false
    end

    return true
end

local function lazyBuild(a1) -- Line: 1687; upvalues: u6346 (val), lazyWatchRemove (val); types: a1: table
    local view = a1.view
    view:ClearAllChildren()

    local Camera = Instance.new("Camera")
    Camera.FieldOfView = u6346.FOV
    Camera.CFrame = a1.icon.camCF
    Camera.Parent = view
    view.CurrentCamera = Camera
    a1.icon.model:Clone().Parent = view
    a1.built = true
    a1.hiddenAt = nil

    if a1.watching == false then
        return
    end

    a1.watching = false

    for i, v in ipairs(a1.chain) do
        lazyWatchRemove(v)
    end
end

local function lazyRelease(a1) -- Line: 1701; upvalues: lazyWatchAdd (val); types: a1: table
    a1.view:ClearAllChildren()

    a1.view.CurrentCamera = nil
    a1.built = false
    a1.hiddenAt = nil

    if a1.watching == true then
        return
    end

    a1.watching = true

    for i, v in ipairs(a1.chain) do
        lazyWatchAdd(v)
    end
end

local function lazyForget(a1) -- Line: 1709; upvalues: u6067 (val), lazyWatchRemove (val); types: a1: userdata
    local v1 = u6067[a1]

    if not v1 then
        return
    end

    u6067[a1] = nil

    if v1.watching ~= false then
        v1.watching = false

        for i, v in ipairs(v1.chain) do
            lazyWatchRemove(v)
        end
    end

    for i2, i3 in ipairs(v1.conns) do
        i3:Disconnect()
    end
end

local function lazyPass(a1)
    -- Line: 1723
    -- upvalues: u6067 (val), lazyInView (val), lazyWatchAdd (val), lazyBuild (val)
    -- types: a1: boolean
    local v1
    local v2 = {}
    local v3 = os.clock()

    for k, v in pairs(u6067) do
        if not v.built then
            v1 = lazyInView(v, v2)

            if not v.built then
                if v1 then
                    lazyBuild(v)
                end
            elseif v1 then
                v.hiddenAt = nil
            elseif not v.hiddenAt then
                v.hiddenAt = v3
            elseif 10 <= v3 - v.hiddenAt then
                v.view:ClearAllChildren()

                v.view.CurrentCamera = nil
                v.built = false
                v.hiddenAt = nil

                if v.watching ~= true then
                    v.watching = true

                    for i, i2 in ipairs(v.chain) do
                        lazyWatchAdd(i2)
                    end
                end
            end
        elseif a1 then
            v1 = lazyInView(v, v2)

            if not v.built then
                if v1 then
                    lazyBuild(v)
                end
            elseif v1 then
                v.hiddenAt = nil
            elseif not v.hiddenAt then
                v.hiddenAt = v3
            elseif 10 <= v3 - v.hiddenAt then
                v.view:ClearAllChildren()

                v.view.CurrentCamera = nil
                v.built = false
                v.hiddenAt = nil

                if v.watching ~= true then
                    v.watching = true

                    for i3, j in ipairs(v.chain) do
                        lazyWatchAdd(j)
                    end
                end
            end
        end
    end
end

local function lazyEnsureLoop() -- Line: 1745; upvalues: u6071 (ref), u6070 (ref), u6069 (ref), lazyPass (val)
    if u6071 then
        return
    end

    u6071 = (game:GetService("RunService")).RenderStepped:Connect(function(a1)
        -- Line: 1749
        -- upvalues: u6070 (upval), u6069 (upval), lazyPass (upval)
        -- types: a1: number
        u6070 = u6070 + a1

        if u6070 >= 0.25 then
            u6070 = 0
            u6069 = false

            lazyPass(true)

            return
        end

        if u6069 then
            u6069 = false
            lazyPass(false)
        end
    end)
end

local function lazyTrack(a1, a2)
    -- Line: 1763
    -- upvalues: u6067 (val), lazyChainOf (val), lazyWatchRemove (val), lazySetWatching (val), u6069 (ref)
    -- upvalues: lazyForget (val), u6071 (ref), u6070 (ref), lazyPass (val), lazyInView (val), lazyBuild (val)
    -- upvalues: lazyWatchAdd (val)
    -- types: a1: userdata, a2: table
    local v1
    local v2 = u6067[a1]

    if not v2 then
        local v3
        v1, v3 = lazyChainOf(a1)
        local u8 = {
            built = false,
            watching = false,
            view = a1,
            icon = a2,
            chain = v1,
            clips = v3,
        }
        u8.conns = {}
        v2 = u8
        u6067[a1] = u8

        table.insert(
            u8.conns,
            (a1.AncestryChanged:Connect(function()
                -- Line: 1770
                -- upvalues: u6067 (upval), a1 (val), u8 (val), lazyWatchRemove (upval), lazyChainOf (upval)
                -- upvalues: lazySetWatching (upval), u6069 (upval)
                local v1 = u6067[a1]

                if v1 == u8 then
                    v1 = u8
                    local watching = v1.watching

                    if v1.watching ~= false then
                        v1.watching = false

                        for i, v in ipairs(v1.chain) do
                            lazyWatchRemove(v)
                        end
                    end

                    local v2, v3 = lazyChainOf(v1.view)
                    v1.chain = v2
                    v1.clips = v3

                    lazySetWatching(v1, watching)

                    u6069 = true
                end
            end))
        )

        table.insert(
            u8.conns,
            (a1.Destroying:Connect(function() -- Line: 1776; upvalues: lazyForget (upval), a1 (val)
                lazyForget(a1)
            end))
        )

        if not u6071 then
            u6071 = (game:GetService("RunService")).RenderStepped:Connect(function(a1)
                -- Line: 1749
                -- upvalues: u6070 (upval), u6069 (upval), lazyPass (upval)
                -- types: a1: number
                u6070 = u6070 + a1

                if u6070 >= 0.25 then
                    u6070 = 0
                    u6069 = false

                    lazyPass(true)

                    return
                end

                if u6069 then
                    u6069 = false
                    lazyPass(false)
                end
            end)
        end
    end

    v1 = v2
    v1.icon = a2
    v1.built = false
    v1.hiddenAt = nil

    if lazyInView(
        v1,
        {}
    ) then
        lazyBuild(v1)
        return
    end

    if v1.watching == true then
        return
    end

    v1.watching = true

    for i, v in ipairs(v1.chain) do
        lazyWatchAdd(v)
    end
end

function u6346._lazyStats() -- Line: 1793; upvalues: u6067 (val)
    local v1 = 0
    local v2 = 0

    for k, v in pairs(u6067) do
        v1 = v1 + 1

        if v.built then
            v2 = v2 + 1
        end
    end

    return v1, v2
end

function u6346.Apply(a1, a2)
    -- Line: 1805
    -- upvalues: u6346 (val), u6066 (ref), lazyForget (val), lazyTrack (val)
    -- types: a1: userdata, a2: string?
    a1:ClearAllChildren()

    a1.CurrentCamera = nil
    local v1 = u6346.Get(a2)

    if not v1 then
        if u6066 then
            lazyForget(a1)
        end

        a1.Visible = false

        return false
    end

    if u6066 then
        a1.Visible = true
        lazyTrack(a1, v1)

        return true
    end

    local Camera = Instance.new("Camera")
    Camera.FieldOfView = u6346.FOV
    Camera.CFrame = v1.camCF
    Camera.Parent = a1
    a1.CurrentCamera = Camera
    v1.model:Clone().Parent = a1
    a1.Visible = true

    return true
end

function u6346.Abbr(a1) -- Line: 1832; upvalues: u6351 (val), u6344 (val); types: a1: string
    if u6351[a1] then
        return u6351[a1]
    end

    local v1 = u6344.Defs[a1]
    local v2 = ""
    local gmatch = string.gmatch

    for i in gmatch(v1 and v1.name or a1, "%a+") do
        v2 = v2 .. string.upper((string.sub(i, 1, 1)))
    end

    return (string.sub(if v2 == "" then string.upper(a1) else v2, 1, 3))
end

function u6346.Color(a1) -- Line: 1844; upvalues: u6344 (val), u6352 (val); types: a1: string
    local v1 = u6344.Defs[a1]

    if v1 and typeof(v1.color) == "Color3" then
        return v1.color
    end

    return u6352
end

function u6346.NewView(a1) -- Line: 1849; types: a1: table?
    local ViewportFrame = Instance.new("ViewportFrame")
    ViewportFrame.Name = "View"
    ViewportFrame.BackgroundTransparency = 1
    ViewportFrame.BorderSizePixel = 0
    ViewportFrame.Ambient = Color3.fromRGB(150, 145, 138)
    ViewportFrame.LightColor = Color3.fromRGB(255, 244, 226)
    ViewportFrame.LightDirection = Vector3.new(-1, -1.399999976158142, -0.6000000238418579)
    ViewportFrame.Visible = false
    local v1 = nil

    if a1 then
        for k, v in pairs(a1) do
            if k ~= "Parent" then
                ViewportFrame[k] = v
            else
                v1 = v
            end
        end
    end

    ViewportFrame.Parent = v1

    return ViewportFrame
end

return u6346
