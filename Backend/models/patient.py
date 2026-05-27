import enum

from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, JSON, String
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.sql import func

from database import Base


class GenderEnum(str, enum.Enum):
    MALE = "MALE"
    FEMALE = "FEMALE"
    OTHER = "OTHER"


class PatientProfile(Base):
    __tablename__ = "patient_profiles"

    user_id = Column(Integer, ForeignKey("users.id"), primary_key=True, nullable=False)
    uhid = Column(String(20), unique=True, nullable=False)
    date_of_birth = Column(Date, nullable=False)
    gender = Column(ENUM(GenderEnum, name="gender_enum", create_type=False), nullable=False)
    blood_group = Column(String(5), nullable=True)
    allergies = Column(JSON, nullable=True)
    chronic_conditions = Column(JSON, nullable=True)
    emergency_contact_name = Column(String(100), nullable=True)
    emergency_contact_phone = Column(String(15), nullable=True)
    created_at = Column(DateTime, server_default=func.now())
