FROM node:20-alpine
WORKDIR /app
RUN apk update && apk upgrade --no-cache libssl3
COPY package*.json ./
RUN npm ci --only=production
COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
