local folder, core = ...
local L = LibStub("AceLocale-3.0"):NewLocale(folder, "frFR")
if not L then return end
L["Add Spell Description"] = "Ajouter une description du sort"
L["Add buffs above NPCs"] = "Ajouter les buffs au-dessus des PNJ"
L["Add buffs above friendly plates"] = "Ajouter les buffs au-dessus des alliés"
L["Add buffs above hostile plates"] = "Ajouter les buffs au-dessus des ennemis"
L["Add buffs above neutral plates"] = "Ajouter les buffs au-dessus des neutres"
L["Add buffs above players"] = "Ajouter les buffs au-dessus des joueurs"
L["Add spell"] = "Ajouter le sort"
L[ [=[Add spell descriptions to the specific spell's list.
Disabling this will lower memory usage and login time.]=] ] = [=[Ajouter des descriptions de sorts à la liste des sorts particuliers.
Désactiver ceci diminuera l'utilisation mémoire et la durée de chargement.]=]
L["Add spell to list."] = "Ajouter le sort à la liste"
L["Added: "] = "Ajouté:"
L["All"] = "Tous"
L["Always"] = "Toujours"
L["Always show spell, only show your spell, never show spell"] = "Toujours montrer le sort, seulement le votre, jamais"
L["Bar"] = "Barre"
L["Bar Anchor Point"] = "Point d'ancrage de la barre"
L["Bar Growth"] = "Agrandissement de la barre. "
L["Bar X Offset"] = "Offset X de la barre"
L["Bar Y Offset"] = "Offset Y de la barre"
L["Bars"] = "Barres"
L["Blink Timeleft"] = "Clignotement du temps restant"
L["Blink spell if below x% timeleft, (only if it's below 60 seconds)"] = "Clignotement du sort si moins de x% sec restantes. (seulement sous les 60 secondes)"
L["Bottom"] = "En Bas"
L["Bottom Left"] = "En Bas à gauche"
L["Bottom Right"] = "En Bas à droite"
L["Center"] = "Centre"
L["Cooldown Size"] = "Taille du temps de recharge"
L["Cooldown Text Font"] = "Police du texte de recharge"
L["Cooldown Text Size"] = "Taille du texte de recharge"
L["Core"] = "Cœur"
L["Default Spells"] = "Sorts par défaut"
L["Display a question mark above plates we don't know spells for. Target or mouseover those plates."] = "Afficher un point d'interrogation au-dessus des icônes / Cibler ou passer la souris au dessus."
L["Down"] = "Bas"
L["Enable"] = "Activer"
L["Enables / Disables the addon"] = "Activer / Désactiver l'Addon"
L[ [=[For each spell on someone, multiply it by the number of icons per bar.
This option won't be saved at logout.]=] ] = [=[Pour chaque sort sur quelqu'un, le multiplier par le nombre d'icônes par barre.
Cette option se sera pas sauvegardé à la déconnexion.]=]
L["Friendly"] = "Amical"
L["Hostile"] = "Hostile"
L["Icon Size"] = "Taille d'icône"
L["Icons per bar"] = "Icônes par barre."
L["Input a spell name. (case sensitive)"] = "Entrer un nom de sort. (sensible à la case)"
L[ [=[Input a spell name. (case sensitive)
Or spellID]=] ] = [=[Entrez un nom de sort. (sensible à la casse)
Ou un ID de sort]=]
L["Larger self spells"] = "Sorts personnels plus gros"
L["Left"] = "Gauche"
L["Left to right offset."] = "Décalage de gauche à droite."
L["Make your spells 20% bigger then other's."] = "Affiche vos sorts 20% plus grand que ceux des autres."
L["Max bars"] = "Nombre max de barres"
L["Max number of bars to show."] = "Nombre max de barres à afficher"
L["Mine Only"] = "Les miens seulement"
L["Mine only"] = "Seulement les miens"
L["NPC"] = "PNJ"
L["NPC combat only"] = "PNJ de combat seulement"
L["Neutral"] = "Neutre"
L["Never"] = "Jamais"
L["None"] = "Aucun"
L["Number of icons to display per bar."] = "Nombre d'icônes par barre."
L["Only show spells above nameplates that are in combat."] = "Montrer les sorts seulement sur les unités en combat"
L["Other"] = "Autre"
L["Plate Anchor Point"] = "Point d'ancrage de la barre de nom"
L["Player combat only"] = "En combat seulement"
L["Players"] = "Joueurs"
L[ [=[Point of the buff frame that gets anchored to the nameplate.
default = Bottom]=] ] = [=[Point du cadre des buffs qui est ancrée à la barre de nom.
Par défaut : bas]=]
L[ [=[Point of the nameplate our buff frame gets anchored to.
default = Top]=] ] = [=[Point de la barre de nom auquel est ancrée le cadre des buffs.
Par défaut : haut]=]
L["Profiles"] = "Profils"
L["Reaction"] = "Réaction"
L[ [=[Remember player GUID's so target/mouseover isn't needed every time nameplate appears.
Keep this enabled]=] ] = [=[Enregistrer l'IU pour ne pas avoir à cibler ou survoler de la souris chaque fois qu'une barre de nom apparaît.
Garder cette option active.]=]
L["Remove Spell"] = "Enlever le sort"
L["Remove spell from list"] = "Enlever le sort de la liste"
L["Right"] = "Droit"
L["Row Anchor Point"] = "Ancre de la ligne"
L["Row Growth"] = "Agrandissement de la ligne"
L["Row X Offset"] = "Décalage horizontal de la ligne"
L["Row Y Offset"] = "Offset vertical de la ligne"
L["Rows"] = "Lignes"
L["Save player GUID"] = "Sauver l'interface du joueur."
L["Save player GUID's"] = "Sauvegarder la GUID du joueur"
L["Show"] = "Montrer"
L["Show Aura"] = "Afficher les auras"
L["Show Buffs"] = "Afficher les buffs"
L["Show Debuffs"] = "Afficher les débuffs"
L["Show Totems"] = "Afficher les totems"
L["Show a clock overlay over spell textures showing the time remaining."] = "Montrer le temps restant par dessus les textures des sorts"
L["Show auras above nameplate. This sometimes causes duplicate buffs."] = [=[Montrer les auras au dessus de la barre de nom.
Cause parfois des doublons de buffs.]=]
L["Show bar background"] = "Montrer le fond des bares"
L["Show buffs above nameplate."] = "Montrer les buffs au-dessus de la barre de nom"
L["Show by default"] = "Montrer par défaut"
L["Show cooldown"] = "Montrer le temps de recharge"
L["Show cooldown overlay"] = "Montrer la spirale de recharge" -- Needs review
L["Show cooldown text under the spell icon."] = "Montrer le temps de recharge sous l'icône du sort"
L["Show debuffs above nameplate."] = "Montrer le debuff au-dessus de la barre de nom"
L["Show spell icons on totems"] = "Montrer les icônes des totems"
L["Show the area where spell icons will be. This is to help you configure the bars."] = "Montrer la zone où seront les icônes de sort. Aide à configurer les barres."
L["Shrink Bar"] = "Réduire la barre"
L["Shrink the bar horizontally when spells frames are hidden."] = "Réduire la barre horizontalement quand les cadres des sorts sont cachés."
L["Size of the icons."] = "Taille des icônes"
L["Specific"] = "Spécifique"
L["Specific Spells"] = "Sorts particuliers"
L["Spell name"] = "Nom du sort"
L["Spells"] = "Sorts"
L["Spells not in the Specific Spells list will use these options."] = "Les sorts qui ne font pas partie des sorts particuliers utiliseront ces options."
L["Stack Size"] = "Taille de la pile"
L["Stack Text Size"] = "Taille du texte du nombre de sort" -- Needs review
L["Test Mode"] = "Mode Test"
L["Text size"] = "Taille du texte"
L["This overlay tends to disappear when the frame's moving."] = "Cette superposition tend à disparaitre quand le cadre bouge"
L["Top"] = "Haut"
L["Top Left"] = "Haut gauche"
L["Top Right"] = "Haut droit"
L["Type"] = "Type"
L["Unknown spell info"] = "Pas d'info de sort"
L["Up"] = "Haut"
L["Up to down offset."] = "Décalage du haut vers le bas"
L["Watch Combatlog"] = "Suivre le log du combat"
L[ [=[Watch combatlog for people gaining/losing spells.
Disable this if you're having performance issues.]=] ] = [=[Suivre le log de combat pour ceux qui gagnent/perdent un sort
Désactiver en cas de problèmes de performances]=]
L["Which way do the bars grow, up or down."] = "Sens vers lequel les barres s'agrandissent, haut ou bas."
L["Who"] = "Qui"
L["sizes: 9, 10, 12, 13, 14, 16, 20"] = "Taille: 9, 10, 12, 13, 14, 16, 20"
L["spells to show by default"] = "Sort à montrer par défaut"
L["Legacy cooldown overlay"] = "Ancien mode de spirale"
L["Use the old clock overlay to which cooldown text addons can hook their texts.\nRequires UI Reload."] = "Utiliser l'ancienne spirale de recharge à laquelle les addons de texte de temps de recharge peuvent ajouter leurs textes.\nNécessite un rechargement de l'interface."