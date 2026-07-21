from datetime import date, time
from typing import Optional

from pydantic import BaseModel, Field

from backend.models.appointment import AppointmentType


class BookAppointmentRequest(BaseModel):
    doctor_id: int
    department_id: int
    appointment_date: date = Field(default_factory=date.today)
    time_slot: time
    appointment_type: AppointmentType = AppointmentType.OPD
    chief_complaint: Optional[str] = None


class BookAppointmentResponse(BaseModel):
    appointment_id: int
    token_number: int
