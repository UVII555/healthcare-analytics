import enum

from sqlalchemy import BigInteger, Column, Date, DateTime, ForeignKey, Integer, String, Text, Time
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.sql import func

from database import Base


class AppointmentStatus(str, enum.Enum):
    SCHEDULED = "SCHEDULED"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
    NO_SHOW = "NO_SHOW"


class AppointmentType(str, enum.Enum):
    OPD = "OPD"
    FOLLOW_UP = "FOLLOW_UP"
    EMERGENCY = "EMERGENCY"


class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(Integer, primary_key=True, index=True)
    hospital_id = Column(BigInteger, ForeignKey("hospitals.hospital_id"), nullable=False)
    patient_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=False)
    time_slot = Column(Time, nullable=False)
    token_number = Column(Integer, nullable=True)
    booked_at = Column(DateTime, server_default=func.now())
    check_in_time = Column(DateTime, nullable=True)
    doctor_start_time = Column(DateTime, nullable=True)
    consultation_end_time = Column(DateTime, nullable=True)
    status = Column(ENUM(AppointmentStatus, name="appointment_status", create_type=False), default=AppointmentStatus.SCHEDULED)
    appointment_type = Column(
        ENUM(AppointmentType, name="appointment_type_enum", create_type=False),
        default=AppointmentType.OPD,
    )
    chief_complaint = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    appointment_date = Column(Date, nullable=False)
