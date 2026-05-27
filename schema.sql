--
-- PostgreSQL database dump
--

\restrict AI9tGIcApVC6NugVTVrXF5EhfhjZHbxCmVMvV1hZqHZI0jZZGb0c6dpQSdOxeLB

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
-- Name: appointment_status; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.appointment_status AS ENUM (
    'SCHEDULED',
    'CHECKED_IN',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
    'NO_SHOW'
);


ALTER TYPE public.appointment_status OWNER TO utsavsingh;

--
-- Name: appointment_type_enum; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.appointment_type_enum AS ENUM (
    'OPD',
    'ENERGENCY',
    'FOLLOW_UP'
);


ALTER TYPE public.appointment_type_enum OWNER TO utsavsingh;

--
-- Name: consent_status_enum; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.consent_status_enum AS ENUM (
    'PENDING',
    'APPROVED',
    'DENIED',
    'REVOKED',
    'EXPIRED'
);


ALTER TYPE public.consent_status_enum OWNER TO utsavsingh;

--
-- Name: consent_type_enum; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.consent_type_enum AS ENUM (
    'OTP',
    'REQUEST',
    'PERMANENT',
    'EMERGENCY'
);


ALTER TYPE public.consent_type_enum OWNER TO utsavsingh;

--
-- Name: gender_enum; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.gender_enum AS ENUM (
    'MALE',
    'FEMALE',
    'OTHER'
);


ALTER TYPE public.gender_enum OWNER TO utsavsingh;

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
-- Name: notification_channel; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.notification_channel AS ENUM (
    'IN_APP',
    'SMS',
    'EMAIL'
);


ALTER TYPE public.notification_channel OWNER TO utsavsingh;

--
-- Name: notification_status; Type: TYPE; Schema: public; Owner: utsavsingh
--

CREATE TYPE public.notification_status AS ENUM (
    'PENDING',
    'SENT',
    'FAILED'
);


