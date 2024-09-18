--
-- The WCA Live Schema
--


--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
-- Not needed anymore
--

CREATE TABLE public.access_tokens (
                                    id bigint NOT NULL,
                                    access_token character varying(255) NOT NULL,
                                    refresh_token character varying(255) NOT NULL,
                                    expires_at timestamp(0) without time zone NOT NULL,
                                    user_id bigint NOT NULL
);


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema
-- create_table "schedule_activities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.string "holder_type", null: false
--     t.bigint "holder_id", null: false
--     t.integer "wcif_id", null: false
--     t.string "name", null: false
--     t.string "activity_code", null: false
--     t.datetime "start_time", precision: nil, null: false
--     t.datetime "end_time", precision: nil, null: false
--     t.integer "scramble_set_id"
--     t.datetime "created_at", precision: nil, null: false
--     t.datetime "updated_at", precision: nil, null: false
-- no room_id, parent_activity_id and round_id but I think you get that through associations
end
--

CREATE TABLE public.activities (
                                 id bigint NOT NULL,
                                 wcif_id integer NOT NULL,
                                 name character varying(255) NOT NULL,
                                 activity_code character varying(255) NOT NULL,
                                 start_time timestamp(0) without time zone NOT NULL,
                                 end_time timestamp(0) without time zone NOT NULL,
                                 room_id bigint,
                                 parent_activity_id bigint,
                                 round_id bigint
);

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema
-- create_table "assignments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.bigint "registration_id"
--     t.string "registration_type"
--     t.bigint "schedule_activity_id"
--     t.integer "station_number"
--     t.string "assignment_code", null: false
-- end
-- no person_id but I think you get that through associations
--

CREATE TABLE public.assignments (
                                  id bigint NOT NULL,
                                  assignment_code character varying(255) NOT NULL,
                                  station_number integer,
                                  person_id bigint NOT NULL,
                                  activity_id bigint NOT NULL
);

--
-- Name: competition_events; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema
-- create_table "competition_events", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.string "competition_id", null: false
--     t.string "event_id", null: false
--     t.integer "fee_lowest_denomination", default: 0, null: false
--     t.text "qualification"
-- end
-- No Competitor Limit
--

CREATE TABLE public.competition_events (
                                         id bigint NOT NULL,
                                         competitor_limit integer,
                                         qualification jsonb,
                                         event_id character varying(6) NOT NULL,
                                         competition_id bigint NOT NULL
);

--
-- Name: competitions; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema:
-- create_table "Competitions", id: { type: :string, limit: 32, default: "" }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.string "name", limit: 50, default: "", null: false
--     t.string "cityName", limit: 50, default: "", null: false
--     t.string "countryId", limit: 50, default: "", null: false
--     t.text "information", size: :medium
--     t.string "venue", limit: 240, default: "", null: false
--     t.string "venueAddress"
--     t.string "venueDetails"
--     t.string "external_website", limit: 200
--     t.string "cellName", limit: 45, default: "", null: false
--     t.boolean "showAtAll", default: false, null: false
--     t.integer "latitude"
--     t.integer "longitude"
--     t.string "contact", limit: 255
--     t.text "remarks"
--     t.datetime "registration_open", precision: nil
--     t.datetime "registration_close", precision: nil
--     t.boolean "use_wca_registration", default: true, null: false
--     t.boolean "guests_enabled", default: true, null: false
--     t.datetime "results_posted_at", precision: nil
--     t.datetime "results_nag_sent_at", precision: nil
--     t.boolean "generate_website"
--     t.datetime "announced_at", precision: nil
--     t.integer "base_entry_fee_lowest_denomination"
--     t.string "currency_code", limit: 255, default: "USD"
--     t.string "connected_stripe_account_id", limit: 255
--     t.date "start_date"
--     t.date "end_date"
--     t.boolean "enable_donations"
--     t.boolean "competitor_limit_enabled"
--     t.integer "competitor_limit"
--     t.text "competitor_limit_reason"
--     t.text "extra_registration_requirements"
--     t.boolean "on_the_spot_registration"
--     t.integer "on_the_spot_entry_fee_lowest_denomination"
--     t.integer "refund_policy_percent"
--     t.datetime "refund_policy_limit_date", precision: nil
--     t.integer "guests_entry_fee_lowest_denomination"
--     t.datetime "created_at", precision: nil
--     t.datetime "updated_at", precision: nil
--     t.datetime "results_submitted_at", precision: nil
--     t.boolean "early_puzzle_submission"
--     t.text "early_puzzle_submission_reason"
--     t.boolean "qualification_results"
--     t.text "qualification_results_reason"
--     t.string "name_reason"
--     t.string "external_registration_page", limit: 200
--     t.datetime "confirmed_at", precision: nil
--     t.boolean "event_restrictions"
--     t.text "event_restrictions_reason"
--     t.datetime "registration_reminder_sent_at", precision: nil
--     t.integer "announced_by"
--     t.integer "results_posted_by"
--     t.string "main_event_id"
--     t.datetime "cancelled_at", precision: nil
--     t.integer "cancelled_by"
--     t.datetime "waiting_list_deadline_date", precision: nil
--     t.datetime "event_change_deadline_date", precision: nil
--     t.integer "guest_entry_status", default: 0, null: false
--     t.boolean "allow_registration_edits", default: false, null: false
--     t.boolean "allow_registration_self_delete_after_acceptance", default: false, null: false
--     t.integer "competition_series_id"
--     t.boolean "use_wca_live_for_scoretaking", default: false, null: false
--     t.boolean "allow_registration_without_qualification", default: false
--     t.integer "guests_per_registration_limit"
--     t.integer "events_per_registration_limit"
--     t.boolean "force_comment_in_registration"
--     t.integer "posting_by"
--     t.boolean "uses_v2_registrations", default: false, null: false
--     t.boolean "forbid_newcomers", default: false, null: false
--     t.string "forbid_newcomers_reason"
-- end
-- Missing synchronized_at, imported_by_id, inserted_at, but that's not needed
--

