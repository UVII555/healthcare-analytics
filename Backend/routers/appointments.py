

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models.appointment import Appointment
from services.auth_service import get_current_user
from datetime import datetime, date

router = APIRouter()


@router.post("/book")
def book_appointment(data: dict, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    hospital_id = current_user["hospital_id"]
    today = date.today()
    count = db.query(Appointment).filter(
        Appointment.doctor_id == data["doctor_id"],
        Appointment.appointment_date == today,
        Appointment.hospital_id == hospital_id
    ).count()
    token_number = count + 1  # auto-increment token for this doctor today
    appt = Appointment(
        hospital_id=hospital_id, patient_id=current_user["user_id"],
        doctor_id=data["doctor_id"], department_id=data["department_id"],
        appointment_date=today, token_number=token_number,
        booked_at=datetime.utcnow(),  # analytics: booking lead time
        status="SCHEDULED", appointment_type="OPD"
    )
    db.add(appt); db.commit(); db.refresh(appt)
    return {"appointment_id": appt.id, "token_number": token_number}


@router.put("/{appt_id}/checkin")
def check_in(appt_id: int, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    appt = db.query(Appointment).filter(Appointment.id == appt_id).first()
    if not appt: raise HTTPException(status_code=404, detail="Not found")
    appt.check_in_time = datetime.utcnow()  # AWT clock STARTS here
    appt.status = "CHECKED_IN"
    db.commit()
    return {"message": "Checked in", "check_in_time": str(appt.check_in_time)}


@router.put("/{appt_id}/start")
def start_consultation(appt_id: int, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    appt = db.query(Appointment).filter(Appointment.id == appt_id).first()
    if not appt: raise HTTPException(status_code=404, detail="Not found")
    appt.doctor_start_time = datetime.utcnow()  # AWT = start - check_in
    appt.status = "IN_PROGRESS"
    db.commit()
    return {"message": "Consultation started"}


@router.put("/{appt_id}/complete")
def complete(appt_id: int, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    appt = db.query(Appointment).filter(Appointment.id == appt_id).first()
    if not appt: raise HTTPException(status_code=404, detail="Not found")
    appt.consultation_end_time = datetime.utcnow()  # duration = end - start
    appt.status = "COMPLETED"
    db.commit()
    return {"message": "Completed"}


@router.get("/{appt_id}/queue")
def queue_position(appt_id: int, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    appt = db.query(Appointment).filter(Appointment.id == appt_id).first()
    if not appt: raise HTTPException(status_code=404, detail="Not found")
    ahead = db.query(Appointment).filter(
        Appointment.doctor_id == appt.doctor_id,
        Appointment.appointment_date == appt.appointment_date,
        Appointment.token_number < appt.token_number,
        Appointment.status.in_(["SCHEDULED", "CHECKED_IN"])
    ).count()
    return {"token": appt.token_number, "ahead": ahead, "wait_min": ahead * 15}