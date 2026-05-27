# Healthcare Analytics SaaS Database Schema

## Current Architecture

```text
hospitals
    │
    ├── users
    │      ├── SUPER_ADMIN
    │      ├── HOSPITAL_ADMIN
    │      ├── DOCTOR
    │      ├── LAB_TECH
    │      └── PATIENT
    │
    ├── hospital_subscriptions
    │
    └── subscription_plans
```

## Description

### hospitals
Master tenant table.

### users
Authentication and authorization table.

Roles:
- SUPER_ADMIN
- HOSPITAL_ADMIN
- DOCTOR
- LAB_TECH
- PATIENT

### subscription_plans
Stores Basic, Pro and Enterprise plans.

### hospital_subscriptions
Links hospitals to subscription plans.


healthcare-analytics
│
├── backend
├── frontend
├── analytics
├── etl
├── tests
│
├── docs
│   ├── database_schema.md
│   ├── er_diagram.drawio
│   └── api_design.md
│
├── README.md
├── requirements.txt
└── .gitignore


# Healthcare Analytics Database Schema

## Current Schema

hospitals
│
├── users
├── subscription_plans
└── hospital_subscriptions

---

## After Adding Departments

hospitals
│
├── users
├── departments
├── subscription_plans
└── hospital_subscriptions

---

## Relationship

One hospital can have many departments.

Example:

Apollo Delhi
├── Cardiology
├── ICU
├── Emergency
└── Orthopaedics

---

### hospitals → departments

Relationship: One-to-Many (1:N)

One hospital can contain multiple departments.

Example:

Hospital ID 1
├── Cardiology
├── ICU
├── Orthopaedics
└── Emergencys


hospitals
│
├── users
│   │
│   ├── patient_profiles
│   └── doctor_profiles (later)
│
├── departments
│   │
│   ├── appointments
│   ├── admissions
│   └── visit_records
│
├── subscription_plans
└── hospital_subscriptions


Relationship after adding admissions
hospitals
│
├── users
│     ├── patient_profiles
│     └── doctors
│
├── departments
│     ├── appointments
│     └── admissions
│
├── subscription_plans
└── hospital_subscriptions

Schema after adding table 12
hospitals
│
├── users
│     │
│     └── patient_profiles
│
├── departments
│
├── appointments
│     │
│     └── visit_records
│            │
│            └── prescriptions
│                   │
│                   └── prescription_items
│
├── admissions
│
├── consent_records
│
├── subscription_plans
│
└── hospital_subscriptions



Relationship
hospitals
│
├── departments
│      │
│      └── kpi_snapshots
│
├── appointments
├── admissions
├── users
└── patient_profiles

Analytics flow:

appointments
      │
admissions
      │
visit_records
      │
      ▼
Nightly ETL Job
      │
      ▼
kpi_snapshots
      │
      ▼
Dashboard





Why kpi_snapshots exists

Without kpi_snapshots:

Dashboard opens
      ↓
JOIN appointments
JOIN admissions
JOIN departments
JOIN patients
      ↓
Calculate KPIs live
      ↓
10-15 second load time

With kpi_snapshots:

Nightly scheduler
      ↓
Computes KPIs once
      ↓
Stores results in kpi_snapshots
      ↓
Dashboard reads 8 rows
      ↓
Loads in milliseconds

This pattern is called:

Pre-aggregation
Materialized analytics layer
Analytics cache table

complete schema
healthdb=# \dt
                  List of relations
 Schema |          Name          | Type  |   Owner    
--------+------------------------+-------+------------
 public | admission_analytics    | table | utsavsingh
 public | admissions             | table | utsavsingh
 public | appointments           | table | utsavsingh
 public | audit_logs             | table | utsavsingh
 public | consent_records        | table | utsavsingh
 public | departments            | table | utsavsingh
 public | doctor_profiles        | table | utsavsingh
 public | hospital_subscriptions | table | utsavsingh
 public | hospitals              | table | utsavsingh
 public | kpi_snapshots          | table | utsavsingh
 public | notifications          | table | utsavsingh
 public | patient_profiles       | table | utsavsingh
 public | prescription_items     | table | utsavsingh
 public | prescriptions          | table | utsavsingh
 public | subscription_plans     | table | utsavsingh
 public | users                  | table | utsavsingh
 public | visit_records          | table | utsavsingh
