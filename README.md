WoW 3.3.5 addon. Kader's PlateBuffs - AwesomeWotlk mod.

Fork of: https://github.com/bkader/PlateBuffs_WoTLK

Changes: 
- Now the code uses functions from the AwesomeWotlk library, we have nameplate tokens (UnitID), and thanks to this, their exact GUIDs. See: https://github.com/FrostAtom/awesome_wotlk
- Potentially updated, fixed the bug where time-infinite auras (like flags on Warsong Gulch/Arathi Basin) weren't displaying, a mistake made by the author.
- I haven't noticed any fake auras on nameplates while testing.
- The difference from the others versions of PlateBuffs circulating on the internet: thanks to the AwesomeWotlk library, it works by GUID, so when a nameplate appears on screen after being hidden, the auras show up instantly. 
- Additionally, there won’t be any duplicate auras on nameplates with the same name.
- The options 'watch combatlog' and 'save player guid' are no longer needed when using AwesomeWotlk, which may improve performance.

I also added some options:

![image](https://github.com/user-attachments/assets/3ca0665d-88f3-4bcb-b368-823b49ca42b3)

https://youtu.be/vuhZJunvZjA
