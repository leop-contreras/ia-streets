import logging
from fastapi import APIRouter, HTTPException, Response, Request
import time
import requests
import json
from fastapi.responses import JSONResponse

from back.vanAlgorithm import get_sequential_route, get_optimized_route

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - Router - %(funcName)s : %(message)s'
)

router = APIRouter()

@router.get("/")
async def root():
    return {"message": "Hi there! What are you doing here?"}

@router.get("/health")
async def get_health(response: Response):
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

@router.post("/get_sequential_path")
async def get_sequential_path(request: Request):
    """
    Route that receives payload and returns shortest route in all the destinations
    """
    payload = await request.json()
    print(payload)

    logging.info(f"Payload received: {payload}")

    path = get_sequential_route(payload)

    return path

@router.post("/get_optimized_path")
async def get_optimized_path(request: Request):
    """
    Route that receives payload and returns shortest route
    """
    payload = await request.json()
    print(payload)

    logging.info(f"Payload received: {payload}")

    path = get_optimized_route(payload)

    return path