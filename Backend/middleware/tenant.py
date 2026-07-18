
from fastapi import Depends, HTTPException
from backend.services.auth_service import get_current_user

def get_hospital_id(current_user = Depends(get_current_user)) -> int:
    hospital_id = current_user.get("hospital_id")
    if hospital_id is None:
        raise HTTPException(status_code=403, detail="No hospital associated with this account")
    return hospital_id
# Usage in any router: hospital_id = Depends(get_hospital_id)
# Then: db.query(X).filter(X.hospital_id == hospital_id)