# Table of Contents #


# API #
For the API: [Click Here](http://robomagellan.caltech.edu/api/compass/javadoc/)

# Details #

## Header ##
In the header, put this:
```
import robomagellan.compass.*;
```

## Constructor ##
To instantiate a `Compass` object:
```
Compass myCompass = new Compass("/dev/ttyUSB0");
```

## Getting Compass Data ##
To get `Compass` data:
```
myCompass.addCompassDataListener(new CompassDataListener() {
   public void processEvent(CompassPacket p){
      //Do your thing with CompassPacket p
   }
});
```

Alternatively, you can create a class elsewhere that implements interface `CompassDataListener` and feed it the object. For instance, if your new class is called `CompassLogger`, you can do this:

```
CompassLogger cl = new CompassLogger();
myCompass.addCompassDataListener(cl);
```

You may only call `addCompassDataListener` once. Otherwise it will throw a `TooManyListenersException`

## Shutting Down ##
To shutdown the `Compass` port:
```
myCompass.stop();
```