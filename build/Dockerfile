FROM mcr.microsoft.com/playwright/mcp:latest

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    x11vnc xvfb novnc websockify && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Chrome browser
RUN npm install -g playwright && npx playwright install chrome --with-deps

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8931 6080

ENTRYPOINT ["/entrypoint.sh"]
