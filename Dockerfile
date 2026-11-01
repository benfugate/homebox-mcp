# Test image only; the server itself is installed with uvx (see README).
#   docker build --target test -t homebox-mcp:test . && docker run --rm homebox-mcp:test
FROM ghcr.io/astral-sh/uv:0.13.6-python3.13-trixie-slim AS test
WORKDIR /src
ENV UV_NO_CACHE=1 UV_PROJECT_ENVIRONMENT=/venv PATH="/venv/bin:$PATH"
COPY pyproject.toml README.md ./
COPY src ./src
RUN uv venv /venv && uv pip install --python /venv/bin/python .
COPY tests ./tests
CMD ["python", "tests/test_offline.py"]
