from sqlalchemy import Column, Integer, String, Numeric, DateTime, Boolean, ForeignKey, Index

from database import Base


class AdmissionAnalytics(Base):
    __tablename__ = "admission_analytics"

    id = Column(Integer, primary_key=True, index=True)
    hospital_id = Column(Integer, ForeignKey("hospitals.id"), nullable=False)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Denormalized — copied from departments table to avoid JOIN
    department_name = Column(String(100))

    # ALOS source — both timestamps needed
    admission_date = Column(DateTime(timezone=True))
    discharge_date = Column(DateTime(timezone=True), nullable=True)

    # Pre-computed length of stay — ETL calculates this
    # ALOS = AVG(los_days) grouped by department
    los_days = Column(Numeric(5, 1), nullable=True)

    # CPV and revenue analytics source
    treatment_cost = Column(Numeric(10, 2), nullable=True)

    # DRG mix and seasonal disease detection source
    diagnosis_code = Column(String(20), nullable=True)
    diagnosis_group = Column(String(50), nullable=True)

    # RAR source — readmission analytics
    readmitted = Column(Boolean, default=False)
    readmission_days = Column(Integer, nullable=True)

    # Readmission risk model input — pre-computed from DOB
    patient_age = Column(Integer, nullable=True)

    # Composite index for fast department + date range queries
    __table_args__ = (
        Index("idx_aa_hospital_dept", "hospital_id", "department_name"),
        Index("idx_aa_admission_date", "admission_date"),
    )
