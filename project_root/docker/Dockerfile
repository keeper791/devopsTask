FROM ubuntu:18.04
RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y build-essential &&\
    apt-get install -y cpanminus &&\
    apt-get install -y curl 
    
RUN cpanm CPAN::Meta\
    MongoDB \
    JSON::XS
#    apt-get -y install linuxbrew-wrapper &&\
#    cpan install JSON &&\
#    cpan install mongodb 
WORKDIR /opt
COPY ../bin/getValue.pl /opt/getValue.pl

ENTRYPOINT ["perl","getValue.pl"]
