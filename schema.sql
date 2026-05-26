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

-- Then create table:
CREATE TABLE appointments (

    id SERIAL PRIMARY KEY,

    hospital_id BIGINT NOT NULL,

    patient_id INTEGER NOT NULL,

    doctor_id INTEGER NOT NULL,

    department_id INTEGER NOT NULL,

    appointment_date DATE NOT NULL,

    time_slot TIME NOT NULL,

    token_number INTEGER,

    booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    check_in_time TIMESTAMP,

    doctor_start_time TIMESTAMP,

    consultation_end_time TIMESTAMP,

    status appointment_status
        DEFAULT 'SCHEDULED',

    appointment_type appointment_type_enum
        DEFAULT 'OPD',

    chief_complaint TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_appointment_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospitals(hospital_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_appointment_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE CASCADE
);

--table 9  Create admissions table
CREATE TABLE admissions (

    id SERIAL PRIMARY KEY,

    hospital_id BIGINT NOT NULL,

    patient_id INTEGER NOT NULL,

    doctor_id INTEGER NOT NULL,

    department_id INTEGER NOT NULL,

    admission_date TIMESTAMP NOT NULL,

    discharge_date TIMESTAMP,

    diagnosis_code VARCHAR(20),

    diagnosis_group VARCHAR(50),

    treatment_cost NUMERIC(10,2),

    readmitted BOOLEAN DEFAULT FALSE,

    readmission_days INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_admission_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospitals(hospital_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_admission_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_admission_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE CASCADE
);
--Table 10 — visit_records

--One consultation record per appointment.
CREATE TABLE visit_records (

    id SERIAL PRIMARY KEY,

    appointment_id INTEGER UNIQUE NOT NULL,

    symptoms TEXT,

    diagnosis TEXT,

    diagnosis_code VARCHAR(20),

    clinical_notes TEXT,

    follow_up_date DATE,

    is_locked BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_visit_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(id)
        ON DELETE CASCADE
);

-- Table 11A — prescriptions

-- One prescription generated during a visit.

CREATE TABLE prescriptions (

    id SERIAL PRIMARY KEY,

    visit_id INTEGER NOT NULL,

    valid_until DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_prescription_visit
        FOREIGN KEY (visit_id)
        REFERENCES visit_records(id)
        ON DELETE CASCADE
);

-- Table 11B — prescription_items

-- Multiple medicines belong to one prescription.

CREATE TABLE prescription_items (

    id SERIAL PRIMARY KEY,

    prescription_id INTEGER NOT NULL,

    medicine_name VARCHAR(200) NOT NULL,

    dosage VARCHAR(50),

    frequency VARCHAR(50),

    duration_days INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_prescription_item
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE
);

-- Table 12 — consent_records

-- First create ENUMs.

-- Consent Type
CREATE TYPE consent_type_enum AS ENUM (
    'OTP',
    'REQUEST',
    'PERMANENT',
    'EMERGENCY'
);
-- Consent Status
CREATE TYPE consent_status_enum AS ENUM (
    'PENDING',
    'APPROVED',
    'DENIED',
    'REVOKED',
    'EXPIRED'
);
-- Then create table:
CREATE TABLE consent_records (

    id SERIAL PRIMARY KEY,

    patient_id INTEGER NOT NULL,

    doctor_id INTEGER NOT NULL,

    consent_type consent_type_enum NOT NULL,

    status consent_status_enum
        DEFAULT 'PENDING',

    otp_code VARCHAR(6),

    otp_expires_at TIMESTAMP,

    emergency_reason TEXT,

    accessed_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_consent_patient
        FOREIGN KEY (patient_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consent_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);