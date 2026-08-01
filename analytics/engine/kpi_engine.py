from sqlalchemy.orm import Session
from backend.database import SessionLocal
from sqlalchemy import text

def compute_alos(db: Session, hospital_id: int)-> float:
    """Average Length of Stays in days"""
    
    r = db.execute(text("""
    SELECT AVG(EXTRACT(epoch FROM (discharge_date - admission_date)) / 86400)
    FROM admissions WHERE hospital_id = :hid AND discharge_date IS NOT NULL"""), {"hid": hospital_id}).scalar()
    return round (float(r or 0), 2)


def compute_awt(db: Session, hospital_id: int)-> float:
    """Average Wait Time in minutes"""


    r = db.execute(text("""
    SELECT AVG(EXTRACT(epoch FROM (doctor_start_time-check_in_time))/60) 
    FROM appointments WHERE hospital_id  = :hid
    AND doctor_start_time is NOT NULL AND check_in_time IS NOT NULL """),
    {"hid": hospital_id}).scalar()
    return round(float(r or 0), 1)


def compute_opd_load(db: Session, hospital_id: int) -> float:
    """" Daily appointment count - last 30 days""" 
    rows = db.execute(text("""
                           SELECT appointment_date::text, COUNT(*) FROM appointments
                           WHERE hospital_id = :hid AND status = 'COMPLETED'
                           GROUP BY appointment_date ORDER BY appointment_date DESC LIMIT 30"""), 
                           {"hid": hospital_id}).fetchall()
    return {r[0]: r[1] for r in rows}


def compute_rar(db: Session, hospital_id:int) -> float:
    """ 30-days Re-admission Rate %"""
    r = db.execute(text("""
        SELECT Round(100.0* SUM (CASE WHEN readmitted THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2)
        FROM admissions WHERE hospital_id = :hid
        """
        ), {"hid":hospital_id}).scalar()
    return float (r or 0)

def compute_drg_mix(db: Session, hospital_id: int) -> dict:
    """Diagnosis mix — count by ICD-10 category"""
    rows = db.execute(text("""
        SELECT LEFT(diagnosis_code, 1) as category, COUNT(*) as count
        FROM admissions
        WHERE hospital_id = :hid AND diagnosis_code IS NOT NULL
        GROUP BY LEFT(diagnosis_code, 1)
        ORDER BY count DESC
    """), {"hid": hospital_id}).fetchall()

    label_map = {
        "A":"Infectious", "C":"Cancer", "I":"Cardiac",
        "J":"Respiratory", "K":"Digestive", "M":"Orthopaedic",
        "N":"Urinary", "S":"Injury"
    }
    return {
        "labels": [label_map.get(r[0], r[0]) for r in rows],
        "data": [r[1] for r in rows]
    }

def compute_bor(db: Session, hospital_id: int) -> float:
    """Bed Occupancy Rate %"""
    occupied = db.execute(text(
        "SELECT COUNT(*) FROM admissions WHERE hospital_id=:hid AND discharge_date IS NULL"
    ), {"hid": hospital_id}).scalar() or 0
    beds = db.execute(text(
        "SELECT total_beds FROM hospitals WHERE id=:hid"
    ), {"hid": hospital_id}).scalar() or 1
    return round((occupied / beds) * 100, 1)


def compute_cpv(db: Session, hospital_id: int) -> float:
    """Cost Per Visit"""
    r = db.execute(text(
        "SELECT AVG(treatment_cost) FROM admissions WHERE hospital_id=:hid AND treatment_cost IS NOT NULL"
    ), {"hid": hospital_id}).scalar()
    return round(float(r or 0), 2)


def compute_revenue(db: Session, hospital_id: int) -> float:
    """Total revenue this month"""
    r = db.execute(text("""
        SELECT SUM(treatment_cost) FROM admissions
        WHERE hospital_id=:hid AND DATE_TRUNC('month',admission_date)=DATE_TRUNC('month',NOW())
    """), {"hid": hospital_id}).scalar()
    return round(float(r or 0), 2)