(17 rows)



final -----

                                   subscription_plans
                                   ------------------
                                   id (PK)
                                         ▲
                                         │ plan_id
                                         │
hospitals ------------------------- hospital_subscriptions
---------                           ----------------------
hospital_id (PK)                    id (PK)
hospital_name                       hospital_id (FK)
hospital_type                       plan_id (FK)
city/state                          status
...                                 start_date
                                    end_date


        │
        │ hospital_id
        ▼

users
-----
id (PK)
hospital_id (FK → hospitals)
email
role
...

│
├───────────────────────────────┐
│                               │
│                               │
▼                               ▼

doctor_profiles                 patient_profiles
---------------                 ----------------
id (PK)                         id (PK)
user_id (FK → users) UNIQUE     user_id (FK → users) UNIQUE
department_id (FK)              uhid
specialization                  blood_group
license_no                      allergies
                                chronic_conditions


│
│ head_doctor_id
▼

departments
-----------
id (PK)
hospital_id (FK → hospitals)
head_doctor_id (FK → users)
name
total_beds
floor


────────────────────────────────────────────────────────────

appointments
------------
id (PK)

hospital_id (FK → hospitals)

patient_id (FK → patient_profiles)

doctor_id (FK → doctor_profiles)

department_id (FK → departments)

appointment_date
check_in_time
doctor_start_time
consultation_end_time
status
appointment_type
...


│
│ one appointment
│ has one visit record
▼

visit_records
-------------
id (PK)

appointment_id (FK → appointments) UNIQUE

symptoms
diagnosis
diagnosis_code
clinical_notes
follow_up_date
is_locked


│
│ one visit can generate
│ one prescription
▼

prescriptions
-------------
id (PK)

visit_id (FK → visit_records)

valid_until
created_at


│
│ one prescription
│ has many medicines
▼

prescription_items
------------------
id (PK)

prescription_id (FK → prescriptions)

medicine_name
dosage
frequency
duration_days


────────────────────────────────────────────────────────────

admissions
----------
id (PK)

hospital_id (FK → hospitals)

patient_id (FK → patient_profiles)

doctor_id (FK → doctor_profiles)

department_id (FK → departments)

admission_date
discharge_date
diagnosis_code
diagnosis_group
treatment_cost
readmitted
readmission_days


│
│ nightly ETL copies data
▼

admission_analytics
-------------------
id (PK)

hospital_id (FK → hospitals)

patient_id
doctor_id

department_name

admission_date
discharge_date
los_days

treatment_cost

diagnosis_code
diagnosis_group

readmitted
readmission_days

patient_age_at_admission


────────────────────────────────────────────────────────────

consent_records
---------------
id (PK)

patient_id (FK → patient_profiles)

doctor_id (FK → doctor_profiles)

consent_type
status
otp_code
accessed_at


────────────────────────────────────────────────────────────

kpi_snapshots
-------------
id (PK)

hospital_id (FK → hospitals)

department_id (FK → departments, NULL allowed)

snapshot_date
kpi_name
kpi_value
computed_at


────────────────────────────────────────────────────────────

notifications
-------------
id (PK)

user_id (FK → users)

notification_type
channel
message
status
scheduled_at
sent_at
read_at


────────────────────────────────────────────────────────────

audit_logs
----------
id (PK)

user_id (FK → users)

action
entity_type
entity_id

ip_address
timestamp



High-level flow
Hospital
   │
   ├── Users
   │      ├── Doctor Profiles
   │      └── Patient Profiles
   │
   ├── Departments
   │
   ├── Appointments
   │      └── Visit Records
   │              └── Prescriptions
   │                      └── Prescription Items
   │
   ├── Admissions
   │      └── Admission Analytics
   │
   ├── KPI Snapshots
   │
   ├── Notifications
   │
   ├── Consent Records
   │
   └── Hospital Subscriptions
            └── Subscription Plans

Audit Logs track activity across everything.