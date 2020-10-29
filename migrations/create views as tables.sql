-- create person_list VIEW
DROP VIEW IF EXISTS person_list_view;
DROP TABLE IF EXISTS person_list_view;

CREATE TABLE person_list_view as
SELECT speaker_id,display_name
FROM person_list
JOIN speaker_list on person_list.person_id = speaker_list.person_id;

CREATE INDEX IF NOT EXISTS pl_idx_display_name
ON person_list_view(display_name);



-- create constituency_list_normalized view helper
DROP VIEW IF EXISTS constituency_list_normalized_view;
DROP TABLE IF EXISTS constituency_list_normalized_view;

CREATE TABLE constituency_list_normalized_view as
SELECT constituency_list_normalized.constituency_id,constituency_list_normalized.state_id,state_name,constituency_list_normalized.district_id,district_number
FROM constituency_list_normalized
INNER JOIN states_list on states_list.state_id = constituency_list_normalized.state_id
INNER JOIN district_list on district_list.district_id = constituency_list_normalized.district_id;

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
constituency_list_normalized_view.district_id,
district_number,
speaker_list.party_id,
party_name
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
