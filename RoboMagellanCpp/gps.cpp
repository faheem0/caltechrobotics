#ifndef __GPS_CPP__
#define __GPS_CPP__

#include "gps.hh"
#include <termios.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "UTMData.hh"
#include <stdio.h>
#include <boost/regex.hpp>
#include <boost/signal.hpp>
#include <stdlib.h>
#include <iostream>


using namespace std;

void GPS::run() {
  initializePort();
  listen();
}

void GPS::initializePort() {
  fd_serial = open(SERIALPORT.c_str(), O_RDWR | O_NOCTTY);
  if (fd_serial < 0) {
    std::cout << "Unable to open serial port in GPS" << std::endl;
    exit(-1);
  }

  // I found this on the internet, mostly don't know what it does...
  tcgetattr(fd_serial, &oldtty);
  tty = oldtty;

  // BAUD_RATE defined in header
  // CS8 means 8 bit, no parity, one stop bit
  // CLOCAL means local connection
  tty.c_cflag = BAUD_RATE | CS8 | CLOCAL;

  // IGNPAR means ignore bytes with parity errors
  // ICRNL means map CR to NL (unsure if this is needed, gotta look at the data)
  tty.c_iflag = IGNPAR | ICRNL;

  // Raw output
  tty.c_oflag = 0;

  // ICANON : Canonical input (block until NL received)
  tty.c_lflag |= ICANON;

  // control characters: may have to edit this if we run into problems
  // disable timer
  tty.c_cc[VTIME] = 0;
  // block until 1 character arrives
  tty.c_cc[VMIN] = 1;

  tcflush(fd_serial, TCIFLUSH);
  tcsetattr(fd_serial, TCSANOW, &tty);


  // Serial port should not be initialized, intializing GPS

  sendCommand("$PASHS,PWR,ON");
  sendCommand("$PASHQ,PRT");
  sendCommand("$PASHQ,RID");
  sendCommand("$PASHS,OUT,A,NMEA");
  sendCommand("$PASHS,NME,UTM,A,ON");
  
}

void GPS::listen() {
  while (active) {
    int res = read(fd_serial, serial_buffer, 255);
    serial_buffer[res] = 0; // null-terminate result
    std::string gps_input = serial_buffer;
    parseInputString(gps_input);
  }
}

GPS::~GPS() {
  // Reset the serial port
  tcsetattr(fd_serial, TCSANOW, &oldtty);
  close(fd_serial);
}

void GPS::sendCommand(const std::string& str) {
  std::string cmdstr = str + "\r\n";
  write(fd_serial, cmdstr.c_str(), cmdstr.length());
}

void GPS::parseInputString(const std::string& istr) {
  if (boost::regex_match(istr.c_str(), gps_matches, gps_regex)) {
    // we should check the checksum (compute by XORing all bytes between $ and * (not inclusive)

    std::string east(gps_matches[3].first, gps_matches[3].second);
    std::string north(gps_matches[4].first, gps_matches[4].second);
    std::string time(gps_matches[1].first, gps_matches[1].second);
    std::string num(gps_matches[6].first, gps_matches[6].second);
    UTMData d(atof(east.c_str()), atof(north.c_str()), atoi(num.c_str()), atof(time.c_str()));
    onDataReceived(d);
  }
}

void print_gps(const UTMData& gpsdata) {
  std::cout << "East: " << gpsdata.easting << " | North: " << gpsdata.northing << " | Time: " << gpsdata.timestamp << " | NumSats: " << gpsdata.numSat << endl;
}

int main() {
  cout << "GPS service initializing" << endl;
  GPS gps;
  boost::signals::connection conn = gps.subscribe(&print_gps);
  gps.run();
  return 0;
}



#endif // __GPS_CPP__
