
// OPEN
int dslopen_ped(lua_State *lua){
	// pools
	lua_register(lua,"RequirePoolSize",&RequirePoolSize);
	lua_register(lua,"GetPoolSize",&GetPoolSize);
	lua_register(lua,"GetPoolUsage",&GetPoolUsage);
	lua_register(lua,"GetPoolSpace",&GetPoolSpace);
	lua_register(lua,"GetAllPoolInfo",&GetAllPoolInfo);
	lua_register(lua,"AllPeds",&AllPeds);
	//lua_register(lua,"AllVehicles",&AllVehicles);
	// peds
	lua_register(lua,"PedCreateScriptless",&PedCreateScriptless);
	lua_register(lua,"PedGetModelId",&PedGetModelId);
	lua_register(lua,"PedGetThrottle",&PedGetThrottle);
	lua_register(lua,"PedSetPosSimple",&PedSetPosSimple);
	lua_register(lua,"PedSetThrottle",&PedSetThrottle);
	lua_register(lua,"PedSpoofModel",&PedSpoofModel);
	// debug
	if(getDslState(lua,1)->flags & DSL_ADD_DEBUG_FUNCS)
		lua_register(lua,"GetCameraAddress",&GetCameraAddress);
	return 0;
}