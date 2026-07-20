# from models import kpi_snapshot  # Table 13
# from models import admission_analytics  # Table 14
# from models import notification  # Table 15
# from models import audit_log  # Table 16


# from fastapi import FastAPI
# app=FastAPI(
#     title="MedConnect API",
#     description="API for managing hospital operations, including patient records, appointments, billing, and analytics",
#     version="1.0.0",
# )
# @app.get("/")
# def root():
#     return {"message": "Welcome to the Hospital Management System API!"}    



# # In backend/main.py — ADD these 2 lines
# # (add import near top, include_router inside the file)

# from routers import auth
# # This imports your new auth router file

# # THEN add this line AFTER you create the `app` variable:
# app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
# # prefix="/api/auth" = all auth routes start with /api/auth
# # So POST /register becomes POST /api/auth/register
# # tags=["Authentication"] = groups endpoints in Swagger UI



# # AFTER MIDDLEWARE/tenant.py and routers/patient.py


# from routers import patients
# app.include_router(patients.router,prefix="/api/patients", tags=["Patients"])


# from routers import appointments 
# app.include_router(appointments.router,prefix="/api/appointments", tags="[Appointments]")
  

#   #to connect all files to main.py

# app.include_router(user_router)
# app.include_router(auth_router)
# app.include_router(kpi_router)


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI
from backend.models import kpi_snapshot  # Table 13
from backend.models import admission_analytics  # Table 14
from backend.models import notification  # Table 15
from backend.models import audit_log  # Table 16
from backend.models import hospital
# Import routers from the routers package
from backend.routers import auth
from backend.routers import patients
from backend.routers import appointments
# If you have a KPI/analytics router, import it here:
# from routers import analytics 

app = FastAPI(
    title="MedConnect API",
    description="API for managing hospital operations, including patient records, appointments, billing, and analytics",
    version="1.0.0",
)

@app.get("/")
def root():
    return {"message": "Welcome to the Hospital Management System API!"}    

# Include routers with clean prefixes and tags
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(patients.router, prefix="/api/patients", tags=["Patients"])
app.include_router(appointments.router, prefix="/api/appointments", tags=["Appointments"])

# If you have an analytics/KPI router endpoint, uncomment below:
# from backend.models import analytics 
# from backend.models import admission_analytics
# app.include_router(admission_analytics.router, prefix="/api/analytics", tags=["Analytics"])


from backend.routers import analytics

app.include_router(analytics.router, prefix="/api/analytics", tags=["Analytics"])