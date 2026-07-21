from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from backend.database import get_db
from backend.models.user import User
from backend.models.patient import PatientProfile
from backend.services.auth_service import get_current_user, hash_password
from backend.schemas.patient import CreatePatientRequest, PatientCreateResponse

router = APIRouter()

@router.get("/")
def list_patients(skip: int = 0, limit: int = 50, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    hospital_id = current_user["hospital_id"]
    patients = db.query(User).filter(User.hospital_id == hospital_id, User.role == "PATIENT").order_by(User.id).offset(skip).limit(limit).all()
    return [{"id": p.id, "email": p.email, "full_name": p.full_name} for p in patients]

@router.get("/{patient_id}")
def get_patient(patient_id: int, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    hospital_id = current_user["hospital_id"]
    patient = db.query(User).filter(User.id == patient_id, User.hospital_id == hospital_id, User.role == "PATIENT").first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    profile = db.query(PatientProfile).filter(PatientProfile.user_id == patient.id).first()
    return {"user": {"id": patient.id, "email": patient.email, "full_name": patient.full_name}, "profile": profile}

@router.post("/", response_model=PatientCreateResponse, status_code=201)
def create_patient(data: CreatePatientRequest, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    hospital_id = current_user["hospital_id"]
    if hospital_id is None:
        raise HTTPException(status_code=403, detail="No hospital associated with this account")

    user = User(hospital_id=hospital_id, email=data.email, hashed_password=hash_password(data.password), full_name=data.full_name, role="PATIENT", is_active=True)
    db.add(user); db.flush()
    count = db.query(PatientProfile).count()
    uhid = f"MED-2025-{str(count+1).zfill(6)}"
    profile = PatientProfile(
        user_id=user.id,
        uhid=uhid,
        date_of_birth=data.date_of_birth,
        gender=data.gender.value,
        blood_group=data.blood_group,
        allergies=data.allergies,
        chronic_conditions=data.chronic_conditions,
        emergency_contact_name=data.emergency_contact_name,
        emergency_contact_phone=data.emergency_contact_phone,
    )
    db.add(profile)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="A patient with this email already exists")
    return {"message": "Patient created", "uhid": uhid, "user_id": user.id}
