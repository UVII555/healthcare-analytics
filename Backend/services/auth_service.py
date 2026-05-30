# File: backend/services/auth_service.py
# Purpose: JWT token creation + bcrypt password hashing
# WHY THIS FILE EXISTS: routers should be thin (just routing).
# All business logic (auth) lives in services.
# This makes logic reusable — ETL, scheduler, CLI can all call these functions.

from datetime import datetime, timedelta
# datetime = Python's built-in date/time library
# timedelta = represents a duration (e.g. 60 minutes)

from jose import JWTError, jwt
# jose = python-jose library. Handles JSON Web Tokens (JWT)
# jwt.encode() = creates a signed token string
# jwt.decode() = reads and verifies a token string

from passlib.context import CryptContext
# passlib = password hashing library
# CryptContext = manages which hashing algorithm to use

from fastapi import Depends, HTTPException, status
# Depends = FastAPI's dependency injection system
# HTTPException = raises an HTTP error response
# status = HTTP status code constants (401, 403, etc.)

from fastapi.security import OAuth2PasswordBearer
# OAuth2PasswordBearer = FastAPI reads JWT from "Authorization: Bearer <token>" header

from config import settings
# Our config.py — gets SECRET_KEY and ALGORITHM


# ── PASSWORD HASHING SETUP ──────────────────────────────────
# bcrypt = industry standard. Slow by design — makes brute force attacks hard.
# deprecated="auto" = if bcrypt is updated, old hashes still work
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ── JWT SETUP ───────────────────────────────────────────────
# tokenUrl = the URL path where users get tokens (used by Swagger UI)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


def hash_password(plain_password: str) -> str:
    """
    Takes a plain text password, returns a bcrypt hash.
    Example: "mypassword" → "$2b$12$8K1p/a0dL1jMsT..."
    NEVER store plain passwords. Always store the hash.
    """
    return pwd_context.hash(plain_password)
    # pwd_context.hash() runs bcrypt algorithm on the password
    # Result is different every time (bcrypt adds random salt)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Checks if a plain password matches a stored bcrypt hash.
    Returns True if they match, False otherwise.
    Used during login to verify what the user typed.
    """
    return pwd_context.verify(plain_password, hashed_password)
    # verify() re-applies bcrypt to plain_password and compares
    # It knows how to handle the salt automatically


def create_access_token(data: dict) -> str:
    """
    Creates a signed JWT token containing the provided data.
    data should contain: user_id, role, hospital_id
    The token encodes this info + expiry time, then signs it with SECRET_KEY.
    Anyone with the token can read user_id/role — but cannot forge a fake token
    without knowing SECRET_KEY.
    """
    to_encode = data.copy()
    # .copy() because we'll add "exp" and don't want to modify the original dict

    expire = datetime.utcnow() + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    # datetime.utcnow() = current time in UTC (never local time in servers)
    # timedelta(minutes=60) = add 60 minutes to current time = expiry time

    to_encode.update({"exp": expire})
    # "exp" (expiry) is a standard JWT claim
    # After this time, jwt.decode() will raise an error automatically

    encoded_jwt = jwt.encode(
        to_encode,           # the payload data to encode
        settings.SECRET_KEY, # the secret that signs the token
        algorithm=settings.ALGORITHM  # "HS256" = HMAC with SHA-256
    )
    return encoded_jwt


def decode_token(token: str) -> dict:
    """
    Decodes and validates a JWT token.
    Returns the payload dict (contains user_id, role, hospital_id).
    Raises HTTP 401 if token is invalid, expired, or tampered with.
    """
    try:
        payload = jwt.decode(
            token,                        # the token string to decode
            settings.SECRET_KEY,          # same secret used to sign it
            algorithms=[settings.ALGORITHM]  # must match encoding algorithm
        )
        return payload
        # payload is the dict we passed to create_access_token()
        # e.g.: {"user_id": 5, "role": "DOCTOR", "hospital_id": 2, "exp": ...}

    except JWTError:
        # JWTError covers: expired token, wrong signature, malformed token
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token. Please login again.",
            headers={"WWW-Authenticate": "Bearer"},
            # WWW-Authenticate header tells browser what auth type is needed
        )


def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    FastAPI DEPENDENCY — use this in any endpoint that requires login.
    How to use in a router:
        @router.get("/something")
        def my_endpoint(current_user = Depends(get_current_user)):
            hospital_id = current_user["hospital_id"]

    FastAPI automatically:
    1. Reads the Authorization: Bearer <token> header
    2. Passes the token string to this function
    3. This function decodes it and returns the user dict
    4. The user dict is injected into your endpoint function
    """
    payload = decode_token(token)
    # decode_token raises 401 if invalid — we don't need to check manually

    user_id = payload.get("user_id")
    if user_id is None:
        # This handles a token that is valid but missing user_id
        # (shouldn't happen with our tokens, but defensive programming)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token is missing user_id"
        )

    # Return a clean dict with the 3 things every endpoint needs:
    return {
        "user_id":     user_id,
        "role":        payload.get("role"),        # "DOCTOR", "PATIENT", etc.
        "hospital_id": payload.get("hospital_id")  # for multi-tenancy scoping
    }