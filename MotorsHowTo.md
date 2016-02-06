# Table of Contents #


# API #
For the API: [Click Here](http://robomagellan.caltech.edu/api/motors/javadoc/)

# Details #

## Header ##
In the header, put this:
```
import robomagellan.motors.*;
```

## Constructor ##
To instantiate a `Motors` object:
```
Motors myMotors = new Motors("/dev/ttyUSB0");
```

## Getting Encoder Data ##
To get `Motors` data:
```
myMotors.addEncoderDataListener(new EncoderDataListener() {
   public void processEvent(EncoderPacket p){
      //Do your thing with EncoderPacket p
   }
});
```

Alternatively, you can create a class elsewhere that implements interface `EncoderDataListener` and feed it the object. For instance, if your new class is called `MotorsLogger`, you can do this:

```
MotorsLogger ml = new MotorsLogger();
myMotors.addEncoderDataListener(ml);
```

You may only call `addEncoderDataListener` once. Otherwise it will throw a `TooManyListenersException`

## Setting the Speed of Motors ##
To set the speed of a motor, do:

```
myMotors.setSpeed(Motors.LEFT, 10);
// or
myMotors.setSpeed(Motors.RIGHT, 10);
// where the second parameter can be any integer between 0 and 10, inclusive.
```

## Shutting Down ##
To shutdown the `Motors` port:
```
myMotors.stop();
```