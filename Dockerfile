FROM ubuntu

RUN apt-get update
RUN apt-get install --yes python python-pip

RUN pip install flask flask-mysql

COPY ./src /opt/src

ENTRYPOINT FLASK_APP=/opt/src/app.py flask run
