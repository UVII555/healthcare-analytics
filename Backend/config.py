
# Purpose: reads .env file, makes all settings available everywhere
# How to use in other files: from config import settings

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    #these names should be same as in  .env file
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str ='HS256'
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    class Config:
        env_file = ".env"
        #tells pydantic to where to look for the .env file



#create an instance of the Setting class globaly top access the settings in other files ... imported everywhere
settings = Settings()

if __name__=="__main__":
    print(f"DB: {settings.DATABASE_URL[:440]}...")
    print(f"Key: {settings.SECRET_KEY[:15]}...")
    print("config.py works ✅")



