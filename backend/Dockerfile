FROM node:26-alpine AS dependencies

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

FROM node:26-alpine AS production

ENV NODE_ENV=production

WORKDIR /app

COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node package*.json ./
COPY --chown=node:node backend/ ./backend/

USER node

EXPOSE 3000

CMD ["node", "backend/server.js"]
