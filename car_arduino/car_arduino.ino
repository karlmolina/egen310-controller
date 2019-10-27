#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Adafruit_MotorShield.h>

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t value = 0;

#define SERVICE_UUID        "b848f29a-7089-407c-8d73-22461900c71d"
#define CHARACTERISTIC_UUID "4b55ae61-a529-4b2c-85f9-82c7401db550"

// The motorshield
Adafruit_MotorShield AFMS = Adafruit_MotorShield();

// The right and left motors
int rightMotorPin = 3;
int leftMotorPin = 4;
Adafruit_DCMotor *rightMotor = AFMS.getMotor(rightMotorPin);
Adafruit_DCMotor *leftMotor = AFMS.getMotor(leftMotorPin);

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      BLEDevice::startAdvertising();
      digitalWrite(13, HIGH);
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      digitalWrite(13, LOW);
    }
};

class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();

      if (value.length() > 0) {
        Serial.println("*********");
        Serial.print("New value: ");

        std::string leftSub = value.substr(0, 4);
        std::string rightSub = value.substr(4, 8);
        std::string leftPinSub = value.substr(8, 9);
        std::string rightPinSub = value.substr(9, 10);
        int leftSpeed = std::atoi(leftSub.c_str());
        int rightSpeed = std::atoi(rightSub.c_str());
        int leftPin = std::atoi(leftPinSub.c_str());
        int rightPin = std::atoi(rightPinSub.c_str());

        changeMotorPins(leftPin, rightPin);

        // Turn on the right motor according to the data
        if (rightSpeed < 0) {
          rightMotor->setSpeed(-rightSpeed);
          rightMotor->run(BACKWARD);
        } else if (rightSpeed > 0) {
          rightMotor->setSpeed(rightSpeed);
          rightMotor->run(FORWARD);
        } else if (rightSpeed == 0) {
          rightMotor->run(RELEASE);
        }
        // Turn on the left motor
        if (leftSpeed < 0) {
          leftMotor->setSpeed(-leftSpeed);
          leftMotor->run(BACKWARD);
        } else if (leftSpeed > 0) {
          leftMotor->setSpeed(leftSpeed);
          leftMotor->run(FORWARD);
        } else if (leftSpeed == 0) {
          leftMotor->run(RELEASE);
        }
      }
    }

    void changeMotorPins(int left, int right) {
    if (leftMotorPin != left) {
      leftMotor->setSpeed(0);
      leftMotorPin = left;
      leftMotor = AFMS.getMotor(leftMotorPin);
    }
    if (rightMotorPin != right) {
      rightMotor->setSpeed(0);
      rightMotorPin = right;
      rightMotor = AFMS.getMotor(rightMotorPin);
    }
  }
};

void setup() {
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  // Start the motorshield
  AFMS.begin();

  Serial.println("Begin");

  // Create the BLE Device
  BLEDevice::init("ESP32");
  Serial.println("Added device ESP32");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  Serial.println("Created server");

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);
  Serial.println("Created service");

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );
  Serial.println("Created characteristic with uuid:");
  Serial.println(CHARACTERISTIC_UUID);

  Serial.println("Add callbacks");
  pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());

  pCharacteristic->addDescriptor(new BLE2902());
  Serial.println("Added descriptor");

  // Start the service
  pService->start();
  Serial.println("Started");

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
    // notify changed value
//    if (deviceConnected) {
//        pCharacteristic->setValue((uint8_t*)&value, 4);
//        pCharacteristic->notify();
//        value++;
//        delay(1000); // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
//    }
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
        value = 0;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
        Serial.println("Connecting");
    }
}
