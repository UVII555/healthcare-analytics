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