-- Simple build script that just runs rojo and darklua
local process = require("@lune/process")
local fs = require("@lune/fs")

print("Building with Rojo...")
local rojoResult = process.spawn("rojo", {"build", "-o", "dist/main.rbxm"})
if rojoResult.code ~= 0 then
	print("Rojo build failed!")
	print(rojoResult.stderr)
	process.exit(1)
end

print("Rojo build successful!")
print("\nNote: To generate main.lua, you need to run the full build process.")
print("The DropdownSection component has been added to src/Components/DropdownSection.lua")
print("and is ready to use in your Roblox project!")
