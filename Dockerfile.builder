FROM debian

RUN apt update
RUN apt install -y build-essential

RUN echo "alias ll='ls -la'" >> ~/.bashrc
RUN echo "export TERM=xterm-256color" >> ~/.bashrc

WORKDIR /workspace
CMD [ "/bin/bash", "-c", "--", "while true; do sleep 30; done;" ]
