# --- ESTÁGIO 1: Build (O caminhão com ferramentas) ---
FROM golang:1.22 AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# O CGO_ENABLED=0 é obrigatório para rodar no Alpine!
RUN CGO_ENABLED=0 GOOS=linux go build -o main main.go

# --- ESTÁGIO 2: Produção (A mochila leve) ---
FROM alpine:latest AS production
WORKDIR /app

# Mantendo suas variáveis da aula
ENV PORT 8080
ENV DB_HOST postgres
ENV DB_USER root
ENV DB_PASSWORD root
ENV DB_NAME root
ENV DB_PORT 5432

# Copiamos só o necessário do estágio de build
COPY --from=build /app/main .
COPY --from=build /app/templates ./templates
COPY --from=build /app/assets ./assets

EXPOSE 8080
CMD [ "./main" ]