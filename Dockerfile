FROM python:2

MAINTAINER Alex Titov

VOLUME /logs
VOLUME /data

# Things required for a python/pip environment
COPY system-requirements.txt /usr/src/app/system-requirements.txt
RUN  \
    awk '$1 ~ "^deb" { $3 = $3 "-backports"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    xargs apt-get -y -q install < /usr/src/app/system-requirements.txt && \
    apt-get clean

ENV HOME /usr/src/app
ENV SHELL bash
ENV WORKON_HOME /usr/src/app
WORKDIR /usr/src/app

COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install --trusted-host None --no-cache-dir --use-wheel -r /usr/src/app/requirements.txt

COPY conf/thumbor.conf.tpl /usr/src/app/thumbor.conf.tpl
COPY conf/nginx.conf.tpl /etc/nginx/nginx.conf.tpl
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

COPY conf/docker-entrypoint.sh /docker-entrypoint.sh
COPY conf/thumbor-entrypoint.sh /usr/src/app/thumbor-entrypoint.sh
COPY conf/kill.py /usr/src/app/kill.py
COPY conf/.profile.d /app/.profile.d

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN \ 
    ln /usr/lib/python2.7/dist-packages/cv2.x86_64-linux-gnu.so /usr/local/lib/python2.7/cv2.so && \
    ln /usr/lib/python2.7/dist-packages/cv.py /usr/local/lib/python2.7/cv.py

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["thumbor"]

EXPOSE 80
