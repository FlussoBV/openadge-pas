FROM devbfvio/openedge-common:12.8.6-rc3

# This Dockerfile is for local testing purposes only.
# Dev and prod images are built via Github Actions and have
# their own Dockerfiles.

RUN mkdir /app/pas && \
    mkdir /app/src && \
    mkdir /app/lib && \
    mkdir /app/config 

RUN pasman create -p 8810 -P 8811 -j 8812 -s 8813 -Z dev -v -f -U openedge -G openedge -N pas /app/pas/as

WORKDIR /app/pas/as    

RUN bin/oeprop.sh AppServer.Agent.pas.PROPATH=".,/app/config,/app/src,/app/lib/logic.pl,/app/dep1,/app/dep2,/app/dep3,/app/dep4,/app/dep5,\${DLC}/tty,\${DLC}/tty/OpenEdge.Core.pl,\${DLC}/tty/netlib/OpenEdge.Net.pl" && \
    touch /app/pas/as.pf && \
    bin/oeprop.sh AppServer.SessMgr.agentStartupParam="-T \"\${catalina.base}/temp\" -pf ./../../as.pf" && \
    bin/oeprop.sh AppServer.SessMgr.pas.agentLogFile="\${catalina.base}/logs/pas.agent.log"

RUN mkdir -p /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/
COPY --chown=openedge:openedge oeablSecurity-dev.csv /app/pas/as/webapps/ROOT/WEB-INF/oeablSecurity.csv

COPY --chown=openedge:openedge --chmod=744 start.sh /app/pas/

RUN touch /app/pas/pas.type.dev 

VOLUME /app/src
VOLUME /app/lib
VOLUME /app/config
    