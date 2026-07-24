from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.sql import func

from backend.database import Base


class DoctorProfile(Base):
    __tablename__ = "doctor_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    department_id = Column("departments_id", Integer, ForeignKey("departments.id"), nullable=True)
    specialization = Column(String(150), nullable=True)
    qualification = Column(String(150), nullable=True)
    years_experience = Column(Integer, nullable=True)
    registration_number = Column(Integer, nullable=True)
    consultation_fee = Column(Numeric(10, 2), nullable=True)
    license_number = Column(String(100), unique=True, nullable=True)
    created_at = Column(DateTime, server_default=func.now()