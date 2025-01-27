# Dockerfile for ETL Development
FROM python:3.10.16-bookworm

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Set workdir
WORKDIR /app

# Copy ETL scripts
COPY constants.py functions.py main.py ./

# Default command
CMD ["python", "./main.py"]