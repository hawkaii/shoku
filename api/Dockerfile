FROM python:3.12-slim

# ffmpeg is here for the extractor, which strips audio from the media it
# fetches. Nothing is installed for transcription: that is an API call.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml README.md ./
COPY shoku_api ./shoku_api
COPY alembic.ini ./
COPY alembic ./alembic

RUN pip install --no-cache-dir ".[prod,worker]"

ENV PYTHONUNBUFFERED=1
EXPOSE 8000

# `migrate` is the deploy step; api and worker both use this image.
CMD ["uvicorn", "shoku_api.asgi:app", "--host", "0.0.0.0", "--port", "8000"]
