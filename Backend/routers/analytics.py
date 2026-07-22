from fastapi import APIRouter , Depends
from sqlalchemy.orm import Session
from backend.database import get_db
from analytics.engine.kpi_engine import (compute_alos,
compute_rar,
compute_awt,
compute_drg_mix,
compute_opd_load
)
# router = APIRouter(prefix="/api/analytics", tags=["Analytics"])
router = APIRouter(prefix="/api/analytics", tags=["Analytics"])

@router.get("/kpis")
def get_kpis(hospital_id:  int= 1, db: Session = Depends(get_db)):
    return{
        "alos_days": compute_alos(db,hospital_id),
        "awt_minutes":compute_awt(db,hospital_id),
        "rar_percent":compute_rar(db,hospital_id)
    }

@router.get("/opd-trend")
def get_opd_trend(hospital_id:int=1,db:Session=Depends(get_db)):
    return compute_opd_load(db,hospital_id)


@router.get("/diagnosis-mix")
def get_diagnosis_mix(hospital_id:int=1,db:Session=Depends(get_db)):
    return compute_drg_mix(db,hospital_id)