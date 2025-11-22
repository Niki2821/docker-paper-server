#start build
FROM alpine:latest

#link can be changed at build time by passing this arg
ARG jarDownloadLink=https://fill-data.papermc.io/v1/objects/d5f47f6393aa647759f101f02231fa8200e5bccd36081a3ee8b6a5fd96739057/paper-1.21.10-115.jar

ARG minRam=1G
ARG maxRam=3G

#using env instead of arg allows for adjusting the ram allocation for java after the image has been built
ENV minRamEnv=$minRam
ENV maxRamEnv=$maxRam

WORKDIR /minecraft

#copy server.properties
COPY . .

#install java
RUN apk add openjdk21 wget sed nano

#get paper jar
RUN wget "$jarDownloadLink" -O paper.jar

#create eula file to allow server to run
RUN echo "eula=true" > eula.txt

#print ram allocation values for debugging
RUN echo "Minimum allocated Ram: $minRamEnv"
RUN echo "Maximum allocated Ram: $maxRamEnv"

#expose minecraft port
EXPOSE 25565

#start server
CMD sh -c "java -Xms${minRamEnv} -Xmx${maxRamEnv} -jar paper.jar --nogui"