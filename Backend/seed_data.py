"""
Seed script for baseline development data.

Usage:
    python seed_data.py
"""

from sqlalchemy.orm import Session

from backend.database import SessionLocal


def seed(session: Session) -> None:
    # Intentionally minimal scaffold so we don't alter existing datasets.
    # Add inserts here when you are ready to seed specific tables.
    session.commit()


def main() -> None:
    db = SessionLocal()
    try:
        seed(db)
        print("Seed completed.")
    finally:
        db.close()


if __name__ == "__main__":
    main()
