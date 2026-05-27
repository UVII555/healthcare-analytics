"""
File: backend/seed.py
Purpose: fills all tables with realistic test data
Run: python seed.py (from backend/ folder with venv active)
Run only ONCE — running twice creates duplicate data.
"""

from datetime import datetime, timedelta, date, time
import json
import random

from faker import Faker
from sqlalchemy import select

from database import SessionLocal
from models.hospital import Hospital
from models.user import User
from models.subscription import SubscriptionPlan, HospitalSubscription
from models.department import Department
from models.doctor import DoctorProfile
from models.patient import PatientProfile
from models.appointment import Appointment
from models.admission import Admission
from models.visit_record import VisitRecord


fake = Faker("en_IN")  # Indian locale — generates Indian names/phones


def fake_hash(raw: str) -> str:
    return f"seeded::{raw}"


def run_seed() -> None:
    db = SessionLocal()
    try:
        ##############################
        # STEP 1 — Subscription Plans
        ##############################
        print("Creating subscription plans...")
        plan_payloads = [
            ("Basic", 2999.00, 500, 2, ["basic_kpis", "appointments", "queue_token"]),
            ("Pro", 9999.00, -1, 20, ["all_kpis", "forecasting", "etl", "pdf_reports"]),
            ("Enterprise", 49999.00, -1, -1, ["all_kpis", "benchmarking", "white_label", "api_access"]),
        ]
        plans = []
        for name, price, max_patients, max_doctors, flags in plan_payloads:
            existing = db.execute(select(SubscriptionPlan).where(SubscriptionPlan.name == name)).scalar_one_or_none()
            if existing:
                plans.append(existing)
                continue
            plan = SubscriptionPlan(
                name=name,
                price_monthly=price,
                max_patients=max_patients,
                max_doctors=max_doctors,
                feature_flags=flags,
            )
            db.add(plan)
            plans.append(plan)
        db.commit()

        ##############################
        # STEP 2 — Hospitals
        ##############################
        print("Creating hospitals...")
        hospitals_data = [
            {"name": "AIIMS Delhi", "type": "GOVERNMENT", "city": "New Delhi", "total_beds": 2478},
            {"name": "Apollo Hospital Chennai", "type": "PRIVATE", "city": "Chennai", "total_beds": 700},
            {"name": "KEM Hospital Mumbai", "type": "GOVERNMENT", "city": "Mumbai", "total_beds": 1800},
        ]

        hospitals = []
        for h in hospitals_data:
            hospital = Hospital(
                name=h["name"],
                hospital_code=f"HSP{random.randint(1000, 9999)}",
                hospital_type=h["type"],
                city=h["city"],
                state="India",
                total_beds=h["total_beds"],
                emergency_available=True,
            )
            db.add(hospital)
            hospitals.append(hospital)
        db.commit()

        # Link hospitals to Pro plan
        for hospital in hospitals:
            sub = HospitalSubscription(
                hospital_id=hospital.id,
                plan_id=next((p.id for p in plans if p.name == "Pro"), plans[0].id),
                status="ACTIVE",
                start_date=date(2025, 1, 1),
                end_date=date(2026, 1, 1),
            )
            db.add(sub)
        db.commit()

        ##############################
        # STEP 3 — Departments
        ##############################
        print("Creating departments...")
        dept_names = ["Cardiology", "Orthopaedics", "Neurology", "Paediatrics", "ICU"]
        all_depts = []
        for hospital in hospitals:
            for i, name in enumerate(dept_names):
                dept = Department(
                    hospital_id=hospital.id,
                    name=name,
                    total_beds=random.randint(20, 80),
                    floor=i + 1,
                )
                db.add(dept)
                all_depts.append(dept)
        db.commit()

        ##############################
        # STEP 4 — Admin users + Doctor users
        ##############################
        print("Creating users...")
        all_doctors = []
        for hospital in hospitals:
            # 1 admin per hospital
            admin = User(
                hospital_id=hospital.id,
                email=f"admin@{hospital.name.lower().replace(' ', '')}.com",
                hashed_password=fake_hash("admin123"),
                role="HOSPITAL_ADMIN",
                full_name=f"Admin {hospital.name}",
                is_active=True,
            )
            db.add(admin)

            # 5 doctors per hospital
            specializations = [
                "Cardiologist",
                "Orthopaedic Surgeon",
                "Neurologist",
                "Paediatrician",
                "Intensivist",
            ]
            for i, spec in enumerate(specializations):
                doctor_user = User(
                    hospital_id=hospital.id,
                    email=f"dr.{spec.lower().replace(' ', '')}@{hospital.id}.com",
                    hashed_password=fake_hash("doctor123"),
                    role="DOCTOR",
                    full_name=f"Dr. {fake.last_name()}",
                    is_active=True,
                )
                db.add(doctor_user)
                all_doctors.append((doctor_user, hospital, i))
        db.commit()

        # Doctor profiles
        hosp_depts = {h.id: [d for d in all_depts if d.hospital_id == h.id] for h in hospitals}
        for doctor_user, hospital, i in all_doctors:
            dept = hosp_depts[hospital.id][i]
            profile = DoctorProfile(
                user_id=doctor_user.id,
                department_id=dept.id,
                specialization=["Cardiologist", "Orthopaedic Surgeon", "Neurologist", "Paediatrician", "Intensivist"][i],
                qualification="MBBS, MD",
                registration_number=random.randint(10000, 99999),
                consultation_fee=random.choice([300, 500, 700, 1000]),
                years_experience=random.randint(3, 20),
                license_number=f"LIC-{hospital.id}-{i+1}-{random.randint(1000,9999)}",
            )
            db.add(profile)
        db.commit()

        ##############################
        # STEP 5 — Patients (200)
        ##############################
        print("Creating 200 patients...")
        blood_groups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
        conditions = ["Diabetes Type 2", "Hypertension", "Asthma", "Arthritis", "None"]
        all_patients = []
        for i in range(200):
            hospital = random.choice(hospitals)
            patient_user = User(
                hospital_id=hospital.id,
                email=fake.unique.email(),
                hashed_password=fake_hash("patient123"),
                role="PATIENT",
                full_name=fake.name(),
                is_active=True,
            )
            db.add(patient_user)
            db.flush()  # get patient_user.id without full commit

            uhid = f"MED-2025-{str(i + 1).zfill(6)}"
            profile = PatientProfile(
                user_id=patient_user.id,
                uhid=uhid,
                date_of_birth=fake.date_of_birth(minimum_age=18, maximum_age=80),
                gender=random.choice(["MALE", "FEMALE"]),
                blood_group=random.choice(blood_groups),
                allergies=json.dumps(random.sample(["Penicillin", "Sulfa", "None"], 1)),
                chronic_conditions=json.dumps(random.sample(conditions, random.randint(0, 2))),
                emergency_contact_name=fake.name(),
                emergency_contact_phone=fake.phone_number(),
            )
            db.add(profile)
            all_patients.append((patient_user, hospital))
        db.commit()
        print("200 patients created")

        ##############################
        # STEP 6 — Appointments (500)
        ##############################
        print("Creating 500 appointments...")
        icd_codes = [
            ("I21", "Acute myocardial infarction", "Cardiac"),
            ("J18", "Pneumonia", "Respiratory"),
            ("M17", "Osteoarthritis of knee", "Orthopaedic"),
            ("G43", "Migraine", "Neurological"),
            ("E11", "Type 2 diabetes mellitus", "Endocrine"),
            ("A90", "Dengue fever", "Infectious"),
            ("K35", "Acute appendicitis", "Surgical"),
        ]
        statuses = ["COMPLETED", "COMPLETED", "COMPLETED", "CANCELLED", "NO_SHOW"]
        admission_count = 0

        for i in range(500):
            patient_user, hospital = random.choice(all_patients)
            depts = hosp_depts[hospital.id]
            dept = random.choice(depts)

            # Appointment in the last 6 months
            appt_date = datetime.now() - timedelta(days=random.randint(1, 180))
            booked_at = appt_date - timedelta(hours=random.randint(2, 72))

            # Analytics timestamps — these power AWT and patient journey KPIs
            check_in = appt_date + timedelta(minutes=random.randint(-15, 20))
            dr_start = check_in + timedelta(minutes=random.randint(5, 60))  # wait time
            consult_end = dr_start + timedelta(minutes=random.randint(10, 30))  # consult duration

            doctor_user, _, _ = random.choice([d for d in all_doctors if d[1].id == hospital.id])
            appt = Appointment(
                hospital_id=hospital.id,
                patient_id=patient_user.id,
                doctor_id=doctor_user.id,
                department_id=dept.id,
                appointment_date=appt_date.date(),
                time_slot=time(hour=random.randint(9, 17), minute=random.choice([0, 15, 30, 45])),
                token_number=i % 30 + 1,
                booked_at=booked_at,
                check_in_time=check_in,
                doctor_start_time=dr_start,
                consultation_end_time=consult_end,
                status=random.choice(statuses),
                appointment_type="OPD",
            )
            db.add(appt)
            db.flush()

            # Create admission for 40% of appointments
            if random.random() < 0.4:
                icd = random.choice(icd_codes)
                adm_date = appt_date
                dis_date = adm_date + timedelta(days=random.randint(1, 14))
                readmit = random.random() < 0.1  # 10% readmission rate
                admission = Admission(
                    hospital_id=hospital.id,
                    patient_id=patient_user.id,
                    doctor_id=doctor_user.id,
                    department_id=dept.id,
                    admission_date=adm_date,
                    discharge_date=dis_date,
                    diagnosis_code=icd[0],
                    diagnosis_group=icd[2],
                    treatment_cost=random.uniform(5000, 150000),
                    readmitted=readmit,
                    readmission_days=random.randint(5, 30) if readmit else None,
                )
                db.add(admission)
                admission_count += 1

            if random.random() < 0.65:
                visit = VisitRecord(
                    appointment_id=appt.id,
                    symptoms=random.choice(["Fever, cough", "Knee pain", "Headache", "Chest discomfort"]),
                    diagnosis=random.choice(["Viral infection", "Arthritis flare", "Migraine", "Angina"]),
                    diagnosis_code=random.choice(["J18", "M17", "G43", "I21"]),
                    clinical_notes="Auto-seeded clinical note for testing.",
                    follow_up_date=(appt_date + timedelta(days=random.randint(7, 30))).date(),
                )
                db.add(visit)

        db.commit()
        print(f"500 appointments + {admission_count} admissions created")
        print("Seed complete! All tables have data.")
        print("Open pgAdmin -> healthdb -> check every table")
    finally:
        db.close()


if __name__ == "__main__":
    run_seed()
