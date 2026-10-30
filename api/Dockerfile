# Two stages: the build stage has a compiler and a pip cache; the runtime stage
# has neither. Every dependency ships a wheel, so the compiler is only a safety
# net for a platform without one.
FROM python:3.12-slim AS build

ENV PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md ./
COPY shoku_api ./shoku_api

# "prod" for the API box, "worker,whisper" for the worker VM.
ARG EXTRAS=prod
RUN python -m venv /opt/venv \
 && /opt/venv/bin/pip install ".[${EXTRAS}]"


FROM python:3.12-slim

# curl is for the compose healthcheck (1 MB). ffmpeg is NOT installed here: the
# apt package drags in ~430 MB of libraries and only the worker needs it, where
# the ~30 MB static binary from imageio-ffmpeg is enough.
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY shoku_api ./shoku_api

# A JS runtime for yt-dlp's YouTube extractor. Only the worker image gets it,
# so the API stays ~400 MB instead of paying for a dependency it never uses.
ARG EXTRAS=prod
RUN if echo "$EXTRAS" | grep -q worker; then \
      apt-get update \
      && apt-get install -y --no-install-recommends nodejs \
      && rm -rf /var/lib/apt/lists/*; \
    fi

# On the worker image, put the static ffmpeg on PATH so yt-dlp finds it.
RUN if /opt/venv/bin/python -c "import imageio_ffmpeg" 2>/dev/null; then \
      /opt/venv/bin/python -c "import imageio_ffmpeg, shutil; shutil.copy(imageio_ffmpeg.get_ffmpeg_exe(), '/usr/local/bin/ffmpeg')" \
      && chmod +x /usr/local/bin/ffmpeg; \
    fi

EXPOSE 8000
CMD ["uvicorn", "shoku_api.asgi:app", "--host", "0.0.0.0", "--port", "8000"]
