import enum

from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, JSON, Numeric, String
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.sql import func

from database import Base


class SubscriptionStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    EXPIRED = "EXPIRED"
    CANCELLED = "CANCELLED"
    TRIAL = "TRIAL"


class SubscriptionPlan(Base):
    __tablename__ = "subscription_plans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False)
    price_monthly = Column(Numeric(10, 2), nullable=False)
    max_patients = Column(Integer, default=-1)
    max_doctors = Column(Integer, default=-1)
    feature_flags = Column(JSON, nullable=False)


class HospitalSubscription(Base):
    __tablename__ = "hospital_subscriptions"

    id = Column(Integer, primary_key=True, index=True)
    hospital_id = Column(Integer, ForeignKey("hospitals.hospital_id"), nullable=False)
    plan_id = Column(Integer, ForeignKey("subscription_plans.id"), nullable=False)
    status = Column(
        ENUM(SubscriptionStatus, name="subscription_status", create_type=False),
        default=SubscriptionStatus.TRIAL,
        nullable=False,
    )
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    trial_ends_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
