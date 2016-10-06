/* most temp and copy table queries removed; zonetemp/doorstemp are needed 8/9/15 */

/* drops and creates temp tables in peq */

use peq;

DROP TABLE IF EXISTS `peq`.`doorstemp`;
CREATE TABLE IF NOT EXISTS `peq`.`doorstemp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doorid` smallint(4) NOT NULL DEFAULT '0',
  `zone` varchar(32) DEFAULT NULL,
  `version` smallint(5) NOT NULL DEFAULT '0',
  `name` varchar(32) NOT NULL DEFAULT '',
  `pos_y` float NOT NULL DEFAULT '0',
  `pos_x` float NOT NULL DEFAULT '0',
  `pos_z` float NOT NULL DEFAULT '0',
  `heading` float NOT NULL DEFAULT '0',
  `opentype` smallint(4) NOT NULL DEFAULT '0',
  `guild` smallint(4) NOT NULL DEFAULT '0',
  `lockpick` smallint(4) NOT NULL DEFAULT '0',
  `keyitem` int(11) NOT NULL DEFAULT '0',
  `nokeyring` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `triggerdoor` smallint(4) NOT NULL DEFAULT '0',
  `triggertype` smallint(4) NOT NULL DEFAULT '0',
  `doorisopen` smallint(4) NOT NULL DEFAULT '0',
  `door_param` int(4) NOT NULL DEFAULT '0',
  `dest_zone` varchar(32) DEFAULT 'NONE',
  `dest_instance` int(10) unsigned NOT NULL DEFAULT '0',
  `dest_x` float DEFAULT '0',
  `dest_y` float DEFAULT '0',
  `dest_z` float DEFAULT '0',
  `dest_heading` float DEFAULT '0',
  `invert_state` int(11) DEFAULT '0',
  `incline` int(11) DEFAULT '0',
  `size` smallint(5) unsigned NOT NULL DEFAULT '100',
  `buffer` float DEFAULT '0',
  `client_version_mask` int(10) unsigned NOT NULL DEFAULT '4294967295',
  `is_ldon_door` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `DoorIndex` (`zone`,`doorid`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
DROP TABLE IF EXISTS `peq`.`zonetemp`;
CREATE TABLE IF NOT EXISTS `peq`.`zonetemp` (
  `zone` varchar(32) NOT NULL DEFAULT '0',
  `zoneidnumber` int(4) NOT NULL DEFAULT '0',
  `id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `zoneidnumber` (`zone`,`zoneidnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* most temp and copy table queries removed; the two above are needed 8/9/15 */

use peq;

# copies character basics, zones and server settings; original expansion
truncate table original.zone;
replace original.zone select * from peq.zone where peq.zone.zoneidnumber < 78 and peq.zone.zoneidnumber != 26 
	and peq.zone.zoneidnumber != 28 and peq.zone.zoneidnumber != 43 and peq.zone.zoneidnumber != 53 and peq.zone.zoneidnumber != 39 
	and peq.zone.zoneidnumber != 71 and peq.zone.zoneidnumber != 72 and peq.zone.zoneidnumber != 76 or peq.zone.zoneidnumber = 98;

# create zonetemp (changed `short_name` to `zone`) change zoneidnumber as needed
truncate table peq.zonetemp;
replace peq.zonetemp (zone,zoneidnumber,id) select zone.short_name,zone.zoneidnumber,zone.id 
	from zone where peq.zone.zoneidnumber < 78 and peq.zone.zoneidnumber != 26 and peq.zone.zoneidnumber != 28
	and peq.zone.zoneidnumber != 43 and peq.zone.zoneidnumber != 53 and peq.zone.zoneidnumber != 39 and peq.zone.zoneidnumber != 71 
	and peq.zone.zoneidnumber != 72 and peq.zone.zoneidnumber != 76 or peq.zone.zoneidnumber = 98;
	
# places zone objects and information

# there are no zone_points for zones 26, 28, 43 and 53
truncate table original.zone_points;
replace original.zone_points SELECT zone_points.* FROM zonetemp JOIN zone_points USING (zone)
	where (peq.zone_points.target_zone_id != 72 and peq.zone_points.target_zone_id != 39 and peq.zone_points.target_zone_id != 71
	and peq.zone_points.target_zone_id != 76) and (peq.zone_points.target_zone_id < 78 or peq.zone_points.target_zone_id = 98);

truncate table peq.doorstemp;
replace peq.doorstemp SELECT doors.* FROM zonetemp JOIN doors USING (zone);

truncate table original.doors;	
replace original.doors select distinct doorstemp.* from zonetemp join doorstemp
	where doorstemp.dest_zone = zonetemp.zone or dest_zone like 'none' and is_ldon_door = 0 and name not like '%700%';

# populates npc and spawn tables
truncate table original.spawn2;
replace original.spawn2 SELECT spawn2.* FROM zonetemp JOIN spawn2 USING (zone); # where version = 0;

truncate table original.spawngroup;
replace original.spawngroup SELECT peq.spawngroup.* FROM original.spawn2 JOIN peq.spawngroup
	where peq.spawngroup.id = original.spawn2.spawngroupID;
	
truncate table original.spawnentry;
replace original.spawnentry SELECT peq.spawnentry.* FROM original.spawngroup JOIN peq.spawnentry
	where original.spawngroup.id = peq.spawnentry.spawngroupID;

truncate table original.npc_types;
replace original.npc_types SELECT peq.npc_types.* FROM original.spawnentry JOIN npc_types
	where npc_types.id = original.spawnentry.npcID;
replace original.npc_types select peq.npc_types.* from quest_npcs
	join peq.npc_types on quest_npcs.npc_id = peq.npc_types.id
	join zonetemp on quest_npcs.zoneid = zonetemp.zoneidnumber where peq.npc_types.expansion = -1;
replace original.npc_types select peq.npc_types.* from quest_npcs
	join peq.npc_types on quest_npcs.npc_id = peq.npc_types.id where peq.npc_types.expansion = 0;

# creates npc behavior and pathing
truncate table original.grid;
replace original.grid select peq.grid.* from zonetemp join peq.grid where zonetemp.zoneidnumber = peq.grid.zoneid;

truncate table original.grid_entries;
replace original.grid_entries select peq.grid_entries.* from zonetemp join peq.grid_entries
	where zonetemp.zoneidnumber = peq.grid_entries.zoneid;

# gives npcs loot
truncate table original.loottable;
replace original.loottable select loottable.* from original.npc_types join loottable
	where loottable.id = original.npc_types.loottable_id;

truncate table original.loottable_entries;
replace original.loottable_entries select loottable_entries.* from original.loottable join loottable_entries
	where original.loottable.id = loottable_entries.loottable_id;

truncate table original.lootdrop;
replace original.lootdrop select lootdrop.* from original.loottable_entries join lootdrop
	where lootdrop.id = original.loottable_entries.lootdrop_id;
	
truncate table original.lootdrop_entries;
replace original.lootdrop_entries select lootdrop_entries.* from original.lootdrop join lootdrop_entries
	where original.lootdrop.id = lootdrop_entries.lootdrop_id;

# populates various items tables
truncate table original.merchantlist;
replace original.merchantlist select merchantlist.* from original.npc_types join merchantlist
	where merchantlist.merchantid = original.npc_types.merchant_id;

truncate table original.tradeskill_recipe;
replace original.tradeskill_recipe select * from peq.tradeskill_recipe where peq.tradeskill_recipe.expansion = 0;

update original.tradeskill_recipe set enabled = 1;

truncate table original.tradeskill_recipe_entries;
replace original.tradeskill_recipe_entries select peq.tradeskill_recipe_entries.* from peq.tradeskill_recipe
	join peq.tradeskill_recipe_entries where peq.tradeskill_recipe_entries.recipe_id = peq.tradeskill_recipe.id
	and peq.tradeskill_recipe.`expansion` = 0;

truncate table original.items;
replace original.items select items.* from items where items.expansion = 0;
replace original.items SELECT distinct items.* FROM peq.forage JOIN items where exists
	(select * from peq.zonetemp where peq.zonetemp.zoneidnumber = peq.forage.zoneid) and peq.forage.Itemid = items.id
	and (peq.items.expansion = -1 or peq.items.expansion = 0);
replace original.items SELECT distinct items.* FROM peq.fishing JOIN items where exists
	(select * from peq.zonetemp where peq.zonetemp.zoneidnumber = peq.fishing.zoneid) and peq.fishing.Itemid = items.id
	and (peq.items.expansion = -1 or peq.items.expansion = 0);
replace original.items SELECT distinct items.* FROM peq.ground_spawns JOIN items where exists
	(select * from peq.zonetemp where peq.zonetemp.zoneidnumber = peq.ground_spawns.zoneid)
	and peq.ground_spawns.Item = items.id and (peq.items.expansion = -1 or peq.items.expansion = 0);
replace original.items select distinct items.* from peq.starting_items join items where exists
	(select * from peq.zonetemp where peq.zonetemp.zoneidnumber = peq.starting_items.zoneid)
	and peq.starting_items.Itemid = items.id and (peq.items.expansion = -1 or peq.items.expansion = 0);
	 	
# update original.items set original.items.expansion = 0;
# update peq.items,original.items set peq.items.expansion = 0 where peq.items.id = original.items.id and original.items.expansion = 0;

replace original.items SELECT items.* FROM original.merchantlist JOIN items
	where original.merchantlist.Item = items.id and (peq.items.expansion = -1 or peq.items.expansion = 0);
replace original.items SELECT items.* FROM original.tradeskill_recipe JOIN items USING (name) 
	where (peq.items.expansion = -1 or peq.items.expansion = 0);
replace original.items SELECT items.* FROM original.tradeskill_recipe_entries JOIN items
	where original.tradeskill_recipe_entries.Item_id = items.id and (peq.items.expansion = -1 or peq.items.expansion = 0);
replace original.items select distinct peq.items.* from original.lootdrop_entries,peq.items
	where peq.items.id = original.lootdrop_entries.item_id and (peq.items.expansion = -1 or peq.items.expansion = 0);

# populates pc spells table, items with spell effects
truncate table original.spells_new;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes1 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes2 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes3 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes4 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes5 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes6 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes7 < 51 order by id;	
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes8 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes9 < 51 order by id;	
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes10 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes11 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes12 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes13 < 51 order by id;
replace original.spells_new select spells_new.* from spells_new join original.items
	where original.items.scrolleffect = spells_new.id and spells_new.classes14 < 51 order by id;

replace original.spells_new select spells_new.* from zonetemp join spells_new where zonetemp.zone = spells_new.teleport_zone;

replace original.items select distinct peq.items.* from peq.items join original.spells_new
	where peq.items.id = original.spells_new.components1;
replace original.items select distinct peq.items.* from peq.items join original.spells_new
	where peq.items.id = original.spells_new.components2;
replace original.items select distinct peq.items.* from peq.items join original.spells_new
	where peq.items.id = original.spells_new.components3;

replace original.spells_new select distinct spells_new.* from spells_new join original.items
	where original.items.clickeffect = spells_new.id and clickeffect > 0 order by id;

replace original.spells_new select distinct spells_new.* from spells_new join original.items
	where original.items.proceffect = spells_new.id and proceffect > 0 order by id;
	
replace original.spells_new select distinct spells_new.* from spells_new join original.items
	where original.items.worneffect = spells_new.id and worneffect > 0 order by id;

replace original.spells_new select distinct spells_new.* from spells_new join original.items
	where original.items.bardeffect = spells_new.id and bardeffect > 0 order by id;

replace original.spells_new select spells_new.* from aa_ranks
	join spells_new on spells_new.id = aa_ranks.spell and peq.aa_ranks.expansion = 0;

/* moved to below 10/22/15
replace original.npc_types select distinct npc_types.* from original.spells_new join npc_types
	where original.spells_new.teleport_zone = npc_types.name and npc_types.name not like '';
*/
truncate table original.npc_spells;
replace original.npc_spells select distinct npc_spells.* from original.npc_types join npc_spells
	where original.npc_types.npc_spells_id = npc_spells.id order by id;
replace original.npc_spells select distinct peq.npc_spells.* from original.npc_spells
	join peq.npc_spells on peq.npc_spells.id = original.npc_spells.parent_list
	where original.npc_spells.parent_list > 0;

truncate table original.npc_spells_entries;
replace original.npc_spells_entries select distinct npc_spells_entries.* from original.npc_types 
	join npc_spells_entries using (npc_spells_id) order by npc_spells_id;
replace original.npc_spells_entries select distinct peq.npc_spells_entries.* from original.npc_spells
	join peq.npc_spells_entries on peq.npc_spells_entries.npc_spells_id = original.npc_spells.parent_list
	where original.npc_spells.parent_list > 0;

replace original.spells_new select distinct spells_new.* from original.npc_spells_entries
	join spells_new where npc_spells_entries.spellid = spells_new.id order by id;
	
replace original.spells_new select distinct spells_new.* from original.npc_spells
	join spells_new where npc_spells.attack_proc = spells_new.id order by id;

replace original.spells_new select distinct peq.spells_new.* from original.spells_new
	join peq.spells_new on peq.spells_new.id = original.spells_new.RecourseLink
	where original.spells_new.RecourseLink > 0 order by peq.spells_new.id;

replace original.npc_types select distinct npc_types.* from original.spells_new join npc_types
	where original.spells_new.teleport_zone = npc_types.name and npc_types.name not like '';
