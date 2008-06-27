#ifndef __UTMData_hh__
#define __UTMData_hh__

class UTMData {
public:
  UTMData(double e, double n, int n, double t) : easting(e), northing(n), numSat(n), timestamp(t) {    
  }

  double easting;
  double northing;
  int numSat;
  double timestamp;
}

#endif // __UTMData_hh__
