#ifndef __MotorControl_cpp__
#define __MotorControl_cpp__

#include "MotorControl.hh"
#include <cassert>
#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/signal.hpp>
#include <termios.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <iostream>
#include <boost/bind.hpp>

void MotorControl::run() {
  initializePort();
  listen();
}

void MotorControl::initializePort() {
  fd_serial = open(SERIALPORT.c_str(), O_RDWR | O_NOCTTY);
  if (fd_serial < 0) {
    std::cout << "Unable to open serial port in motor" << std::endl;
    exit(-1);
  }

  tcgetattr(fd_serial, &oldtty);
  tty = oldtty;

  tty.c_cflag = BAUD_RATE | CS8 | CLOCAL;
  tty.c_iflag = IGNPAR | ICRNL;

  // no output processing
  tty.c_oflag = 0;

  // noncanonical input
  tty.c_lflag &= ~ICANON;

  // disable timer
  tty.c_cc[VTIME] = 0;

  // block until one character arrives
  tty.c_cc[VMIN] = 1;

  tcflush(fd_serial, TCIFLUSH);
  tcsetattr(fd_serial, TCSANOW, &tty);
}

void MotorControl::listen() {
  while (active) {
    
  }
}

MotorControl::~MotorControl() {
  // Reset the serial port
  tcsetattr(fd_serial, TCSANOW, &oldtty);
  close(fd_serial);
}

void MotorControl::sendBytes(char* arr, int nBytes) {

  write(fd_serial, arr, nBytes);
}

void MotorControl::sendCommand(MotorCommand cmd, char* args, int nArgs) {
  boost::mutex::scoped_lock lock(outputMutex);

  char* bytes = new char[nArgs + 3];
  bytes[0] = COMMAND_START;
  bytes[1] = static_cast<char>(cmd);

  for(int i = 0; i < nArgs; i++) {
    bytes[i + 2] = args[i];
  }
  
  bytes[nArgs + 2] = COMMAND_STOP;
  sendBytes(bytes, nArgs + 3);
  delete[] bytes;

}

void MotorControl::setMotorSpeed(int left, int right) {
  assert(-100 <= left && left <= 100);
  assert(-100 <= right && right <= 100);

  char* args = new char[2];
  args[0] = static_cast<char>(left + MAX_SPEED);
  args[1] = static_cast<char>(right + MAX_SPEED);
  sendCommand(MOVE, args, 2);
  delete[] args;
}


void MotorControl::stop(boost::function<void ()> callback) {
  assert(stopCompleteSignal.empty());
  
  boost::signals::connection* cptr;
  
  // I think this will work...
  cptr = new boost::signals::connection(stopCompleteSignal.connect(boost::bind(&wrapSlotDisconnect, callback, cptr)));

  sendCommand(STOP, NULL, 0);

}




void MotorControl::turn(int bearing, boost::function<void ()> callback) {
  assert(turnCompleteSignal.empty());

  boost::signals::connection* cptr;
  
  // I think this will work...
  cptr = new boost::signals::connection(turnCompleteSignal.connect(boost::bind(&wrapSlotDisconnect, callback, cptr)));

  assert(0 <= bearing && bearing <= 360);

  char* args = new char[2];
  
  if (bearing > 255) {
    args[0] = 255;
    args[1] = static_cast<char>(bearing - 255);
  }
  else {
    args[0] = static_cast<char>(bearing);
    args[1] = 0;
  }

  sendCommand(TURN, args, 2);

}

void MotorControl::sendAck() {
  sendCommand(ACK, NULL, 0);
}

int main() {
  return 0;
}

#endif // __MotorControl_cpp__
