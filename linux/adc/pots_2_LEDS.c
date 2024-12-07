#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

// TODO: update these offsets if your address are different
#define CH0_OFFSET 0x0
#define CH1_OFFSET 0x4
#define CH2_OFFSET 0x8
#define PERIOD_OFFSET 0
#define RED_VALUE_OFFSET 12
#define GREEN_VALUE_OFFSET 4
#define BLUE_VALUE_OFFSET 8

static volatile int keepRunning = 1;


void intHandler(int dummy) {
    keepRunning = 0;
}

int main () {
	FILE *file;
	FILE *file2;
	size_t ret;	
	size_t ret2;
	uint32_t val;
	uint32_t val2;

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

	// Test reading the registers sequentially
	printf("\n************************************************\n");
	printf("   move potentiometer values for LED lightups \n");
	printf("************************************************\n\n");

    while(keepRunning) {
		val2 = 0xFF;
		ret2 = fseek(file2, PERIOD_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);

        ret = fread(&val, 4, 1, file);
		val2 = val/(4095/255);
		ret2 = fseek(file2, RED_VALUE_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file2);
		ret2 = fseek(file2, RED_VALUE_OFFSET, SEEK_SET);
		ret2 = fread(&val2, 4, 1, file2);
        //printf("CH0 = 0x%x\n", val);
		//printf("R value = 0x%x\n", val2);

        ret = fread(&val, 4, 1, file);
		val2 = val/(4095/255);
		ret2 = fseek(file2, GREEN_VALUE_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file2);
		ret2 = fseek(file2, GREEN_VALUE_OFFSET, SEEK_SET);
		ret2 = fread(&val2, 4, 1, file2);
        //printf("CH1 = 0x%x\n", val);
		//printf("G value = 0x%x\n", val2);

        ret = fread(&val, 4, 1, file);
		val2 = val/(4095/255);
		ret2 = fseek(file2, BLUE_VALUE_OFFSET, SEEK_SET);
		ret2 = fwrite(&val2, 4, 1, file2);
		// We need to "flush" so the OS finishes writing to the file before our code continues.
		fflush(file2);
		ret2 = fseek(file2, BLUE_VALUE_OFFSET, SEEK_SET);
		ret2 = fread(&val2, 4, 1, file2);
        //printf("CH2 = 0x%x\n", val);
		//printf("B value = 0x%x\n", val2);

        // Reset file position to 0
        ret = fseek(file, 0, SEEK_SET);
        //printf("fseek ret = %d\n", ret);
        //printf("errno =%s\n", strerror(errno));

        usleep(10);
    }


	/*
    printf("\n************************************\n*");
	printf("* write values\n");
	printf("************************************\n\n");
	// Turn on software-control mode
	val = 0x01;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	// We need to "flush" so the OS finishes writing to the file before our code continues.
	fflush(file);

	// Write some values to the LEDs
	printf("writing custom pattern to LEDs....\n");

    val = 0xF0;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);
    
    signal(SIGINT, intHandler);

    while(keepRunning) {

        val = 0x2A;
        ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
        ret = fwrite(&val, 4, 1, file);
        fflush(file); 

        usleep(75*1000);

        val = 0x55;
        ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
        ret = fwrite(&val, 4, 1, file);
        fflush(file); 

        usleep(75*1000);

    }

	sleep(1);

	// Turn on hardware-control mode
	printf("\nback to hardware-control mode....\n");
	val = 0x00;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	val = 0x07;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(3);

	// Speed up the base period!
	//val = 0x02;
    //ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	//ret = fwrite(&val, 4, 1, file);
	//fflush(file);

*/
	printf("\n************************************\n*");
	printf("* read new register values\n");
	printf("************************************\n\n");
	
	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	fclose(file);
	return 0;
}