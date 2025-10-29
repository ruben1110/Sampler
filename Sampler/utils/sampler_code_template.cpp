#include <iostream>
#include <windows.h>
#include <stdio.h>
#include <string>
#include <cstdlib>
#include <cmath>

using namespace std;


// Configuration parameters
#define MIN_OMEGA_VALUE 1
#define MAX_OMEGA_VALUE 100
#define OMEGA_INCREMENT 1

// Constants
const char* COM_PORT = "COM3";
const DWORD BAUD_RATE = 1000000;
const char END_SAMPLING_CHAR = 'E';
const char LINE_TERMINATOR = '\n';

// Function prototypes
HANDLE initializeSerialPort();
bool configureSerialPort(HANDLE serialHandle);
bool sendValueToSerial(HANDLE serialHandle, float value);
void collectDataToFile(HANDLE serialHandle, FILE* dataFile);
void processDataCollection(HANDLE serialHandle);

int main() {
    
    HANDLE serialHandle = initializeSerialPort();
    if (serialHandle == INVALID_HANDLE_VALUE) {
        cerr << "Error: Unable to open serial port " << COM_PORT << endl;
        return EXIT_FAILURE;
    }
    
    if (!configureSerialPort(serialHandle)) {
        cerr << "Error: Failed to configure serial port" << endl;
        CloseHandle(serialHandle);
        return EXIT_FAILURE;
    }
    
    processDataCollection(serialHandle);
    
    CloseHandle(serialHandle);
    cout << "\n\n Sampling has been completed successfully" << endl;
    
    return EXIT_SUCCESS;
}

HANDLE initializeSerialPort() {
    HANDLE serialHandle = CreateFile(COM_PORT, 
                                   GENERIC_READ | GENERIC_WRITE,
                                   0,
                                   NULL,
                                   OPEN_EXISTING,
                                   FILE_ATTRIBUTE_NORMAL,
                                   NULL);
    
    return serialHandle;
}

bool configureSerialPort(HANDLE serialHandle) {
    DCB serialConfig = {0};
    serialConfig.DCBlength = sizeof(serialConfig);
    
    if (!GetCommState(serialHandle, &serialConfig)) {
        return false;
    }
    
    // Configure serial port parameters
    serialConfig.BaudRate = BAUD_RATE;
    serialConfig.ByteSize = 8;
    serialConfig.Parity = NOPARITY;
    serialConfig.StopBits = ONESTOPBIT;
    serialConfig.fBinary = TRUE;
    serialConfig.fParity = TRUE;
    
    if (!SetCommState(serialHandle, &serialConfig)) {
        return false;
    }
    
    // Set communication mask to wait for received characters
    SetCommMask(serialHandle, EV_RXCHAR);
    
    return true;
}

bool sendValueToSerial(HANDLE serialHandle, float value) {
    string valueString = to_string(value);
    DWORD bytesWritten;
    
    // Send the value character by character
    for (size_t charIndex = 0; charIndex < valueString.length(); charIndex++) {
        if (!WriteFile(serialHandle, &valueString[charIndex], 1, &bytesWritten, NULL)) {
            cerr << "Error: Failed to send character at position " << charIndex << endl;
            return false;
        }
    }
    
    // Send line terminator
    if (!WriteFile(serialHandle, &LINE_TERMINATOR, 1, &bytesWritten, NULL)) {
        cerr << "Error: Failed to send line terminator" << endl;
        return false;
    }
    
    return true;
}

void collectDataToFile(HANDLE serialHandle, FILE* dataFile) {
    char receivedChar;
    DWORD bytesRead;
    
    while (true) {
        if (ReadFile(serialHandle, &receivedChar, 1, &bytesRead, NULL) && bytesRead > 0) {
            if (receivedChar == END_SAMPLING_CHAR) {
                break;
            } else {
                // Write character directly to file
                fprintf(dataFile, "%c", receivedChar);
                fflush(dataFile); // Ensure data is written immediately
            }
        }
    }
}

void processDataCollection(HANDLE serialHandle)
{
    float currentOmegaValue;
    bool collectionComplete = false;
    
    for (int omegaValue = MIN_OMEGA_VALUE; omegaValue <= MAX_OMEGA_VALUE; omegaValue += OMEGA_INCREMENT) {
        // Create filename for current omega value
        char filename[15];
        sprintf(filename, "omega_%d.txt", omegaValue);
        
        FILE* dataFile = fopen(filename, "w+");
        if (dataFile == NULL) {
            cerr << "Error: Unable to create file " << filename << endl;
            continue;
        }
        cout << "\Receiving samples for oemga = " << omegaValue << ", and collecting data to " << filename << endl;
        
        // Collect data until end character is received
        collectDataToFile(serialHandle, dataFile);
        
        fclose(dataFile);
        
        // Optional: Small delay between files
        Sleep(500);
    }
}