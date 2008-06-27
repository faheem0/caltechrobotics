#ifndef __gps_hh__
#define __gps_hh__

#include "UTMData.hh"
#include <boost/signal.hpp>
#include <termios.h>
#include <boost/regex.hpp>

class GPS {

public:
  GPS() : coords(0,0,0,0), gpsSignal(), active(true), gps_regex() {   
    gps_regex.assign(REGEX_STRING);
  }
  ~GPS();

  void subscribe(boost::function<void (const UTMData&)> f) {
    gpsSignal.connect(f);
  }

  void run();



private:
  UTMData coords;
  boost::signal<void (const UTMData&)> gpsSignal;

  int fd_serial;
  struct termios oldtty;
  struct termios tty;
  char serial_buffer[256];
  boost::regex gps_regex;
  boost::cmatch gps_matches;

  void onDataReceived(const UTMData& d) {
    coords = d;
    gpsSignal(coords);
  }

  void initializePort();
  void listen();
  void parseInputString(const std::string& s);
  void sendCommand(const std::string& cmd);
  bool active;

                                                                               
  // ^\$PASHR,UTM,([0-9]+.?[0-9]*),([0-9]+[NS]),([-]?[0-9]+.?[0-9]*),([-]?[0-9]+.?[0-9]*),([12]),([0-9]{1,2}),([0-9]+.?[0-9]*),([-]?[0-9]+.?[0-9]*),(M),([-]?[0-9]+.?[0-9]*),(M),([0-9]{1,3}),([0-9a-zA-Z]{4})\*([0-9a-zA-Z]*)$

  static const std::string REGEX_STRING;
  static const int BAUD_RATE = B4800;
  static const int DATA_BITS = 8;
  static const int DEFAULT_TIMEOUT = 500;
  static const std::string SERIALPORT;
};

const std::string GPS::SERIALPORT("/dev/ttyS0");
const std::string GPS::REGEX_STRING("^\\$PASHR,UTM,([0-9]+.?[0-9]*),([0-9]+[NS]),([-]?[0-9]+.?[0-9]*),([-]?[0-9]+.?[0-9]*),([12]),([0-9]{1,2}),([0-9]+.?[0-9]*),([-]?[0-9]+.?[0-9]*),(M),([-]?[0-9]+.?[0-9]*),(M),([0-9]{1,3}),([0-9a-zA-Z]{4})\\*([0-9a-zA-Z]*)$");

#endif // __gps_hh__

