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

ConVar gcv_OverlayEnabled;
ConVar gcv_IgnoreAlpha;
ConVar gcv_Overlay_T_R;
ConVar gcv_Overlay_T_G;
ConVar gcv_Overlay_T_B;
ConVar gcv_Overlay_T_A;
ConVar gcv_Overlay_CT_R;
ConVar gcv_Overlay_CT_G;
ConVar gcv_Overlay_CT_B;
ConVar gcv_Overlay_CT_A;

public void UpdatePlayerColor(int client)
{
	if (gcv_OverlayEnabled.IntValue == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	int team = GetClientTeam(client);
	if (team < CS_TEAM_T)
		return;

	int red = 255;
	int green = 255;
	int blue = 255;
	int alpha = 255;

	switch (team)
	{
		case CS_TEAM_T:
		{
			red   = gcv_Overlay_T_R.IntValue;
			green = gcv_Overlay_T_G.IntValue;
			blue  = gcv_Overlay_T_B.IntValue;
			alpha = gcv_Overlay_T_A.IntValue;
		}

		case CS_TEAM_CT:
		{
			red   = gcv_Overlay_CT_R.IntValue;
			green = gcv_Overlay_CT_G.IntValue;
			blue  = gcv_Overlay_CT_B.IntValue;
			alpha = gcv_Overlay_CT_A.IntValue;
		}
	}

	int active_red, active_green, active_blue, active_alpha;
	GetEntityRenderColor(client, active_red, active_green, active_blue, active_alpha);

	if (gcv_IgnoreAlpha.IntValue)
		alpha = active_alpha;

	bool unchanged_check = (red == active_red && green == active_green && blue == active_blue && alpha == active_alpha);

	if (unchanged_check)
		return;

	SetEntityRenderColor(client, red, green, blue, alpha);
}

public void OnPluginStart()
{
	PrintToServer("[SM] Team Color Overlay has been loaded");
	gcv_OverlayEnabled = CreateConVar("sm_overlay_enabled", "1", "Team Overlay Toggle State");
	gcv_IgnoreAlpha = CreateConVar("sm_overlay_ignore_alpha", "1", "Ignore Alpha Value");
	gcv_Overlay_T_R = CreateConVar("sm_overlay_t_r", "255", "Terrorist Team Red Value");
	gcv_Overlay_T_G = CreateConVar("sm_overlay_t_g", "155", "Terrorist Team Green Value");
	gcv_Overlay_T_B = CreateConVar("sm_overlay_t_b", "105", "Terrorist Team Blue Value");
	gcv_Overlay_T_A = CreateConVar("sm_overlay_t_a", "255", "Terrorist Team Alpha Value");
	gcv_Overlay_CT_R = CreateConVar("sm_overlay_ct_r", "105", "Counter-Terrorists Team Red Value");
	gcv_Overlay_CT_G = CreateConVar("sm_overlay_ct_g", "155", "Counter-Terrorists Team Green Value");
	gcv_Overlay_CT_B = CreateConVar("sm_overlay_ct_b", "255", "Counter-Terrorists Team Blue Value");
	gcv_Overlay_CT_A = CreateConVar("sm_overlay_ct_a", "255", "Counter-Terrorists Team Alpha Value");
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    UpdatePlayerColor(client);
}
