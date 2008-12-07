#ifndef __MotorControl_hh__
#define __MotorControl_hh__

#include <termios.h>
#include <boost/thread.hpp>
#include <boost/signals.hpp>
#include <cassert>

typedef enum {
  MOVE = 217,
  ACK = 218,
  STOP = 219,
  TURN = 220,
  TURNREL = 221,
  COMMAND_START = 254,
  COMMAND_STOP = 233,
  HAS_STOPPED = 216,
  TURN_COMPLETE = 215
} MotorCommand;


class MotorControl {

public:
  MotorControl() : active(true), serialIndex(0) {}
  ~MotorControl();

  void run();

  void setMotorSpeed(int left, int right);
  void stop(boost::function<void ()> callback);
  void turn(int bearing, boost::function<void ()> callback);
  void sendAck();

private:

  void initializePort();
  void listen();
  void sendBytes(char* arr, int nBytes);
  void sendCommand(MotorCommand cmd, char* args, int nArgs);
  static void wrapSlotDisconnect(boost::function<void ()> callback, boost::signals::connection* c) {
    assert(c->connected());
    c->disconnect();
    delete c;
    callback();
  };
  
  bool active;
  int fd_serial;
  struct termios oldtty;
  struct termios tty;
  char serial_buffer[256];
  int serialIndex;
  
  boost::mutex outputMutex;

  boost::signal<void ()> stopCompleteSignal;
  boost::signal<void ()> turnCompleteSignal;

  static const int BAUD_RATE = B115200;
  static const std::string SERIALPORT;

  static const int MAX_SPEED = 100;
};

const std::string MotorControl::SERIALPORT("/dev/ttyS1");

#endif // __MotorControl_hh__
