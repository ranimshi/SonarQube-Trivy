FROM 10.253.30.42:5000/dotnet-7-0-sonar

# Create user and set environment
#RUN useradd -m -s /bin/bash gitlab-runner

# Set permissions for dotnet tools and app directory
ENV PATH="$PATH:/home/gitlab-runner/.dotnet/tools"

# Create workdir and set correct permissions
WORKDIR /app
COPY ["." , "." ]
COPY ["Activate Data Point" , "/app" ]
COPY ["Activate Data Point.sln" , "/app" ]
COPY ["NuGet.config" , "/app" ]
COPY ["trivy-sonar-report.json" , "/app/Activate Data Point"]
#COPY ["Activate-Data-Point.csproj", "/app/Activate Data Point"]

# Change ownership of /app to gitlab-runner
#RUN chown -R gitlab-runner:gitlab-runner /app

# Set environment variables
ENV SONAR_HOST_URL=http://10.x.x.x:9000
ENV SONAR_TOKEN=$SONAR_TOKEN
ENV SONAR_PROJECT_KEY=$SONAR_PROJECT_KEY

# Switch to the new user
#USER gitlab-runner

# Dotnet operations
RUN dotnet restore --source http://10.253.30.42:8081/repository/nuget-hosted/ "Activate Data Point/Activate Data Point.csproj"

RUN dotnet build

RUN dotnet sonarscanner begin /k:"$PROJECT-KEY" \
    /d:sonar.host.url="$SONAR_HOST_URL" \
    /d:sonar.token="$SONAR_TOKEN" \
    /d:sonar.externalIssuesReportPaths="/app/Activate Data Point/trivy-sonar-report.json"

RUN dotnet build

RUN dotnet sonarscanner end /d:sonar.token="$SONAR_TOKEN"
