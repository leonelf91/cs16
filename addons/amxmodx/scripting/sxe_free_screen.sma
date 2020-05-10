#include <amxmodx>
#include <amxmisc>

#define PLUGIN "FS:sXe Free Screen Menu"
#define VERSION "1.0beta"
#define AUTHOR "Destro"

new g_maxplayers
new cvar_waiting, cvar_maxscreen, cvar_waiting_target, cvar_maxscreen_target, cvar_hudinfo


new g_screen_data[33][4]

const MAX_STATS_SAVED = 35
new db_ip[MAX_STATS_SAVED][32]
new db_screen[MAX_STATS_SAVED][2]
new db_slot_i

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("amx_sxe_screen", "cmd_screen")
	register_clcmd("amx_sxe_free_screen", "show_menu_free_screen")
	
	cvar_waiting = register_cvar("amx_fs_waiting", "60")
	cvar_maxscreen = register_cvar("amx_fs_maxscreen", "14")
	cvar_waiting_target = register_cvar("amx_fs_waiting_target", "120")
	cvar_maxscreen_target = register_cvar("amx_fs_maxscreen_target", "7")
	cvar_hudinfo = register_cvar("amx_fs_hudinfo", "0")


	register_cvar("sxe_free_screen", "FS:sXe Free Screen Menu 1.0", FCVAR_SERVER|FCVAR_SPONLY)
	
	g_maxplayers = get_maxplayers()
}

public plugin_cfg()
{
	if(is_plugin_loaded("Pause Plugins") > -1)
		server_cmd("amx_pausecfg add ^"%s^"", PLUGIN)
}

public client_disconnect(id)
{
	save(id)
}

public client_putinserver(id)
{
	g_screen_data[id][0] = 0
	g_screen_data[id][1] = 0
	g_screen_data[id][2] = 0
	g_screen_data[id][3] = 0
	load(id)
}

/* Admin Screen ========================================================================
===================================================================================*/
public cmd_screen(id, level, cid)
{
	if(get_user_flags(id)&ADMIN_KICK)
		show_menu_screen(id)
	else
		client_print(id, print_console, "[sXe FS] No tienes acceso.") 

	return PLUGIN_HANDLED
}

show_menu_screen(id)
{
	new name[32], data[14]
	new menu = menu_create("Admin Screen Menu:", "menu_screen")  
    
	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i)) continue
			
		get_user_name(i, name, 31)
		formatex(data, 13, "%d %d", i, get_user_userid(i))
		menu_additem(menu, name, data)
	}
	
	menu_display(id, menu, 0)
}

public menu_screen(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
    
	new data[14], null, name[32]
	menu_item_getinfo(menu, item, null, data, 13, name, 31, null)
	
	new target
	if(!check_player_menu(data, target) || !is_user_connected(target) || is_user_hltv(target) || is_user_bot(target))
	{
		chat_color(id, "!g[sXe FS] !tPlayer invalido")
		menu_destroy(menu)
		show_menu_screen(id)
		return PLUGIN_HANDLED
	}
	
	chat_color(id, "!g[sXe FS] !tScreen sacada al player: !y%s", name)
	
	if(get_pcvar_num(cvar_hudinfo))
	{
		new hid[20], fecha[32]
		get_user_info(target, "*HID", hid, 19)
		get_time("%d/%m/%y - %H:%M", fecha, 31)
	
		set_dhudmessage(255, 255, 255, 0.01, 0.68, 0, 0.1, 0.5, 0.1, 0.1)
		show_dhudmessage(target, "%s^n%s^n%s", name, hid, fecha)

		new temp[1]
		temp[0] = target
		set_task(0.3, "task_screen", id, temp, 2)
	}
	else server_cmd("sxe_screen #%d #%d", get_user_userid(target), get_user_userid(id))

	menu_display(id, menu)
	return PLUGIN_HANDLED
}

/* Free Screen ======================================================================
===================================================================================*/

public show_menu_free_screen(id)
{
	new util = get_pcvar_num(cvar_maxscreen)
	
	if(g_screen_data[id][0] > util)
	{
		chat_color(id, "!g[sXe FS] !tAlcanzaste el limite de ScreenShot que puedes sacar por map. !y(Max %d)", util)
		return
	}
	
	util = get_systime()
	if(g_screen_data[id][1] > util)
	{
		util = g_screen_data[id][1]-util
		chat_color(id, "!g[sXe FS] !tDebes esperar !y%d !tsegundos para volver a sacar una screen.", util)
		return
	}
	
	new name[32], data[14]
	new menu = menu_create("Admin Screen Menu:", "menu_free_screen")  
    
	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i)) continue
			
		get_user_name(i, name, 31)
		formatex(data, 13, "%d %d", i, get_user_userid(i))
		menu_additem(menu, name, data)
	}
	
	menu_display(id, menu, 0)
}

