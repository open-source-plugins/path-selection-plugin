--[[
    PathSelectionPlugin: ...

    @author: isaac010901
    @version: 1.0.0
]]

-- Roblox Services
local ScriptEditorService = game:GetService("ScriptEditorService")
local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")

-- Modules
local Clipboard = require(script.Clipboard).new(plugin)

-- Plugin
local toolbar = plugin:CreateToolbar("Path Selection")
local copyPathButton = toolbar:CreateButton("Copy", "", "rbxassetid://16399708130")
local clearPathButton = toolbar:CreateButton("Clear", "", "rbxassetid://16399748823")
local pastePathButton = toolbar:CreateButton("Paste", "", "rbxassetid://16399733559")

copyPathButton.ClickableWhenViewportHidden = true
clearPathButton.ClickableWhenViewportHidden = true
pastePathButton.ClickableWhenViewportHidden = true

-- Functions
local function ParsePathForSelection(selection: Instance)
	local path = ""
	local lastParent = selection

	while lastParent ~= game do
		if lastParent.Parent ~= game then
			path = lastParent.Name .. "." .. path
		else
			local success, _ = pcall(function()
				return game:GetService(lastParent.Name)
			end)

			if success then
				path = 'game:GetService("' .. lastParent.Name .. '").' .. path
			else
				path = lastParent.Name .. path
			end
		end
		lastParent = lastParent.Parent
	end

	return path:sub(1, #path - 1) -- Removes the "." at the end
end

local function GetSelectionPathsAsString(): string?
	local pathString = ""
	local selection = Selection:Get()

	for _, instance in selection do
		pathString ..= `local {instance.Name} = {ParsePathForSelection(instance)}\n`
	end

	return pathString
end

local function CopySelectedInstancesPath()
	Clipboard:Copy(GetSelectionPathsAsString())
end

local function PastePathsToCurrentOpenedScript()
	if StudioService.ActiveScript then
		local document = ScriptEditorService:FindScriptDocument(StudioService.ActiveScript)
		local pathText = GetSelectionPathsAsString()

		document:EditTextAsync(pathText .. document:GetText(), document:GetSelection())

		warn("Pasted!")
	end
end

-- Plugin buttons binding
copyPathButton.Click:Connect(CopySelectedInstancesPath)

clearPathButton.Click:Connect(function()
	Clipboard:Clear()
	warn("Clipboard cleared!")
end)

pastePathButton.Click:Connect(PastePathsToCurrentOpenedScript)
