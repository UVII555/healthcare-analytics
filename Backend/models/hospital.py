import enum

from sqlalchemy import BigInteger, Boolean, Column, DateTime, Integer, String, Text
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.sql import func

from database import Base


class HospitalType(str, enum.Enum):
    GOVERNMENT = "GOVERNMENT"
    PRIVATE = "PRIVATE"
    CLINIC = "CLINIC"
    DIAGNOSTIC = "DIAGNOSTIC"


class Hospital(Base):
    __tablename__ = "hospitals"

    id = Column("hospital_id", BigInteger, primary_key=True, index=True)
    name = Column("hospital_name", String(200), nullable=False)
    hospital_code = Column(String(50), unique=True, nullable=False)
    hospital_type = Column(ENUM(HospitalType, name="hospital_type_enum", create_type=False), nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    address = Column(Text, nullable=True)
    phone = Column(String(20), nullable=True)
    email = Column(String(255), nullable=True)
    total_beds = Column(Integer, nullable=True)
    emergency_available = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
