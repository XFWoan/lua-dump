#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int l_gen_lightuserdata(lua_State* L)
{
    lua_pushlightuserdata(L, (void*)0x12345678);
    return 1;
}

static const struct luaL_Reg userdata_lib[] = {
    {"gen_lightuserdata", l_gen_lightuserdata},

    {NULL, NULL},
};

extern int luaopen_userdata(lua_State* L)
{
    luaL_newlib(L, userdata_lib);
    return 1;
}