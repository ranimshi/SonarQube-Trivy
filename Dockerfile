FROM 10.253.30.42:5000/mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app

COPY ["Activate Data Point/MODEL/Script.txt", "/"]

FROM 10.253.30.42:5000/mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
# WORKDIR /src
COPY ["Activate Data Point/library/SSRM.dll", "Activate Data Point/library/"]

COPY ["Activate Data Point/Activate Data Point.csproj", "Activate Data Point/"]
COPY ["Activate Data Point/.","Activate Data Point/"]

RUN dotnet restore --source http://10.253.30.42:8081/repository/nuget-hosted/ "Activate Data Point/Activate Data Point.csproj"

WORKDIR "/src/Activate Data Point"

RUN dotnet build "Activate Data Point.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Activate Data Point.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Activate Data Point.dll"]
