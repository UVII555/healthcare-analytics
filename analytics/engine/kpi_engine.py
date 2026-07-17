from sqlalchemy.orm import Session

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
    FROM appointments WHERE hospital_id  =:hid
    AND doctor_start_time is NOT NULL AND check_in_time IS NOT NULL """),
    {"hid": hospital_id}).scalar()
    return round(float(r or 0), 1)


def compute_opd_load(db: Session, hospital_id: int) -> dict:
    """" Daily appointment count - last 30 days""" 
    rows = db.execute(text("""
                           SELECT appoinment_date::text, COUNT(*) FROM appointments
                           WHERE hospital_id = : hid AND status = 'COMPLETED'
                           GROUP BY appointment_date ORDER BY appointment_date DESC LIMIT 30"""), 
                           {"hid": hospital_id}).fetchall()
    return {r[0]: r[1] for r in rows}


def compute_rar(db: Session, hospital_id:int) -> dict:
    """ 30-days Re-admission Rate %"""
    r = db.execute(text("""
        SELECT Round(100.0* SUM (CASE WHEN readmitted THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2)
        FROM admissions WHERE hospital_id =: hid
        """
        ), {"hid":hospital_id}).scalar()
    return float (r or 0)