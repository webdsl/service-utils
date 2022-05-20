# Build webdsl
FROM frekele/ant:1.10.3-jdk8
RUN apt update && apt install -y wget unzip ant nailgun
RUN wget --no-check-certificate https://buildfarm.metaborg.org/job/webdsl-compiler/lastSuccessfulBuild/artifact/webdsl.zip
RUN unzip webdsl.zip
ENV PATH "$PATH:/root/webdsl/bin"
ENV JAVA_TOOL_OPTIONS "-Dfile.encoding=UTF8"

RUN echo '/usr/bin/ng-nailgun "$@"' > /usr/bin/ng && chmod +x /usr/bin/ng

# Sanity check
RUN webdsl version

# TODO development image?
# TODO ci testing image?

# Actually build project
ARG app_name
COPY ./webdsl /webdsl-project
COPY ./application.ini /webdsl-project/
RUN sed -i "1s/.*/appname=$app_name/" /webdsl-project/application.ini

# Needs to copy at least one file, using application.ini as dummy file
# the [t] makes the copy of react directory optional
COPY ./application.ini ./reac[t] ./react/

#Node.js v16.x:
#Using Ubuntu
RUN if [ -n "$(ls -A ./react/package.json)" ]; then curl -fsSL https://deb.nodesource.com/setup_16.x | bash && apt-get install -y nodejs; npm i -g yarn; fi

WORKDIR /
RUN wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64

COPY ./runscript.sh /
WORKDIR /

RUN echo "$app_name" > /app_name
CMD ./runscript.sh