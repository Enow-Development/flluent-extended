local fs = require("@lune/fs")
local process = require("@lune/process")

-- Load modules with full path
local BuildCodegenCode = fs.readFile("build/modules/BuildCodegen.luau")
local LuaEncodeCode = fs.readFile("build/modules/LuaEncode.luau")

-- Create a simple module loader
local function loadModule(code, name)
	local fn, err = loadstring(code, name)
	if not fn then
		error("Failed to load " .. name .. ": " .. tostring(err))
	end
	return fn()
end

-- Load LuaEncode first (BuildCodegen depends on it)
local LuaEncode = loadModule(LuaEncodeCode, "LuaEncode")

-- Inject LuaEncode into BuildCodegen's environment
local BuildCodegenEnv = {
	require = function(name)
		if name == "@lune/roblox" then
			return require("@lune/roblox")
		elseif name == "LuaEncode" then
			return LuaEncode
		end
		error("Unknown module: " .. name)
	end
}
setmetatable(BuildCodegenEnv, { __index = _G })

local BuildCodegenFn = loadstring(BuildCodegenCode, "BuildCodegen")
setfenv(BuildCodegenFn, BuildCodegenEnv)
local BuildCodegen = BuildCodegenFn()

local FilePath = "dist/main.lua"
local TempFile = "dist/temp.lua"
local Header = fs.readFile("build/header.luau")

local function minify(text)
	fs.writeFile(TempFile, text)
    process.spawn("darklua", {"process", TempFile, TempFile, "--config", "build/darklua.json"})
	local value = fs.readFile(TempFile)
	fs.removeFile(TempFile)
	return value
end

local Module = fs.readFile("dist/main.rbxm")
local ModelCodegen = BuildCodegen(Module, false)

fs.writeFile(FilePath, Header .. "\n" .. minify(ModelCodegen))