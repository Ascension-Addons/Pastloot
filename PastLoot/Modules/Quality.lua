local PastLoot = LibStub("AceAddon-3.0"):GetAddon("PastLoot")
local L = LibStub("AceLocale-3.0"):GetLocale("PastLoot")
--[[
Checklist if creating a new module
- first choose an existing module that most closely matches what you want to do
- modify module_key, module_name, module_tooltip to unique values
- make sure to update locales
- Modify SetMatch and GetMatch
- Create/Modify local functions as needed
]]
local module_key = "Quality"
local module_name = L["Quality"]
local module_tooltip = L["Selected rule will only match this quality of items."]

local module = PastLoot:NewModule(module_name)

module.Choices = {
	L["Any"],
	ITEM_QUALITY_COLORS[0].hex .. ITEM_QUALITY0_DESC .. "|r", --Poor
	ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC .. "|r", --Common
	ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC .. "|r", --Uncommon
	ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC .. "|r", --Rare
	ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC .. "|r", --Epic
	ITEM_QUALITY_COLORS[5].hex .. ITEM_QUALITY5_DESC .. "|r", --Legendary
	ITEM_QUALITY_COLORS[6].hex .. ITEM_QUALITY6_DESC .. "|r", --Artifact
	ITEM_QUALITY_COLORS[7].hex .. ITEM_QUALITY7_DESC .. "|r" -- Vanity
}
module.ConfigOptions_RuleDefaults = {
	-- { VariableName, Default },
	{
		module_key,
		-- {
		-- [1] = { Value, Exception }
		-- },
	},
}
module.NewFilterValue = 1

function module:OnEnable()
	self:RegisterDefaultVariables(self.ConfigOptions_RuleDefaults)
	self:AddWidget(self.Widget)
end

function module:OnDisable()
	self:UnregisterDefaultVariables()
	self:RemoveWidgets()
end

function module:CreateWidget()
	local frame_name = "PastLoot_Frames_Widgets_Quality"
	return PastLoot:CreateSimpleDropdown(self, module_name, frame_name, module_tooltip)
end

module.Widget = module:CreateWidget()

-- Local function to get the data or return an empty table if no data found
function module.Widget:GetData(RuleNum)
	return module:GetConfigOption(module_key, RuleNum) or {}
end

function module.Widget:GetNumFilters(RuleNum)
	local Value = self:GetData(RuleNum)
	return #Value
end

function module.Widget:AddNewFilter()
	local Value = self:GetData()
	table.insert(Value, { module.NewFilterValue, false })
	module:SetConfigOption(module_key, Value)
end

function module.Widget:RemoveFilter(Index)
	local Value = self:GetData()
	table.remove(Value, Index)
	if (#Value == 0) then
		Value = nil
	end
	module:SetConfigOption(module_key, Value)
end

function module.Widget:DisplayWidget(Index)
	if (Index) then
		module.FilterIndex = Index
	end
	local Value = self:GetData()
	UIDropDownMenu_SetText(module.Widget, module.Choices[Value[module.FilterIndex][1]])
end

function module.Widget:GetFilterText(Index)
	local Value = self:GetData()
	return module.Choices[Value[Index][1]]
end

function module.Widget:IsException(RuleNum, Index)
	local Data = self:GetData(RuleNum)
	return Data[Index][2]
end

function module.Widget:SetException(RuleNum, Index, Value)
	local Data = self:GetData(RuleNum)
	Data[Index][2] = Value
	module:SetConfigOption(module_key, Data)
end

function module.Widget:SetMatch(itemObj, Tooltip)
	module.CurrentMatch = itemObj.quality
	module:Debug("Quality Type: " .. (Quality or "nil"))
end

function module.Widget:GetMatch(RuleNum, Index)
	local RuleValue = self:GetData(RuleNum)
	if (RuleValue[Index][1] > 1) then
		if (RuleValue[Index][1] - 2 ~= tonumber(module.CurrentMatch)) then
			return false
		end
	end
	return true
end

function module:DropDown_Init(Frame, Level)
	Level = Level or 1
	local info = {}
	info.checked = false
	info.notCheckable = true
	info.func = function(...) self:DropDown_OnClick(...) end
	info.owner = Frame
	for Key, Value in ipairs(self.Choices) do
		info.text = Value
		info.value = Key
		UIDropDownMenu_AddButton(info, Level)
	end
end

function module:DropDown_OnClick(Frame)
	local Value = self.Widget:GetData()
	Value[self.FilterIndex][1] = Frame.value
	self:SetConfigOption(module_key, Value)
	UIDropDownMenu_SetText(Frame.owner, Frame:GetText())
end
