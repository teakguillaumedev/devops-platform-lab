FROM python:3.12-alpine
WORKDIR /app
COPY worker.py start.sh ./
RUN chmod +x start.sh
CMD ["/app/start.sh"]
