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