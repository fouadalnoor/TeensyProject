///
/// @mainpage	TeensyProject
///
/// @details	Using the ADC for Teensy 3.1
/// @n
/// @n
/// @n @a		Developed with [embedXcode+](http://embedXcode.weebly.com)
///
/// @author		Fouad Al-Noor
/// @author		Fouad Al-Noor
/// @date		5/13/16 13:38
/// @version	<#version#>
///
/// @copyright	(c) Fouad Al-Noor, 2016
/// @copyright	Licence
///
/// @see		ReadMe.txt for references
///


///
/// @file		TeensyProject.ino
/// @brief		Main sketch
///
/// @details	<#details#>
/// @n @a		Developed with [embedXcode+](http://embedXcode.weebly.com)
///
/// @author		Fouad Al-Noor
/// @author		Fouad Al-Noor
/// @date		5/13/16 13:38
/// @version	<#version#>
///
/// @copyright	(c) Fouad Al-Noor, 2016
/// @copyright	Licence
///
/// @see		ReadMe.txt for references
/// @n
///


// Core library for code-sense - IDE-based
#if defined(WIRING) // Wiring specific
    #include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
    #include "WProgram.h"
#elif defined(ROBOTIS) // Robotis specific
    #include "libpandora_types.h"
    #include "pandora.h"
#elif defined(MPIDE) // chipKIT specific
    #include "WProgram.h"
#elif defined(DIGISPARK) // Digispark specific
    #include "Arduino.h"
#elif defined(ENERGIA) // LaunchPad specific
    #include "Energia.h"
#elif defined(LITTLEROBOTFRIENDS) // LittleRobotFriends specific
    #include "LRF.h"
#elif defined(MICRODUINO) // Microduino specific
    #include "Arduino.h"
#elif defined(TEENSYDUINO) // Teensy specific
    #include "Arduino.h"
#elif defined(REDBEARLAB) // RedBearLab specific
    #include "Arduino.h"
#elif defined(RFDUINO) // RFduino specific
    #include "Arduino.h"
#elif defined(SPARK) || defined(PARTICLE) // Particle / Spark specific
    #include "application.h"
#elif defined(ESP8266) // ESP8266 specific
    #include "Arduino.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
    #include "Arduino.h"
#else // error
    #   error Platform not defined
#endif // end IDE

// Set parameters


// Include application, user and local libraries
#include "ADC.h"
#include "Arduino.h"
#include "Test.h"
#include "LowPower_Teensy3_mod.h"
#include "TimerOne.h"
//#include "LowPower.h"
//#include "DS3231RTC.h"
//#include "SoftSPI.h"


// Define structures and classes
   ADC *adc = new ADC(); // adc object

// Define variables and constants
int analogue_value;
int adc_resolution;
float final_analogue_voltage;

TEENSY3_LP LP = TEENSY3_LP(); //Create Object for sleep

// Prototypes
void sleepInterrupt(void);
//void callbackhandler(void);


// Add setup code
void setup()
{
    pinMode(13, OUTPUT);
    Serial.begin(115200);
    adc->setResolution(16);
    adc->setReference(ADC_REF_1V2); //set as 1.2V as the battery goes down to 3.4V. Thus the internal 3.3V ref will not be reliable.
    Timer1.initialize();
    Timer1.attachInterrupt(sleepInterrupt, 1000000); //Max time period is 1ms?
    
    //Set pin0 to input and attach callbackhandler as an external interrupt.
    //pinMode(0, INPUT);
    //attachInterrupt(0, callbackhandler, CHANGE);
}

// Add loop code
void loop()
{
    
    Serial.print("\n");
    Serial.print("In main loop - Awake \n");
    Serial.print("\n");
    
    
    //delay needs to be there to ensure that the ADC reads the actual value. Could be potentially removed, but leave it for stability
    //and to see the serial output.
    delay(50);
    

    //At Vcc = 3.4V the analogue value will be 0.95V at the ADC input (due to potential divider) I.e that's the threshold voltage
    //using a 220K and 560K potential divider (tolerance plays a role here..).

    if(final_analogue_voltage<0.95)
    {
        //slow blinking indicates low voltage.
        digitalWrite(13, HIGH);
        delay(500);
        digitalWrite(13, LOW);

    }
    
     //Sleep most of the time. Sample ADC every 1ms

    //LP.DeepSleep(LPTMR_WAKE, 1, sleepInterrupt()); // not sure why its not working.
    LP.Sleep();
    
    ///THE REST THE CODE SHOULD BE BELOW HERE///
}

void sleepInterrupt() {

    //Is entered every 1ms
    Serial.print("Sleep Interrupt Entered\n");
    Serial.print("\n");
    
    //Update voltage measurment.
    int analogue_value = adc->analogRead(A9);
    float analogue_voltage = (float)analogue_value;
    float dividend = 54612.5; //convert 1.2V binary to voltage
    final_analogue_voltage = analogue_voltage/dividend;
    
    
    Serial.print("Final analogue value: ");
    Serial.print(final_analogue_voltage);
    Serial.print("\n");
}

/*
void callbackhandler() {
    
    Serial.print("Entered Callback Handler"); //only accurate to about 2 decimal places. Supply limit might play a role.
    Serial.print("\n");
}
*/
