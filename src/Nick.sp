#include <sourcemod>
#include <sdktools>
 
 
#pragma semicolon 1
#pragma newdecls required

ConVar g_cvarNickCharacterLimit = null;
 
public Plugin myinfo = {
	name = "Nick Plugin",
	author = "FeaturedSpace",
	description = "Allow VIPs to nick themselves if they have a value in the specified database",
	version = "1.0.0",
	url = "http://www.sourcemod.net/"
}
 
public void OnPluginStart() {
	RegAdminCmd("nick", Command_Nick, ADMFLAG_CHAT);
	//LoadTranslations("common.phrases.txt");
 
	g_cvarNickCharacterLimit = CreateConVar("nick_character_limit", "16", "Maximum nick characters");
	AutoExecConfig(true, "plugin_nick");
}
 
public Action Command_Nick(int client, int args) {
	char arg1[32], arg2[32];
	int max_chars = g_cvarNickCharacterLimit.IntValue;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
	
	
	char[32] target_name;
	int target = client;
 
	/* If there are 2 or more arguments, then that means an admin is attempting to set the nick
	of another user. The 1st arg is the target and the second is the new nickname.
	 */
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2))) {
		target = FindTarget(client, arg1);
		if (target == -1)
		{
			/* FindTarget() automatically replies with the 
			 * failure reason and returns -1 so we know not 
			 * to continue
			 */
			ReplyToCommand("Failed to find that player!");
			return Plugin_Handled;
		}
	
		char[max_chars] nick = arg2;
	} else {
		char[max_chars] nick = arg1;
 	}
	
	// Retrieve our clients current name
	GetClientName(target, target_name, sizeof(target_name));
	
 	
	// Change the client's name
	NickPlayer(target, nick);
	
	// Broadcast the name. (In the final version this will definitely not be included. There is simply no need.
	ShowActivity2(client, "[WiT] ", "%t changed their nickname to %t!", target_name, nick);
 
	return Plugin_Handled;
}

public void NickPlayer(int client, char[max_chars] nick) {
	SetClientName(client, nick);
	LogAction(client, "ID \"%L\"'s nick was set to \"%L\"", client, nick);
}
