from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.sql import func

from database import Base


class VisitRecord(Base):
    __tablename__ = "visit_records"

    id = Column(Integer, primary_key=True, index=True)
    appointment_id = Column(Integer, ForeignKey("appointments.id"), unique=True, nullable=False)
    symptoms = Column(Text, nullable=True)
    diagnosis = Column(Text, nullable=True)
    diagnosis_code = Column(String(20), nullable=True)
    clinical_notes = Column(Text, nullable=True)
    follow_up_date = Column(Date, nullable=True)
    is_locked = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())
