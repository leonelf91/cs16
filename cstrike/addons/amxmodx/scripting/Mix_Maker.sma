/* 
*     	   _____  .__            _____          __                 
*         /     \ |__|__  ___   /     \ _____  |  | __ ___________ 
*        /  \ /  \|  \  \/  /  /  \ /  \\__  \ |  |/ // __ \_  __ \
*       /    Y    \  |>    <  /    Y    \/ __ \|    <\  ___/|  | \/
*       \____|__  /__/__/\_ \ \____|__  (____  /__|_ \\___  >__|   
*               \/         \/         \/     \/     \/    \/       
*
*	Mix Maker is free software,
*	you can redistribute it and/or modify it under the terms of the
*	GNU General Public License as published by the Free Software Foundation.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY, without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with Mix Maker, if not, write to the
*	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
*	Boston, MA 02111-1307, USA.
*
*	AMX Mod X Script
*
*	Copyright© All rights reserved ( Federico '#8 SickneSS' Fernández )
*
*	~~~~~~~
*	Credits
*	~~~~~~~
*		ReymonARG
*		Alucard^
*		golsilver
*		Linux
*		[Lo]Phreak^n^c
*		Jonaa#
*		Niiqo
*		Mr. Beatbox
*		AwperLJ
*		d a n i
*		
*
*	~~~~~~~~~~~~~~~~~
*	Code Help Credits
*	~~~~~~~~~~~~~~~~~
*		Exolent[jNr]
*			- Tell me how to set a random model.
*		VEN
*			- Hook first jointeam of the server.
*
*	~~~~~~~~~~~~~~~~~~
*	Communitys Credits
*	~~~~~~~~~~~~~~~~~~
*		Next-Version Community
*		Imperio-LNJ Community
*		Wgamers Community
*		Kz-Argentina Community
*		AlliedModders Community
*
*	~~~~~~~
*	Contact
*	~~~~~~~
*		MSN : Sickness@1337-Games.com
*		Steam ID : SicknessARG
*		Facebook : https://www.facebook.com/FeddeA7X
*/
/*==========================================================================
*		Start Customization.					   *
===========================================================================*/

//====================[*Configurations*]===========================//

new const MixMaker_CFG[] = "Mix_Maker.cfg"
new const MixMaker_Maps_File[] = "MixMaker_Maps.ini"
new const MixMaker_CFG_Public[] = "publico.cfg"
new const MixMaker_CFG_WarmUP[] = "practica.cfg"
new const MixMaker_CFG_Closed[] = "cerrado.cfg"
new const MixMaker_CFG_Rates[] = "rates.cfg"
new const MixMaker_CFG_Live[] = "vale.cfg"

//====================[*Access to all admins commands*]===========================//

#define ADMIN_ACCESS		ADMIN_CFG

/*==========================================================================
*	Customization ends here! Editing anything beyond		   *
*	here is not officially supported.Proceed at your own risk...	   *
===========================================================================*/

//====================[*Includes*]===========================//

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

//====================[*Define Plugin Version*]===========================//

new const MixMaker_Version[] =	"10.0"

//====================[*Definitions*]===========================//

#define valids_teams(%1)	(CS_TEAM_T <= cs_get_user_team(%1) <= CS_TEAM_CT)
#define TEAM_SELECT_VGUI_MENU_ID 2
#define MAXMAPS			20
#define MAPLEN			64

//====================[*Global Registrations*]===========================//

/* pCvars */
new Enable
new ShowExtras
new TVTEnable
new SetToPublic
new MinPlayers
new LiveType
new Sounds
new SoundsType
new Swaper
new RoundsHalf
new RoundsEnd
new defPassword
new PasswordMode
new ShowBestsFraggers
new NoNick
new NoSay
new NoSayType
new TLPrefix

/* pCvars Strings */
new GameName
new ChtPrefix

/* Strings */
new szGameName[33]
new szPrefix[33]

/* Cvars Pointer */
new pRestart
new pAlltalk
new pPassword

/* Messages */
new SayText
new TeamScore

/* Players */
new MaxPlayers

/* Models */
new const CsInternalModel:CTsModels[] =
{
	CS_CT_URBAN,
	CS_CT_GSG9,
	CS_CT_SAS,
	CS_CT_GIGN
}

new const CsInternalModel:TsModels[] =
{
	CS_T_TERROR,
	CS_T_LEET,
	CS_T_ARCTIC,
	CS_T_GUERILLA
}

/* Score */
new ScoreCT
new TotalCT
new ScoreT
new TotalT
new FragsHalf
new FragsEnd
new BestFragger1
new BestFragger2

/* Sync Hud */
new shCountdown
new Countdown 

/* Ban Type */
new BanType[33]

/* Maps File */
new Maps[MAXMAPS+1][MAPLEN+1]

/* Booleans */
new bool:Half
new bool:End
new bool:bChangeteam
new bool:FirstSpawn[33]
new bool:TLCounterTerrorist[33]
new bool:TLTerrorist[33]
new bool:BlockClCorpse[33]
new bool:SetPublic

//====================[*Plugin Start*]===========================//

