from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
# Import your centralized settings framework
from .config import settings 

# Make sure BOTH models are imported so SQLAlchemy maps their relationships
# from backend.models.hospital import Hospital  # Adjust path to your actual file
# from backend.models.user import User

# 1. Create the engine using your pydantic-settings configuration
# 'echo=True' will print every raw SQL query to your terminal (great for learning!)
engine = create_engine(settings.DATABASE_URL, echo=True)



# 2. Create your session factory factory binded to the engine
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# 3. Create the Base class that your 16 models inherit from
Base = declarative_base()



# 4. THE FIX: The missing dependency generator that routers/auth.py is looking for
def get_db():
    """
    Yields a database session instance for a single incoming request
    and ensures it safely closes afterwards to prevent memory leaks.
    """
    db = SessionLocal()
    try:
        yield db  # Hand the database session over to the calling router
    finally:
        db.close()  # Automatically runs after the API response is sent