ALTER TYPE public.notification_status OWNER TO utsavsingh;

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
-- Name: admission_analytics; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.admission_analytics (
    id integer NOT NULL,
    hospital_id bigint NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    department_name character varying(100) NOT NULL,
    admission_date timestamp without time zone NOT NULL,
    discharge_date timestamp without time zone,
    los_days numeric(5,1),
    treatment_cost numeric(10,2),
    diagnosis_code character varying(20),
    diagnosis_group character varying(50),
    readmitted boolean DEFAULT false,
    readmission_days integer,
    patient_age_at_admission integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admission_analytics OWNER TO utsavsingh;

--
-- Name: admission_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.admission_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admission_analytics_id_seq OWNER TO utsavsingh;

--
-- Name: admission_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.admission_analytics_id_seq OWNED BY public.admission_analytics.id;


--
-- Name: admissions; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.admissions (
    id integer NOT NULL,
    hospital_id bigint NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    department_id integer NOT NULL,
    admission_date timestamp without time zone NOT NULL,
    discharge_date timestamp without time zone,
    diagnosis_code character varying(20),
    diagnosis_group character varying(50),
    treatment_cost numeric(10,2),
    readmitted boolean DEFAULT false,
    readmission_days integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admissions OWNER TO utsavsingh;

--
-- Name: admissions_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.admissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admissions_id_seq OWNER TO utsavsingh;

--
-- Name: admissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.admissions_id_seq OWNED BY public.admissions.id;


--
-- Name: appointments; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.appointments (
    id integer NOT NULL,
    hospital_id bigint NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    department_id integer NOT NULL,
    time_slot time without time zone NOT NULL,
    tokem_number integer,
    booked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    check_in_time timestamp without time zone,
    doctor_start_time timestamp without time zone,
    consultant_end_time timestamp without time zone,
    status public.appointment_status DEFAULT 'SCHEDULED'::public.appointment_status,
    appointment_type public.appointment_type_enum DEFAULT 'OPD'::public.appointment_type_enum,
    chief_complaint text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.appointments OWNER TO utsavsingh;

--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.appointments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.appointments_id_seq OWNER TO utsavsingh;

--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    action character varying(100) NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id integer NOT NULL,
    ip_address character varying(45),
    event_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO utsavsingh;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO utsavsingh;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: consent_records; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.consent_records (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    consent_type public.consent_type_enum NOT NULL,
    status public.consent_status_enum DEFAULT 'PENDING'::public.consent_status_enum,
    otp_code character varying(6),
    otp_expires_at timestamp without time zone,
    emergency_reason text,
    accessed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.consent_records OWNER TO utsavsingh;

--
-- Name: consent_records_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.consent_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consent_records_id_seq OWNER TO utsavsingh;

--
-- Name: consent_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.consent_records_id_seq OWNED BY public.consent_records.id;


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
-- Name: doctor_profiles; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.doctor_profiles (
    id integer NOT NULL,
    user_id integer NOT NULL,
    departments_id integer,
    specialization character varying(150),
    qualification character varying(150),
    years_experience integer,
    registration_number integer,
    consultation_fee numeric(10,2),
    license_number character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.doctor_profiles OWNER TO utsavsingh;

--
-- Name: doctor_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.doctor_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_profiles_id_seq OWNER TO utsavsingh;

--
-- Name: doctor_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.doctor_profiles_id_seq OWNED BY public.doctor_profiles.id;


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
-- Name: kpi_snapshots; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.kpi_snapshots (
    id integer NOT NULL,
    hospital_id bigint NOT NULL,
    snapshot_date date NOT NULL,
    department_id integer,
    kpi_name character varying(50) NOT NULL,
    kpi_value numeric(12,4) NOT NULL,
    computed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.kpi_snapshots OWNER TO utsavsingh;

--
-- Name: kpi_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.kpi_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kpi_snapshots_id_seq OWNER TO utsavsingh;

--
-- Name: kpi_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.kpi_snapshots_id_seq OWNED BY public.kpi_snapshots.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    notification_type character varying(50) NOT NULL,
    channel public.notification_channel NOT NULL,
    message text NOT NULL,
    status public.notification_status DEFAULT 'PENDING'::public.notification_status,
    scheduled_at timestamp without time zone NOT NULL,
    sent_at timestamp without time zone,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO utsavsingh;

--
-- Name: notificaions_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.notificaions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notificaions_id_seq OWNER TO utsavsingh;

--
-- Name: notificaions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.notificaions_id_seq OWNED BY public.notifications.id;


--
-- Name: patient_profiles; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.patient_profiles (
    user_id integer NOT NULL,
    uhid character varying(20) NOT NULL,
    date_of_birth date NOT NULL,
    gender public.gender_enum NOT NULL,
    blood_group character varying(5),
    allergies jsonb,
    chronic_conditions jsonb,
    emergency_contact_name character varying(100),
    emergency_contact_phone character varying(15),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.patient_profiles OWNER TO utsavsingh;

--
-- Name: prescription_items; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.prescription_items (
    id integer NOT NULL,
    prescription_id integer NOT NULL,
    medicine_name character varying(200) NOT NULL,
    dosage character varying(50),
    frequency character varying(50),
    duration_days integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.prescription_items OWNER TO utsavsingh;

--
-- Name: prescription_items_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.prescription_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prescription_items_id_seq OWNER TO utsavsingh;

--
-- Name: prescription_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.prescription_items_id_seq OWNED BY public.prescription_items.id;


--
-- Name: prescriptions; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.prescriptions (
    id integer NOT NULL,
    visit_id integer NOT NULL,
    valid_until date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.prescriptions OWNER TO utsavsingh;

--
-- Name: prescriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.prescriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prescriptions_id_seq OWNER TO utsavsingh;

--
-- Name: prescriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.prescriptions_id_seq OWNED BY public.prescriptions.id;


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
-- Name: visit_records; Type: TABLE; Schema: public; Owner: utsavsingh
--

CREATE TABLE public.visit_records (
    id integer NOT NULL,
    appointment_id integer NOT NULL,
    symptoms text,
    diagnosis text,
    diagnosis_code character varying(20),
    clinical_notes text,
    follow_up_date date,
    is_locked boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.visit_records OWNER TO utsavsingh;

--
-- Name: visit_records_id_seq; Type: SEQUENCE; Schema: public; Owner: utsavsingh
--

CREATE SEQUENCE public.visit_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visit_records_id_seq OWNER TO utsavsingh;

--
-- Name: visit_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: utsavsingh
--

ALTER SEQUENCE public.visit_records_id_seq OWNED BY public.visit_records.id;


--
-- Name: admission_analytics id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admission_analytics ALTER COLUMN id SET DEFAULT nextval('public.admission_analytics_id_seq'::regclass);


--
-- Name: admissions id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admissions ALTER COLUMN id SET DEFAULT nextval('public.admissions_id_seq'::regclass);


--
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: consent_records id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.consent_records ALTER COLUMN id SET DEFAULT nextval('public.consent_records_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: doctor_profiles id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.doctor_profiles ALTER COLUMN id SET DEFAULT nextval('public.doctor_profiles_id_seq'::regclass);


--
-- Name: hospital_subscriptions id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.hospital_subscriptions_id_seq'::regclass);


--
-- Name: hospitals hospital_id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospitals ALTER COLUMN hospital_id SET DEFAULT nextval('public.hospitals_hospital_id_seq'::regclass);


--
-- Name: kpi_snapshots id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.kpi_snapshots ALTER COLUMN id SET DEFAULT nextval('public.kpi_snapshots_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notificaions_id_seq'::regclass);


--
-- Name: prescription_items id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.prescription_items ALTER COLUMN id SET DEFAULT nextval('public.prescription_items_id_seq'::regclass);


--
-- Name: prescriptions id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.prescriptions ALTER COLUMN id SET DEFAULT nextval('public.prescriptions_id_seq'::regclass);


--
-- Name: subscription_plans id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.subscription_plans ALTER COLUMN id SET DEFAULT nextval('public.subscription_plans_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: visit_records id; Type: DEFAULT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.visit_records ALTER COLUMN id SET DEFAULT nextval('public.visit_records_id_seq'::regclass);


--
-- Name: admission_analytics admission_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admission_analytics
    ADD CONSTRAINT admission_analytics_pkey PRIMARY KEY (id);


--
-- Name: admissions admissions_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admissions
    ADD CONSTRAINT admissions_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: consent_records consent_records_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.consent_records
    ADD CONSTRAINT consent_records_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: doctor_profiles doctor_profiles_license_number_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.doctor_profiles
    ADD CONSTRAINT doctor_profiles_license_number_key UNIQUE (license_number);


--
-- Name: doctor_profiles doctor_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.doctor_profiles
    ADD CONSTRAINT doctor_profiles_pkey PRIMARY KEY (id);


--
-- Name: doctor_profiles doctor_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.doctor_profiles
    ADD CONSTRAINT doctor_profiles_user_id_key UNIQUE (user_id);


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
-- Name: kpi_snapshots kpi_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.kpi_snapshots
    ADD CONSTRAINT kpi_snapshots_pkey PRIMARY KEY (id);


--
-- Name: notifications notificaions_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notificaions_pkey PRIMARY KEY (id);


--
-- Name: patient_profiles patient_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.patient_profiles
    ADD CONSTRAINT patient_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: patient_profiles patient_profiles_uhid_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.patient_profiles
    ADD CONSTRAINT patient_profiles_uhid_key UNIQUE (uhid);


--
-- Name: prescription_items prescription_items_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.prescription_items
    ADD CONSTRAINT prescription_items_pkey PRIMARY KEY (id);


--
-- Name: prescriptions prescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pkey PRIMARY KEY (id);


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
-- Name: visit_records visit_records_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.visit_records
    ADD CONSTRAINT visit_records_appointment_id_key UNIQUE (appointment_id);


--
-- Name: visit_records visit_records_pkey; Type: CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.visit_records
    ADD CONSTRAINT visit_records_pkey PRIMARY KEY (id);


--
-- Name: admission_analytics fk_aa_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admission_analytics
    ADD CONSTRAINT fk_aa_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: admissions fk_admission_department; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admissions
    ADD CONSTRAINT fk_admission_department FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: admissions fk_admission_doctor; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admissions
    ADD CONSTRAINT fk_admission_doctor FOREIGN KEY (doctor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: admissions fk_admission_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admissions
    ADD CONSTRAINT fk_admission_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: admissions fk_admission_patient; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.admissions
    ADD CONSTRAINT fk_admission_patient FOREIGN KEY (patient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: appointments fk_appointment_department; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_appointment_department FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: appointments fk_appointment_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_appointment_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: appointments fk_appointment_patient; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_appointment_patient FOREIGN KEY (doctor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: audit_logs fk_audit_user; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: consent_records fk_consent_doctor; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.consent_records
    ADD CONSTRAINT fk_consent_doctor FOREIGN KEY (doctor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: consent_records fk_consent_patient; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.consent_records
    ADD CONSTRAINT fk_consent_patient FOREIGN KEY (patient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: departments fk_department_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT fk_department_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: doctor_profiles fk_doctor_department; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.doctor_profiles
    ADD CONSTRAINT fk_doctor_department FOREIGN KEY (departments_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: doctor_profiles fk_doctor_user; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.doctor_profiles
    ADD CONSTRAINT fk_doctor_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: hospital_subscriptions fk_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions
    ADD CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: kpi_snapshots fk_kpi_departement; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.kpi_snapshots
    ADD CONSTRAINT fk_kpi_departement FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: notifications fk_notificaton_user; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_notificaton_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: patient_profiles fk_patient_user; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.patient_profiles
    ADD CONSTRAINT fk_patient_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: hospital_subscriptions fk_plan; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.hospital_subscriptions
    ADD CONSTRAINT fk_plan FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE RESTRICT;


--
-- Name: prescription_items fk_prescription_item; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.prescription_items
    ADD CONSTRAINT fk_prescription_item FOREIGN KEY (prescription_id) REFERENCES public.prescriptions(id) ON DELETE CASCADE;


--
-- Name: prescriptions fk_prescription_visit; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT fk_prescription_visit FOREIGN KEY (visit_id) REFERENCES public.visit_records(id) ON DELETE CASCADE;


--
-- Name: users fk_user_hospital; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_user_hospital FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id) ON DELETE CASCADE;


--
-- Name: visit_records fk_visit_appointment; Type: FK CONSTRAINT; Schema: public; Owner: utsavsingh
--

ALTER TABLE ONLY public.visit_records
    ADD CONSTRAINT fk_visit_appointment FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict AI9tGIcApVC6NugVTVrXF5EhfhjZHbxCmVMvV1hZqHZI0jZZGb0c6dpQSdOxeLB

