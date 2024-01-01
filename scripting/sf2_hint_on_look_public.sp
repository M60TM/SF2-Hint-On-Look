#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <morecolors>
#include <sf2>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name = "[SF2M] Hint on Look",
	author = "Sandy",
	description = "Notify boss's stun state",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart() {
	LoadTranslations("sf2_hint.phrases");
}

public void SF2_OnClientLooksAtBoss(int client, int bossIndex) {
	if (SF2_IsClientEliminated(client)) {
		return;
	}
	
	if (SF2_GetBossType(bossIndex) != SF2BossType_Chaser) {
		return;
	}
	
	int entIndex = SF2_BossIndexToEntIndexEx(bossIndex);
	if (entIndex == -1) {
		return;
	}
	
	SF2_ChaserBossEntity chaserBossEntity = SF2_ChaserBossEntity(entIndex);
	if (!chaserBossEntity.IsValid) {
		return;
	}
	
	SF2ChaserBossProfileData chaserBossProfileData;
	chaserBossEntity.ProfileData(chaserBossProfileData);
	
	if (chaserBossProfileData.StunEnabled) {
		if (!chaserBossProfileData.DisappearOnStun) {
			int difficulty = SF2_GetCurrentDifficulty();
			if (chaserBossProfileData.FlashlightStun[difficulty]) {
				if (!chaserBossEntity.CanBeStunned) {
					PrintHintText(client, "%t", "SF2 Hint Flash Stun");
				} else {
					PrintHintText(client, "%t", "SF2 Hint Can Flash Stun");
				}
			} else {
				if (!chaserBossEntity.CanBeStunned) {
					PrintHintText(client, "%t", "SF2 Hint Hit Stun");
				} else {
					PrintHintText(client, "%t", "SF2 Hint Can Hit Stun");
				}
			}
		} else {
			int difficulty = SF2_GetCurrentDifficulty();
			if (chaserBossProfileData.FlashlightStun[difficulty]) {
				PrintHintText(client, "%t", "SF2 Hint Flash Kill");
			} else {
				PrintHintText(client, "%t", "SF2 Hint Hit Kill");
			}
		}
	}
}