CREATE TABLE public.competitions (
                                   id bigint NOT NULL,
                                   wca_id character varying(255) NOT NULL,
                                   name character varying(255) NOT NULL,
                                   short_name character varying(255) NOT NULL,
                                   start_date date NOT NULL,
                                   end_date date NOT NULL,
                                   start_time timestamp(0) without time zone NOT NULL,
                                   end_time timestamp(0) without time zone NOT NULL,
                                   competitor_limit integer,
                                   synchronized_at timestamp(0) without time zone NOT NULL,
                                   imported_by_id bigint NOT NULL,
                                   inserted_at timestamp(0) without time zone NOT NULL,
                                   updated_at timestamp(0) without time zone NOT NULL
);

--
-- Name: one_time_codes; Type: TABLE; Schema: public; Owner: -
-- We probably don't need this? Not sure if we have something else already on the website
--

CREATE TABLE public.one_time_codes (
                                     id bigint NOT NULL,
                                     code character varying(255),
                                     expires_at timestamp(0) without time zone,
                                     user_id bigint NOT NULL,
                                     inserted_at timestamp(0) without time zone NOT NULL
);

--
-- Name: people; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema:
-- create_table "Persons", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.string "wca_id", limit: 10, default: "", null: false
--     t.integer "subId", limit: 1, default: 1, null: false
--     t.string "name", limit: 80
--     t.string "countryId", limit: 50, default: "", null: false
--     t.string "gender", limit: 1, default: ""
--     t.date "dob"
--     t.string "comments", limit: 40, default: "", null: false
--     t.integer "incorrect_wca_id_claim_count", default: 0, null: false
-- end
-- No wca_user_id, email, avatar_url, avatar_thumb_url, roles but those are handled through associations
-- No competition_id
--

CREATE TABLE public.people (
                             id bigint NOT NULL,
                             registrant_id integer,
                             name character varying(255) NOT NULL,
                             wca_user_id integer NOT NULL,
                             wca_id character varying(255),
                             country_iso2 character varying(2) NOT NULL,
                             gender character(1) NOT NULL,
                             birthdate date NOT NULL,
                             email character varying(255) NOT NULL,
                             avatar_url character varying(255),
                             avatar_thumb_url character varying(255),
                             roles character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
                             competition_id bigint NOT NULL
);

--
-- Name: personal_bests; Type: TABLE; Schema: public; Owner: -
-- Already part of our database but only as a method on the person model
-- def personal_records
--     [self.ranksAverage, self.ranksSingle].compact.flatten
-- end
--

