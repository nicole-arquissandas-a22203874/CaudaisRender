FROM rocker/r-base:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-dev python3-pip python3-venv \
    build-essential libffi-dev libssl-dev \
    libxml2-dev libcurl4-openssl-dev \
    libbz2-dev libzstd-dev liblzma-dev \
    libfreetype6-dev libpng-dev libjpeg-dev \
    libopenblas-dev gfortran \
    git curl nginx \
    && apt-get clean

# Create virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python packages
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Install R packages
RUN Rscript -e "install.packages(c('forecast','openxlsx','season','MASS','ggplot2','stats','gdata','survival','lubridate','robustbase','matrixStats','xlsx'), repos='http://cran.r-project.org')"

# Copy the rest of the project
WORKDIR /app
COPY . .

# Prepare static files
RUN python manage.py collectstatic --noinput

# Copy NGINX config and start script
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose NGINX port
EXPOSE 80

# Run app
CMD ["/start.sh"]
