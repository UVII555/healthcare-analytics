--
-- PostgreSQL database dump
--

\restrict gYB9M3OVb1iFslOfMpQs0kRhrUZWHohxyIyaVsYDw6BHzJqqfboSOPrEfECqMYX

-- Dumped from database version 16.14 (Homebrew)
-- Dumped by pg_dump version 16.14 (Homebrew)

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

--
-- Name: hospital_type_enum; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.hospital_type_enum AS ENUM (
    'GOVERNMENT',
    'PRIVATE',
    'CLINIC',
    'DIAGNOSTIC'
);


ALTER TYPE public.hospital_type_enum OWNER TO utsavsingh;

--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.subscription_status AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'CANCELLED',
    'TRIAL'
);


ALTER TYPE public.subscription_status OWNER TO utsavsingh;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.user_role AS ENUM (
    'SUPER_ADMIN',
    'HOSPITAL_ADMIN',
    'DOCTOR',
    'LAB_TECH',
    'PATIENT'
);


ALTER TYPE public.user_role OWNER TO utsavsingh;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    hospital_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    head_doctor_id integer,
    total_beds integer DEFAULT 0,
    floor integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.departments OWNER TO utsavsingh;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO utsavsingh;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: hospital_subscriptions; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.hospital_subscriptions (
    id integer NOT NULL,
    hospital_id integer NOT NULL,
    plan_id integer NOT NULL,
    status public.subscription_status DEFAULT 'TRIAL'::public.subscription_status NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    trial_ends_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hospital_subscriptions OWNER TO utsavsingh;

--
-- Name: hospital_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.hospital_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_subscriptions_id_seq OWNER TO utsavsingh;

--
-- Name: hospital_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.hospital_subscriptions_id_seq OWNED BY public.hospital_subscriptions.id;


--
-- Name: hospitals; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.hospitals (
    hospital_id bigint NOT NULL,
    hospital_name character varying(200) NOT NULL,
    hospital_code character varying(50) NOT NULL,
    hospital_type public.hospital_type_enum,
    city character varying(100),
    state character varying(100),
    address text,
    phone character varying(20),
    email character varying(255),
    total_beds integer,
    emergency_available boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hospitals OWNER TO utsavsingh;

--
-- Name: hospitals_hospital_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.hospitals_hospital_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospitals_hospital_id_seq OWNER TO utsavsingh;

--
-- Name: hospitals_hospital_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.hospitals_hospital_id_seq OWNED BY public.hospitals.hospital_id;


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.subscription_plans (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    price_monthly numeric(10,2) NOT NULL,
    max_patients integer DEFAULT '-1'::integer,
    max_doctors integer DEFAULT '-1'::integer,
    feature_flags json NOT NULL
);


ALTER TABLE public.subscription_plans OWNER TO utsavsingh;

--
-- Name: subscription_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.subscription_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subscription_plans_id_seq OWNER TO utsavsingh;

--
-- Name: subscription_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.subscription_plans_id_seq OWNED BY public.subscription_plans.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.users (
    id integer NOT NULL,
    hospital_id bigint,
    email character varying(150) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    role public.user_role NOT NULL,
    full_name character varying(200) NOT NULL,
    phone character varying(15),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO utsavsingh;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO utsavsingh;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: hospital_subscriptions id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.hospital_subscriptions_id_seq'::regclass);


--
-- Name: hospitals hospital_id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospitals ALTER COLUMN hospital_id SET DEFAULT nextval('public.hospitals_hospital_id_seq'::regclass);


--
-- Name: subscription_plans id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.subscription_plans ALTER COLUMN id SET DEFAULT nextval('public.subscription_plans_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: hospital_subscriptions hospital_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions
    ADD CONSTRAINT hospital_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: hospitals hospitals_hospital_code_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospitals
    ADD CONSTRAINT hospitals_hospital_code_key UNIQUE (hospital_code);


--
-- Name: hospitals hospitals_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospitals
    ADD CONSTRAINT hospitals_pkey PRIMARY KEY (hospital_id);


--
-- Name: subscription_plans subscription_plans_name_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_name_key UNIQUE (name);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: departments fk_department_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT fk_department_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: hospital_subscriptions fk_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions
    ADD CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: hospital_subscriptions fk_plan; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions
    ADD CONSTRAINT fk_plan FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE RESTRICT;


--
-- Name: users fk_user_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_user_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict gYB9M3OVb1iFslOfMpQs0kRhrUZWHohxyIyaVsYDw6BHzJqqfboSOPrEfECqMYX

