FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 8080

CMD ["node", "index.js"]

# FROM node:16

# COPY . .

# RUN npm install

# CMD node index.js
