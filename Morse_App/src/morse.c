#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "fpga.h"

int main()
{
  init_platform();

  print("Starting program..\n\r");

  while (1) {
    // when fpga gets data from loopback -> output to uart_tx
    if (has_new_symbol()) {
      for(int i = 0; i<10000000; ++i) {}
      uart_write(get_rx_ascii());
    }

    // when microblaze receives data on rx from pc -> write to led
    if (uart_rx_has_valid_data()) {
      xil_printf("uart_rx has valid data: %c\r\n", uart_read());
      send_ascii(uart_read());
    }
  }
  cleanup_platform();

  return 0;
}