--
-- PostgreSQL database dump
--

-- Dumped from database version 10.0
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE attachments (
    id integer NOT NULL,
    course_id integer,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    document_file_name character varying,
    document_content_type character varying,
    document_file_size integer,
    document_updated_at timestamp without time zone,
    doc_type character varying,
    file_description character varying
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying,
    category_order integer,
    organization_id integer,
    enabled boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: ckeditor_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ckeditor_assets (
    id integer NOT NULL,
    data_file_name character varying NOT NULL,
    data_content_type character varying,
    data_file_size integer,
    assetable_id integer,
    assetable_type character varying(30),
    type character varying(30),
    width integer,
    height integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ckeditor_assets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ckeditor_assets_id_seq OWNED BY ckeditor_assets.id;


--
-- Name: cms_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cms_pages (
    id integer NOT NULL,
    title character varying(90),
    author character varying,
    audience character varying,
    pub_status character varying DEFAULT 'D'::character varying,
    pub_date timestamp without time zone,
    seo_page_title character varying(90),
    meta_desc character varying(156),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying,
    cms_page_order integer,
    language_id integer,
    body text,
    organization_id integer
);


--
-- Name: cms_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cms_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cms_pages_id_seq OWNED BY cms_pages.id;


--
-- Name: completed_lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE completed_lessons (
    id integer NOT NULL,
    course_progress_id integer,
    lesson_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE completed_lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE completed_lessons_id_seq OWNED BY completed_lessons.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contacts (
    id integer NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    organization character varying(50) NOT NULL,
    city character varying(30) NOT NULL,
    state character varying(2) NOT NULL,
    email character varying(30) NOT NULL,
    phone character varying(20),
    comments text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: course_progresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE course_progresses (
    id integer NOT NULL,
    user_id integer,
    course_id integer,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tracked boolean DEFAULT false
);


--
-- Name: course_progresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_progresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_progresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_progresses_id_seq OWNED BY course_progresses.id;


--
-- Name: course_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE course_topics (
    id integer NOT NULL,
    topic_id integer,
    course_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: course_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_topics_id_seq OWNED BY course_topics.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE courses (
    id integer NOT NULL,
    title character varying(90),
    seo_page_title character varying(90),
    meta_desc character varying(156),
    summary character varying(156),
    description text,
    contributor character varying,
    pub_status character varying DEFAULT 'D'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    language_id integer,
    level character varying,
    notes text,
    slug character varying,
    course_order integer,
    pub_date timestamp without time zone,
    format character varying,
    subsite_course boolean DEFAULT false,
    parent_id integer,
    display_on_dl boolean DEFAULT false,
    category_id integer
);


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_id_seq OWNED BY courses.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE languages (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE languages_id_seq OWNED BY languages.id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE lessons (
    id integer NOT NULL,
    lesson_order integer,
    title character varying(90),
    duration integer,
    course_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying,
    summary character varying(156),
    story_line character varying(156),
    seo_page_title character varying(90),
    meta_desc character varying(156),
    is_assessment boolean,
    story_line_file_name character varying,
    story_line_content_type character varying,
    story_line_file_size integer,
    story_line_updated_at timestamp without time zone,
    pub_status character varying,
    parent_lesson_id integer
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lessons_id_seq OWNED BY lessons.id;


--
-- Name: library_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE library_locations (
    id integer NOT NULL,
    name character varying,
    zipcode integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    sort_order integer DEFAULT 0
);


--
-- Name: library_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE library_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: library_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE library_locations_id_seq OWNED BY library_locations.id;


--
-- Name: organization_courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organization_courses (
    id integer NOT NULL,
    organization_id integer,
    course_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organization_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organization_courses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organization_courses_id_seq OWNED BY organization_courses.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying,
    subdomain character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    branches boolean,
    accepts_programs boolean
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_id integer,
    searchable_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pg_search_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pg_search_documents_id_seq OWNED BY pg_search_documents.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE profiles (
    id integer NOT NULL,
    first_name character varying,
    zip_code character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    language_id integer,
    library_location_id integer,
    last_name character varying,
    phone character varying,
    street_address character varying,
    city character varying,
    state character varying,
    opt_out_of_recommendations boolean DEFAULT false
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: program_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE program_locations (
    id integer NOT NULL,
    location_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    enabled boolean DEFAULT true,
    program_id integer
);


--
-- Name: program_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE program_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: program_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE program_locations_id_seq OWNED BY program_locations.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE programs (
    id integer NOT NULL,
    program_name character varying,
    location_required boolean DEFAULT false,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_type integer
);


--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE programs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE programs_id_seq OWNED BY programs.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying,
    resource_id integer,
    resource_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schools (
    id integer NOT NULL,
    school_name character varying,
    enabled boolean DEFAULT true,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schools_id_seq OWNED BY schools.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE topics (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topics_id_seq OWNED BY topics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_id integer,
    quiz_modal_complete boolean DEFAULT false,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id integer,
    invited_by_type character varying,
    invitations_count integer DEFAULT 0,
    token character varying,
    organization_id integer,
    school_id integer,
    program_location_id integer,
    acting_as character varying,
    library_card_number character varying,
    student_id character varying,
    date_of_birth timestamp without time zone,
    grade integer,
    quiz_responses_object text,
    program_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users_roles (
    user_id integer,
    role_id integer
);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: ckeditor_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ckeditor_assets ALTER COLUMN id SET DEFAULT nextval('ckeditor_assets_id_seq'::regclass);


--
-- Name: cms_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cms_pages ALTER COLUMN id SET DEFAULT nextval('cms_pages_id_seq'::regclass);


--
-- Name: completed_lessons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY completed_lessons ALTER COLUMN id SET DEFAULT nextval('completed_lessons_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: course_progresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_progresses ALTER COLUMN id SET DEFAULT nextval('course_progresses_id_seq'::regclass);


--
-- Name: course_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_topics ALTER COLUMN id SET DEFAULT nextval('course_topics_id_seq'::regclass);


--
-- Name: courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses ALTER COLUMN id SET DEFAULT nextval('courses_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages ALTER COLUMN id SET DEFAULT nextval('languages_id_seq'::regclass);


--
-- Name: lessons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons ALTER COLUMN id SET DEFAULT nextval('lessons_id_seq'::regclass);


--
-- Name: library_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY library_locations ALTER COLUMN id SET DEFAULT nextval('library_locations_id_seq'::regclass);


--
-- Name: organization_courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_courses ALTER COLUMN id SET DEFAULT nextval('organization_courses_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_search_documents ALTER COLUMN id SET DEFAULT nextval('pg_search_documents_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: program_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY program_locations ALTER COLUMN id SET DEFAULT nextval('program_locations_id_seq'::regclass);


--
-- Name: programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs ALTER COLUMN id SET DEFAULT nextval('programs_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schools ALTER COLUMN id SET DEFAULT nextval('schools_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: ckeditor_assets ckeditor_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ckeditor_assets
    ADD CONSTRAINT ckeditor_assets_pkey PRIMARY KEY (id);


--
-- Name: cms_pages cms_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cms_pages
    ADD CONSTRAINT cms_pages_pkey PRIMARY KEY (id);


--
-- Name: completed_lessons completed_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY completed_lessons
    ADD CONSTRAINT completed_lessons_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: course_progresses course_progresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_progresses
    ADD CONSTRAINT course_progresses_pkey PRIMARY KEY (id);


--
-- Name: course_topics course_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_topics
    ADD CONSTRAINT course_topics_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: library_locations library_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY library_locations
    ADD CONSTRAINT library_locations_pkey PRIMARY KEY (id);


--
-- Name: organization_courses organization_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_courses
    ADD CONSTRAINT organization_courses_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: program_locations program_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY program_locations
    ADD CONSTRAINT program_locations_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_ckeditor_assetable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ckeditor_assetable ON ckeditor_assets USING btree (assetable_type, assetable_id);


--
-- Name: idx_ckeditor_assetable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ckeditor_assetable_type ON ckeditor_assets USING btree (assetable_type, type, assetable_id);


--
-- Name: index_cms_pages_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cms_pages_on_slug ON cms_pages USING btree (slug);


--
-- Name: index_courses_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_on_category_id ON courses USING btree (category_id);


--
-- Name: index_courses_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_on_slug ON courses USING btree (slug);


--
-- Name: index_courses_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_on_title ON courses USING btree (title);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_lessons_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lessons_on_slug ON lessons USING btree (slug);


--
-- Name: index_library_locations_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_library_locations_on_organization_id ON library_locations USING btree (organization_id);


--
-- Name: index_pg_search_documents_on_searchable_type_and_searchable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_searchable_type_and_searchable_id ON pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_program_locations_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_locations_on_program_id ON program_locations USING btree (program_id);


--
-- Name: index_programs_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_organization_id ON programs USING btree (organization_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON roles USING btree (name, resource_type, resource_id);


--
-- Name: index_schools_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_organization_id ON schools USING btree (organization_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON users USING btree (invited_by_id);


--
-- Name: index_users_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organization_id ON users USING btree (organization_id);


--
-- Name: index_users_on_program_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_program_location_id ON users USING btree (program_location_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON users_roles USING btree (user_id, role_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: programs fk_rails_0586629141; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT fk_rails_0586629141 FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: schools fk_rails_099ab22c67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schools
    ADD CONSTRAINT fk_rails_099ab22c67 FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: users fk_rails_4dce22cfb5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_4dce22cfb5 FOREIGN KEY (program_location_id) REFERENCES program_locations(id);


--
-- Name: program_locations fk_rails_684ed17f10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY program_locations
    ADD CONSTRAINT fk_rails_684ed17f10 FOREIGN KEY (program_id) REFERENCES programs(id);


--
-- Name: users fk_rails_d7b9ff90af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_d7b9ff90af FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: library_locations fk_rails_fe22bb8133; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY library_locations
    ADD CONSTRAINT fk_rails_fe22bb8133 FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20151006221749');

INSERT INTO schema_migrations (version) VALUES ('20151006223043');

INSERT INTO schema_migrations (version) VALUES ('20151006223358');

INSERT INTO schema_migrations (version) VALUES ('20151007231646');

INSERT INTO schema_migrations (version) VALUES ('20151008191410');

INSERT INTO schema_migrations (version) VALUES ('20151008191502');

INSERT INTO schema_migrations (version) VALUES ('20151008194245');

INSERT INTO schema_migrations (version) VALUES ('20151008200711');

INSERT INTO schema_migrations (version) VALUES ('20151012205414');

INSERT INTO schema_migrations (version) VALUES ('20151012212235');

INSERT INTO schema_migrations (version) VALUES ('20151012212330');

INSERT INTO schema_migrations (version) VALUES ('20151013152406');

INSERT INTO schema_migrations (version) VALUES ('20151013153234');

INSERT INTO schema_migrations (version) VALUES ('20151013190948');

INSERT INTO schema_migrations (version) VALUES ('20151013213922');

INSERT INTO schema_migrations (version) VALUES ('20151014161239');

INSERT INTO schema_migrations (version) VALUES ('20151014162217');

INSERT INTO schema_migrations (version) VALUES ('20151014201805');

INSERT INTO schema_migrations (version) VALUES ('20151014214757');

INSERT INTO schema_migrations (version) VALUES ('20151015192124');

INSERT INTO schema_migrations (version) VALUES ('20151015192553');

INSERT INTO schema_migrations (version) VALUES ('20151020051806');

INSERT INTO schema_migrations (version) VALUES ('20151020222324');

INSERT INTO schema_migrations (version) VALUES ('20151022192231');

INSERT INTO schema_migrations (version) VALUES ('20151027171059');

INSERT INTO schema_migrations (version) VALUES ('20151027193006');

INSERT INTO schema_migrations (version) VALUES ('20151027213418');

INSERT INTO schema_migrations (version) VALUES ('20151028151936');

INSERT INTO schema_migrations (version) VALUES ('20151028205201');

INSERT INTO schema_migrations (version) VALUES ('20151101001943');

INSERT INTO schema_migrations (version) VALUES ('20151101002423');

INSERT INTO schema_migrations (version) VALUES ('20151103175556');

INSERT INTO schema_migrations (version) VALUES ('20151103175815');

INSERT INTO schema_migrations (version) VALUES ('20151103175901');

INSERT INTO schema_migrations (version) VALUES ('20151103215214');

INSERT INTO schema_migrations (version) VALUES ('20151104003304');

INSERT INTO schema_migrations (version) VALUES ('20151105154753');

INSERT INTO schema_migrations (version) VALUES ('20151109220449');

INSERT INTO schema_migrations (version) VALUES ('20151110194610');

INSERT INTO schema_migrations (version) VALUES ('20151111165405');

INSERT INTO schema_migrations (version) VALUES ('20151111210450');

INSERT INTO schema_migrations (version) VALUES ('20151111211038');

INSERT INTO schema_migrations (version) VALUES ('20151111214208');

INSERT INTO schema_migrations (version) VALUES ('20151118174539');

INSERT INTO schema_migrations (version) VALUES ('20151118192418');

INSERT INTO schema_migrations (version) VALUES ('20151119191647');

INSERT INTO schema_migrations (version) VALUES ('20151119191906');

INSERT INTO schema_migrations (version) VALUES ('20151119192048');

INSERT INTO schema_migrations (version) VALUES ('20151119202029');

INSERT INTO schema_migrations (version) VALUES ('20151124211721');

INSERT INTO schema_migrations (version) VALUES ('20151201005018');

INSERT INTO schema_migrations (version) VALUES ('20151203004228');

INSERT INTO schema_migrations (version) VALUES ('20160112013224');

INSERT INTO schema_migrations (version) VALUES ('20160113033555');

INSERT INTO schema_migrations (version) VALUES ('20160114060850');

INSERT INTO schema_migrations (version) VALUES ('20160114061700');

INSERT INTO schema_migrations (version) VALUES ('20160114085838');

INSERT INTO schema_migrations (version) VALUES ('20160118182316');

INSERT INTO schema_migrations (version) VALUES ('20160209173722');

INSERT INTO schema_migrations (version) VALUES ('20160218191705');

INSERT INTO schema_migrations (version) VALUES ('20160307180329');

INSERT INTO schema_migrations (version) VALUES ('20160309170154');

INSERT INTO schema_migrations (version) VALUES ('20160310210749');

INSERT INTO schema_migrations (version) VALUES ('20160310210918');

INSERT INTO schema_migrations (version) VALUES ('20160310212508');

INSERT INTO schema_migrations (version) VALUES ('20160315204732');

INSERT INTO schema_migrations (version) VALUES ('20160412193744');

INSERT INTO schema_migrations (version) VALUES ('20160421153406');

INSERT INTO schema_migrations (version) VALUES ('20160726200925');

INSERT INTO schema_migrations (version) VALUES ('20161004043125');

INSERT INTO schema_migrations (version) VALUES ('20161013231902');

INSERT INTO schema_migrations (version) VALUES ('20161014040703');

INSERT INTO schema_migrations (version) VALUES ('20161018030748');

INSERT INTO schema_migrations (version) VALUES ('20161107203204');

INSERT INTO schema_migrations (version) VALUES ('20161107205206');

INSERT INTO schema_migrations (version) VALUES ('20161110193750');

INSERT INTO schema_migrations (version) VALUES ('20161110224949');

INSERT INTO schema_migrations (version) VALUES ('20161110224954');

INSERT INTO schema_migrations (version) VALUES ('20161111163954');

INSERT INTO schema_migrations (version) VALUES ('20161111165026');

INSERT INTO schema_migrations (version) VALUES ('20161116175916');

INSERT INTO schema_migrations (version) VALUES ('20170104190831');

INSERT INTO schema_migrations (version) VALUES ('20170104212615');

INSERT INTO schema_migrations (version) VALUES ('20170104220648');

INSERT INTO schema_migrations (version) VALUES ('20170105201500');

INSERT INTO schema_migrations (version) VALUES ('20170314175120');

INSERT INTO schema_migrations (version) VALUES ('20170331200655');

INSERT INTO schema_migrations (version) VALUES ('20170920031218');

INSERT INTO schema_migrations (version) VALUES ('20171219194830');

INSERT INTO schema_migrations (version) VALUES ('20171220180542');

