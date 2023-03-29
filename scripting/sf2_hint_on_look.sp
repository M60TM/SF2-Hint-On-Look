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
    if ((SF2_GetBossType(bossIndex) == SF2BossType_Chaser) && (SF2_GetBossState(bossIndex) == STATE_CHASE || SF2_GetBossState(bossIndex) == STATE_ALERT)
            && (SF2_IsBossStunnableByFlashlight(bossIndex) && SF2_IsBossStunnable(bossIndex)))
    {
        PrintHintText(client, "%T", "SF2 Hint Flash Stun", client);
    }
    else if ((SF2_GetBossType(bossIndex) == SF2BossType_Chaser) && (SF2_GetBossState(bossIndex) == STATE_CHASE || SF2_GetBossState(bossIndex) == STATE_ALERT)
            && (!SF2_IsBossStunnableByFlashlight(bossIndex) && SF2_IsBossStunnable(bossIndex)))
    {
        PrintHintText(client, "%T", "SF2 Hint Hit Stun", client);
    }
    else
    {
    }
    
    /*
    int bossFlag = SF2_GetBossFlags(bossIndex);
    if (bossFlag & SFF_STATICONLOOK)
    {
        PrintHintText(client, "%T", "SF2 Hint Static on Look", client);
    }
    */
}