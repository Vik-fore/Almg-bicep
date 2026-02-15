from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def root():
    return {"status": "ok", "service": "alm-chatbot-prod-app-test"}
