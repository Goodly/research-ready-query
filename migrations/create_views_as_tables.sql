-- create person_list VIEW
-- DROP VIEW IF EXISTS person_list_view;
DROP TABLE IF EXISTS person_list_view;

CREATE TABLE person_list_view as
SELECT speaker_id,display_name
FROM person_list
JOIN speaker_list on person_list.person_id = speaker_list.person_id;

CREATE INDEX IF NOT EXISTS pl_idx_display_name
ON person_list_view(display_name);


-- create state list
DROP TABLE IF EXISTS states_list;

CREATE TABLE states_list(state_id integer primary key AUTOINCREMENT
                , state_name varchar(100));
               
INSERT INTO states_list (state_name)
SELECT DISTINCT state_name FROM constituency_list;


-- create constituency_list_normalized view helper
DROP VIEW IF EXISTS constituency_list_normalized_view;
DROP TABLE IF EXISTS constituency_list_normalized_view;

CREATE TABLE constituency_list_normalized_view as
SELECT cl.constituency_id, sl.state_id,cl.state_name,cl.district_number
FROM constituency_list cl
Join states_list sl
ON cl.state_name  = sl.state_name;

CREATE INDEX IF NOT EXISTS cl_idx_state_id
ON constituency_list_normalized_view(state_id);

CREATE INDEX IF NOT EXISTS cl_idx_district_id
ON constituency_list_normalized_view(state_id, district_number);



--- JF commetned out: SELECT * FROM constituency_list_normalized_view;

-- create overall data view
DROP VIEW IF EXISTS advance_data_view;
DROP TABLE IF EXISTS advance_data_view;

-- want columns:
-- speech_text
-- word_count
-- full_name
-- state_name
-- district_number
-- heading_title
-- party name
-- chamber_name
-- proceeding_name
-- speech date

CREATE TABLE advance_data_view as 
SELECT 
speaker_list.speaker_id,
speech_text,
speech_date,
word_count,
display_name,
constituency_list_normalized_view.constituency_id,
constituency_list_normalized_view.state_id,
state_name,
district_number,
speaker_list.party_id,
party_name,
speaker_list.chamber_id,
chamber_name,
speaker_list.congress_id
FROM speech_list
INNER JOIN speaker_list on speaker_list.speaker_id = speech_list.speaker_id
INNER JOIN person_list on person_list.person_id = speaker_list.person_id
INNER JOIN party_list on party_list.party_id = speaker_list.party_id
INNER JOIN occasion_list on occasion_list.occasion_id = speech_list.occasion_id
LEFT JOIN speech_proceeding on speech_proceeding.speech_id = speech_list.speech_id
LEFT JOIN proceeding_list on proceeding_list.proceeding_id = speech_proceeding.proceeding_id
INNER JOIN chamber_list on chamber_list.chamber_id = speaker_list.chamber_id
INNER JOIN person_role_list on person_role_list.person_role_id = speech_list.person_role_id
LEFT JOIN constituency_list_normalized_view on constituency_list_normalized_view.constituency_id = speaker_list.constituency_id;


CREATE INDEX IF NOT EXISTS adv_idx_speaker_id
ON advance_data_view(speaker_id);

CREATE INDEX IF NOT EXISTS adv_idx_speaker_date
ON advance_data_view(speaker_id, speech_date);

CREATE INDEX IF NOT EXISTS adv_idx_party_id
ON advance_data_view(party_id);

CREATE INDEX IF NOT EXISTS adv_idx_party_date
ON advance_data_view(party_id, speech_date);

CREATE INDEX IF NOT EXISTS adv_idx_state_id
ON advance_data_view(state_id);

CREATE INDEX IF NOT EXISTS adv_idx_district_id
ON advance_data_view(state_id, district_number);

-- removing tables that are no longer need for this app
DROP TABLE IF EXISTS speech_list;
                                     
-- These could go, too, but I don't want to risk throwing off a query now.                                     
-- DROP TABLE IF EXISTS constituency_list;
-- DROP TABLE IF EXISTS hearing_list;
-- DROP TABLE IF EXISTS chamber_list;
-- DROP TABLE IF EXISTS committee_list;
-- DROP TABLE IF EXISTS congress_list;
-- DROP TABLE IF EXISTS constituency_characteristics;
-- DROP TABLE IF EXISTS hearing_list;
-- DROP TABLE IF EXISTS hearing_person;
-- DROP TABLE IF EXISTS hearing_speech;
-- DROP TABLE IF EXISTS legislation_list;
-- DROP TABLE IF EXISTS legislation_speech;
-- DROP TABLE IF EXISTS legislation_type_list;
-- DROP TABLE IF EXISTS occasion_list;
-- DROP TABLE IF EXISTS party_list;
-- DROP TABLE IF EXISTS person_list;
-- DROP TABLE IF EXISTS person_role_list;
-- DROP TABLE IF EXISTS speaker_list;
-- DROP TABLE IF EXISTS speech_proceeding;
-- DROP TABLE IF EXISTS witness_list;
-- DROP TABLE IF EXISTS zip_code_list;

VACUUM;
