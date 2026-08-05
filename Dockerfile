FROM node:22-alpine

LABEL org.opencontainers.image.title="api-pagamentos"
LABEL org.opencontainers.image.description="API ficticia de pagamentos para laboratorio DevSecOps"
LABEL org.opencontainers.image.source="https://github.com/NoxMundus/policy-as-code-sbom-e-supply-chain-security-proj"

# Cria usuário e grupo não-privilegiados para compliance de segurança
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copia os arquivos de dependências de dentro da pasta app/ do seu PC
COPY app/package*.json ./

# Instala apenas dependências de produção
RUN npm ci --omit=dev \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

# Copia o restante do código da pasta app/ e define o appuser como dono
COPY --chown=appuser:appgroup app/ ./

ENV NODE_ENV=production
ENV PORT=8080

# Altera para o usuário sem privilégios
USER appuser

EXPOSE 8080

CMD ["node", "server.js"]