CREATE TABLE public.personal_bests (
                                     id bigint NOT NULL,
                                     best integer NOT NULL,
                                     type character varying(255) NOT NULL,
                                     world_ranking integer NOT NULL,
                                     continental_ranking integer NOT NULL,
                                     national_ranking integer NOT NULL,
                                     event_id character varying(6) NOT NULL,
                                     person_id bigint NOT NULL
);

--
-- Name: registration_competition_events; Type: TABLE; Schema: public; Owner: -
-- Already part of our database (for v1, but not easy to get this information from v2)
-- create_table "registration_competition_events", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.integer "registration_id"
--     t.integer "competition_event_id"
-- end
--

CREATE TABLE public.registration_competition_events (
                                                      registration_id bigint NOT NULL,
                                                      competition_event_id bigint NOT NULL
);


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: -
-- Already part of our database, different schema for v1 and v2, but we have all this data
--

CREATE TABLE public.registrations (
                                    id bigint NOT NULL,
                                    wca_registration_id integer NOT NULL,
                                    status character varying(255) NOT NULL,
                                    guests integer NOT NULL,
                                    comments text NOT NULL,
                                    person_id bigint NOT NULL
);


--
-- Name: results; Type: TABLE; Schema: public; Owner: -
-- These are live results! So this is a new table
--

CREATE TABLE public.results (
                              id bigint NOT NULL,
                              ranking integer,
                              attempts jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
                              best integer NOT NULL,
                              average integer NOT NULL,
                              single_record_tag character varying(255),
                              average_record_tag character varying(255),
                              advancing boolean DEFAULT false NOT NULL,
                              person_id bigint NOT NULL,
                              round_id bigint NOT NULL,
                              entered_by_id bigint,
                              entered_at timestamp(0) without time zone,
                              inserted_at timestamp(0) without time zone NOT NULL,
                              updated_at timestamp(0) without time zone NOT NULL,
                              advancing_questionable boolean DEFAULT false NOT NULL
);

--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema:
-- create_table "venue_rooms", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.bigint "competition_venue_id", null: false
--     t.integer "wcif_id", null: false
--     t.string "name", null: false
--     t.datetime "created_at", precision: nil, null: false
--     t.datetime "updated_at", precision: nil, null: false
--     t.string "color", limit: 7, null: false
-- end
--
--

CREATE TABLE public.rooms (
                            id bigint NOT NULL,
                            wcif_id integer NOT NULL,
                            name character varying(255) NOT NULL,
                            color character varying(255) NOT NULL,
                            venue_id bigint NOT NULL
);

--
-- Name: rounds; Type: TABLE; Schema: public; Owner: -
-- Already part of our database
-- create_table "rounds", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.integer "competition_event_id", null: false
--     t.string "format_id", limit: 255, null: false
--     t.integer "number", null: false
--     t.datetime "created_at", precision: nil, null: false
--     t.datetime "updated_at", precision: nil, null: false
--     t.text "time_limit"
--     t.text "cutoff"
--     t.text "advancement_condition"
--     t.integer "scramble_set_count", default: 1, null: false
--     t.text "round_results", size: :medium
--     t.integer "total_number_of_rounds", null: false
--     t.string "old_type", limit: 1
-- end
--

CREATE TABLE public.rounds (
                             id bigint NOT NULL,
                             number integer NOT NULL,
                             format_id character(1) NOT NULL,
                             time_limit jsonb,
                             cutoff jsonb,
                             advancement_condition jsonb,
                             scramble_set_count integer NOT NULL,
                             competition_event_id bigint NOT NULL
);

--
-- Name: scoretaking_tokens; Type: TABLE; Schema: public; Owner: -
-- Not sure what the difference is between this and one time tokens
--

CREATE TABLE public.scoretaking_tokens (
                                         id bigint NOT NULL,
                                         token_hash bytea NOT NULL,
                                         user_id bigint NOT NULL,
                                         competition_id bigint NOT NULL,
                                         inserted_at timestamp(0) without time zone NOT NULL
);

--
-- Name: staff_members; Type: TABLE; Schema: public; Owner: -
-- Already part of our database as part of the UserRoles Model
--

CREATE TABLE public.staff_members (
                                    id bigint NOT NULL,
                                    roles character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
                                    user_id bigint NOT NULL,
                                    competition_id bigint NOT NULL
);

--
-- Name: terms; Type: TABLE; Schema: public; Owner: -
-- Don't know what this is yet
--

CREATE TABLE public.terms (
                            key character varying(255) NOT NULL,
                            value bytea NOT NULL
);


--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -
-- Not sure what the difference is between this and scoretaking tokens/one time tokens
--

CREATE TABLE public.user_tokens (
                                  id bigint NOT NULL,
                                  user_id bigint NOT NULL,
                                  token character varying(255) NOT NULL,
                                  context character varying(255) NOT NULL,
                                  inserted_at timestamp(0) without time zone NOT NULL
);

--
-- Name: users; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema
-- create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.string "email", default: "", null: false
--     t.string "encrypted_password", limit: 255, default: "", null: false
--     t.string "reset_password_token"
--     t.datetime "reset_password_sent_at", precision: nil
--     t.datetime "remember_created_at", precision: nil
--     t.integer "sign_in_count", default: 0, null: false
--     t.datetime "current_sign_in_at", precision: nil
--     t.datetime "last_sign_in_at", precision: nil
--     t.string "current_sign_in_ip", limit: 255
--     t.string "last_sign_in_ip", limit: 255
--     t.string "confirmation_token", limit: 255
--     t.datetime "confirmed_at", precision: nil
--     t.datetime "confirmation_sent_at", precision: nil
--     t.string "unconfirmed_email", limit: 255
--     t.datetime "created_at", precision: nil
--     t.datetime "updated_at", precision: nil
--     t.string "name", limit: 255
--     t.string "wca_id"
--     t.string "avatar", limit: 255
--     t.string "pending_avatar", limit: 255
--     t.integer "saved_avatar_crop_x"
--     t.integer "saved_avatar_crop_y"
--     t.integer "saved_avatar_crop_w"
--     t.integer "saved_avatar_crop_h"
--     t.integer "saved_pending_avatar_crop_x"
--     t.integer "saved_pending_avatar_crop_y"
--     t.integer "saved_pending_avatar_crop_w"
--     t.integer "saved_pending_avatar_crop_h"
--     t.string "unconfirmed_wca_id", limit: 255
--     t.integer "delegate_id_to_handle_wca_id_claim"
--     t.date "dob"
--     t.string "gender", limit: 255
--     t.string "country_iso2", limit: 255
--     t.boolean "results_notifications_enabled", default: false
--     t.string "preferred_locale", limit: 255
--     t.boolean "competition_notifications_enabled"
--     t.boolean "receive_delegate_reports", default: false, null: false
--     t.boolean "dummy_account", default: false, null: false
--     t.integer "consumed_timestep"
--     t.boolean "otp_required_for_login", default: false
--     t.text "otp_backup_codes"
--     t.string "session_validity_token"
--     t.boolean "cookies_acknowledged", default: false, null: false
--     t.boolean "registration_notifications_enabled", default: false
--     t.string "otp_secret"
-- end
-- no inserted_at, but doesn't matter
--

CREATE TABLE public.users (
                            id bigint NOT NULL,
                            email character varying(255) NOT NULL,
                            wca_user_id integer NOT NULL,
                            name character varying(255) NOT NULL,
                            wca_id character varying(255),
                            country_iso2 character varying(2),
                            avatar_url character varying(255),
                            avatar_thumb_url character varying(255),
                            wca_teams character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
                            inserted_at timestamp(0) without time zone NOT NULL,
                            updated_at timestamp(0) without time zone NOT NULL
);

--
-- Name: venues; Type: TABLE; Schema: public; Owner: -
-- Already part of our database with schema
-- create_table "competition_venues", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
--     t.string "competition_id", null: false
--     t.integer "wcif_id", null: false
--     t.string "name", null: false
--     t.integer "latitude_microdegrees", null: false
--     t.integer "longitude_microdegrees", null: false
--     t.string "timezone_id", null: false
--     t.datetime "created_at", precision: nil, null: false
--     t.datetime "updated_at", precision: nil, null: false
--     t.string "country_iso2", null: false
-- end
--

CREATE TABLE public.venues (
                             id bigint NOT NULL,
                             wcif_id integer NOT NULL,
                             name character varying(255) NOT NULL,
                             latitude_microdegrees integer NOT NULL,
                             longitude_microdegrees integer NOT NULL,
                             country_iso2 character varying(2) NOT NULL,
                             timezone character varying(255) NOT NULL,
                             competition_id bigint NOT NULL
);

--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
  ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
  ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
  ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: competition_events competition_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competition_events
  ADD CONSTRAINT competition_events_pkey PRIMARY KEY (id);


--
-- Name: competitions competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
  ADD CONSTRAINT competitions_pkey PRIMARY KEY (id);


--
-- Name: one_time_codes one_time_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.one_time_codes
  ADD CONSTRAINT one_time_codes_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
  ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: personal_bests personal_bests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_bests
  ADD CONSTRAINT personal_bests_pkey PRIMARY KEY (id);


--
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
  ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: results results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.results
  ADD CONSTRAINT results_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
  ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: rounds rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rounds
  ADD CONSTRAINT rounds_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
  ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scoretaking_tokens scoretaking_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scoretaking_tokens
  ADD CONSTRAINT scoretaking_tokens_pkey PRIMARY KEY (id);


--
-- Name: staff_members staff_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_members
  ADD CONSTRAINT staff_members_pkey PRIMARY KEY (id);


--
-- Name: terms terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms
  ADD CONSTRAINT terms_pkey PRIMARY KEY (key);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
  ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
  ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venues
  ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: access_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_tokens_user_id_index ON public.access_tokens USING btree (user_id);


--
-- Name: activities_parent_activity_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activities_parent_activity_id_index ON public.activities USING btree (parent_activity_id);


--
-- Name: activities_room_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activities_room_id_index ON public.activities USING btree (room_id);


--
-- Name: activities_round_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activities_round_id_index ON public.activities USING btree (round_id);


--
-- Name: assignments_activity_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assignments_activity_id_index ON public.assignments USING btree (activity_id);


--
-- Name: assignments_person_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assignments_person_id_index ON public.assignments USING btree (person_id);


--
-- Name: competition_events_competition_id_event_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX competition_events_competition_id_event_id_index ON public.competition_events USING btree (competition_id, event_id);


--
-- Name: competitions_imported_by_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitions_imported_by_id_index ON public.competitions USING btree (imported_by_id);


--
-- Name: competitions_start_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitions_start_date_index ON public.competitions USING btree (start_date);


--
-- Name: competitions_wca_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX competitions_wca_id_index ON public.competitions USING btree (wca_id);


--
-- Name: one_time_codes_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX one_time_codes_code_index ON public.one_time_codes USING btree (code);


--
-- Name: one_time_codes_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX one_time_codes_user_id_index ON public.one_time_codes USING btree (user_id);


--
-- Name: people_competition_id_registrant_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX people_competition_id_registrant_id_index ON public.people USING btree (competition_id, registrant_id);


--
-- Name: personal_bests_person_id_event_id_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX personal_bests_person_id_event_id_type_index ON public.personal_bests USING btree (person_id, event_id, type);


--
-- Name: registration_competition_events_competition_event_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX registration_competition_events_competition_event_id_index ON public.registration_competition_events USING btree (competition_event_id);


--
-- Name: registration_competition_events_registration_id_competition_eve; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX registration_competition_events_registration_id_competition_eve ON public.registration_competition_events USING btree (registration_id, competition_event_id);


--
-- Name: registrations_person_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX registrations_person_id_index ON public.registrations USING btree (person_id);


--
-- Name: results_average_record_tag_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX results_average_record_tag_index ON public.results USING btree (average_record_tag);


--
-- Name: results_person_id_round_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX results_person_id_round_id_index ON public.results USING btree (person_id, round_id);


--
-- Name: results_round_id_ranking_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX results_round_id_ranking_index ON public.results USING btree (round_id, ranking);


--
-- Name: results_single_record_tag_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX results_single_record_tag_index ON public.results USING btree (single_record_tag);


--
-- Name: rooms_venue_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rooms_venue_id_index ON public.rooms USING btree (venue_id);


--
-- Name: rounds_competition_event_id_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rounds_competition_event_id_number_index ON public.rounds USING btree (competition_event_id, number);


--
-- Name: scoretaking_tokens_competition_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scoretaking_tokens_competition_id_index ON public.scoretaking_tokens USING btree (competition_id);


--
-- Name: scoretaking_tokens_token_hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX scoretaking_tokens_token_hash_index ON public.scoretaking_tokens USING btree (token_hash);


--
-- Name: scoretaking_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scoretaking_tokens_user_id_index ON public.scoretaking_tokens USING btree (user_id);


--
-- Name: staff_members_competition_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX staff_members_competition_id_user_id_index ON public.staff_members USING btree (competition_id, user_id);


--
-- Name: staff_members_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_members_user_id_index ON public.staff_members USING btree (user_id);


--
-- Name: user_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_tokens_context_token_index ON public.user_tokens USING btree (context, token);


--
-- Name: user_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_tokens_user_id_index ON public.user_tokens USING btree (user_id);


--
-- Name: users_wca_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_wca_user_id_index ON public.users USING btree (wca_user_id);


--
-- Name: venues_competition_id_wcif_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX venues_competition_id_wcif_id_index ON public.venues USING btree (competition_id, wcif_id);


--
-- Name: access_tokens access_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
  ADD CONSTRAINT access_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: activities activities_parent_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
  ADD CONSTRAINT activities_parent_activity_id_fkey FOREIGN KEY (parent_activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- Name: activities activities_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
  ADD CONSTRAINT activities_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: activities activities_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
  ADD CONSTRAINT activities_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE SET NULL;


--
-- Name: assignments assignments_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
  ADD CONSTRAINT assignments_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- Name: assignments assignments_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
  ADD CONSTRAINT assignments_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id) ON DELETE CASCADE;


--
-- Name: competition_events competition_events_competition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competition_events
  ADD CONSTRAINT competition_events_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id) ON DELETE CASCADE;


--
-- Name: competitions competitions_imported_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
  ADD CONSTRAINT competitions_imported_by_id_fkey FOREIGN KEY (imported_by_id) REFERENCES public.users(id);


--
-- Name: one_time_codes one_time_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.one_time_codes
  ADD CONSTRAINT one_time_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: people people_competition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
  ADD CONSTRAINT people_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id) ON DELETE CASCADE;


--
-- Name: personal_bests personal_bests_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_bests
  ADD CONSTRAINT personal_bests_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id) ON DELETE CASCADE;


--
-- Name: registration_competition_events registration_competition_events_competition_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_competition_events
  ADD CONSTRAINT registration_competition_events_competition_event_id_fkey FOREIGN KEY (competition_event_id) REFERENCES public.competition_events(id) ON DELETE CASCADE;


--
-- Name: registration_competition_events registration_competition_events_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_competition_events
  ADD CONSTRAINT registration_competition_events_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.registrations(id) ON DELETE CASCADE;


--
-- Name: registrations registrations_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
  ADD CONSTRAINT registrations_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id) ON DELETE CASCADE;


--
-- Name: results results_entered_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.results
  ADD CONSTRAINT results_entered_by_id_fkey FOREIGN KEY (entered_by_id) REFERENCES public.users(id);


--
-- Name: results results_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.results
  ADD CONSTRAINT results_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: results results_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.results
  ADD CONSTRAINT results_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: rooms rooms_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
  ADD CONSTRAINT rooms_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id) ON DELETE CASCADE;


--
-- Name: rounds rounds_competition_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rounds
  ADD CONSTRAINT rounds_competition_event_id_fkey FOREIGN KEY (competition_event_id) REFERENCES public.competition_events(id) ON DELETE CASCADE;


--
-- Name: scoretaking_tokens scoretaking_tokens_competition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scoretaking_tokens
  ADD CONSTRAINT scoretaking_tokens_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id) ON DELETE CASCADE;


--
-- Name: scoretaking_tokens scoretaking_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scoretaking_tokens
  ADD CONSTRAINT scoretaking_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: staff_members staff_members_competition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_members
  ADD CONSTRAINT staff_members_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id) ON DELETE CASCADE;


--
-- Name: staff_members staff_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_members
  ADD CONSTRAINT staff_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_tokens user_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
  ADD CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: venues venues_competition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venues
  ADD CONSTRAINT venues_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id) ON DELETE CASCADE;
