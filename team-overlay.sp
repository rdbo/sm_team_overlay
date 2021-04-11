#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

public Plugin my_info =
{
	name = "Team Color Overlay",
	author = "rdbo",
	description = "Team-Based Model Color Overlay",
	version = "1.0",
	url = ""
}

public void UpdatePlayerColor(int client)
{
	ConVar gcv_OverlayEnabled = FindConVar("sm_overlay_enabled");

	if (gcv_OverlayEnabled.IntValue == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	int team = GetClientTeam(client);

	int red = 255;
	int green = 255;
	int blue = 255;
	int alpha = 255;

	switch (team)
	{
		case CS_TEAM_T:
		{
			red   = FindConVar("sm_overlay_t_r").IntValue;
			green = FindConVar("sm_overlay_t_g").IntValue;
			blue  = FindConVar("sm_overlay_t_b").IntValue;
			alpha = FindConVar("sm_overlay_t_a").IntValue;
		}

		case CS_TEAM_CT:
		{
			red   = FindConVar("sm_overlay_ct_r").IntValue;
			green = FindConVar("sm_overlay_ct_g").IntValue;
			blue  = FindConVar("sm_overlay_ct_b").IntValue;
			alpha = FindConVar("sm_overlay_ct_a").IntValue;
		}
	}

	int active_red, active_green, active_blue, active_alpha;
	RenderMode rm = GetEntityRenderMode(client);
	GetEntityRenderColor(client, active_red, active_green, active_blue, active_alpha);

	ConVar ignore_alpha = FindConVar("sm_overlay_ignore_alpha");
	if (ignore_alpha.IntValue)
		alpha = active_alpha;

	bool unchanged_check = (red == active_red && green == active_green && blue == active_blue && alpha == active_alpha);

	if (unchanged_check)
		return;

	SetEntityRenderColor(client, red, green, blue, active_alpha);
}

public void OnPluginStart()
{
	PrintToServer("[SM] Team Color Overlay has been loaded");
	CreateConVar("sm_overlay_enabled", "1", "Team Overlay Toggle State");
	CreateConVar("sm_overlay_ignore_alpha", "1", "Ignore Alpha Value");
	CreateConVar("sm_overlay_t_r", "255", "Terrorist Team Red Value");
	CreateConVar("sm_overlay_t_g", "155", "Terrorist Team Green Value");
	CreateConVar("sm_overlay_t_b", "105", "Terrorist Team Blue Value");
	CreateConVar("sm_overlay_t_a", "255", "Terrorist Team Alpha Value");
	CreateConVar("sm_overlay_ct_r", "105", "Counter-Terrorists Team Red Value");
	CreateConVar("sm_overlay_ct_g", "155", "Counter-Terrorists Team Green Value");
	CreateConVar("sm_overlay_ct_b", "255", "Counter-Terrorists Team Blue Value");
	CreateConVar("sm_overlay_ct_a", "255", "Counter-Terrorists Team Alpha Value");
	HookEvent("player_spawn", UpdateColorsHook);
}

public void UpdateColorHook(int client)
{
	UpdatePlayerColor(client);
}

public Action UpdateColorsHook(Event event, const char[] name, bool dontBroadcast)
{	
	int client = GetClientOfUserId(event.GetInt("userId"));
	SDKHook(client, SDKHook_PostThinkPost, UpdateColorHook);
}
