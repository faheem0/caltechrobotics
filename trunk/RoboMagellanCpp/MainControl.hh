#ifndef __MainControl_hh__
#define __MainControl_hh__

#include "UTMData.hh"
#include <list.h>


typedef enum {
  STATE_STOPPING,
  STATE_STOPPED,
  STATE_TURNING,
  STATE_DRIVING,
  STATE_ERROR,
  STATE_STANDBY,
  STATE_SCANNING
} MainControlState;

class MainControl {
public:
  MainControl() : state(STATE_STANDBY), location(NULL), destination(NULL), destinations(new list<UTMData*>()) {  }

private:
  MainControlState state;
  UTMData* location;
  UTMData* destination;  
  list<UTMData*> * destinations;

};


#endif // __MainControl_hh__