public plugin_init() 
{	
	/* Plugin Registration */
	register_plugin("Mix Maker",MixMaker_Version,"#8 SickneSS")
	
	/* Dictionary */
	register_dictionary("common.txt")
	
	/* Cvars */
	register_cvar("mixm_version","10.0",FCVAR_SPONLY|FCVAR_SERVER)
	register_cvar("mixm_author","#8 SickneSS",FCVAR_SPONLY|FCVAR_SERVER)
	
	/* pCvars */
	Enable = register_cvar("mixm_enable","0")
	ShowExtras = register_cvar("mixm_smextras","1")
	TVTEnable = register_cvar("mixm_tvtenable","1")	
	SetToPublic = register_cvar("mixm_set2public","1")
	MinPlayers = register_cvar("mixm_minplayers","3")
	LiveType = register_cvar("mixm_livetype","0")
	Sounds = register_cvar("mixm_sounds","1")
	SoundsType = register_cvar("mixm_soundstype","0") 
	Swaper = register_cvar("mixm_swapteams","1")
	RoundsHalf = register_cvar("mixm_rounds2half","15")
	RoundsEnd = register_cvar("mixm_rounds2end","16")    
	defPassword = register_cvar("mixm_defpassword","1337")
	PasswordMode = register_cvar("mixm_pshowmode","2")
	ShowBestsFraggers = register_cvar("mixm_showbestsfraggers","1")
	NoNick = register_cvar("mixm_nonick","0")
	NoSay = register_cvar("mixm_nosay","0")
	NoSayType = register_cvar("mixm_nosaytype","1")
	TLPrefix = register_cvar("mixm_tlprefix","[TL]")
	
	/* pCvars Strings */
	GameName = register_cvar("mixm_gamename","Mix Maker v10.0")
	ChtPrefix = register_cvar("mixm_prefix","!y[!gMix Maker!y]")
	
	/* Console Commands */
	register_concmd("amx_password","cmdSetPassword",ADMIN_ACCESS,"^"password^"")
	register_concmd("amx_alltalk","cmdSetAlltalk",ADMIN_ACCESS,"^n* 1 : Activado^n* 0 : Desactivado")
	register_concmd("amx_vale","cmdLive",ADMIN_ACCESS)
	register_concmd("amx_live","cmdLive",ADMIN_ACCESS)
	register_concmd("amx_nuevo","cmdNew",ADMIN_ACCESS)
	register_concmd("amx_new","cmdNew",ADMIN_ACCESS)

	/* Say Commands */
	register_saycmd("on","cmdOn",ADMIN_ACCESS)
	register_saycmd("off","cmdOff",ADMIN_ACCESS)
	register_saycmd("spec","cmdSpec",ADMIN_ACCESS)
	register_saycmd("spect","cmdSpec",ADMIN_ACCESS)	
	register_saycmd("vale","cmdLive",ADMIN_ACCESS)
	register_saycmd("live","cmdLive",ADMIN_ACCESS)
	register_saycmd("cfg","MixMenu",ADMIN_ACCESS)	
	register_saycmd("mix","MixMenu",ADMIN_ACCESS)
	register_saycmd("menu","MixMenu",ADMIN_ACCESS)
	register_saycmd("map","MapsMenu",ADMIN_ACCESS)	
	register_saycmd("maps","MapsMenu",ADMIN_ACCESS)	
	register_saycmd("nonick","cmdNoNick",ADMIN_ACCESS)
	register_saycmd("noname","cmdNoNick",ADMIN_ACCESS)
	register_saycmd("nosay","cmdNoSay",ADMIN_ACCESS)
	register_saycmd("nochat","cmdNoSay",ADMIN_ACCESS)
	register_saycmd("block","cmdTeams",ADMIN_ACCESS)
	
	/* Hooks & Commands */
	register_concmd("chooseteam","HookChangeteam")
	register_concmd("jointeam","HookChangeteam")
	register_clcmd("say","cmdSayPassOrSayAlltalk")
	register_clcmd("say_team","cmdSayPassOrSayAlltalk")
	register_clcmd("say","cmdBlock")
	register_clcmd("say","cmdSayRestart",ADMIN_ACCESS)
	
	/* Forwards */
	register_forward(FM_GetGameDescription,"fwdGamename")
	register_forward(FM_ClientUserInfoChanged,"fwdClientInfoChanged")
	
	/* Ham Registration */
	RegisterHam(Ham_Spawn,"player","HamSpawnPlayer",1)
	
	/* Messages */
	register_message(get_user_msgid("TeamScore"),"MessageTeamScore")
	register_message(get_user_msgid("SayText"),"MessageNameChange")
	register_message(get_user_msgid("ShowMenu"),"MessageShowMenu")
	register_message(get_user_msgid("VGUIMenu"),"MessageVGUIMenu")	
	register_message(get_user_msgid("ClCorpse"),"MessageClCorpse")
	
	/* Events */
	register_event("TeamScore","EventTeamScore","a")
	register_logevent("LogEventRoundEnd",2,"1=Round_End")
	register_event("HLTV","EventHLTV","a","1=0","2=0")
}
//----------------------------------------------------------//
public plugin_cfg() 
{
	/* Mix Maker Configuration File */
	new Path[256]
	get_configsdir(Path,255)
	format(Path,255,"%s/%s",Path,MixMaker_CFG)
	
	if(!file_exists(Path))
		log_amx("[AMXX] Configuration file can't be located")
	else	
		server_cmd("exec %s",Path)
	
	/* Cvars Pointer */
	pRestart = get_cvar_pointer("sv_restart")
	pAlltalk = get_cvar_pointer("sv_alltalk")
	pPassword = get_cvar_pointer("sv_password")
	
	/* Players */
	MaxPlayers = get_maxplayers()
	
	/* Messages */
	SayText = get_user_msgid("SayText")
	TeamScore = get_user_msgid("TeamScore")
	
	/* Strings */
	get_pcvar_string(GameName,szGameName,32)
	get_pcvar_string(ChtPrefix,szPrefix,32)
	
	/* Continue working with amx_off */
	if(is_plugin_loaded("Pause Plugins") != -1)
		server_cmd("amx_pausecfg add ^"Mix Maker^"")
}

//====================[*Set to Public*]===========================//

public EventHLTV()
{
	new GetPlayers = get_playersnum(1)
	new Players = get_pcvar_num(MinPlayers)
	
	if(GetPlayers <= Players && get_pcvar_num(SetToPublic))
	{
		if(SetPublic)
		{
			ScoreCT = 0
			TotalCT = 0
			ScoreT = 0
			TotalT = 0
			Half = false
			End = false
			bChangeteam = false	
			server_cmd("exec %s",MixMaker_CFG_Public)
			server_exec()
		}
		else
		{
			SetPublic = true
			ChatColor(0,"%s !ySe seteara el servidor en modo publico por la cantidad de personas en el servidor",szPrefix)
		}
		
	}
}

//====================[*Game Name*]===========================//

public fwdGamename() 
{
	forward_return(FMV_STRING,szGameName)
	return FMRES_SUPERCEDE
}

//====================[*Welcome Message*]===========================//

public client_putinserver(id)
	FirstSpawn[id] = true
//----------------------------------------------------------//
public HamSpawnPlayer(id)
{
	if(get_pcvar_num(Enable) && FirstSpawn[id])
	{
		ChatColor(id,"!yEste servidor usa !tMix Maker v%s !yby !g#8 SickneSS",MixMaker_Version)
		FirstSpawn[id] = false
	}
	
}
//----------------------------------------------------------//
public client_disconnect(id)
{
	if(FirstSpawn[id] || TLCounterTerrorist[id] || TLTerrorist[id] || BlockClCorpse[id])
	{
		FirstSpawn[id] = false
		TLCounterTerrorist[id] = false
		TLTerrorist[id] = false
		BlockClCorpse[id] = false
	}
	
	if(BanType[id] > 0)
		BanType[id] = 0
}

//====================[*AMXX*]===========================//	

