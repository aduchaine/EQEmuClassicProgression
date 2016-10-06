/* Deletion of errant and stagnant accounts and characters
	USE WITH CARE - comment out as needed */

use jeryds;

# errant logins
delete from account where charname = ' ';

# 180 days and under 30 minutes in game
delete from character_data where last_login < unix_timestamp () - 15552000 and time_played < 30;

# 30 days and under 10 minutes in game
delete from character_data where last_login < unix_timestamp () - 2592000 and time_played < 10;

/* deletes account and character entries associated with inactive/unused characters above
	USE WITH CARE */
/* unsure if this will delete accounts if it has active characters and inactive characters
	deleted from the previous query */
delete from account where not exists (select * from character_data 
	where character_data.account_id = account.id);

delete from character_lookup where not exists (select * from character_data 
	where character_data.id = character_lookup.id);

delete from character_bind where not exists (select * from character_data 
	where character_data.id = character_bind.id); 

delete from character_buffs where not exists (select * from character_data 
	where character_data.id = character_buffs.character_id); 

delete from character_corpses where not exists (select * from character_data 
	where character_data.id = character_corpses.charid); 

delete from character_currency where not exists (select * from character_data 
	where character_data.id = character_currency.id); 

delete from character_languages where not exists (select * from character_data 
	where character_data.id = character_languages.id); 

delete from character_memmed_spells where not exists (select * from character_data 
	where character_data.id = character_memmed_spells.id); 

delete from character_pet_buffs where not exists (select * from character_data 
	where character_data.id = character_pet_buffs.char_id);
	
delete from character_skills where not exists (select * from character_data 
	where character_data.id = character_skills.id); 	
	
delete from character_spells where not exists (select * from character_data 
	where character_data.id = character_spells.id);	
	
delete from char_recipe_list where not exists (select * from character_data 
	where character_data.id = char_recipe_list.char_id);	
	
delete from faction_values where not exists (select * from character_data 
	where character_data.id = faction_values.char_id);	
	
delete from friends where not exists (select * from character_data 
	where character_data.id = friends.charid); 	

delete from inventory where not exists (select * from character_data 
	where character_data.id = inventory.charid);
		
delete from mail where not exists (select * from character_data 
	where character_data.id = mail.charid);	

/* Deletion of old qs records
	USE WITH CARE - comment out as needed */

use eq_player_data_backup;

delete from qs_merchant_transaction_record where `time` 
	< date_sub(current_timestamp (),interval 90 DAY);

delete from qs_merchant_transaction_record_entries where not exists (select * from qs_merchant_transaction_record 
	where qs_merchant_transaction_record_entries.event_id = qs_merchant_transaction_record.transaction_id); 

delete from qs_player_delete_record where `time` 
	< date_sub(current_timestamp (),interval 90 DAY);

delete from qs_player_delete_record_entries where not exists (select * from qs_player_delete_record 
	where qs_player_delete_record_entries.event_id = qs_player_delete_record.delete_id);

delete from qs_player_handin_record where `time` 
	< date_sub(current_timestamp (),interval 90 DAY);

delete from qs_player_handin_record_entries where not exists (select * from qs_player_handin_record 
	where qs_player_handin_record_entries.event_id = qs_player_handin_record.handin_id); 

delete from qs_player_move_record where `time` 
	< date_sub(current_timestamp (),interval 90 DAY);

delete from qs_player_move_record_entries where not exists (select * from qs_player_move_record 
	where qs_player_move_record_entries.event_id = qs_player_move_record.move_id); 

delete from qs_player_npc_kill_record where `time` 
	< date_sub(current_timestamp (),interval 90 DAY);

delete from qs_player_npc_kill_record_entries where not exists (select * from qs_player_npc_kill_record 
	where qs_player_npc_kill_record_entries.event_id = qs_player_npc_kill_record.fight_id); 

delete from qs_player_speech where `timerecorded` 
	< date_sub(current_timestamp (),interval 720 DAY);

delete from qs_player_trade_record where `time` 
	< date_sub(current_timestamp (),interval 90 DAY);

delete from qs_player_trade_record_entries where not exists (select * from qs_player_trade_record 
	where qs_player_trade_record_entries.event_id = qs_player_trade_record.trade_id); 
