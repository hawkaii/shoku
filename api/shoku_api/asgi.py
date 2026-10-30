"""Uvicorn target: `uvicorn shoku_api.asgi:app`.

Kept separate from `main.py` so importing the factory never opens a database.
"""

from .main import create_app

app = create_app()
