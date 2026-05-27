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
