FROM node:4.4.0

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# install soft
RUN npm install -g bower gulp

# get the app from github
RUN git clone https://github.com/kashesandr/NRTC.git && cd NRTC

# build the app
RUN npm install && gulp

# expose port for a web server
#EXPOSE 8080

# get logs from

# start the app
CMD [ "npm", "start" ]
