#ifndef __UTMData_hh__
#define __UTMData_hh__

class UTMData {
public:
  UTMData(double e, double n, int num, double t) : easting(e), northing(n), numSat(num), timestamp(t) {    
  }

  double easting;
  double northing;
  int numSat;
  double timestamp;
}

#endif // __UTMData_hh__
