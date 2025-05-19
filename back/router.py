import logging
from fastapi import APIRouter, HTTPException, Response, Request
import time
import requests

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - Router - %(funcName)s : %(message)s'
)

router = APIRouter()

@router.get("/")
async def root_route():
    return {"message": "Hi there! What are you doing here?"}

@router.get("/health")
async def get_health_route(response: Response):
    """
    Check the health of the API
    """
    server_time = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())

    try:
        public_ip = requests.get("https://api.ipify.org?format=json", timeout=10).json()
    except requests.RequestException:
        public_ip = 'Unavailable'

    logging.info(f"Health check. At {server_time} with IP {public_ip}")

    return {
        "status": "ok",
        "server_time": server_time,
        **public_ip,
    }

@router.get("/get_upocket_calendar_id")
async def get_upocket_calendar_id_route(
):
    """
    Obtain the calendar_id assigned for the UPocket calendar
    """
    logging.info(f"Calendar ID requested")

    try:
        calendar_id = gcalService.get_upocket_calendar_id()
        if calendar_id:
            return {"status": "success", "calendar_id": calendar_id}
        return {"status": "fail", "message": "UPocket calendar does not exist"}
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")

@router.post("/get_path")
async def create_shedule_route(request: Request):
    """
    Route that receives payload and returns shortest route
    """
    logging.info(f"Payload received")
    payload = await request.json()

    return payload