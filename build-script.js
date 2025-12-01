const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

console.log('🔨 Building Fluent Library...\n');

// Get aftman bin path
const aftmanBin = path.join(os.homedir(), '.aftman', 'bin');
const rojoPath = path.join(aftmanBin, 'rojo.exe');
const lunePath = path.join(aftmanBin, 'lune.exe');

// Step 1: Create dist directory
console.log('Step 1: Creating dist directory...');
if (!fs.existsSync('dist')) {
    fs.mkdirSync('dist');
}

// Step 2: Build with Rojo
console.log('Step 2: Building with Rojo...');
try {
    execSync(`"${rojoPath}" build -o dist/main.rbxm`, { stdio: 'inherit' });
    console.log('✅ Rojo build successful!\n');
} catch (error) {
    console.error('❌ Rojo build failed!');
    process.exit(1);
}

// Step 3: Run Lune build script
console.log('Step 3: Converting to Lua...');
try {
    execSync(`"${lunePath}" build/init.luau`, { stdio: 'inherit' });
    console.log('✅ Conversion complete!\n');
    
    // Copy to root
    if (fs.existsSync('dist/main.lua')) {
        fs.copyFileSync('dist/main.lua', 'main.lua');
        console.log('📦 main.lua has been generated!');
        const stats = fs.statSync('main.lua');
        console.log(`📊 File size: ${(stats.size / 1024).toFixed(2)} KB`);
    }
} catch (error) {
    console.error('❌ Lune build failed!');
    console.error(error.message);
    process.exit(1);
}
