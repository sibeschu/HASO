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
#include "platform.h"
#include "xil_printf.h"

#define C_BASEADDR  0x80000000
#define UART_RX     (*(volatile u32 *)(C_BASEADDR + 0x0))
#define UART_TX     (*(volatile u32 *)(C_BASEADDR + 0x04))
#define UART_STATUS (*(volatile u32 *)(C_BASEADDR + 0x08))
#define GPI        (*(volatile u32 *)(C_BASEADDR + 0x20))
#define GPO        (*(volatile u32 *)(C_BASEADDR + 0x14))
#define NEW_SYMBOL_BIT 9 // GPI
#define TX_READY_BIT 10 // GPI
#define START_TX_BIT 9 // GPO
/* ASCII & RX_ASCII are the lowest 8 bit of GPO and GPI */

bool has_new_symbol(void) {
  return ((GPI >> NEW_SYMBOL_BIT) & 1u) != 0;
}

bool is_tx_ready(void) {
  return ((GPI >> TX_READY_BIT) & 1u) != 0;
}

void pulse_start_tx(void) {
  GPO |= (1u << START_TX_BIT);
  GPO &= ~(1u << START_TX_BIT);
}

void set_led_ascii(u8 letter) {
  GPO = (GPO & ~0xFFu) | (u8)letter;
}

void send_led(u8 c) {
  while (!is_tx_ready()) {}
  set_led_ascii(c);
  pulse_start_tx();
}

u8 get_rx_ascii(void) {
  return (u8)(GPI & 0xFFu);
}

bool uart_tx_busy() 
{ 
return (UART_STATUS & (1u << 3)) != 0;
}

bool uart_rx_has_valid_data()
{
  return (UART_STATUS & (1u << 0)) != 0;
}

void uart_putc(u8 letter) {
  while (uart_tx_busy()) {}
  UART_TX = (u8)letter;
}

u8 uart_getc(void) {
  while (!uart_rx_has_valid_data()) {}
  return (u8)(UART_RX & 0xFF);
}


int main()
{
    init_platform();
    
    print("Starting program..\n\r");

  while (1) {
    print("doing while loop");
    // when fpga gets data from loopback -> output to uart_tx
    if (has_new_symbol()) {
      uart_putc(get_rx_ascii());
    }

    // when microblaze receives data on rx from pc -> write to led
    if (uart_rx_has_valid_data()) {
        print("uart_rx has valid data");
        send_led(uart_getc());
            }

    cleanup_platform();
    return 0;
  }
}
