FROM rocker/r-base:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    python3 python3-dev python3-pip python3-venv \
    build-essential libffi-dev libssl-dev \
    libxml2-dev libcurl4-openssl-dev \
    libbz2-dev libzstd-dev liblzma-dev \
    libfreetype6-dev libpng-dev libjpeg-dev \
    libopenblas-dev gfortran \
    git \
    curl \
    && apt-get clean

# Ambiente virtual Python
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Instalar pacotes Python
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Instalar pacotes R
RUN Rscript -e "install.packages(c('forecast','openxlsx','season','MASS','ggplot2','stats','gdata','survival','lubridate','robustbase','matrixStats','xlsx'), repos='http://cran.r-project.org')"

# Definir diretório de trabalho
WORKDIR /app
COPY . .

# Preparar ficheiros estáticos para produção
RUN python manage.py collectstatic --noinput

# Expor porta esperada pelo professor
EXPOSE 3000

# Comando de arranque (produção)
CMD ["gunicorn", "--bind", "0.0.0.0:3000", "--timeout=86400","Project_django.wsgi:application"]
