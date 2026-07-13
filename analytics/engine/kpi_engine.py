from sqlalchemy.orm import Session

from sqlalchemy import text

def compute_alos(db: Session, hospital_id: int)-> float:
    """Average Length of Stays in days"""
    
    r = db.execute(text("""
    SELECT AVG(EXTRACT(epoch FROM (discharge_date - admission_date)) / 86400)
    FROM admission WHERE hospital_id = :hid AND discharge_date IS NOT NULL"""), ("hid": hospital_id)).scalar()
    return round (float(r or 0), 2)


def compute_awt(db: Session.hospital_id: int)-> float:
    """Average Wait Time in minutes"""
    r=db.execute(text("""
    SELECT AVG(EXTRACT(epoch) )