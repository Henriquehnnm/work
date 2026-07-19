FROM docker.io/oven/bun:1.3 AS base

WORKDIR /app

# --- Estágio de Dependências ---
FROM base AS deps
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# --- Estágio Final (Runner) ---
FROM base AS runner
WORKDIR /app

# 1. Instala apenas o que o apt-get precisa (sem npx aqui)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 2. Copia os arquivos de dependência primeiro
COPY --from=deps /app/node_modules ./node_modules
COPY package.json tsconfig.json playwright.config.ts ./

# 3. Agora que o node_modules está aqui, o npx funciona!
RUN bunx playwright install-deps
RUN bunx playwright install chromium

# 4. Copia o resto do código
COPY src/ ./src/
COPY tests/ ./tests/ 

ENV NODE_ENV=production

EXPOSE 3000

CMD ["bun", "run", "src/index.ts"]
