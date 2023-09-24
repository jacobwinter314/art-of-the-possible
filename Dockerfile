FROM python:3.8-slim-bullseye

WORKDIR /app
COPY Pipfile* ./

RUN pip install --no-cache-dir pipenv==2023.3.20 && \
    pipenv install --deploy --clear && \
    apt-get update && \
    apt-get install -y --no-install-recommends procps && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 5000
HEALTHCHECK --interval=2m --timeout=3s \
    CMD curl -f http://localhost:5000/health || exit 1

COPY flask_server /app/flask_server
RUN id \
    && adduser --uid 1000 --system nonroot \
    && chown -R nonroot /app
USER nonroot

RUN pipenv lock \
    && pipenv sync

CMD ["pipenv", "run", "flask", "--app", "flask_server", "run", "--host", "0.0.0.0", "--port", "5000"]
