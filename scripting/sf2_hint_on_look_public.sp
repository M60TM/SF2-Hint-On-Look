#include <sourcemod>
#include <sf2>
#include <cbasenpc>
#include <cbasenpc/util>

#pragma semicolon 1
#pragma newdecls required

// TODO: MAKE NATIVE
static bool g_NpcHasDisappearOnStun[MAX_BOSSES] = { false, ... };

public void OnPluginStart()
{
	LoadTranslations("sf2_hint.phrases");
}

public void SF2_OnBossAdded(int bossIndex)
{
	char profile[SF2_MAX_PROFILE_NAME_LENGTH];
	SF2_GetBossName(bossIndex, profile, sizeof(profile));
	
	g_NpcHasDisappearOnStun[bossIndex] = view_as<bool>(SF2_GetBossProfileNum(profile, "disappear_on_stun", 0));
}

public void SF2_OnClientLooksAtBoss(int client, int bossIndex)
{
	if (SF2_IsClientEliminated(client))
		return;
	
	if ((SF2_GetBossType(bossIndex) == SF2BossType_Chaser) && SF2_IsBossStunnable(bossIndex))
	{
		if ((SF2_GetBossState(bossIndex) == STATE_CHASE || SF2_GetBossState(bossIndex) == STATE_ALERT))
		{
			if (!g_NpcHasDisappearOnStun[bossIndex])
			{
				if (SF2_GetBossNextStunTime(bossIndex) > GetGameTime())
				{
					if (SF2_IsBossStunnableByFlashlight(bossIndex))
					{
						PrintHintText(client, "%T", "SF2 Hint Flash Stun", client);
					}
					else
					{
						PrintHintText(client, "%T", "SF2 Hint Hit Stun", client);
					}
				}
				else
				{
					if (SF2_IsBossStunnableByFlashlight(bossIndex))
					{
						PrintHintText(client, "%T", "SF2 Hint Can Flash Stun", client);
					}
					else
					{
						PrintHintText(client, "%T", "SF2 Hint Can Hit Stun", client);
					}
				}
			}
			else
			{
				if (SF2_IsBossStunnableByFlashlight(bossIndex))
				{
					PrintHintText(client, "%T", "SF2 Hint Flash Kill", client);
				}
				else
				{
					PrintHintText(client, "%T", "SF2 Hint Hit Kill", client);
				}
			}
		}
	}
}