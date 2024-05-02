name = "Refinery & Repair Chest"
description = "Container that auto refines items and Chest that repairs your tools"
author = "Wolf_EX"
version = "1.5.3"
api_version = 10
forumthread = ""

dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

all_clients_require_mod = true

server_filter_tags = {
"item", "container",
}

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
	{
		name = "repairchestfuel",
		label = "Repair Chest Fueled",
		hover = "Whether the repair chest needs fuel to work",
		options =
		{
			{description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true
	},
	{
		name = "refinechestfuel",
		label = "Refinery Fueled",
		hover = "Whether the refinery needs fuel to work",
		options =
		{
			{description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true
	},
	{
		name = "repairchestitems",
		label = "Repair Chest Items",
		hover = "What type of items can be repaired",
		options =
		{
			{description = "Armor and Weapons", data = 0},
			{description = "Armor, Weapons, Tools", data = 1},
		},
		default = 1
	},
}