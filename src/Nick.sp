#include <sourcemod>
#include <sdktools>
 
 
#pragma semicolon 1
#pragma newdecls required

ConVar g_cvarNickCharacterLimit = null;
 
public Plugin myinfo = {
	name = "Basic Nick Plugin",
	author = "FeaturedSpace",
	description = "Allow VIPs to nick themselves if they have a value in the specified database",
	version = "1.0.0",
	url = "http://www.sourcemod.net/"
}
 
public void OnPluginStart() {
	RegAdminCmd("nick", Command_Nick, ADMFLAG_CHAT);
	LoadTranslations("common.phrases.txt");
 
	g_cvarMySlapDamage = CreateConVar("nick_character_limit", "16", "Maximum nick characters");
	AutoExecConfig(true, "plugin_nick");
}
 
public Action Command_Nick(int client, int args) {
	char arg1[32], arg2[32];
	int max_chars = g_cvarNickCharacterLimit.IntValue;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
	
	
	
 
	/* If there are 2 or more arguments, then that means an admin is attempting to set the nick
	of another user. The 1st arg is the target and the second is the new nickname.
	 */
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2))) {
		/**
		 * target_name - stores the noun identifying the target(s)
		 * target_list - array to store clients
		 * target_count - variable to store number of clients
		 * tn_is_ml - stores whether the noun must be translated
		 */
		char target_name[MAX_TARGET_LENGTH];
		int target_list[MAXPLAYERS], target_count;
		bool tn_is_ml;

		if ((target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE, /* Only allow alive players */
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			/* This function replies to the admin with a failure message */
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}

		for (int i = 0; i < target_count; i++) {
			NickPlayer(target_list[i], nick);
			LogAction(client, target_list[i], "\"%L\" nicked \"%L\" (nick: %L)", client, target_list[i], nick);
		}
	}
	
	char[max_chars] nick = arg1;
 
	
 
	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "Nicked to %t!", target_name, nick);
	}
	else {
		ShowActivity2(client, "[SM] ", "Nicked to %t!", target_name, nick);
	}
 
	return Plugin_Handled;
}

public void NickPlayer(int client, char[max_chars] nick) {
	SetClientName(client, nick);
	LogAction(client, "ID \"%L\"'s nick was set to \"%L\"", client, nick);
}
