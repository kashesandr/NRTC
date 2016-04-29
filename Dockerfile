FROM node:4.4.0

# Copy the App
ADD . /usr/src/app
WORKDIR /usr/src/app

# installation
RUN npm install -g bower gulp

# build the app
RUN npm install && gulp

# expose port for a web server
#EXPOSE 8080

# get logs from

# start the app
CMD [ "npm", "start" ]