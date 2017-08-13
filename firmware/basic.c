#include <stdio.h>
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"

uint32_t readLogData(void);
uint32_t isReadable(void);
uint32_t writeReg(uint32_t reg_num, uint32_t data);
uint32_t readReg(uint32_t reg_num);
uint8_t ulpiWritePHYReg(uint8_t addr, uint8_t data);
uint8_t  ulpiReadPHYReg(uint8_t addr);
void printFunctionControlStatus(void);
void printOTG(void);
void testScratchPadRegisters(void);
void handlereset(void);


#define USB_DEVICE_BASEADDR XPAR_USB_DEVICE_0_S_AXI_BASEADDR

int main()
{
    init_platform();

    print("Hello World\n\r");

    uint8_t funct_cntrl = 0;
    uint32_t log_data= 0;

    xil_printf("Vendor ID Low : 0x%02X\r\n", ulpiReadPHYReg(0x00));
    xil_printf("Vendor ID High: 0x%02X\r\n", ulpiReadPHYReg(0x01));

    funct_cntrl = ulpiReadPHYReg(0x04);
    xil_printf("Function Control: 0x%02X\r\n", funct_cntrl);
    print("ScratchPad Register Tests...\r\n");
    testScratchPadRegisters();
    print("\n\rFuncion Control Status\n\r");
    printFunctionControlStatus();

    printOTG();


	do {
		log_data= readLogData();
		if	(log_data & (1<<31))
			xil_printf("[RXCMD]: 0x%X\r\n", log_data & 0xff);
		else
			xil_printf("[USB]  : 0x%X\r\n", log_data & 0xff);
	}while(isReadable());


	handlereset();



    while(1){
    	if (isReadable()){
    		log_data= readLogData();
    		if	(log_data & (1<<31))
    			xil_printf("[RXCMD]: 0x%X\r\n", log_data & 0xff);
    		else
    			xil_printf("[USB]  : 0x%X\r\n", log_data & 0xff);
    	}
    }

    cleanup_platform();
    return 0;
}

uint32_t readLogData(void){
	return Xil_In32((USB_DEVICE_BASEADDR) + (0));
}

uint32_t isReadable(void){
	return Xil_In32((USB_DEVICE_BASEADDR) + (4));
}

uint32_t writeReg(uint32_t reg_num, uint32_t data){
	reg_num = reg_num << 2;
	Xil_Out32((USB_DEVICE_BASEADDR) + (reg_num), data);
	return 0;
}

uint32_t readReg(uint32_t reg_num){
	return Xil_In32((USB_DEVICE_BASEADDR) + (reg_num << 2));
}

uint8_t ulpiReadPHYReg(uint8_t addr){
	uint32_t status = 0;
	writeReg(6, addr);
	writeReg(8, 0); // clear trigger
	writeReg(8, 1);

	do{
		status = readReg(9);
	} while((status & 0x3) != 0x2);

	return readReg(7) & 0xff;
}

uint8_t ulpiWritePHYReg(uint8_t addr, uint8_t data){
	uint32_t status = 0;
	writeReg(2, addr);
	writeReg(3, data);
	writeReg(4, 0); // clear trigger
	writeReg(4, 1);

	do{
		status = readReg(5);
	} while((status & 0x3) != 0x2);

	return 0;
}

void printFunctionControlStatus(void){
	uint8_t funct_cntrl = 0;
	funct_cntrl = ulpiReadPHYReg(0x04);

	print("XcvrSelect: ");
	switch(funct_cntrl & 0b11){
		case 0: print("High-Speed Transceiver\n\r"); break;
		case 1: print("Full-Speed Transceiver\n\r"); break;\
		case 2: print("Low-Speed Transceiver\n\r"); break;
		case 3: print("Full Speed Transceiver for LS packets\n\r"); break;
	}

	xil_printf("TermSelect: %d\r\n", ((funct_cntrl & 0b100) >> 2));

	print("OpMode: ");
	switch((funct_cntrl & 0b11000) >> 3){
		case 0: print("Normal Operation\n\r"); break;
		case 1: print("Non-Driving\n\r"); break;\
		case 2: print("Disable bit-stuff and NRZI encoding\n\r"); break;
		case 3: print("Reserved\n\r"); break;
	}

	xil_printf("Reset: %d\r\n", ((funct_cntrl & 0b100000) >> 5));
	xil_printf("Suspend: %d\r\n", ((funct_cntrl & 0b1000000) >> 6));
	xil_printf("Reserved: %d\r\n", ((funct_cntrl & 0b10000000) >> 7));

}

void printOTG(void){
	uint8_t otg = 0;
	otg = ulpiReadPHYReg(0x0A);
	xil_printf("OTG: 0x%02X\r\n", otg);
	xil_printf("DpPulldown: 0x%02X\r\n", (otg & 0b10) >> 1);
	xil_printf("DmPulldown: 0x%02X\r\n", (otg & 0b100) >> 2);
}

void testScratchPadRegisters(void){
	xil_printf("Reading 0x16 : 0x%02X\r\n", ulpiReadPHYReg(0x16));
	xil_printf("Writing 0x81 to 0x16...\r\n");
	ulpiWritePHYReg(0x16, 0xff);
	xil_printf("Reading 0x16 : 0x%02X\r\n", ulpiReadPHYReg(0x16));
	xil_printf("Reading 0x17 : 0x%02X\r\n", ulpiReadPHYReg(0x17));
	xil_printf("Reading 0x18 : 0x%02X\r\n", ulpiReadPHYReg(0x18));


	xil_printf("Writing 0xff to 0x17...\r\n");
	ulpiWritePHYReg(0x17, 0xff);
	xil_printf("Reading 0x16 : 0x%02X\r\n", ulpiReadPHYReg(0x16));
	xil_printf("Reading 0x17 : 0x%02X\r\n", ulpiReadPHYReg(0x17));
	xil_printf("Reading 0x18 : 0x%02X\r\n", ulpiReadPHYReg(0x18));


	xil_printf("Writing 0xA5 to 0x18...\r\n");
	ulpiWritePHYReg(0x18, 0x5A);
	xil_printf("Reading 0x16 : 0x%02X\r\n", ulpiReadPHYReg(0x16));
	xil_printf("Reading 0x17 : 0x%02X\r\n", ulpiReadPHYReg(0x17));
	xil_printf("Reading 0x18 : 0x%02X\r\n", ulpiReadPHYReg(0x18));


}

void handlereset(void){
	// Disable Pulldowns. Move from Host to peripheral mode
	ulpiWritePHYReg(0xA, 0x00);
	ulpiWritePHYReg(0x5, 0x4);
	print("\n\rFuncion Control Status\n\r");
	printFunctionControlStatus();
	printOTG();
}
