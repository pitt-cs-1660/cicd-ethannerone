FROM python:3.11-buster AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock ./

RUN pip install poetry

RUN python -m venv /venv \
    && . /venv/bin/activate \
    && poetry config virtualenvs.create false \
    && poetry install --no-root

FROM python:3.11-buster
WORKDIR /app

COPY --from=builder /venv /venv

ENV PATH="/venv/bin:$PATH"

EXPOSE 8000

ENTRYPOINT ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
