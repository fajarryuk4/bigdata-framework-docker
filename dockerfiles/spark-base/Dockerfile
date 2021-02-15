FROM jupyter/all-spark-notebook:latest

COPY require .

USER root

ENV GRANT_SUDO=yes

RUN pip install --no-cache-dir -r requirement.txt
