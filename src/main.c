#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

static void init_gpio(void)
{
	rcc_periph_clock_enable(RCC_GPIOA);
	gpio_mode_setup(GPIOA, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO5);
}

int main(void)
{
	init_gpio();

	while (1) {
		gpio_toggle(GPIOA, GPIO5);
		
		for (int i = 0; i < 1500000; ++i)
			__asm__("nop");
	}
}
