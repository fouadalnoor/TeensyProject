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



// Define structures and classes
   ADC *adc = new ADC(); // adc object

// Define variables and constants


// Prototypes
int analogue_value;
int adc_resolution;
bool en = true;



// Add setup code
void setup()
{
    pinMode(13, OUTPUT);
    Serial.begin(9600);
    adc->setResolution(16);
  

   
    
}

// Add loop code
void loop()
{
 
    //while loop not working...
    
    /*
    while(en){
        adc_resolution = adc->getResolution();
        
        Serial.print("Analogue Resolution: \n");
        Serial.print(adc_resolution);
        en = false;
        
    }
     */
    
    int analogue_value = adc->analogRead(A9);
    float analogue_voltage = (float)analogue_value; //19275;//convert to voltage
    float dividend = 19275.0;
    float final_analogue_voltage = analogue_voltage/dividend;

    
    //Serial.print("Analogue Value: \n");
    //Serial.print(analogue_voltage);
    Serial.print("\n");
    Serial.print(final_analogue_voltage, 3);
    Serial.print("\n");
  
    
    digitalWrite(13, HIGH);
    //delay(100);
    digitalWrite(13, LOW);
    //delay(100);


    
    
    
    
}
