# Pull official base image for Python 3.10
FROM python:3.10.10-slim

# Set work directory
WORKDIR /usr/src/app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set DJANGO_SETTINGS_MODULE environment variable
ENV DJANGO_SETTINGS_MODULE=hello_django.settings  

# Install PostgreSQL dependencies
RUN apt-get update \
  && apt-get -y install gcc postgresql \
  && apt-get clean

# Install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Create a user with UID 1000 and GID 1000
RUN groupadd -g 1000 appgroup && \
    useradd -r -u 1000 -g appgroup appuser

# Switch to this user
USER 1000:1000

# Copy project files
COPY . .

# ✅ Run Django when the container starts
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
