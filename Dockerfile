ARG YQ_URL=https://github.com/mikefarah/yq/releases/download/v4.24.2/yq_linux_amd64
ARG JQ_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
ARG PARAMS_SHELL_URL=https://raw.githubusercontent.com/PeekLeon/params-shell/master/params-shell.sh

FROM bash:alpine3.15

WORKDIR /data

ARG YQ_URL
ARG JQ_URL
ARG PARAMS_SHELL_URL
## xterm and ncurses for "tabs"
ENV TERM=xterm
RUN apk --update add curl wget openssl ncurses
RUN wget ${YQ_URL} -O /usr/bin/yq && chmod +x /usr/bin/yq
RUN wget ${JQ_URL} -O /usr/bin/jq && chmod +x /usr/bin/jq
RUN mkdir /scripts
RUN wget ${PARAMS_SHELL_URL} -O /scripts/params-shell.sh && chmod +x /scripts/params-shell.sh

COPY gitlab-var-mng.sh /scripts/gitlab-var-mng.sh

ENTRYPOINT ["bash", "/scripts/gitlab-var-mng.sh"]
