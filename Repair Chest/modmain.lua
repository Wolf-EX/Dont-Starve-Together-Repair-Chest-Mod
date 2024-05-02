local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local STRINGS = GLOBAL.STRINGS
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local containers = require "containers"
local refinerecipe = require "refinerecipe"


PrefabFiles = {

	"repairchest",
	"refinechest",
}

Assets = {

	Asset("ANIM", "anim/ui_chest_3x2.zip"),
	Asset("ANIM", "anim/ui_chest_3x1.zip"),
	
	Asset("ATLAS", "images/inventoryimages/refinery.xml"),
	Asset("IMAGE", "images/inventoryimages/refinery.tex"),
}

if GetModConfigData("repairchestitems") == 0 then

repairprefabs = {

"armor_dragonfly",
"armor_grass",
"armor_marble",
"armor_ruins",
"armor_sanity",
"armor_snurtleshell",
"armor_wood",
"armorskeleton",
"batbat",
"boomerang",
"hambat",
"nightsword",
"spear",
"spear_wathgrithr",
"icestaff",
"firestaff",
"telestaff",
"orangestaff",
"opalstaff",
"tentaclespike",
"whip",
"beehat",
"footballhat",
"slurtlehat",
"ruinshat",
"wathgrithrhat",
"hivehat",
"skeletonhat",
"glasscutter",
"trident",
} else

repairprefabs = {

"axe",
"goldenaxe",
"moonglassaxe",
"pickaxe",
"goldenpickaxe",
"shovel",
"goldenshovel",
"pitchfork",
"hammer",
"razor",
"batbat",
"boomerang",
"hambat",
"nightsword",
"spear",
"spear_wathgrithr",
"icestaff",
"firestaff",
"telestaff",
"orangestaff",
"opalstaff",
"tentaclespike",
"whip",
"armor_dragonfly",
"armor_grass",
"armor_marble",
"armor_ruins",
"armor_sanity",
"armor_snurtleshell",
"armor_wood",
"armorskeleton",
"beehat",
"footballhat",
"slurtlehat",
"ruinshat",
"wathgrithrhat",
"hivehat",
"skeletonhat",
"farm_hoe",
"golden_farm_hoe",
"fishingrod",
"nightstick",
"amulet",
"blueamulet",
"purpleamulet",
"glasscutter",
"trident",
"moonglassaxe",
"brush",
"oar",
"oar_driftwood",
"bugnet",
"torch",
} end

--strings
STRINGS.NAMES.REPAIRCHEST = "Repair Chest"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.REPAIRCHEST = "It can repair all my weapons!"

STRINGS.NAMES.REFINECHEST = "Refinery"
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.REFINECHEST = ""

--recipes
AddRecipe("repairchest", {Ingredient("gears", 2), Ingredient("boards", 6), Ingredient("transistor", 2), Ingredient("hammer", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "repairchest_placer", nil, nil, nil, nil, "images/inventoryimages/refinery.xml", "refinery.tex")
AddRecipe("refinechest", {Ingredient("gears", 1), Ingredient("boards", 2), Ingredient("transistor", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "refinechest_placer", nil, nil, nil, nil,"images/inventoryimages/refinery.xml", "refinery.tex")

--configurations
TUNING.REPAIRCHESTFUEL = GetModConfigData("repairchestfuel")
TUNING.REFINECHESTFUEL = GetModConfigData("refinechestfuel")

--containers

--repair chest
local params = {}

params.repairchest =
{
	widget =
	{
		slotpos ={},
		animbank = "ui_chest_3x2",
        animbuild = "ui_chest_3x2",
		pos = GLOBAL.Vector3(0, 200, 0),
        side_align_tip = 160,
	},
	type = "chest",
}

for y = 1, 0, -1 do
	for x = 0, 2 do
		table.insert(params.repairchest.widget.slotpos, GLOBAL.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
	end
end

function params.repairchest.itemtestfn(container, item, slot)

	for _,i in ipairs(repairprefabs) do
		if item.prefab == i then return true end
	end
end

containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.repairchest.widget.slotpos ~= nil and #params.repairchest.widget.slotpos or 0)

--refine chest
params.refinechest = 
{
	widget = 
	{
		slotpos =
		{
			Vector3(-72, 0, 0),
			Vector3(72, 0, 0), 
		},
		animbank = "ui_chest_3x1",
        animbuild = "ui_chest_3x1",
		pos = GLOBAL.Vector3(0, 200, 0),
        side_align_tip = 160,
--[[
		buttoninfo =
        {
            text = "Refine",
            position = Vector3(0, -100, 0),
        },
]]
	},
	type = "chest",
}

function params.refinechest.itemtestfn(container, item, slot)

	return refinerecipe[item.prefab] and (slot == 1 or slot == 2 and container.inst.on)
end

--[[
function params.refinechest.widget.buttoninfo.fn(container, inst, doer)
    if REFINECHESTFUEL then
		if not container.inst.components.fueled:IsEmpty() then container.inst.components.machine:TurnOn() end
	else
		container.inst.components.machine:TurnOn()
	end
end
]]

containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.refinechest.widget.slotpos ~= nil and #params.refinechest.widget.slotpos or 0)

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data)
    end
end