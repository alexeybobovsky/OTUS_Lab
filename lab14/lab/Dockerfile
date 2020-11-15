FROM nginx:alpine
RUN apk update && apk upgrade
COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/
EXPOSE 8080
ENTRYPOINT ["nginx", "-g", "daemon off;"]