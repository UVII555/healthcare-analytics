from sqlalchemy import Column, Integer, String, Numeric, DateTime, Date, ForeignKey, Index
from sqlalchemy.sql import func

from database import Base


class KPISnapshot(Base):
    __tablename__ = "kpi_snapshots"

    id = Column(Integer, primary_key=True, index=True)
    # Which hospital this KPI belongs to
    hospital_id = Column(Integer, ForeignKey("hospitals.id"), nullable=False)
    # The date this snapshot covers — dashboard queries date ranges
    snapshot_date = Column(Date, nullable=False)
    # NULL = hospital-wide KPI, not null = department-specific KPI
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=True)
    # KPI name — "ALOS", "RAR", "BOR", "AWT", "CPV", "OPD_LOAD", "REVENUE"
    kpi_name = Column(String(50), nullable=False)
    # The computed value — 4 decimal places for precision
    kpi_value = Column(Numeric(12, 4), nullable=False)
    # When this was computed — dashboard shows "Last updated: 2:00 AM"
    computed_at = Column(DateTime(timezone=True), server_default=func.now())

    # Composite index: hospital + date + kpi_name = fast dashboard queries
    __table_args__ = (
        Index("idx_kpi_hospital_date", "hospital_id", "snapshot_date", "kpi_name"),
    )
