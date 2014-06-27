FROM ubuntu:12.04

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN export LANGUAGE="en_US.UTF-8"
RUN export LC_ALL="en_US.UTF-8"

RUN mkdir galaxy-python
RUN mkdir galaxy-python/galaxy
RUN mkdir galaxy-python/galaxyTools
RUN mkdir galaxy-python/galaxyIndices

RUN mkdir /nfs

# install stuff

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y language-pack-en gfortran gcc g++ make bison autoconf flex aptitude curl libcurl4-openssl-dev uuid-dev byacc python-numpy python-scipy python-netcdf python-setuptools postgresql python-setuptools python-dev libffi-dev build-essential mercurial openssh-server samba smbfs r-base octave gnuplot python-pip python-matplotlib git subversion libxml2-utils libx11-dev libxmu-dev libjasper-dev libxslt-dev libxml2-dev grads nco cdo

# TODO: use pip?
RUN easy_install -U globus-provision jsonschema lxml simplekml pykml PIL

# Install the Globus Online python nexus client
# TODO: install with package manager instead of git?
RUN git clone -b JIRA-GRAPH-1069 https://github.com/globusonline/python-nexus-client.git && cd python-nexus-client && python setup.py install && cd .. && rm -rf python-nexus-client

# clone galaxy
RUN hg clone https://bitbucket.org/faceit/galaxy galaxy-python/galaxy

# patch galaxy config to a) use sqlite and b) add pete.vilter@gmail.com as an admin user
COPY patch_config.patch /patch_config.patch
RUN patch galaxy-python/galaxy/universe_wsgi.ini /patch_config.patch && rm /patch_config.patch

EXPOSE 8080

CMD ["galaxy-python/galaxy/run.sh"]
