# NRTC
NodeJS RFID Time Controller

Version 0.1.1

# What is it?
It is the application which allows to calculate time that somebody spent somewhere. It's perfectly suitable for a time-based cafes. When you're paid for time that visitors spent in your cafe.
When a visitor enters he must be checked in and checked out when exits. The system automatically calculates (based on defined rules) the price for the visitor when he gets out.

# How to use it?
## Requirements

The app tested on Windows (7/8) and MAC (El Capitan)

Hardware (that I used):
- Computer with windows 7/8 or MAC
- RFID reader (model CF-RL120: freq 125KHz, interface USB or RS232)
- RFID tags (125KHz EM4100)

Software (that I used):
- Drivers for the reader (http://www.prolific.com.tw/US/ShowProduct.aspx?pcid=41)
- NodeJS + npm (https://nodejs.org/)
- Python 2.7.6 (https://www.python.org/download/releases/2.7.6/)
- Visual Studio Express 2013 for Windows Desktop (https://www.visualstudio.com/en-us/products/visual-studio-express-vs.aspx) (`node-gyp` plugin uses that to build `node-serialport`)
- Account on `http://parse.com/` (it is a data storage for the app)

## Installation
- Install drivers and plug in the RFID reader, make sure COM port is used correctly
- Set up a new application on `http://parse.com/`
- Download the app from github
- Go to the root app's folder
- Fill `settings.json` with proper data
- Run `npm install bower gulp -g`
- Run `npm install`
- Run `gulp`
- Run `node build/backend/main`
- If everything is OK, open `http://localhost:8090` and see the live statistics

## Using
- After you've done all the steps above, you will see a
-- CMD window
-- Web page
- Each time you move an RFID tag close to the reader the app will produce an action and logs that in the `parse.com`
- You can see users' login/logout, time spent, prices on the web page
- You can remove a log
- You can see some statistics

# Any questions/bugs/feedback?
- I guess there are some, please let me know @kashesandr
