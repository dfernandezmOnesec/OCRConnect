FROM mcr.microsoft.com/azure-functions/python:3.0-python3.9-appservice

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

# Instala dependencias del sistema necesarias para OCR
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-script-latn \
    poppler-utils \
    libleptonica-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Copia requirements y realiza instalación en un solo paso
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# Copia el resto del código de la función
COPY . /home/site/wwwroot
