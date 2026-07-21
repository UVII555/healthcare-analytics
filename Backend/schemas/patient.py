from datetime import date
from typing import Optional

from pydantic import BaseModel, EmailStr, Field

from backend.models.patient import GenderEnum


class CreatePatientRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str
    date_of_birth: date
    gender: GenderEnum
    blood_group: Optional[str] = None
    allergies: Optional[list[str]] = None
    chronic_conditions: Optional[list[str]] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None


class PatientCreateResponse(BaseModel):
    user_id: int
    uhid: str
    message: str
