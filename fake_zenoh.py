import asyncio
import json
import random
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sse_starlette.sse import EventSourceResponse
import uvicorn

app = FastAPI()

# Add CORS middleware to allow connections if testing via Chrome
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def telemetry_generator():
    """Simulates the Jetson Nano generating telemetry every 1 second."""
    while True:
        # Generate simulated water quality data
        sensor_data = {
            "ph": round(random.uniform(6.5, 8.5), 2),
            "tds": round(random.uniform(100.0, 300.0), 2),
            "turbidity": round(random.uniform(1.0, 5.0), 2),
            "microplastics": random.randint(0, 50)
        }

        # Zenoh REST plugin wraps the payload inside a 'value' key
        zenoh_payload = {
            "key": "neerdrishtiy/telemetry",
            "value": sensor_data
        }

        # Yield the Server-Sent Event format expected by the Flutter app
        yield {
            "data": json.dumps(zenoh_payload)
        }

        await asyncio.sleep(1.0)

@app.get("/neerdrishtiy/telemetry")
async def get_telemetry():
    """SSE endpoint simulating the Zenoh REST Router."""
    return EventSourceResponse(telemetry_generator())

if __name__ == "__main__":
    print("Starting Fake Zenoh Server on http://127.0.0.1:8000")
    print("Serving SSE stream at http://127.0.0.1:8000/neerdrishtiy/telemetry")
    uvicorn.run(app, host="127.0.0.1", port=8000)
