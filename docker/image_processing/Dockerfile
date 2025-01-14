FROM python:3.10

# Setup default directory
RUN mkdir /var/source
WORKDIR /var/source

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir --upgrade -r /requirements.txt

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
