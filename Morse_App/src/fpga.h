/* 
a & 0x01 liest bit 0
a & 0xFF liest untere 8 bit
a | (1u << 9); setzt bit 9 auf 1 
~a bitweise NOT invertiert alle bits
a ^ b bits togglen mit XOR
1u << n links shift verschiebt eine 1 um n stellen nach links
a >> n schiebt nach rechts
(GPI >> 9) & 1u liest bit 9

poll rx_ascii -> output to uart_tx
poll uart_rx -> send_led 
*/ 

#include <stdio.h>
#include "stdbool.h"
#include "sleep.h"
#include "xil_types.h"

#define C_BASEADDR  0x80000000
#define UART_RX     (*(volatile u32 *)(C_BASEADDR + 0x0))
#define UART_TX     (*(volatile u32 *)(C_BASEADDR + 0x04))
#define UART_STATUS (*(volatile u32 *)(C_BASEADDR + 0x08))
#define GPI        (*(volatile u32 *)(C_BASEADDR + 0x20))
#define GPO        (*(volatile u32 *)(C_BASEADDR + 0x14))
#define NEW_SYMBOL_BIT 8 // GPI
#define TX_READY_BIT 9 // GPI
#define START_TX_BIT 8 // GPO
/* ASCII & RX_ASCII are the lowest 8 bit of GPO and GPI */


/* RX & TX, PC to FPGA, FPGA to PC */
bool uart_tx_busy(void) 
{ 
    return ((UART_STATUS >> 3) & 0x01) != 0;
}

bool uart_rx_has_valid_data(void)
{
    return (UART_STATUS & 0x01) != 0;
}

void uart_write(u8 c) {
    while (uart_tx_busy()) {}
    UART_TX = (u32)c;
}

u8 uart_read(void) {
    return (u8)(UART_RX & 0xFF);
}

/* Loopback Tx und Loopback Rx */ 
bool has_new_symbol(void) {
    return ((GPI >> NEW_SYMBOL_BIT) & 0x01) != 0;
}

bool is_tx_ready(void) {
    return ((GPI >> TX_READY_BIT) & 0x01) != 0;
}

// void pulse_start_tx(void) {
//     GPO |= (0x01 << START_TX_BIT);
//     for(int i = 0; i<=1000000; ++i) {} //usleep(5);
//     GPO &= ~(0x01 << START_TX_BIT);
// }

// void set_led_ascii(u8 c) {
//     GPO = ((GPO & ~0xFFu) | (u8)c);
// }

void send_ascii(u8 c) {
    while (!is_tx_ready()) {}

    // set ascii register
    GPO = ((GPO & ~0xFFu) | (u8)c);

    // pulse start_tx
    GPO |= (0x01 << START_TX_BIT);
    usleep(5);
    GPO &= ~(0x01 << START_TX_BIT);
}

u8 get_rx_ascii(void) {
    return (u8)(GPI & 0xFFu);
}