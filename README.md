# coffeeshop_app

A simple application to show querying a reactive server.
It requires reactive-coffeeshop-api Quarkus microservice.

## Getting Started

Head to lib/constants.dart to configure localhost or internet based server. You can use ngrok to have an android emulator going to your localhost:8080 through ngrok application simply running

\# ngrok http localhost:8080


Avoid CORS blocking when testing in browser

\# flutter run -d chrome --web-browser-flag "--disable-web-security"