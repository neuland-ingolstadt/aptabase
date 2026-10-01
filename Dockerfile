# Server Build
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS server
WORKDIR /work/src

COPY ./src/Aptabase.csproj /work/src

ARG TARGETARCH
RUN dotnet restore "./Aptabase.csproj" -a $TARGETARCH

COPY ./etc/clickhouse /work/etc/clickhouse
COPY ./etc/geoip /work/etc/geoip
COPY ./src /work/src

RUN dotnet publish "Aptabase.csproj" -a $TARGETARCH -c Release -o /work/publish /p:UseAppHost=false

# Final (backend only — no web UI)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

COPY --from=server /work/publish .
COPY LICENSE .

ENTRYPOINT ["dotnet", "Aptabase.dll"]
