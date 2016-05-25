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
//#include "SoftSPI.h"
#include "LowPower_Teensy3_mod.h"
#include "TimerOne.h"
//#include "DS3231RTC.h"


// Define structures and classes
   ADC *adc = new ADC(); // adc object
   //DS3231RTC *ds = new DS3231RTC();
    Test myTest = Test(3);
// Define variables and constants


// Prototypes
int analogue_value;
int adc_resolution;
bool en = true;
float final_analogue_voltage;

TEENSY3_LP LP = TEENSY3_LP(); //Create Object for sleep



void sleepInterrupt() {
 
    //Is entered every 1ms
    Serial.print("Sleep Interrupt Entered\n");
    Serial.print("\n");
    
    //fast blinking indicates entered sleep interrupt
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    delay(100);
    

    /*
    //Measure voltage
    int analogue_value = adc->analogRead(A9);
    float analogue_voltage = (float)analogue_value; //19275;//convert to voltage
    float dividend = 19275.0;
    final_analogue_voltage = analogue_voltage/dividend;
    */
    
    //Serial.print("Voltage value is: ");
   // Serial.print(final_analogue_voltage); //only accurate to about 2 decimal places. Supply limit might play a role.
    //Serial.print("\n");
     
    
    
  //check battery voltage is below 2V (should be 3.4V), then sleep
    
    

    /*
    if(final_analogue_voltage<2)
    {
        Serial.print("Enter Sleep mode"); //only accurate to about 2 decimal places. Supply limit might play a role.
        Serial.print("\n");
        
        LP.Sleep(); //May disable Timer1?  or disable digital interrupt?
        
    }
    
    else {
        loop(); //Enter loop if voltage is >2V (should be 3.4V)
    }
     
    */
 
     loop();
}


void callbackhandler() {
    
    Serial.print("Entered Callback Handler"); //only accurate to about 2 decimal places. Supply limit might play a role.
    Serial.print("\n");
    
    digitalWrite(LED_BUILTIN, HIGH);
    delay(1000);
    digitalWrite(LED_BUILTIN, LOW);
    
    //loop();//Go back to the loop when awake again.
    sleepInterrupt();
}

// Add setup code
void setup()
{
    pinMode(13, OUTPUT);
    Serial.begin(9600);
    adc->setResolution(16);
    //ds->chipPresent();
    
    //Set  pin 0 as an input and attach it as an interrupt (for sleeping purposes).
    pinMode(0, INPUT);
    attachInterrupt(0, callbackhandler, CHANGE); //Only change from Low-High works? - Seems like both work.
    
    //Example Timer as an interrupt trigger - Need the .h file.
    
    //Timer1.initialize();
    //Timer1.attachInterrupt(sleepInterrupt, 1000000); //Max time period is 1ms? //does not work when asleep?

}

// Add loop code
void loop()
{
    Serial.print("\n");
    Serial.print("In main loop - Awake \n");
    Serial.print("\n");
    
    //slow blinking indicates awake
    digitalWrite(13, HIGH);
    delay(1000);
    digitalWrite(13, LOW);
    delay(1000);

    //it appears that we need the reading of the ADC and the if statement to check voltage level in this loop?
    int analogue_value = adc->analogRead(A9);
    float analogue_voltage = (float)analogue_value; //19275;//convert to voltage
    float dividend = 19275.0;
    final_analogue_voltage = analogue_voltage/dividend;
    
    
    //The value should be <3.4
    if(final_analogue_voltage<2)
    {
        //sleep
        Serial.print("Enter Sleep mode"); //only accurate to about 2 decimal places. Supply limit might play a role.
        Serial.print("\n");
        
        digitalWrite(13, HIGH);
        delay(100);
        digitalWrite(13, LOW);
        delay(100);
        LP.Sleep();
    }
    
    
   
    
}
