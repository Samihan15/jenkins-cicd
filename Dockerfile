FROM node:18-alpine3.20

WORKDIR /app

COPY app/package*.json ./

RUN npm ci --omit=dev

COPY app .

RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup
USER nodeuser

EXPOSE 3000

CMD ["node", "index.js"]
