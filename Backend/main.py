from models import kpi_snapshot  # Table 13
from models import admission_analytics  # Table 14
from models import notification  # Table 15
from models import audit_log  # Table 16


from fastapi import FastAPI
app=FastAPI(
    title="MedConnect API",
    description="API for managing hospital operations, including patient records, appointments, billing, and analytics",
    version="1.0.0",
)
@app.get("/")
def root():
    return {"message": "Welcome to the Hospital Management System API!"}    



# In backend/main.py — ADD these 2 lines
# (add import near top, include_router inside the file)

from routers import auth
# This imports your new auth router file

# THEN add this line AFTER you create the `app` variable:
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
# prefix="/api/auth" = all auth routes start with /api/auth
# So POST /register becomes POST /api/auth/register
# tags=["Authentication"] = groups endpoints in Swagger UI



# AFTER MIDDLEWARE/tenant.py and routers/patient.py


from routers import patients
app.include_router(patient.router,prefix="/api/patients", tags=["Patients"])


from routers import appointments 
app.include_router(appointment.router,prefix="/api/appointments", tags"[Appointments]")


