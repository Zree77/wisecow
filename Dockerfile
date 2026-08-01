FROM ubuntu:22.04

# Install dependencies: fortune-mod for quotes, cowsay for ASCII art, netcat for the HTTP server
RUN apt-get update && \
    apt-get install -y fortune-mod cowsay netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# cowsay installs to a non-standard PATH location — add it
ENV PATH="/usr/games:${PATH}"

WORKDIR /app
COPY wisecow.sh .
RUN chmod +x wisecow.sh

EXPOSE 4499

CMD ["./wisecow.sh"]
