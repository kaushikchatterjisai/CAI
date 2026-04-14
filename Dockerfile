FROM tomcat:9-jre11-slim
COPY abc_tech.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]
