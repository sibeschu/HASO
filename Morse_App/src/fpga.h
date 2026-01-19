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


/* RX & TX, PC to FPGA, FPGA to PC */
bool uart_tx_busy(void) 
{ 
    return ((UART_STATUS >> 3) & 0x01 ) != 0;
}

bool uart_rx_has_valid_data(void)
{
    return (UART_STATUS & 0x01) != 0;
}

void uart_putc(u8 letter) {
    while (uart_tx_busy()) {}
    UART_TX = (u32)letter;
}

u8 uart_getc(void) {
    return (u8)(UART_RX & 0xFF);
}

/* Loopback Tx und Loopback Rx */ 
bool has_new_symbol(void) {
    return ((GPI >> NEW_SYMBOL_BIT) & 1u) != 0;
}

bool is_tx_ready(void) {
    return ((GPI >> TX_READY_BIT) & 1u) != 0;
}

void pulse_start_tx(void) {
    GPO |= (1u << START_TX_BIT);
    for(int i = 0; i<=1000000; ++i) {}
    GPO &= ~(1u << START_TX_BIT);
}

void set_led_ascii(u8 letter) {
    GPO = ((GPO & ~0xFFu) | (u8)letter);
}

void send_led(u8 c) {
    while (!is_tx_ready()) {}
    set_led_ascii(c);
    pulse_start_tx();
}

u8 get_rx_ascii(void) {
    return (u8)(GPI & 0xFFu);
}