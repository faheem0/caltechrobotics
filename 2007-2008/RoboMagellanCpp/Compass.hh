#ifndef __Compass_hh__
#define __Compass_hh__

#include  <boost/signals.hpp>
#include <termios.h>

class Compass {

public:
  Compass() {}
  ~Compass();

  boost::signals::connection subscribe(boost::function<void (int)> callback)
  {
    return compassSignal.connect(callback);
  }

  void run();

private:
  void initializePort();
  void listen();
  
  boost::signal<void (int)> compassSignal;

  int fd_serial;
  struct termios oldtty;
  struct termios tty;
  char serial_buffer[256];
  
  bool active;

  void onDataReceived(int bearing) {
    compassSignal(bearing);
  }

  static const int BAUD_RATE = B115200;
  static const std::string SERIALPORT;
};

const std::string Compass::SERIALPORT("/dev/ttyS2");

#endif // __Compass_hh__
