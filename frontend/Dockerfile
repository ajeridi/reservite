# Étape 1 : compiler l'app Flutter pour le web (même version de Flutter que dans pubspec.yaml)
FROM ghcr.io/cirruslabs/flutter:3.38.7 AS build
WORKDIR /app

# Dépendances d'abord : cette couche reste en cache tant que pubspec ne change pas
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Étape 2 : servir les fichiers compilés avec Nginx (image finale légère)
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
