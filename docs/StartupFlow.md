What happens step by step----
flow/startup flow chart....

1.  .env stores real values like DATABASE_URL and SECRET_KEY.
2.  config.py reads those values using Settings.
3.  settings = Settings() creates the actual loaded config object.
4.  database.py uses settings.DATABASE_URL to connect to PostgreSQL.
5.  models/*.py defines tables using Base.
6.  main.py creates the FastAPI app.
7.      main.py includes routers.
8.  uvicorn starts the app and serves it on localhost:8000.



Example ----
If you call GET /patients:
---------------------------

1.  Browser sends request
2.  Router receives it
3.  FastAPI gives it a DB session using Depends(get_db)
4.  Router calls a service function
5.  Service uses SQLAlchemy to query PostgreSQL
6.  Data comes back
7.  Router returns JSON to the browser
----------------------------------------------------------------
 What executes first----
 For our backend project, the usual order is:

1.  config.py loads settings
2.  database.py creates DB connection tools
3.  models/*.py defines tables
4.  main.py creates the app and includes routers
5.  Router file handles the request
6.  Service file does the business logic
7.  SQLAlchemy talks to PostgreSQL
8.  Response goes back to Swagger/browser


--------------
Mental model----
-------------------
.   config.py = reads environment values
.   database.py = creates DB connection setup
.   models/ = defines tables
.   schemas/ = defines request/response shapes
.   services/ = business logic
.   routers/ = API endpoints
.   main.py = app entry point