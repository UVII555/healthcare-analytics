from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.middleware.tenant import get_hospital_id
from backend.models.department import Department
from backend.models.doctor import DoctorProfile
from backend.models.hospital import Hospital
from backend.models.user import User, UserRole

router = APIRouter(prefix="/api/lookups", tags=["Lookups"])


@router.get("/hospitals")
def list_hospitals(db: Session = Depends(get_db)):
    hospitals = db.query(Hospital).filter(Hospital.is_active.is_(True)).order_by(Hospital.id).all()
    return [{"id": hospital.id, "name": hospital.name, "city": hospital.city} for hospital in hospitals]


@router.get("/departments")
def list_departments(hospital_id: int = Depends(get_hospital_id), db: Session = Depends(get_db)):
    departments = db.query(Department).filter(Department.hospital_id == hospital_id).order_by(Department.id).all()
    return [{"id": department.id, "name": department.name} for department in departments]


@router.get("/doctors")
def list_doctors(hospital_id: int = Depends(get_hospital_id), db: Session = Depends(get_db)):
    rows = db.query(User, DoctorProfile).join(DoctorProfile, DoctorProfile.user_id == User.id).filter(
        User.hospital_id == hospital_id,
        User.role == UserRole.DOCTOR,
        User.is_active.is_(True),
    ).order_by(User.id).all()
    return [
        {
            "id": user.id,
            "full_name": user.full_name,
            "department_id": profile.department_id,
            "specialization": profile.specialization,
        }
        for user, profile in rows
    ]
