from sqlalchemy import BigInteger, Boolean, Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.sql import func

from database import Base


class Admission(Base):
    __tablename__ = "admissions"

    id = Column(Integer, primary_key=True, index=True)
    hospital_id = Column(BigInteger, ForeignKey("hospitals.hospital_id"), nullable=False)
    patient_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=False)
    admission_date = Column(DateTime, nullable=False)
    discharge_date = Column(DateTime, nullable=True)
    diagnosis_code = Column(String(20), nullable=True)
    diagnosis_group = Column(String(50), nullable=True)
    treatment_cost = Column(Numeric(10, 2), nullable=True)
    readmitted = Column(Boolean, default=False)
    readmission_days = Column(Integer, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
