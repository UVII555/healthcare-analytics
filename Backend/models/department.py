from sqlalchemy import BigInteger, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.sql import func

from database import Base


class Department(Base):
    __tablename__ = "departments"

    id = Column(Integer, primary_key=True, index=True)
    hospital_id = Column(BigInteger, ForeignKey("hospitals.hospital_id"), nullable=False)
    name = Column(String(100), nullable=False)
    head_doctor_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    total_beds = Column(Integer, default=0)
    floor = Column(Integer, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
