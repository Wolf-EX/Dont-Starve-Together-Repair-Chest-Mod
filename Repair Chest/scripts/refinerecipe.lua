local itemstat = {
	log = {
		stacksize = 4,
		newitem = "boards",
		returnamount = 1,
	},
	boards = {
		stacksize = 1,
		newitem = "log",
		returnamount = 4,
	},
	cutgrass = {
		stacksize = 3,
		newitem = "rope",
		returnamount = 1,
	},
	rope = {
		stacksize = 1,
		newitem = "cutgrass",
		returnamount = 3,
	},
	rocks = {
		stacksize = 3,
		newitem = "cutstone",
		returnamount = 1,
	},
	cutstone = {
		stacksize = 1,
		newitem = "rocks",
		returnamount = 3,
	},
	cutreeds = {
		stacksize = 4,
		newitem = "papyrus",
		returnamount = 1,
	},
	papyrus = {
		stacksize = 1,
		newitem = "cutreeds",
		returnamount = 4,
	},
	petals_evil = {
		stacksize = 4,
		newitem = "nightmarefuel",
		returnamount = 1,
	},
	nightmarefuel = {
		stacksize = 1,
		newitem = "petals_evil",
		returnamount = 4,
	},
	moonrocknugget = {
		stacksize = 3,
		newitem = "moonrockcrater",
		returnamount = 1,
	},
	moonrockcrater = {
		stacksize = 1,
		newitem = "moonrocknugget",
		returnamount = 3,
	},
	marble = {
		stacksize = 1,
		newitem = "marblebean",
		returnamount = 1,
	},
	marblebean = {
		stacksize = 1,
		newitem = "marble",
		returnamount = 1,
	},
	honeycomb = {
		stacksize = 1,
		newitem = "beeswax",
		returnamount = 1,
	},
	beeswax = {
		stacksize = 1,
		newitem = "honeycomb",
		returnamount = 1,
	},
}
return itemstat