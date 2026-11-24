# Unity Catalog server. The official image is 2.8 GB because it carries the build tools; this is the same server without them.
FROM eclipse-temurin:17-jdk-noble AS build
ADD https://github.com/coursier/coursier/releases/download/v2.1.27/coursier /usr/local/bin/cs
RUN chmod +x /usr/local/bin/cs && mkdir /jars && cs fetch \
      io.unitycatalog:unitycatalog-server:0.7.0 \
      org.postgresql:postgresql:42.7.13 \
    | xargs -I{} cp {} /jars/
COPY RustfsCredentials.java /
RUN javac -cp '/jars/*' -d /classes /RustfsCredentials.java

FROM eclipse-temurin:17-jre-noble
RUN useradd --system --uid 10002 --home-dir /opt/unitycatalog --create-home unitycatalog
COPY --from=build /jars/ /opt/unitycatalog/jars/
COPY --from=build /classes/ /opt/unitycatalog/classes/
COPY --chmod=755 entrypoint.sh /
WORKDIR /opt/unitycatalog
USER unitycatalog
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
