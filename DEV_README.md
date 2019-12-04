# :busts_in_silhouette: Developer Documentation

This is a guide to get you up and running :running: with controller development.

## Requirements :computer:

### Hardware

- iPhone running iOS 13
- Computer running macOS

### Software

- XCode
- Arduino IDE
- Required Adafuit libraries:
  - Adafruit ESP32
  - Adafruit BLE
  - Adafruit Motor Shield

## Setup :hammer: :couple:

Clone the repository with git or download the code.

```
git clone git@github.com:sambehrens/egen310-controller.git
```

Open the `CarController` folder with XCode.

Open the `car_arduino` folder with the Arduino IDE.

## Testing :triangular_ruler:

To test the controller app without bluetooth, run the app in the iOS simulator.

To test bluetooth, it must be run on your iPhone. To do so, plug your phone into the computer and choose to run on your device.

To test the microcontroller code, plug the microcontroller into the computer via USB. Then click upload in the IDE to upload the code to the microcontroller.

## Done! :tada:
