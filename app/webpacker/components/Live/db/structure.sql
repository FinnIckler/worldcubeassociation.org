--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Debian 12.4-1.pgdg100+1)
-- Dumped by pg_dump version 13.16 (Debian 13.16-0+deb11u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_tokens (
                                    id bigint NOT NULL,
                                    access_token character varying(255) NOT NULL,
                                    refresh_token character varying(255) NOT NULL,
                                    expires_at timestamp(0) without time zone NOT NULL,
                                    user_id bigint NOT NULL
);


--
-- Name: access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_tokens_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_tokens_id_seq OWNED BY public.access_tokens.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
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
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
                                  id bigint NOT NULL,
                                  assignment_code character varying(255) NOT NULL,
                                  station_number integer,
                                  person_id bigint NOT NULL,
                                  activity_id bigint NOT NULL
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: competition_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competition_events (
                                         id bigint NOT NULL,
                                         competitor_limit integer,
                                         qualification jsonb,
                                         event_id character varying(6) NOT NULL,
                                         competition_id bigint NOT NULL
);


--
-- Name: competition_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competition_events_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: competition_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competition_events_id_seq OWNED BY public.competition_events.id;


--
-- Name: competitions; Type: TABLE; Schema: public; Owner: -
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
-- Name: competitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitions_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: competitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitions_id_seq OWNED BY public.competitions.id;


--
-- Name: one_time_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.one_time_codes (
                                     id bigint NOT NULL,
                                     code character varying(255),
                                     expires_at timestamp(0) without time zone,
                                     user_id bigint NOT NULL,
                                     inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: one_time_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.one_time_codes_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: one_time_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.one_time_codes_id_seq OWNED BY public.one_time_codes.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
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
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.people_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- Name: personal_bests; Type: TABLE; Schema: public; Owner: -
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
-- Name: personal_bests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_bests_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: personal_bests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_bests_id_seq OWNED BY public.personal_bests.id;


--
-- Name: registration_competition_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_competition_events (
                                                      registration_id bigint NOT NULL,
                                                      competition_event_id bigint NOT NULL
);


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: -
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
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registrations_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registrations_id_seq OWNED BY public.registrations.id;


--
-- Name: results; Type: TABLE; Schema: public; Owner: -
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
-- Name: results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.results_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.results_id_seq OWNED BY public.results.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
                            id bigint NOT NULL,
                            wcif_id integer NOT NULL,
                            name character varying(255) NOT NULL,
                            color character varying(255) NOT NULL,
                            venue_id bigint NOT NULL
);


--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rooms_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- Name: rounds; Type: TABLE; Schema: public; Owner: -
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
-- Name: rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rounds_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rounds_id_seq OWNED BY public.rounds.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
                                        version bigint NOT NULL,
                                        inserted_at timestamp(0) without time zone
);


--
-- Name: scoretaking_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scoretaking_tokens (
                                         id bigint NOT NULL,
                                         token_hash bytea NOT NULL,
                                         user_id bigint NOT NULL,
                                         competition_id bigint NOT NULL,
                                         inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: scoretaking_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scoretaking_tokens_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: scoretaking_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scoretaking_tokens_id_seq OWNED BY public.scoretaking_tokens.id;


--
-- Name: staff_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_members (
                                    id bigint NOT NULL,
                                    roles character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
                                    user_id bigint NOT NULL,
                                    competition_id bigint NOT NULL
);


--
-- Name: staff_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staff_members_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: staff_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staff_members_id_seq OWNED BY public.staff_members.id;


--
-- Name: terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terms (
                            key character varying(255) NOT NULL,
                            value bytea NOT NULL
);


--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tokens (
                                  id bigint NOT NULL,
                                  user_id bigint NOT NULL,
                                  token character varying(255) NOT NULL,
                                  context character varying(255) NOT NULL,
                                  inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_tokens_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: user_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_tokens_id_seq OWNED BY public.user_tokens.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: -
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
-- Name: venues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.venues_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;


--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.venues_id_seq OWNED BY public.venues.id;


--
-- Name: access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens ALTER COLUMN id SET DEFAULT nextval('public.access_tokens_id_seq'::regclass);


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: competition_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competition_events ALTER COLUMN id SET DEFAULT nextval('public.competition_events_id_seq'::regclass);


--
-- Name: competitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions ALTER COLUMN id SET DEFAULT nextval('public.competitions_id_seq'::regclass);


--
-- Name: one_time_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.one_time_codes ALTER COLUMN id SET DEFAULT nextval('public.one_time_codes_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- Name: personal_bests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_bests ALTER COLUMN id SET DEFAULT nextval('public.personal_bests_id_seq'::regclass);


--
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations ALTER COLUMN id SET DEFAULT nextval('public.registrations_id_seq'::regclass);


--
-- Name: results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.results ALTER COLUMN id SET DEFAULT nextval('public.results_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- Name: rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rounds ALTER COLUMN id SET DEFAULT nextval('public.rounds_id_seq'::regclass);


--
-- Name: scoretaking_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scoretaking_tokens ALTER COLUMN id SET DEFAULT nextval('public.scoretaking_tokens_id_seq'::regclass);


--
-- Name: staff_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_members ALTER COLUMN id SET DEFAULT nextval('public.staff_members_id_seq'::regclass);


--
-- Name: user_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens ALTER COLUMN id SET DEFAULT nextval('public.user_tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: venues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venues ALTER COLUMN id SET DEFAULT nextval('public.venues_id_seq'::regclass);


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


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20200702161510);
INSERT INTO public."schema_migrations" (version) VALUES (20200702162823);
INSERT INTO public."schema_migrations" (version) VALUES (20200703135005);
INSERT INTO public."schema_migrations" (version) VALUES (20200703161125);
INSERT INTO public."schema_migrations" (version) VALUES (20200703161746);
INSERT INTO public."schema_migrations" (version) VALUES (20200703193245);
INSERT INTO public."schema_migrations" (version) VALUES (20200704200959);
INSERT INTO public."schema_migrations" (version) VALUES (20200704205906);
INSERT INTO public."schema_migrations" (version) VALUES (20200704210540);
INSERT INTO public."schema_migrations" (version) VALUES (20200704212229);
INSERT INTO public."schema_migrations" (version) VALUES (20200704212339);
INSERT INTO public."schema_migrations" (version) VALUES (20200704212804);
INSERT INTO public."schema_migrations" (version) VALUES (20200704213210);
INSERT INTO public."schema_migrations" (version) VALUES (20200713153510);
INSERT INTO public."schema_migrations" (version) VALUES (20200715220238);
INSERT INTO public."schema_migrations" (version) VALUES (20200822144750);
INSERT INTO public."schema_migrations" (version) VALUES (20230701204010);
INSERT INTO public."schema_migrations" (version) VALUES (20230730174034);
INSERT INTO public."schema_migrations" (version) VALUES (20230924155518);
INSERT INTO public."schema_migrations" (version) VALUES (20240802124914);