public menu_free_screen(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
    
	new data[14], null, name[32]
	menu_item_getinfo(menu, item, null, data, 13, name, 31, null)
	
	new target
	if(!check_player_menu(data, target) || !is_user_connected(target) || is_user_hltv(target) || is_user_bot(target))
	{
		chat_color(id, "!g[sXe FS] !tPlayer invalido")
		menu_destroy(menu)
		show_menu_free_screen(id)
		return PLUGIN_HANDLED
	}
	
	new util = get_pcvar_num(cvar_maxscreen_target)
	
	if(g_screen_data[target][2] > util)
	{
		chat_color(id, "!g[sXe FS] !No le pueden sacar mas Screen a %s,ha alcando el limite por map. (limite: %d)", util)
		return PLUGIN_HANDLED
	}
	
	util = get_systime()
	if(g_screen_data[target][3] > util)
	{
		util = g_screen_data[target][3]-util
		chat_color(id, "!g[sXe FS] !tYa le han sacado una screen a !y%s!t,espera %d segundos para volver a sacarle.", name, util)
		return PLUGIN_HANDLED
	}

	g_screen_data[id][0]++
	g_screen_data[id][1] = get_systime()+get_pcvar_num(cvar_waiting)
	g_screen_data[target][2]++
	g_screen_data[target][3] = get_systime()+get_pcvar_num(cvar_waiting_target)
	
	chat_color(id, "!g[sXe FS] !tScreen sacada al player: !y%s", name)
	
	if(get_pcvar_num(cvar_hudinfo))
	{
		new hid[20], fecha[32]
		get_user_info(target, "*HID", hid, 19)
		get_time("%d/%m/%y - %H:%M", fecha, 31)
	
		set_dhudmessage(255, 255, 255, 0.01, 0.68, 0, 0.1, 0.5, 0.1, 0.1)
		show_dhudmessage(target, "%s^n%s^n%s", name, hid, fecha)

		new temp[1]
		temp[0] = target
		set_task(0.3, "task_screen", id, temp, 2)
	}
	else server_cmd("sxe_screen #%d #%d", get_user_userid(target), get_user_userid(id))

	return PLUGIN_HANDLED
}


// ---------
public task_screen(target[1], id)
{
	server_cmd("sxe_screen #%d #%d", get_user_userid(target[0]), get_user_userid(id))
}


/* Save/Load ========================================================================
===================================================================================*/
save(id)
{	
	static ip[25]
	get_user_ip(id, ip, 24)

	if(db_ip[id][0] && !equal(ip, db_ip[id]))
	{
		if(db_slot_i >= sizeof db_ip)
			db_slot_i = g_maxplayers+1
		
		copy(db_ip[db_slot_i], charsmax(db_ip[]), db_ip[id])

		db_screen[db_slot_i][0] = db_screen[id][0]
		db_screen[db_slot_i][1] = db_screen[id][1]
		
		db_slot_i++
	}
	
	copy(db_ip[id], charsmax(db_ip[]), ip)
	db_screen[id][0] = g_screen_data[id][0]
	db_screen[id][1] = g_screen_data[id][1]
}

load(id)
{		
	static ip[25]
	get_user_ip(id, ip, 25)
	for (new i = 0; i < sizeof db_ip; i++)
	{
		if(equal(ip, db_ip[i]))
		{
			g_screen_data[id][0]  = db_screen[i][0]
			g_screen_data[id][1]  = db_screen[i][1]
			return
		}
	}
}

/* STOCKs ===========================================================================
===================================================================================*/
stock chat_color(const id, const input[], any:...)
{
	new count = 1, players[32], i
	static msg[191]

	if(numargs() == 2)
		copy(msg, 190, input)
	else
		vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for(i = 0; i < count; i++)
		{
			if(is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i])
				write_string(msg)
				message_end();
			}
		}
	}
}

stock check_player_menu(data[], &return_player)
{
	static strid[6], struserid[8]
	parse(data, strid, 5, struserid, 7)
	
	return_player = str_to_num(strid)
	if(is_user_connected(return_player) && get_user_userid(return_player) == str_to_num(struserid))
		return 1
		
	return 0
}

/* DHUD Menu ========================================================================
===================================================================================*/
stock __dhud_color
stock __dhud_x
stock __dhud_y
stock __dhud_effect
stock __dhud_fxtime
stock __dhud_holdtime
stock __dhud_fadeintime
stock __dhud_fadeouttime

stock set_dhudmessage(red=0, green=160, blue=0, Float:x=-1.0, Float:y=0.65, effects=2, Float:fxtime=6.0, Float:holdtime=3.0, Float:fadeintime=0.1, Float:fadeouttime=1.5)
{
	#define clamp_byte(%1)       (clamp(%1, 0, 255))
	#define pack_color(%1,%2,%3) (%3 + (%2<<8) + (%1<<16))

	__dhud_color       = pack_color( clamp_byte(red), clamp_byte(green), clamp_byte(blue))
	__dhud_x           = _:x
	__dhud_y           = _:y
	__dhud_effect      = effects
	__dhud_fxtime      = _:fxtime
	__dhud_holdtime    = _:holdtime
	__dhud_fadeintime  = _:fadeintime
	__dhud_fadeouttime = _:fadeouttime

	return 1
}

stock show_dhudmessage(id, const msg[], any:...)
{
	new numArguments = numargs()

	if(numArguments == 2)
	{
		send_dhudMessage(id, msg)
	}
	else {
		new buffer[128]
		vformat(buffer, charsmax(buffer), msg, 3)
		send_dhudMessage(id, buffer)
	}
	return 1
}

stock send_dhudMessage(const id, const msg[])
{
	message_begin(id?MSG_ONE_UNRELIABLE:MSG_BROADCAST, SVC_DIRECTOR, _, id)
	{
		write_byte(strlen(msg) + 31)
		write_byte(DRC_CMD_MESSAGE)
		write_byte(__dhud_effect)
		write_long(__dhud_color)
		write_long(__dhud_x)
		write_long(__dhud_y)
		write_long(__dhud_fadeintime)
		write_long(__dhud_fadeouttime)
		write_long(__dhud_holdtime)
		write_long(__dhud_fxtime)
		write_string(msg)
	}
	message_end()
}
