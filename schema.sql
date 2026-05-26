-- table 1
CREATE TABLE hospitals (
    hospital_id BIGSERIAL PRIMARY KEY,
    hospital_name VARCHAR(200) NOT NULL,
    hospital_code VARCHAR(50) UNIQUE NOT NULL
);


CREATE TYPE hospital_type_enum AS ENUM (
    'GOVERNMENT',
    'PRIVATE',
    'CLINIC',
    'DIAGNOSTIC'
);

CREATE TYPE subscription_status AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'CANCELLED',
    'TRIAL'
);c

CREATE TYPE user_role AS ENUM (
    'SUPER_ADMIN',
    'HOSPITAL_ADMIN',
    'DOCTOR',
    'LAB_TECH',
    'PATIENT'
);
-- table 2
CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price_monthly NUMERIC(10,2),
    max_patients INTEGER,
    max_doctors INTEGER,
    feature_flags JSON
);

-- //hospital_subscriptions table 3
CREATE TABLE hospital_subscriptions (
    id SERIAL PRIMARY KEY,

    hospital_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,

    status subscription_status NOT NULL DEFAULT 'TRIAL',

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    trial_ends_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospitals(hospital_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_plan
        FOREIGN KEY (plan_id)
        REFERENCES subscription_plans(id)
        ON DELETE RESTRICT
);

--Role ENUM

--Create the role type first:

CREATE TYPE user_role AS ENUM (
    'SUPER_ADMIN',
    'HOSPITAL_ADMIN',
    'DOCTOR',
    'LAB_TECH',
    'PATIENT'
);
 --USERS table table 4

 CREATE TABLE users (

    id SERIAL PRIMARY KEY,

    hospital_id BIGINT,

    email VARCHAR(150) UNIQUE NOT NULL,

    hashed_password VARCHAR(255) NOT NULL,

    role user_role NOT NULL,

    full_name VARCHAR(200) NOT NULL,

    phone VARCHAR(15),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospitals(hospital_id)
        ON DELETE CASCADE
);

-- table 5
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,

    hospital_id BIGINT NOT NULL,

    name VARCHAR(100) NOT NULL,

    head_doctor_id INTEGER,

    total_beds INTEGER DEFAULT 0,

    floor INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_department_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospitals(hospital_id)
        ON DELETE CASCADE
);

-- table 6
CREATE TABLE doctor_profiles (
    id SERIAL PRIMARY KEY,

    user_id INTEGER UNIQUE NOT NULL,

    department_id INTEGER,

    specialization VARCHAR(150),

    qualification VARCHAR(150),

    years_experience INTEGER,

    consultation_fee NUMERIC(10,2),

    license_number VARCHAR(100) UNIQUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_doctor_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_doctor_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE SET NULL
);
-- -- table 7
-- CREATE TABLE doctor_profiles(
-- id SERIAL PRIMARY KEY,
-- user_id INTEGER UNIQUE NOT NULL,
-- departments_id INTEGER,
-- specialization VARCHAR(150),
-- qualification VARCHAR(150),
-- years_experience INTEGER,
-- registration_number INTEGER,
-- consultation_fee NUMERIC(10,2),
-- license_number VARCHAR(100) UNIQUE,
-- created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- CONSTRAINT fk_doctor_user
-- FOREIGN KEY (user_id)
-- REFERENCES users(id)
-- ON DELETE CASCADE,
-- CONSTRAINT fk_doctor_department
-- FOREIGN KEY (departments_id)
-- REFERENCES departments(id)
-- ON DELETE SET NULL);
-- table 




-- Table 7: patient_profiles

-- First create ENUM for gender.

CREATE TYPE gender_enum AS ENUM (
    'MALE',
    'FEMALE',
    'OTHER'
);

-- Then create table:
CREATE TABLE patient_profiles (
    user_id INTEGER PRIMARY KEY,

    uhid VARCHAR(20) UNIQUE NOT NULL,

    date_of_birth DATE NOT NULL,

    gender gender_enum NOT NULL,

    blood_group VARCHAR(5),

    allergies JSONB,

    chronic_conditions JSONB,

    emergency_contact_name VARCHAR(100),

    emergency_contact_phone VARCHAR(15),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_patient_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- Table 8: appointments

-- Create ENUMs first.

-- Appointment Status

CREATE TYPE appointment_status AS ENUM (
    'SCHEDULED',
    'CHECKED_IN',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
    'NO_SHOW'
);

--Appointment Type
CREATE TYPE appointment_type_enum AS ENUM (
    'OPD',
    'EMERGENCY',
    'FOLLOW_UP'
);