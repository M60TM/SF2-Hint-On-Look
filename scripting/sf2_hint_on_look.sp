#include <sourcemod>
#include <sf2>
#include <cbasenpc>
#include <cbasenpc/util>

#pragma semicolon 1
#pragma newdecls required

public void OnPluginStart()
{
	LoadTranslations("sf2_hint.phrases");
}

public void SF2_OnClientLooksAtBoss(int client, int bossIndex)
{
	if (SF2_IsClientEliminated(client))
		return;
	
	if ((SF2_GetBossType(bossIndex) == SF2BossType_Chaser) && SF2_IsBossStunnable(bossIndex))
	{
		if ((SF2_GetBossState(bossIndex) == STATE_CHASE || SF2_GetBossState(bossIndex) == STATE_ALERT))
		{
			if (!SF2_CanBossDisappearOnStun(bossIndex))
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