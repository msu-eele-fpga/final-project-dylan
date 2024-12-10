#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

#define CH0_OFFSET 0x0
#define CH1_OFFSET 0x4
#define CH2_OFFSET 0x8
#define PERIOD_OFFSET 0
#define RED_VALUE_OFFSET 12
#define GREEN_VALUE_OFFSET 4
#define BLUE_VALUE_OFFSET 8
#define DUTY_CYCLE_OFFSET 0

static volatile int keepRunning = 1;

void intHandler(int dummy) {
    keepRunning = 0;
}

int main () {
	FILE *file;
	FILE *file2;
	FILE *file3;
	size_t ret;	
	size_t ret2;
	size_t ret3;
	uint32_t val;
	uint32_t val2;
	uint32_t val3;
	bool red_active;
	bool blue_active;
	bool green_active;

	// -------- opens the device drivers -------------

	file = fopen("/dev/de10nano_adc" , "rb+" );
	if (file == NULL) {
		printf("failed to open adc file\n");
		exit(1);
	}

	file2 = fopen("/dev/rgb_controller" , "rb+" );
	if (file == NULL) {
		printf("failed to open rgb file\n");
		exit(1);
	}

	file3 = fopen("/dev/servo_controller" , "rb+" );
	if (file == NULL) {
		printf("failed to open servo file\n");
		exit(1);
	}

	// ---------------------------------------------

	// Start up our program!
	printf("\n************************************************\n");
	printf(  "          Move potentiometer values for:        \n");
	printf(  "            - RGB LED lightup                   \n");
	printf(  "            - Servo Movement                    \n");
	printf("************************************************\n\n");

	// will loop until Ctrl+C is pressed
    while(keepRunning) {
		// set our period for our RGB LED to FF for simplicity
		val2 = 0xFF;
		ret2 = fseek(file2, PERIOD_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);

		// reads the adc value from the red potentiometer, then converts it 
		// from a 0 to 4095 value to a 0 to 255 value, then sends that 
		// to the rgb led's red node
        ret = fread(&val, 4, 1, file);
		val2 = val/(4095/255);
		ret2 = fseek(file2, RED_VALUE_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file2);
		// if the red part of the rgb is on, red_active is true
		if (val2 > 0) {
			red_active = true;
		} else {
			red_active = false;
		}
		
		
		// reads the adc value from the green potentiometer, then converts it 
		// from a 0 to 4095 value to a 0 to 255 value, then sends that 
		// to the rgb led's green node
        ret = fread(&val, 4, 1, file);
		val2 = val/(4095/255);
		ret2 = fseek(file2, GREEN_VALUE_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file2);
		// if the green part of the rgb is on, red_active is true
		if (val2 > 0) {
			green_active = true;
		} else {
			green_active = false;
		}
		
		// reads the adc value from the blue potentiometer, then converts it 
		// from a 0 to 4095 value to a 0 to 255 value, then sends that 
		// to the rgb led's blue node
        ret = fread(&val, 4, 1, file);
		val2 = val/(4095/255);
		ret2 = fseek(file2, BLUE_VALUE_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file2);
		// if the blue part of the rgb is on, red_active is true
		if (val2 > 0) {
			blue_active = true;
		} else {
			blue_active = false;
		}
		
		// checks to see what colors are on; sends the corresponding 
		// servo pwm to the servo so the arm will be in the right spot
		// on the gauge chart
		if (red_active && green_active && blue_active) {
			val3 = 255;
		} else if (!red_active && green_active && blue_active) {
			val3 = 210;
		} else if (red_active && !green_active && blue_active) {
			val3 = 170;
		} else if (red_active && green_active && !blue_active) {
			val3 = 125;
		} else if (red_active && !green_active && !blue_active) {
			val3 = 80;
		} else if (!red_active && green_active && !blue_active) {
			val3 = 40;
		} else if (!red_active && !green_active && blue_active) {
			val3 = 00;
		} else if (!red_active && !green_active && !blue_active) {
			// do not change value;
		} 
		ret3 = fseek(file3, DUTY_CYCLE_OFFSET, SEEK_SET);
		ret3 = fwrite(&val3, 4, 1, file3);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file3);

		// Reset file positions to 0
        ret = fseek(file, 0, SEEK_SET);
		ret2 = fseek(file2, 0, SEEK_SET);
		ret3 = fseek(file3, 0, SEEK_SET);

        usleep(10);

    }
	
	// Reset file positions to 0
	ret = fseek(file, 0, SEEK_SET);
	ret2 = fseek(file2, 0, SEEK_SET);
	ret3 = fseek(file3, 0, SEEK_SET);
	// -------- closes the device drivers -------------
	fclose(file);
	fclose(file2);
	fclose(file3);
	// ------------------------------------------------
	return 0;
}