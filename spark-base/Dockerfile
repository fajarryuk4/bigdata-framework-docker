FROM jupyter/all-spark-notebook

COPY require .

USER root

ENV GRANT_SUDO=yes

RUN pip install --no-cache-dir -r requirement.txt
