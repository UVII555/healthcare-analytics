# File: backend/schemas/auth.py
# Purpose: defines request/response shapes for auth endpoints
# WHY: FastAPI validates ALL incoming JSON against these schemas.
# Wrong data type = automatic 422 error with clear message.

from pydantic import BaseModel, EmailStr, Field
from backend.models.user import UserRole
# BaseModel = base class for all Pydantic schemas
# EmailStr = validates that the string is a valid email format

from typing import Optional


class RegisterRequest(BaseModel):
    """Shape of the JSON body for POST /register"""
    email:       EmailStr        # validates email format automatically
    password:    str = Field(min_length=8)
    full_name:   str
    role:        UserRole = UserRole.PATIENT
    hospital_id: Optional[int] = None


class LoginRequest(BaseModel):
    """Shape of the JSON body for POST /login"""
    email:    EmailStr
    password: str


class TokenResponse(BaseModel):
    """Shape of the JSON response from login/register"""
    access_token: str   # the JWT token string
    token_type:   str = "bearer"  # always "bearer" for JWT


class UserResponse(BaseModel):
    """Shape of the response from GET /me"""
    user_id:     int
    role:        str
    hospital_id: Optional[int]


# backend/schemas/auth.py mein
from enum import Enum

class UserRole(str, Enum):
    PATIENT = "PATIENT"
    DOCTOR = "DOCTOR"
    HOSPITAL_ADMIN = "HOSPITAL_ADMIN"
    SUPER_ADMIN = "SUPER_ADMIN"

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    role: UserRole   # ab galat role bhejne pe 422 aayega, silent PATIENT nahi banega
    hospital_id: int