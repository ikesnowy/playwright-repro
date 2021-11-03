FROM mcr.microsoft.com/playwright:v1.16.1 AS base
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb
RUN apt update && \
    apt install -y apt-transport-https && \
    apt update && \
    apt install -y dotnet-runtime-5.0
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /src
COPY ["PlaywrightRepro.csproj", "./"]
RUN dotnet restore "PlaywrightRepro.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "PlaywrightRepro.csproj" -c Release

FROM build AS publish
RUN dotnet publish "PlaywrightRepro.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PlaywrightRepro.dll"]