public cmdOn(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	server_cmd("amx_on")
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public cmdOff(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	server_cmd("amx_off")	
	return PLUGIN_HANDLED
}

//====================[*Goto Spectator*]===========================//

public cmdSpec(id)
{
	if(!valids_teams(id))
		ChatColor(id,"%s Ya eres espectador",szPrefix)
	
	if(is_user_alive(id))
	{	
		set_pev(id,pev_deadflag,DEAD_DEAD)
		cs_set_user_team(id,CS_TEAM_SPECTATOR)
		
		BlockClCorpse[id] = true
	}
	else
		ChatColor(id,"%s Debes estar vivo para usar este comando",szPrefix)
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public MessageClCorpse()
{
	static id
	
	id = get_msg_arg_int(12)
	
	if(BlockClCorpse[id])
	{
		BlockClCorpse[id] = false
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

//====================[*Live*]===========================//

public cmdLive(id,level,cid) 
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	if(get_pcvar_num(Enable))
	{
		new name[32]
		get_user_name(id,name,31)
		
		ChatColor(0,"%s ADMIN %s : Ejecuto el vale",szPrefix,name)
		
		if(get_pcvar_num(Swaper))
			bChangeteam = true
		
		server_cmd("amx_off")
		
		new szPassword[64]
		get_pcvar_string(pPassword,szPassword,63)
		
		new szDefPassword[64]
		get_pcvar_string(defPassword,szDefPassword,63)
		
		if(!szPassword[0])
			set_pcvar_string(pPassword,szDefPassword)
		
		if(Half)
		{
			ScoreCT = 0
			ScoreT = 0
		}
		else
		{
			ScoreCT = 0
			TotalCT = 0
			ScoreT = 0
			TotalT = 0
			End = false
		}
		
		switch(get_pcvar_num(LiveType))
		{
			case 0 :
			{
				Countdown = 5
				shCountdown = CreateHudSyncObj()
				cmdCountdown()
			}
			
			case 1 : cmdVale()
			
			case 2 :
			{
				server_cmd("exec %s",MixMaker_CFG_Live)
				server_exec()
			}
		}
	}
	else
		ChatColor(id,"%s Mix Maker desactivado",szPrefix)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public cmdCountdown() 
{
	if(Countdown <= 0)
		cmdVale()
	else
	{	
		if(get_pcvar_num(Sounds))
		{
			new szNum[6]
			num_to_word(Countdown,szNum,5)
			
			client_cmd(0,"spk ^"%s/%s^"",get_pcvar_num(SoundsType) ? "vox" : "fvox",szNum)
		}
		
		set_hudmessage(255,0,0,-1.0,-1.0,1,6.0,1.0)
		ShowSyncHudMsg(0,shCountdown,"[%d]",Countdown)
		
		set_task(1.0,"cmdCountdown")
		
		if(Countdown == 3)    
		{
			ChatColor(0,"%s Alltalk : %s",szPrefix,get_pcvar_num(pAlltalk) ? "Activado" : "Desactivado")
			
			new szPassword[64]
			get_pcvar_string(pPassword,szPassword,63)
			
			if(szPassword[0])
				ChatColor(0,"%s Password : %s",szPrefix,szPassword)
			
		}	
	}
	Countdown --
}
//----------------------------------------------------------//
public cmdVale()
{
	set_hudmessage(64, 64, 64, -1.0, 0.17, 2, 0.1, 3.0, 0.05, 1.0, 1)
	show_hudmessage(0,"Vale al Restart de 3")
	set_task(2.0,"cmdRestart")
	set_task(5.0,"cmdRestart")
	set_task(8.0,"cmdRestart3")
	set_task(12.0,"cmdStart")
}
//----------------------------------------------------------//
public cmdRestart()
	set_pcvar_num(pRestart,1)
//----------------------------------------------------------//
public cmdRestart3()
	set_pcvar_num(pRestart,3)
//----------------------------------------------------------//    
public cmdStart() 
{
	set_hudmessage(44, 156, 122, -1.0, 0.17, 1, 0.1, 3.0, 0.05, 1.0, 1)
	show_hudmessage(0,"Comienza el Match^n%s Parte^nGood Luck & Have Fun",Half ? "Segunda" : "Primera")
}

//====================[*Score And Swaper]===========================//

public EventTeamScore() 
{	
	if(get_pcvar_num(Enable))
	{    
		new szTeam[2]
		read_data(1,szTeam,1)
		
		switch(szTeam[0])
		{
			case 'C' : ScoreCT = read_data(2)
			
			case 'T' : 
			{
				ScoreT = read_data(2)
				LogEventRoundEnd()
			}
		}
	}
}
//----------------------------------------------------------//
public MessageTeamScore(id)
{
	if(get_pcvar_num(Enable) && Half)
		UpdateTeamScore()
}
//----------------------------------------------------------//
public LogEventRoundEnd() 
{	
	if(get_pcvar_num(Enable))
	{    
		new RoundsH = get_pcvar_num(RoundsHalf)
		new RoundsE = get_pcvar_num(RoundsEnd)
		
		if(ScoreCT + ScoreT >= RoundsH && (!Half))
		{			
			Half = true
			
			FragsHalf = Best_Fraggers()
			BestFragger1 = get_user_frags(FragsHalf)
			
			if(get_pcvar_num(Swaper))
				cmdSwap()
			
			TotalCT = ScoreT
			TotalT = ScoreCT
			
			ScoreCT = 0
			ScoreT = 0
			
			set_pcvar_num(pRestart,1)
		}
		
		if(Half)
		{			
			UpdateTeamScore()
			
			if(ScoreCT + TotalCT >= RoundsE)
			{
				set_hudmessage(64, 64, 255, -1.0, -1.0, 1)
				show_hudmessage(0,"Game Over^nCounter-Terrrorists Ganan El Mapa")
				
				End = true 
			}
			
			if(ScoreT + TotalT >= RoundsE)
			{
				set_hudmessage(255, 64, 64, -1.0, -1.0, 1)
				show_hudmessage(0,"Game Over^nTerrorist Team Ganan El Mapa")
				
				End = true
			}
			
			if(ScoreCT + TotalCT >= RoundsH && ScoreT + TotalT >= RoundsH)
			{
				set_hudmessage(64, 255, 64, -1.0, -1.0, 1)
				show_hudmessage(0,"Game Over^nMapa Empatado")
				
				End = true
			}
		}
		
		if(End)
		{
			FragsEnd = Best_Fraggers()
			BestFragger2 = get_user_frags(FragsEnd)
			
			End = false
			Half = false
			bChangeteam = false
			set_pcvar_num(Enable,0)
			
			server_cmd("exec %s",MixMaker_CFG_WarmUP)
			
			if(get_pcvar_num(ShowBestsFraggers))
				set_task(5.0,"BestFrgrs")
		}
	}        
}    
//----------------------------------------------------------//    
public cmdSwap() 
{
	new Players[32]
	new Num
	get_players(Players,Num,"ch")
	
	new Index
	for(new i = 0;i < Num;i++)
	{
		Index = Players[i]
		
		switch(cs_get_user_team(Index))
		{
			case CS_TEAM_CT : cs_set_user_team(Index,CS_TEAM_T,TsModels[random(sizeof (TsModels))])
			
			case CS_TEAM_T : cs_set_user_team(Index,CS_TEAM_CT,CTsModels[random(sizeof (CTsModels))])
		}
	}
}
//----------------------------------------------------------//
public Best_Fraggers() 
{
	new Players[32]
	new Num
	get_players(Players,Num,"ch")
	
	new Index
	new GetFrags	
	for(new i = 0;i < Num;i++)
	{
		Index = Players[i]
		
		if(!GetFrags) 
			GetFrags = Players[0]
		
		if(get_user_frags(Index) > get_user_frags(GetFrags))	
			
		GetFrags = Index
	}
	return GetFrags
}
//----------------------------------------------------------//        
public BestFrgrs() 
{	
	new BestF1[32]
	get_user_name(FragsHalf,BestF1,31)
	
	new BestF2[32]
	get_user_name(FragsEnd,BestF2,31)
	
	set_hudmessage(64, 64, 64, -1.0, 0.29, 2, 0.1, 10.0, 0.05, 1.0, 1)
	show_hudmessage(0,"Mas Fragger Primera Mitad %s Con %i Frags^nMas Fragger Segunda Mitad %s Con %i Frags",BestF1,BestFragger1,BestF2,BestFragger2)
}

//====================[*Data Clear*]===========================//

public cmdNew(id,level,cid) 
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	ScoreCT = 0
	TotalCT = 0
	ScoreT = 0
	TotalT = 0
	Half = false
	End = false
	bChangeteam = false
	
	return PLUGIN_HANDLED
}

//====================[*Block Change Team*]===========================//

public cmdTeams(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	if(!get_pcvar_num(Enable))
		return PLUGIN_HANDLED
	
	new name[32]
	get_user_name(id,name,31)
	
	bChangeteam = !bChangeteam
	ChatColor(0,"%s ADMIN %s : %sabilito el cambio de team",szPrefix,name,bChangeteam ? "Desh" : "H")
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------// 
public MessageShowMenu(msgid, dest, id)
{
	static team_select[] = "#Team_Select"
	static menu_text_code[sizeof team_select]
	
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	
	if(equal(menu_text_code, team_select))
	{
		if(get_pcvar_num(Enable) && bChangeteam)
		{
			ShowMenuTeams(id)
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------// 
public MessageVGUIMenu(msgid, dest, id)
{
	if (!(get_msg_arg_int(1) != TEAM_SELECT_VGUI_MENU_ID))
	{
		if(get_pcvar_num(Enable) && bChangeteam)
		{
			ShowMenuTeams(id)
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------// 
public HookChangeteam(id) 
{
	if(get_pcvar_num(Enable) && bChangeteam)
	{
		if(!valids_teams(id))
			ShowMenuTeams(id)
		else
			ChatColor(id,"%s No puedes cambiarte de team en este momento",szPrefix)
		
		return PLUGIN_HANDLED 
	}
	
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------// 
public ShowMenuTeams(id)
{
	new Menu = menu_create("\r[Mix Maker] \yTeams Menu :","ChangeTeam_Handler")
	
	new Players[32]
	new Num
	get_players(Players,Num,"ceh","TERRORIST")
	
	if(Num >= 5)
		menu_additem(Menu,"\dTerrorist","1")
	else
		menu_additem(Menu,"Terrorist","1")
	
	new Playersz[32]
	new Numz
	get_players(Playersz,Numz,"ceh","CT")
	
	if(Numz >= 5)
		menu_additem(Menu,"\dCounter-Terrorist","2")
	else
		menu_additem(Menu,"Counter-Terrorist","2")
	
	menu_additem(Menu,"Spectator","3")
	
	menu_setprop(Menu,MPROP_EXITNAME,"Cerrar")
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public ChangeTeam_Handler(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Item = str_to_num(iData)
	
	switch(Item)
	{
		case 1 :
		{
			new Players[32]
			new Num
			get_players(Players,Num,"ceh","TERRORIST")
			
			if(Num >= 5)
				ChatColor(id,"%s Terrorist Team Full!",szPrefix)
			else
				engclient_cmd(id,"jointeam","1")
		}
		
		case 2 : 
		{
			new Players[32]
			new Num
			get_players(Players,Num,"ceh","CT")
			
			if(Num >= 5)
				ChatColor(id,"%s Counter-Terrorist Team Full!",szPrefix)
			else
				engclient_cmd(id,"jointeam","2")
		}
		
		case 3 : engclient_cmd(id,"jointeam","6")
	}
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

//====================[*Set Password*]===========================//

public cmdSetPassword(id,level,cid) 
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	
	new szPassword[64]
	read_argv(1,szPassword,63)
	set_pcvar_string(pPassword,szPassword)
	remove_quotes(szPassword)
	
	static name[32]
	get_user_name(id,name,31)
	
	if(szPassword[0])
	{
		switch(get_pcvar_num(PasswordMode))
		{
			case 0 : ChatColor(0,"%s ADMIN %s : Cambio el password a ***PROTECTED***",szPrefix,name)
			
			case 1 : 			
			{	
				ChatColor(0,"%s ADMIN %s : Cambio el password a %s",szPrefix,name,szPassword)
				client_cmd(0,"password ^"%s^"",szPassword)
			}
			
			case 2 :
			{
				for(new i = 1;i <= MaxPlayers;i++)
				{
					if(get_user_flags(i) & ADMIN_ACCESS)
					{
						ChatColor(i,"%s ADMIN %s : Cambio el password a %s",szPrefix,name,szPassword)
						client_cmd(i,"password ^"%s^"",szPassword)
					}
					else
						ChatColor(i,"%s ADMIN %s : Cambio el password a ***PROTECTED***",szPrefix,name)
				}	
			}
		}
	}
	
	return PLUGIN_HANDLED
}

//====================[*Set Alltalk*]===========================//

public cmdSetAlltalk(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	
	new nAlltalk[2]
	read_argv(1,nAlltalk,1)
	set_pcvar_num(pAlltalk,str_to_num(nAlltalk))
	remove_quotes(nAlltalk)
	
	new name[32]
	get_user_name(id,name,31)
	
	ChatColor(0,"%s ADMIN %s : %sctivo el alltalk",szPrefix,name,get_pcvar_num(pAlltalk) ? "A" : "Desa")
	
	return PLUGIN_HANDLED
}

//====================[*Say Pass Or Say Alltalk*]===========================//

public cmdSayPassOrSayAlltalk(id) 
{	
	new said[192]
	read_args(said,191)
	
	new ServerIp[25]
	get_user_ip(0,ServerIp,24,0)
	
	new szPassword[64]
	get_pcvar_string(pPassword,szPassword,63)
	
	if(containi(said,"alltalk") != -1)
		ChatColor(id,"%s Alltalk : %s",szPrefix,get_pcvar_num(pAlltalk) ? "Activado" : "Desactivado")
	
	if(containi(said,"pass") != -1
	|| containi(said,"pw") != -1)
	{
		if(szPassword[0])
		{
			ChatColor(id,"%s Password : %s",szPrefix,szPassword)
			client_cmd(id,"password ^"%s^"",szPassword)
		}
		else
			ChatColor(id,"%s El servidor no tiene password",szPrefix)
	}
	
	if(containi(said,"data") != -1
	|| containi(said,"datos") != -1)
	{		
		if(szPassword[0])
			ChatColor(id,"%s connect %s; password %s",szPrefix,ServerIp,szPassword)
		else
			ChatColor(id,"%s connect %s",szPrefix,ServerIp)
	}
	
	return PLUGIN_CONTINUE
}	

//====================[*Name Change Blocker*]===========================//

public cmdNoNick(id,level,cid) 
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new name[32]
	get_user_name(id,name,31)
	
	set_pcvar_num(NoNick,get_pcvar_num(NoNick) == 0 ? 1 : 0)
	ChatColor(0,"%s ADMIN %s : %sabilito el cambio de nick",szPrefix,name,get_pcvar_num(NoNick) ? "Desh" : "H")
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public fwdClientInfoChanged(id,buffer) 
{	
	if(!get_pcvar_num(NoNick) || is_user_admin(id) || !is_user_connected(id))
		return FMRES_IGNORED
	
	new name[32]
	new newname[32]
	
	get_user_name(id,name,31)
	engfunc(EngFunc_InfoKeyValue,buffer,"name",newname,31)
	
	if(!equal(name,newname))
	{
		engfunc(EngFunc_SetClientKeyValue,id,buffer,"name",name)
		client_cmd(id,"name ^"%s^"",name)
		
		ChatColor(id,"%s No puedes cambiarte el nombre en este momento",szPrefix)
	}
	
	return FMRES_IGNORED
}
//----------------------------------------------------------//
public MessageNameChange(id) 
{
	if(!get_pcvar_num(NoNick) || !is_user_connected(id))
		return PLUGIN_CONTINUE
	
	if(is_user_admin(id))
		return PLUGIN_CONTINUE
	
	new szInfo[64] 
	get_msg_arg_string(2,szInfo,63) 
	
	if(equali(szInfo,"#Cstrike_Name_Change"))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

//====================[*Chat Blocker*]===========================//

public cmdNoSay(id,level,cid) 
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new name[32]
	get_user_name(id,name,31)
	
	set_pcvar_num(NoSay,get_pcvar_num(NoSay) == 0 ? 1 : 0)
	ChatColor(0,"%s ADMIN %s : %sabilito el say",szPrefix,name,get_pcvar_num(NoSay) ? "Desh" : "H")
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public cmdBlock(id) 
{	
	if(!get_pcvar_num(NoSay))
		return PLUGIN_CONTINUE
	
	if(get_user_flags(id) & ADMIN_ACCESS)
		return PLUGIN_CONTINUE	
	
	if(!valids_teams(id))
		return PLUGIN_HANDLED
	
	new said[192]
	read_args(said,191)
	remove_quotes(said)
	
	if(!strlen(said) || said[0] == ' ')
		return PLUGIN_HANDLED
	
	static name[32]
	get_user_name(id,name,31)
	
	if(TLCounterTerrorist[id] || TLTerrorist[id] && get_pcvar_num(TVTEnable))
	{
		new szTLPrefix[13]
		get_pcvar_string(TLPrefix,szTLPrefix,12)
		
		new Msg[192]
		formatex(Msg,191,"%s^x04%s^x03 %s^x01 :  %s",is_user_alive(id) ? "" : "^x01*DEAD* ",szTLPrefix,name,said)
		
		for(new i = 1;i <= MaxPlayers;i++)
		{
			if(is_user_connected(i))
			{
				if(is_user_alive(id) && is_user_alive(i)
				|| !is_user_alive(id) && !is_user_alive(i))
				{
					message_begin(MSG_ONE_UNRELIABLE,SayText,_,i)
					write_byte(id)
					write_string(Msg)
					message_end()
				}
			}
		}
		return PLUGIN_HANDLED
	}
	
	switch(get_pcvar_num(NoSayType))
	{
		case 0 : 
		{
			ChatColor(id,"%s Chat bloqueado",szPrefix)
			return PLUGIN_HANDLED
		}
		
		case 1 :
		{
			new const Chat[][] = 
			{ 
				"/chat","!chat",".chat"
			}

			for(new i = 0;i < sizeof Chat;i++)
			{
				if(containi(said,Chat[i]) != -1)
				{
					ChatColor(0,"%s El jugador %s esta pidiendo que desbloqueen el chat",szPrefix,name)
					return PLUGIN_HANDLED
				}
				else
				{
					ChatColor(id,"%s Chat bloqueado",szPrefix)
					ChatColor(id,"%s Solo puedes escribir /chat para pedir que desbloqueen el chat",szPrefix)
					return PLUGIN_HANDLED
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

//====================[*Restart Command*]===========================//

public cmdSayRestart(id,level,cid) 
{	
	new said[192]
	read_args(said,191)
	remove_quotes(said)
	
	if(!strlen(said) || said[0] == ' ')
		return PLUGIN_HANDLED
	
	if(!is_user_admin(id))
		return PLUGIN_CONTINUE
	
	if(cmd_access(id,level,cid,1))
	{
		new name[32]
		get_user_name(id,name,31)
		
		new Restart[11]
		new Tmp[11]
		strbreak(said,Restart,10,Tmp,10)
		
		new Value = str_to_num(Tmp)
		
		new const Restrts[][] = 
		{ 
			"/restart","!restart",".restart",
			"/rr","!rr",".rr",
			"/r","!r",".r"
		}
		
		for(new i = 0;i < sizeof Restrts;i++)
		{
			if(equali(Restart,Restrts[i]))
			{
				if(!is_str_num(Tmp) || Value > 60)
					Value = 1
				
				if(Tmp[0])
					set_pcvar_num(pRestart,Value)
				else
					set_pcvar_num(pRestart,1)
				
				ChatColor(0,"%s ADMIN %s : Restarteo la ronda [%d]",szPrefix,name,Value)
				return PLUGIN_HANDLED
			}
		}
	}
		
	return PLUGIN_CONTINUE
}

//====================[*Mix Menu*]===========================//

public MixMenu(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	OpenMixMenu(id)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public OpenMixMenu(id)
{			
	new Menu = menu_create("\r[Mix Maker]\y Mix Menu :","MixMenu_Handler")
	
	menu_additem(Menu,"Publico","1")
	menu_additem(Menu,"Practica","2")
	menu_additem(Menu,"Cerrado","3")
	menu_additem(Menu,"Rates","4")
	menu_additem(Menu,"Vale","5")
	if(get_pcvar_num(ShowExtras))
		menu_additem(Menu,"Extras","6")
	
	menu_setprop(Menu,MPROP_EXITNAME,"Cerrar")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public MixMenu_Handler(id,Menu,item) 
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Key = str_to_num(iData)
	
	static name[32]
	get_user_name(id,name,31)
	
	switch(Key)
	{
		case 1 : 
		{
			set_hudmessage(0, 255, 0, -1.0, 0.31, 2, 0.1, 3.0, 0.05, 1.0, 1)
			show_hudmessage(0,"Server en modo^nPublico")
			server_cmd("exec %s",MixMaker_CFG_Public)
			server_exec()
			set_task(1.5,"cmdRestart")
			ChatColor(0,"%s ADMIN %s : Ejecuto publico.cfg",szPrefix,name)
			
			if(is_user_connected(id))
				OpenMixMenu(id)
		}
		
		case 2 :	
		{
			set_hudmessage(0, 0, 255, -1.0, 0.31, 2, 0.1, 3.0, 0.05, 1.0, 1)
			show_hudmessage(0,"Server en modo^nPractica")
			server_cmd("exec %s",MixMaker_CFG_WarmUP)
			server_exec()
			set_task(1.5,"cmdRestart")
			ChatColor(0,"%s ADMIN %s : Ejecuto practica.cfg",szPrefix,name)
			
			if(is_user_connected(id))
				OpenMixMenu(id)			
		}
		
		case 3 :
		{		
			set_hudmessage(255, 0, 0, -1.0, 0.31, 2, 0.1, 3.0, 0.05, 1.0, 1)
			show_hudmessage(0,"Server en modo^nCerrado")
			server_cmd("exec %s",MixMaker_CFG_Closed)
			server_exec()
			set_task(1.5,"cmdRestart")
			ChatColor(0,"%s ADMIN %s : Ejecuto cerrado.cfg",szPrefix,name)
			
			if(is_user_connected(id))
				OpenMixMenu(id)		
		}
		
		case 4 :
		{
			set_hudmessage(128, 128, 128, -1.0, 0.31, 1, 0.1, 3.0, 0.5, 1.0, 1)
			show_hudmessage(0,"Servidor Rateado")
			server_cmd("exec %s",MixMaker_CFG_Rates)
			ChatColor(0,"%s ADMIN %s : Ejecuto rates.cfg",szPrefix,name)
			server_exec()
			client_cmd(id,"say /maps")
		}
		
		case 5 : client_cmd(id,"amx_vale")
		
		case 6 :
		{
			if(get_pcvar_num(ShowExtras) && is_user_connected(id))
				Extras(id)
			else
			{
				ChatColor(id,"%s Submenu Extras Desactivado",szPrefix)
				
				if(is_user_connected(id))
					OpenMixMenu(id)
			}
		}
	}
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

//====================[*Submenu Extras*]===========================//	

Extras(id) 
{	
	new Menu = menu_create("\r[Mix Maker]\y Extras :","ExtraStuff_Handler")
	
	menu_additem(Menu,"Todos a Spec","1")
	menu_additem(Menu,"Kickear Team","2")
	menu_additem(Menu,"Banear Team","3")
	if(get_pcvar_num(ShowExtras) && get_pcvar_num(TVTEnable))
		menu_additem(Menu,"TVT Menu","4")
	
	menu_setprop(Menu,MPROP_BACKNAME,"Atras")
	menu_setprop(Menu,MPROP_NEXTNAME,"Siguiente")	
	menu_setprop(Menu,MPROP_EXITNAME,"\yMix Menu")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public ExtraStuff_Handler(id,Menu,item) 
{	
	if(item == MENU_EXIT)
	{
		if(is_user_connected(id))
			OpenMixMenu(id)
		
		return PLUGIN_HANDLED
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Key = str_to_num(iData)
	
	switch(Key)
	{		
		case 1 :
		{
			set_hudmessage(64,64,64,-1.0,0.21,1,0.2,5.0,0.01,0.1)
			show_hudmessage(0,"Todos para Spec")
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				if(is_user_connected(i))
				{
					set_pev(i,pev_deadflag,DEAD_DEAD)
					cs_set_user_team(i,CS_TEAM_SPECTATOR)
					
					BlockClCorpse[i] = true
				}
			}
			
			if(is_user_connected(id))
				Extras(id)
		}
		
		case 2 :
		{
			if(is_user_connected(id))
				KickMenu(id)
		}
		
		case 3 :
		{
			if(is_user_connected(id))
				BanMenu(id)
		}
		
		case 4 :
		{
			if(get_pcvar_num(ShowExtras) && get_pcvar_num(TVTEnable) && is_user_connected(id))
				TVTMenu(id)
			else
			{
				ChatColor(id,"%s TVT Menu Desactivado",szPrefix)
				
				if(is_user_connected(id))
					Extras(id)
			}
		}
	}
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

//====================[*Kick Menu*]===========================//	

KickMenu(id)
{
	new Menu = menu_create("\r[Mix Maker]\y Kick Menu :","KickTeamMenu")
	menu_additem(Menu,"Terrorists","1")
	menu_additem(Menu,"Counter-Terrorists","2")
	menu_additem(Menu,"Spectators","3")
	
	menu_setprop(Menu,MPROP_EXITNAME,"\yExtras")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public KickTeamMenu(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		if(is_user_connected(id))
			Extras(id)
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Key = str_to_num(iData)
	
	switch(Key)
	{	
		case 1 :
		{
			new name[32]
			get_user_name(id,name,31)
			
			ChatColor(0,"%s ADMIN %s : Kickeo a los del team Terrorist",szPrefix,name)
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				new userid = get_user_userid(i)
				
				if(!is_user_admin(i))
				{
					if(is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T)
						server_cmd("kick #%d [Mix Maker] Kickeado",userid)
				}
			}
		}
		
		case 2 :
		{
			new name[32]
			get_user_name(id,name,31)
			
			ChatColor(0,"%s ADMIN %s : Kickeo a los del team Counter-Terrorist",szPrefix,name)
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				new userid = get_user_userid(i)
				
				if(!is_user_admin(i))
				{
					if(is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT)
						server_cmd("kick #%d [Mix Maker] Kickeado",userid)
				}
			}
		}	
		
		case 3 :
		{
			new name[32]
			get_user_name(id,name,31)
			
			ChatColor(0,"%s ADMIN %s : Kickeo a los del team Spectator",szPrefix,name)
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				new userid = get_user_userid(i)
				
				if(!is_user_admin(i))
				{
					if(is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_SPECTATOR)
						server_cmd("kick #%d [Mix Maker] Kickeado",userid)
				}
			}
		}
	}
	if(is_user_connected(id))
		Extras(id)
	
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

//====================[*Ban Menu*]===========================//

BanMenu(id)
{
	new Menu = menu_create("\r[Mix Maker]\y Ban Menu :","BanTeamMenu")
	menu_additem(Menu,"Terrorists","1")
	menu_additem(Menu,"Counter-Terrorists","2")
	menu_additem(Menu,"Spectators^n","3")
	
	static temp[256]
	switch(BanType[id])
	{
		case 0 : formatex(temp,255,"Banear : \rPor 30 minutos")
		case 1 : formatex(temp,255,"Banear : \rPor 60 minutos")
		case 2 : formatex(temp,255,"Banear : \rPermanentemente")
		case 3 : formatex(temp,255,"Banear : \rLocalmente")
	}
	menu_additem(Menu,temp,"4")
	
	menu_setprop(Menu,MPROP_EXITNAME,"\yExtras")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public BanTeamMenu(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		if(is_user_connected(id))
			Extras(id)
		
		BanType[id] = 0	
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Key = str_to_num(iData)
	
	switch(Key)
	{			
		case 1 :
		{
			static name[32]
			get_user_name(id,name,31)
			
			switch(BanType[id])
			{
				case 0 : ChatColor(id,"%s ADMIN %s : Baneo por 30 minutos a los del team Terrorist",szPrefix,name)
				case 1 : ChatColor(id,"%s ADMIN %s : Baneo por 60 minutos a los del team Terrorist",szPrefix,name)
				case 2 : ChatColor(id,"%s ADMIN %s : Baneo permanentemente a los del team Terrorist",szPrefix,name)
				case 3 : ChatColor(id,"%s ADMIN %s : Baneo localmente a los del team Terrorist",szPrefix,name)
			}
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				new userid = get_user_userid(i)
				
				if(!is_user_admin(i))
				{
					if(is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T)
					{
						switch(BanType[id])
						{
							case 0 : server_cmd("kick #%d [Mix Maker] Baneado por 30 minutos;wait;banid 30;wait;writeid",userid)
							case 1 : server_cmd("kick #%d [Mix Maker] Baneado por 60 minutos;wait;banid 30;wait;writeid",userid)
							case 2 : server_cmd("kick #%d [Mix Maker] Baneado permanentemente;wait;banid 30;wait;writeid",userid)
							case 3 : server_cmd("sxe_ban #%d",userid)
						}
					}
				}
			}
			
			if(is_user_connected(id))
				Extras(id)	
		}
		
		case 2 :
		{
			static name[32]
			get_user_name(id,name,31)
			
			switch(BanType[id])
			{
				case 0 : ChatColor(id,"%s ADMIN %s : Baneo por 30 minutos a los del team Counter-Terrorist",szPrefix,name)
				case 1 : ChatColor(id,"%s ADMIN %s : Baneo por 60 minutos a los del team Counter-Terrorist",szPrefix,name)
				case 2 : ChatColor(id,"%s ADMIN %s : Baneo permanentemente a los del team Counter-Terrorist",szPrefix,name)
				case 3 : ChatColor(id,"%s ADMIN %s : Baneo localmente a los del team Counter-Terrorist",szPrefix,name)
			}
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				new userid = get_user_userid(i)
				
				if(!is_user_admin(i))
				{
					if(is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT)
					{
						switch(BanType[id])
						{
							case 0 : server_cmd("kick #%d [Mix Maker] Baneado por 30 minutos;wait;banid 30;wait;writeid",userid)
							case 1 : server_cmd("kick #%d [Mix Maker] Baneado por 60 minutos;wait;banid 30;wait;writeid",userid)
							case 2 : server_cmd("kick #%d [Mix Maker] Baneado permanentemente;wait;banid 30;wait;writeid",userid)
							case 3 : server_cmd("sxe_ban #%d",userid)
						}
					}
				}
			}
			
			if(is_user_connected(id))
				Extras(id)	
		}	
		
		case 3 :
		{
			static name[32]
			get_user_name(id,name,31)
			
			switch(BanType[id])
			{
				case 0 : ChatColor(id,"%s ADMIN %s : Baneo por 30 minutos a los del team Spectator",szPrefix,name)
				case 1 : ChatColor(id,"%s ADMIN %s : Baneo por 60 minutos a los del team Spectator",szPrefix,name)
				case 2 : ChatColor(id,"%s ADMIN %s : Baneo permanentemente a los del team Spectator",szPrefix,name)
				case 3 : ChatColor(id,"%s ADMIN %s : Baneo localmente a los del team Spectator",szPrefix,name)
			}
			
			for(new i = 1;i <= MaxPlayers;i++)
			{
				new userid = get_user_userid(i)
				
				if(!is_user_admin(i))
				{
					if(is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_SPECTATOR)
					{
						switch(BanType[id])
						{
							case 0 : server_cmd("kick #%d [Mix Maker] Baneado por 30 minutos;wait;banid 30;wait;writeid",userid)
							case 1 : server_cmd("kick #%d [Mix Maker] Baneado por 60 minutos;wait;banid 30;wait;writeid",userid)
							case 2 : server_cmd("kick #%d [Mix Maker] Baneado permanentemente;wait;banid 30;wait;writeid",userid)
							case 3 : server_cmd("sxe_ban #%d",userid)
						}
					}
				}
			}
			
			if(is_user_connected(id))
				Extras(id)
		}
		
		case 4 : 
		{
			switch(BanType[id])
			{
				case 0 : BanType[id] = 1
				case 1 : BanType[id] = 2
				case 2 : BanType[id] = 3
				case 3 : BanType[id] = 0
			}
			
			if(is_user_connected(id))
				BanMenu(id)
		}
	}
	
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

//====================[*Team vs Team Menu*]===========================//

public TVTMenu(id)
{
	new Menu = menu_create("\r[Mix Maker]\y TVT Menu :","TVTMenu_Handler")
	
	menu_additem(Menu,"Setear TL Counter-Terrorist","1")
	menu_additem(Menu,"Setear TL Terrorist","2")
	
	menu_setprop(Menu,MPROP_EXITNAME,"\yExtras")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}

public TVTMenu_Handler(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		if(is_user_connected(id))
			Extras(id)
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new TvTChoosed = str_to_num(iData)
	
	switch(TvTChoosed)
	{
		case 1 :
		{				
			for(new i = 1;i <= MaxPlayers;i++)
				TLCounterTerrorist[i] = false
			
			new Players[32]
			new Num
			get_players(Players,Num,"ceh","CT")
			
			if(Num >= 5)
			{
				if(is_user_connected(id))
					MenuCounterTerrorist(id)
			}
			else
			{
				ChatColor(id,"%s Debe haber por lo menos 5 jugadores en el team Counter-Terrorist",szPrefix)
				
				if(is_user_connected(id))
					TVTMenu(id)
			}
			
		}	
		
		case 2 :
		{
			for(new i = 1;i <= MaxPlayers;i++)
				TLTerrorist[i] = false
			
			new Players[32]
			new Num
			get_players(Players,Num,"ceh","TERRORIST")
			
			if(Num >= 5)
			{
				if(is_user_connected(id))
					MenuTerrorist(id)
			}
			else
			{
				ChatColor(id,"%s Debe haber por lo menos 5 jugadores en el team Terrorist",szPrefix)
				
				if(is_user_connected(id))
					TVTMenu(id)
			}
		}
	}
	
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

//====================[*Team Leaders*]===========================//

//-------------------------/* Counter-Terrorists */---------------------------------//
MenuCounterTerrorist(id)
{
	new Menu = menu_create("\r[Mix Maker]\y Counter-Terrorists :","CTMenu_Handler")
	
	static name[32]
	static item[32]
	
	new Players[32]
	new Num
	get_players(Players,Num,"ceh","CT")
	
	for(new i = 0;i < Num;i++)
	{
		if(is_user_connected(i) && !is_user_admin(i))
		{
			get_user_name(i,name,31)
			num_to_str(i,item,31)
			
			menu_additem(Menu,name,item)
		}
	}
	
	menu_setprop(Menu,MPROP_EXITNAME,"\yTVT Menu")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public CTMenu_Handler(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		if(is_user_connected(id))
			Extras(id)
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Target = str_to_num(iData)
	
	if(Target)
	{
		TLCounterTerrorist[Target] = true
		
		new name[32]
		get_user_name(id,name,31)
		
		ChatColor(id,"%s ADMIN %s : Seteo a %s como TL de los Counter-Terrorists",szPrefix,name,iName)
	}
	
	if(is_user_connected(id))
		Extras(id)
	return PLUGIN_HANDLED
}
//-------------------------/* Terrorists */---------------------------------//
MenuTerrorist(id)
{
	new Menu = menu_create("\r[Mix Maker]\y Terrorists :","TMenu_Handler")
	
	static name[32]
	static item[32]
	
	new Players[32]
	new Num
	get_players(Players,Num,"ceh","TERRORIST")
	
	for(new i = 0;i < Num;i++)
	{
		if(is_user_connected(i) && !is_user_admin(i))
		{
			get_user_name(i,name,31)
			num_to_str(i,item,31)
			
			menu_additem(Menu,name,item)
		}
	}
	
	menu_setprop(Menu,MPROP_EXITNAME,"\yTVT Menu")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public TMenu_Handler(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		if(is_user_connected(id))
			Extras(id)
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	new Target = str_to_num(iData)
	
	if(Target)
	{
		TLTerrorist[Target] = true
		
		new name[32]
		get_user_name(id,name,31)
		
		ChatColor(id,"%s ADMIN %s : Seteo a %s como TL de los Terrorists",szPrefix,name,iName)
	}
	
	if(is_user_connected(id))
		Extras(id)
	return PLUGIN_HANDLED
}

//====================[*Maps Menu*]===========================//

public MapsMenu(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new Menu = menu_create("\r[Mix Maker]\y Maps Menu :","MapsMenu_Handler")
	
	/* Mix Maker Maps File */
	new Path[256]
	get_configsdir(Path,255)
	format(Path,255,"%s/%s",Path,MixMaker_Maps_File)
	
	if(!file_exists(Path))
	{
		log_amx("[AMXX] Maps file can't be located")
		ChatColor(id,"%s No se ha encontrado el archivo de mapas",szPrefix)
		client_cmd(id,"amx_mapmenu")
	}
	
	new f = fopen(Path,"rt")
	
	new Mapname[MAPLEN+1]
	new Item
	
	while(!feof(f))
	{
		fgets(f,Mapname,64)
	
		trim(Mapname)
		strtolower(Mapname)
			
		if(!Mapname[0] || Mapname[0] == ';'
		|| Mapname[0] == '/' && Mapname[1] == '/' ) continue;
			
		copy(Maps[Item],64,Mapname)
		Item++
		
		if(Item >= MAXMAPS+1) break;
		
		menu_additem(Menu,Mapname,Maps[Item])
	}
	fclose(f)
	
	menu_setprop(Menu,MPROP_BACKNAME,"Atras")
	menu_setprop(Menu,MPROP_NEXTNAME,"Siguiente")	
	menu_setprop(Menu,MPROP_EXITNAME,"Cerrar")
	
	menu_display(id,Menu)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public MapsMenu_Handler(id,Menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED
	}
	
	new iData[6]
	new iName[64]
	new Access
	new Callback
	menu_item_getinfo(Menu,item,Access,iData,5,iName,63,Callback)
	
	if(!is_map_valid(iName))
		ChatColor(id,"%s Mapa no encontrado",szPrefix)
	else
		client_cmd(id,"amx_on;amx_map %s",iName)
		
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}  

//====================[*Custom Stocks*]===========================//

stock register_saycmd(const command[],const function[],flag) 
{ /* Made by me to register the say commands with the / - ! and . */	
	new temp[64]
	formatex(temp,63,"say /%s",command)
	register_clcmd(temp,function,flag)
	formatex(temp,63,"say !%s",command)
	register_clcmd(temp,function,flag)
	formatex(temp,63,"say .%s",command)
	register_clcmd(temp,function,flag)
	
}
//----------------------------------------------------------//
stock UpdateTeamScore()
{ /* Made by me to update the score in scoreboard */
	/* Counter-Terrorist */
	message_begin(MSG_ALL,TeamScore)
	write_string("CT")
	write_short(ScoreCT+TotalCT)
	message_end()
	
	/* Terrorist */
	message_begin(MSG_ALL,TeamScore)
	write_string("TERRORIST")
	write_short(ScoreT+TotalT)
	message_end()
}

//===================[*Other Stocks*]===========================//

stock ChatColor(const id, const input[], any:...) 
{ /* Used in all chats */	
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^x04")
	replace_all(msg, 190, "!y", "^x01")
	replace_all(msg, 190, "!t", "^x03")
	
	if(id)
		players[0] = id
	else
	get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
