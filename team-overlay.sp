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

int g_TeamColor[2][4] = {{255, 150, 150, 255}, {150, 150, 255, 255}};

public void SetPlayerColor(int client, int r, int g, int b, int a)
{
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, r, g, b, a);
}

public void UpdateColor(int client)
{
	int overlay_state = FindConVar("sm_overlay_enable").IntValue;

	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (overlay_state == 0)
		{
			SetPlayerColor(client, 255, 255, 255, 255);
			return;
		}

		int team = GetClientTeam(client);

		switch(team)
		{
			case CS_TEAM_T:
			{
				SetPlayerColor(client, g_TeamColor[0][0], g_TeamColor[0][1], g_TeamColor[0][2], g_TeamColor[0][3]);
			}

			case CS_TEAM_CT:
			{
				SetPlayerColor(client, g_TeamColor[1][0], g_TeamColor[1][1], g_TeamColor[1][2], g_TeamColor[1][3]);
			}
		}
	}
}

public void UpdateColors()
{
	for (int i = 1; i < MaxClients; ++i)
	{
		UpdateColor(i);
	}
}

public Action CMD_UpdateColors(int client, int args)
{
	UpdateColors();

	ReplyToCommand(client, "[SM] Colors Updated");

	return Plugin_Handled;
}

public void OnPluginStart()
{
	PrintToServer("[SM] Team Color Overlay has been loaded");
	CreateConVar("sm_overlay_enable", "1", "Team Overlay Toggle State");
	RegAdminCmd("sm_updatecolors", CMD_UpdateColors, ADMFLAG_ROOT, "Update Player Colors");
	HookEvent("player_spawn", UpdateColorsHook);
}

public void UpdateColorHook(int client)
{
	UpdateColor(client);
}

public Action UpdateColorsHook(Event event, const char[] name, bool dontBroadcast)
{	
	int client = GetClientOfUserId(event.GetInt("userId"));
	SDKHook(client, SDKHook_PostThinkPost, UpdateColorHook);
}
