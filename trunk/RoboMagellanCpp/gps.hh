#ifndef __gps_hh__
#define __gps_hh__

#include "UTMData.hh"
#include <boost/signal.hpp>
#include <termios.h>

public class GPS {

public:
  GPS() : coords(), gpsSignal() {}

  void subscribe(boost::function<void (const UTMData&)> f) {
    gpsSignal.connect(f);
  }

  void run();

private:
  UTMData coords;
  boost::signal<void (const UTMData&)> gpsSignal;

  int serial_fd;
  struct termios oldtty;
  char serial_buffer[256];
  char last_buffer[256];
  int serial_index;


  void onDataReceived(const UTMData& d) {
    coords = d;
    gpsSignal(coords);
  }

  bool initializePort();
  void startListening();
  void parseInputString(string s);

  static int BAUD_RATE = 4800;
  static int DATA_BITS = 8;
  static int DEFAULT_TIMEOUT = 500;
  
}

#endif // __gps_hh__
