#ifndef __Compass_cpp__
#define __Compass_cpp__

#include "Compass.hh"
#include "MotorControl.hh"

#include <stdio.h>
#include <iostream>
#include <termios.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>

#include <boost/signals.hpp>

void Compass::initializePort() {
  fd_serial = open(SERIALPORT.c_str(), O_RDWR | O_NOCTTY);
  if (fd_serial < 0) {
    std::cout << "Unable to open serial port in compass" << std::endl;
    exit(-1);
  }

  tcgetattr(fd_serial, &oldtty);
  tty = oldtty;
  
  tty.c_cflag = BAUD_RATE | CS8 | CLOCAL;
  tty.c_iflag = IGNPAR | ICRNL;
  
  tty.c_oflag = 0;
  
  tty.c_lflag &= ~ICANON;

  tty.c_cc[VTIME] = 0;
  tty.c_cc[VMIN] = 4;

  tcflush(fd_serial, TCIFLUSH);
  tcsetattr(fd_serial, TCSANOW, &tty);
}

void Compass::listen() {
  while (active) {
    int res = read(fd_serial, serial_buffer, 255);
    if (res != 4) {
      std::cout << "Buffer underflow in Compass, recieved " << res << " bytes" << std::endl;
    }
    else {
      int b = serial_buffer[1] + serial_buffer[2];
      if(serial_buffer[0] != static_cast<char>(COMMAND_START) || serial_buffer[3] != static_cast<char>(COMMAND_STOP) || b >= 360) {
	std::cout << "Invalid input in Compass, recieved " << serial_buffer[0] << "|" << serial_buffer[1] << "|" << serial_buffer[2] << "|" << serial_buffer[3] << "|" << std::endl;
      }
      onDataReceived(b);
    }
  }
}

Compass::~Compass() {
  tcsetattr(fd_serial, TCSANOW, &oldtty);
  close(fd_serial);
}

int main() {
  return 0;
}

#endif // __Compass_cpp__
