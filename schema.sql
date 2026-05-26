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

CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price_monthly NUMERIC(10,2),
    max_patients INTEGER,
    max_doctors INTEGER,
    feature_flags JSON
);

-- //hospital_subscriptions
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
 --USERS table

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