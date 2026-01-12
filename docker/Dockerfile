FROM node:18-alpine

WORKDIR /app

COPY app/package*.json ./
RUN npm ci --only=production

COPY app .

RUN adduser -D nodeuser
USER nodeuser

EXPOSE 3000
CMD ["node", "index.js"]
