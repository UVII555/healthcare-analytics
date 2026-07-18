# File: backend/routers/auth.py
# Purpose: HTTP endpoints for authentication
# WHY THIN: the router's only job = receive request, call service, return response.
# All logic (hashing, JWT creation) is in auth_service.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models.user import User
# ↑ change "user" to whatever your User model file is named
from backend.schemas.auth import RegisterRequest, LoginRequest, TokenResponse
from backend.services.auth_service import (
    hash_password,
    verify_password,
    create_access_token,
    get_current_user
)

router = APIRouter()
# APIRouter = a mini-app. We register all auth routes here.
# Then in main.py we include this router with a prefix.


@router.post("/register", response_model=TokenResponse)
def register(
    request: RegisterRequest,        # FastAPI validates JSON → RegisterRequest
    db:      Session = Depends(get_db)  # FastAPI injects a DB session
):
    """
    Creates a new user account and returns a JWT token.
    The user is immediately logged in after registration.
    """
    # Step 1: Check if email already exists
    existing = db.query(User).filter(User.email == request.email).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail="This email is already registered. Please login instead."
        )

    # Step 2: Create user with hashed password (NEVER store plain password)
    user = User(
        email=request.email,
        hashed_password=hash_password(request.password),
        full_name=request.full_name,
        role=request.role,
        hospital_id=request.hospital_id,
        is_active=True
    )
    db.add(user)       # stage for insertion
    db.commit()        # write to PostgreSQL
    db.refresh(user)   # reload from DB to get the auto-generated id

    # Step 3: Create JWT token with user info in payload
    token = create_access_token({
        "user_id":     user.id,
        "role":        user.role,
        "hospital_id": user.hospital_id
    })

    return {"access_token": token, "token_type": "bearer"}
    # FastAPI validates this against TokenResponse schema before sending


@router.post("/login", response_model=TokenResponse)
def login(
    request: LoginRequest,
    db:      Session = Depends(get_db)
):
    """
    Verifies email + password. Returns JWT token if correct.
    Returns 401 if email not found OR password wrong.
    (Same error message for both — never reveal which one failed. Security.)
    """
    # Step 1: Find user by email
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
            # Don't say "email not found" — that reveals which emails are registered
        )

    # Step 2: Verify the password against stored hash
    if not verify_password(request.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    # Step 3: Check account is active
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is deactivated")

    # Step 4: Create and return JWT
    token = create_access_token({
        "user_id":     user.id,
        "role":        user.role,
        "hospital_id": user.hospital_id
    })
    return {"access_token": token, "token_type": "bearer"}


@router.get("/me")
def get_me(current_user = Depends(get_current_user)):
    """
    Returns the currently logged-in user's info.
    Depends(get_current_user) automatically:
    1. Reads Authorization header
    2. Decodes JWT
    3. Returns {user_id, role, hospital_id} dict
    """
    return current_user