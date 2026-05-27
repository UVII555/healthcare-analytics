import enum

from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, ForeignKey
from sqlalchemy.sql import func

from database import Base


class NotificationChannel(str, enum.Enum):
    IN_APP = "IN_APP"
    SMS = "SMS"
    EMAIL = "EMAIL"


class NotificationStatus(str, enum.Enum):
    PENDING = "PENDING"
    SENT = "SENT"
    FAILED = "FAILED"
    READ = "READ"


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    notification_type = Column(String(50), nullable=False)  # "APPOINTMENT_REMINDER"
    channel = Column(Enum(NotificationChannel), nullable=False)
    message = Column(Text, nullable=False)
    status = Column(Enum(NotificationStatus), default=NotificationStatus.PENDING)

    # When to send it — scheduler checks this
    scheduled_at = Column(DateTime(timezone=True), nullable=True)
    # Set automatically when actually sent
    sent_at = Column(DateTime(timezone=True), nullable=True)
    read_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
