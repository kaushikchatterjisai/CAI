FROM tomcat:9-jre11-slim
WORKDIR /usr/local/tomcat/webapps
COPY abc_tech.war ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
