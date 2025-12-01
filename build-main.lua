-- Build script to generate main.lua from source
local fs = require("@lune/fs")
local process = require("@lune/process")

print("Step 1: Building with Rojo...")
local rojoPath = process.env.LOCALAPPDATA .. "\\Microsoft\\WinGet\\Links\\rojo.exe"
local result = process.spawn(rojoPath, {"build", "-o", "dist/main.rbxm"}, {
	cwd = process.cwd,
	shell = true
})

if result.code ~= 0 then
	print("❌ Rojo build failed!")
	print(result.stderr)
	process.exit(1)
end
print("✅ Rojo build successful!")

print("\nStep 2: Converting to Lua with BuildCodegen...")

-- Load the build modules
local function requireRelative(path)
	local code = fs.readFile(path)
	local fn, err = load(code, "@" .. path)
	if not fn then
		error("Failed to load " .. path .. ": " .. tostring(err))
	end
	
	-- Create environment with require function
	local env = setmetatable({}, { __index = _G })
	env.require = function(name)
		if name == "@lune/roblox" then
			return require("@lune/roblox")
		elseif name == "LuaEncode" then
			return requireRelative("build/modules/LuaEncode.luau")
		end
		return require(name)
	end
	
	setfenv(fn, env)
	return fn()
end

local BuildCodegen = requireRelative("build/modules/BuildCodegen.luau")
local Header = fs.readFile("build/header.luau")

print("Step 3: Processing model file...")
local Module = fs.readFile("dist/main.rbxm")
local ModelCodegen = BuildCodegen(Module, false)

print("Step 4: Minifying with darklua...")
local TempFile = "dist/temp.lua"
fs.writeFile(TempFile, ModelCodegen)

local darkluaPath = process.env.LOCALAPPDATA .. "\\Microsoft\\WinGet\\Links\\darklua.exe"
local darkluaResult = process.spawn(darkluaPath, {
	"process", 
	TempFile, 
	TempFile, 
	"--config", 
	"build/darklua.json"
}, {
	cwd = process.cwd,
	shell = true
})

if darkluaResult.code ~= 0 then
	print("⚠️  Darklua minification failed, using unminified version")
	print(darkluaResult.stderr)
end

local finalCode = fs.readFile(TempFile)
fs.removeFile(TempFile)

print("Step 5: Writing final main.lua...")
fs.writeFile("main.lua", Header .. "\n" .. finalCode)
fs.writeFile("dist/main.lua", Header .. "\n" .. finalCode)

print("\n✅ Build complete! main.lua has been generated.")
print("📦 File size: " .. #finalCode .. " bytes")
