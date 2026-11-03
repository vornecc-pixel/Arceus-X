// Runs tests/hub_mock.lua without a native Lua interpreter.
// From the repository root:  npm install --no-save fengari && node tests/run_hub_mock.js
const fs = require('fs');
const path = require('path');

let fengari;
try {
    fengari = require('fengari');
} catch (error) {
    console.error('fengari is required: npm install --no-save fengari');
    process.exit(1);
}

const { lua, lauxlib, lualib, to_luastring } = fengari;
const root = path.resolve(__dirname, '..');
const hubSource = fs.readFileSync(path.join(root, 'scripts', 'main.lua'), 'utf8');
const testSource = fs.readFileSync(path.join(__dirname, 'hub_mock.lua'), 'utf8');

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
lua.lua_pushstring(L, to_luastring(hubSource));
lua.lua_setglobal(L, to_luastring('HUB_SOURCE'));

if (lauxlib.luaL_dostring(L, to_luastring(testSource)) !== lua.LUA_OK) {
    console.error('Hub mock tests failed:', lua.lua_tojsstring(L, -1));
    process.exit(1);
}
