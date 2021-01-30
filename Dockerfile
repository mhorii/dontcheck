FROM ubuntu:20.04

RUN apt-get update

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

RUN apt-get install -y nodejs npm nkf jq curl

RUN npm install -g crontab-ui
RUN mkdir /dontcheck
WORKDIR /dontcheck

ENV PATH=$PATH:/dontcheck

CMD crontab-ui



