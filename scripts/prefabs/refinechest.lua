require "prefabutil"
local refinerecipe = require "refinerecipe"

local assets = {

	Asset("ANIM", "anim/refinechest.zip"),
	Asset("ANIM", "anim/chest_meter.zip"),
}

local function RefineItems(inst, item)

	if item and refinerecipe[item.prefab] then
		if item.components.stackable then
			if item.components.stackable:StackSize() >= refinerecipe[item.prefab].stacksize then
				for i = 1, refinerecipe[item.prefab].returnamount do
					inst.components.container:GiveItem(SpawnPrefab(refinerecipe[item.prefab].newitem), 2)
				end
				if item.components.stackable:StackSize() == refinerecipe[item.prefab].stacksize then
					inst.components.container:RemoveItemBySlot(1)
					inst.components.machine:TurnOff()
					inst.AnimState:PlayAnimation("idle")
				else
					item.components.stackable:SetStackSize(item.components.stackable:StackSize() - refinerecipe[item.prefab].stacksize)
					if item.components.stackable:StackSize() < refinerecipe[item.prefab].stacksize then
						inst.components.machine:TurnOff()
						inst.AnimState:PlayAnimation("idle")
					end
				end
			else
			inst.components.machine:TurnOff()
			inst.AnimState:PlayAnimation("idle")
			end
		else
			for i = 1, refinerecipe[item.prefab].returnamount do
				inst.components.container:GiveItem(SpawnPrefab(refinerecipe[item.prefab].newitem), 2)
			end
			inst.components.container:RemoveItemBySlot(1)
			inst.components.machine:TurnOff()
			inst.AnimState:PlayAnimation("idle")
		end
	else
		inst.components.machine:TurnOff()
		inst.AnimState:PlayAnimation("idle")
	end
end

local function onbuilt(inst)

	inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end


local function onopen(inst)

        inst.AnimState:PlayAnimation("open", false)
		inst.AnimState:PushAnimation("opened", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
		
		inst.components.machine:TurnOff()
end 

local function onclose(inst)

        inst.AnimState:PlayAnimation("close", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)

    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
		inst.AnimState:PlayAnimation("hit")
    end
end

local function TurnOn(inst)

	inst.on = true
	
	if inst.components.container:IsOpen() then
		inst.components.container:Close()
	end
	
	if TUNING.REFINECHESTFUEL then
		inst.components.fueled:StartConsuming()
	end
	inst.AnimState:PushAnimation("work", true)
	local item = inst.components.container:GetItemInSlot(1)
	inst.taskrefine = inst:DoPeriodicTask(1, RefineItems, nil, item)
end

local function TurnOff(inst)

    inst.on = false
	inst.AnimState:PlayAnimation("idle", false)

	if TUNING.REFINECHESTFUEL then
		inst.components.fueled:StopConsuming()
	end
	
	if inst.taskrefine ~= nil then
		inst.taskrefine:Cancel()
		inst.taskrefine = nil
	end
end

local function CanInteract(inst)

	if TUNING.REFINECHESTFUEL then
		return not inst.components.fueled:IsEmpty()
	else
		return true
	end
end

local function OnFuelEmpty(inst)

    inst.components.machine:TurnOff()
	inst.AnimState:PlayAnimation("idle")
end

local function OnAddFuel(inst)

	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
end

local function OnFuelSectionChange(new, old, inst)

    if inst._fuellevel ~= new then
		inst._fuellevel = new
		if inst._fuellevel == 10 then
			inst.AnimState:ClearOverrideSymbol("swap_meter")
		else
			inst.AnimState:OverrideSymbol("swap_meter", "chest_meter", tostring(new))
		end

    end
end

    local function init()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        --inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        --inst.MiniMapEntity:SetIcon(name..".png")

        inst:AddTag("structure")
        inst:AddTag("chest")

        inst.AnimState:SetBank("refinechest")
        inst.AnimState:SetBuild("refinechest")
        inst.AnimState:PlayAnimation("idle")
		inst.AnimState:OverrideSymbol("swap_meter", "chest_meter", "10")

	
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
		
        inst:AddComponent("container")
        inst.components.container:WidgetSetup("refinechest")
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose
		
		inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)
		
		inst:AddComponent("machine")
		inst.components.machine.turnonfn = TurnOn
		inst.components.machine.turnofffn = TurnOff
		inst.components.machine.caninteractfn = CanInteract
		inst.components.machine.cooldowntime = 0.5
		
		if TUNING.REFINECHESTFUEL then
		inst:AddComponent("fueled")
		inst.components.fueled:SetDepletedFn(OnFuelEmpty)
		inst.components.fueled:SetTakeFuelFn(OnAddFuel)
		inst.components.fueled.accepting = true
		inst.components.fueled:SetSections(10)
		inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
		inst.components.fueled:InitializeFuelLevel(1000)
		inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL
		inst.components.fueled.rate = 50
		end
		
        inst:ListenForEvent("onbuilt", onbuilt)
		
        return inst
    end

    return Prefab("common/refinechest", init, assets),
		MakePlacer("common/refinechest_placer", "refinechest", "refinechest", "idle")