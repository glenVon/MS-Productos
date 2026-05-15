# Etapa 1: Construcción (Build Stage)
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Copiamos el pom.xml y descargamos dependencias (optimiza la caché)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiamos el código fuente y compilamos el proyecto
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Producción (Production Stage)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Creación de usuario sin privilegios root (Seguridad - IE6)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copiamos el archivo .jar generado en la Etapa 1
COPY --from=builder /app/target/*.jar app.jar

# Exponemos el puerto
EXPOSE 8080

# Ejecutamos la aplicación
CMD ["java", "-jar", "app.jar"]