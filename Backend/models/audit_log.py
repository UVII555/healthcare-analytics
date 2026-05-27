from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Index
from sqlalchemy.sql import func

from database import Base


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # What action was performed
    action = Column(String(100), nullable=False)  # "VIEWED_PATIENT_HISTORY"
    # What kind of record was accessed
    entity_type = Column(String(50))  # "patient", "prescription", "lab_result"
    entity_id = Column(Integer)  # the ID of that record

    # Security info — IPv6 needs 45 chars
    ip_address = Column(String(45), nullable=True)

    # Indexed for fast time-range audit queries
    timestamp = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    __table_args__ = (
        Index("idx_audit_user_time", "user_id", "timestamp"),
    )
