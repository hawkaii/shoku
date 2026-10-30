FROM python:3.12-slim

# ffmpeg is here for the extractor, which strips audio from the media it fetches.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pyproject.toml README.md ./
COPY shoku_api ./shoku_api
RUN pip install --no-cache-dir ".[prod]"

ENV PYTHONUNBUFFERED=1
EXPOSE 8000
CMD ["uvicorn", "shoku_api.asgi:app", "--host", "0.0.0.0", "--port", "8000"]
