require "prefabutil"

local assets = {

	Asset("ANIM", "anim/repairchest.zip"),
	Asset("ANIM", "anim/chest_meter.zip"),
}

local repairspeed = .01

local function RepairItems(inst)

	local item = inst.components.container:FindItem(function(v) return (v.components.armor and v.components.armor:GetPercent() < 1) or (v.components.finiteuses and v.components.finiteuses:GetPercent() < 1) or (v.components.fueled and v.components.fueled:GetPercent() < 1) end)
	if item then
		if item.components.armor and item.components.armor:GetPercent() < 1 then
			item.components.armor:SetPercent(item.components.armor:GetPercent() + repairspeed)
			inst.AnimState:PlayAnimation("work", false)
			if TUNING.REPAIRCHESTFUEL then 
				inst.components.fueled:DoDelta(-10)
			end
		elseif item.components.fueled and item.components.fueled:GetPercent() < 1 then
				TheNet:SystemMessage("Fueling", false)
				item.components.fueled:StopConsuming()
				item.components.fueled:DoDelta(repairspeed * 180)
				TheNet:SystemMessage(item.components.fueled:GetPercent(), false)
				inst.AnimState:PlayAnimation("work", false)
				if TUNING.REPAIRCHESTFUEL then 
					inst.components.fueled:DoDelta(-10)
				end
		elseif item.components.finiteuses then
				if item.components.finiteuses:GetPercent() < 1 - repairspeed then
					item.components.finiteuses:SetPercent(item.components.finiteuses:GetPercent() + repairspeed)
					inst.AnimState:PlayAnimation("work", false)
					if TUNING.REPAIRCHESTFUEL then
						inst.components.fueled:DoDelta(-10)
					end
				else
					item.components.finiteuses:SetPercent(1)
					inst.AnimState:PlayAnimation("work", false)
					if TUNING.REPAIRCHESTFUEL then
						inst.components.fueled:DoDelta(-10)
					end
				end					
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
    
	inst.components.machine:TurnOff()
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
		
end 

local function onclose(inst)

    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		
	if not TUNING.REPAIRCHESTFUEL then
		inst.components.machine:TurnOn()
	end
    
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

	if inst.components.container:IsOpen() then
		inst.components.container:Close()
	end

	inst.on = true    
	inst.taskrepair = inst:DoPeriodicTask(1, RepairItems, nil)
end

local function TurnOff(inst)

    inst.on = false
	inst.AnimState:PlayAnimation("idle", false)

	if TUNING.REPAIRCHESTFUEL then
		inst.components.fueled:StopConsuming()
	end

	if inst.taskrepair ~= nil then
		inst.taskrepair:Cancel()
		inst.taskrepair = nil
	end
end

local function CanInteract(inst)
    
	if TUNING.REPAIRCHESTFUEL then
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

        inst.AnimState:SetBank("repairchest")
        inst.AnimState:SetBuild("repairchest")
        inst.AnimState:PlayAnimation("idle")
		inst.AnimState:OverrideSymbol("swap_meter", "chest_meter", "10")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
		
        inst:AddComponent("container")
        inst.components.container:WidgetSetup("repairchest")
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
		
		if TUNING.REPAIRCHESTFUEL then
		inst:AddComponent("fueled")
		inst.components.fueled:SetDepletedFn(OnFuelEmpty)
		inst.components.fueled:SetTakeFuelFn(OnAddFuel)
		inst.components.fueled.accepting = true
		inst.components.fueled:SetSections(10)
		inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
		inst.components.fueled:InitializeFuelLevel(500)
		inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL
		inst.components.fueled.rate = 25
		end

        inst:ListenForEvent("onbuilt", onbuilt)

        return inst
    end

    return Prefab("common/repairchest", init, assets),
	MakePlacer("common/repairchest_placer", "repairchest", "repairchest", "idle")