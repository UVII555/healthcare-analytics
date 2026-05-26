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
);

CREATE TYPE user_role AS ENUM (
    'SUPER_ADMIN',
    'HOSPITAL_ADMIN',
    'DOCTOR',
    'LAB_TECH',
    'PATIENT'
);

CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price_monthly NUMERIC(10,2),
    max_patients INTEGER,
    max_doctors INTEGER,
    feature_flags JSON
);