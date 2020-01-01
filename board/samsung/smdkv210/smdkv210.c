/*
 *  Copyright (C) 2008-2009 Samsung Electronics
 *  Minkyu Kang <mk7.kang@samsung.com>
 *  Kyungmin Park <kyungmin.park@samsung.com>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <common.h>
#include <asm/io.h>
#include <asm/arch/sromc.h>
#include <asm/arch/gpio.h>
#include <asm/arch/mmc.h>
#include <asm/arch/clock.h>
#include <netdev.h>
#include <spl.h>

DECLARE_GLOBAL_DATA_PTR;



/*
 * Miscellaneous platform dependent initialisations
 */
 
#ifdef CONFIG_DRIVER_DM9000
static void dm9000_pre_init(void)
{
	u32 smc_bw_conf, smc_bc_conf;

	/* gpio configuration GPK0CON */
	gpio_cfg_pin(S5PC100_GPIO_K00 + CONFIG_ENV_SROM_BANK, S5P_GPIO_FUNC(2));

	/* Ethernet needs bus width of 16 bits */
	smc_bw_conf = SMC_DATA16_WIDTH(CONFIG_ENV_SROM_BANK) | SMC_BYTE_ADDR_MODE(CONFIG_ENV_SROM_BANK) \
			| SMC_WAIT_ENABLE(CONFIG_ENV_SROM_BANK) | SMC_BYTE_ENABLE(CONFIG_ENV_SROM_BANK);
	
	smc_bc_conf = SMC_BC_TACS(0x0) | SMC_BC_TCOS(0x1) | SMC_BC_TACC(0x5)
			| SMC_BC_TCOH(0x1) | SMC_BC_TAH(0x4)
			| SMC_BC_TACP(0x6) | SMC_BC_PMC(0x0);

	/* Select and configure the SROMC bank */
	s5p_config_sromc(CONFIG_ENV_SROM_BANK, smc_bw_conf, smc_bc_conf);
}
#endif
#ifdef CONFIG_GENERIC_MMC

static int setup_hsmmc_gpio(bd_t *bis)
{
	int i, ret, ret_sd1 = 0, ret_sd2 = 0;
	/*
	 * MMC0 GPIO
	 * GPG0[0]	SD_0_CLK
	 * GPG0[1]	SD_0_CMD
	 * GPG0[2]	SD_0_CDn	-> Not used
	 * GPG0[3:6]	SD_0_DATA[0:3]
	 * GPG1[3:6]	SD_0_DATA[3:6]
	 */
	for (i = S5PC110_GPIO_G00; i < S5PC110_GPIO_G07; i++) {
		if (i == S5PC110_GPIO_G02)
			continue;
		/* GPG0[0:6] special function 2 */
		gpio_cfg_pin(i, 0x2);
		/* GPG0[0:6] pull disable */
		gpio_set_pull(i, S5P_GPIO_PULL_NONE);
		/* GPG0[0:6] drv 4x */
		gpio_set_drv(i, S5P_GPIO_DRV_4X);
	}

	for (i = S5PC110_GPIO_G13; i < S5PC110_GPIO_G17; i++) {
		/* GPG1[3:6] special function 3 */
		gpio_cfg_pin(i, 0x3);
		/* GPG0[0:6] pull disable */
		gpio_set_pull(i, S5P_GPIO_PULL_NONE);
		/* GPG1[3:6] drv 4x */
		gpio_set_drv(i, S5P_GPIO_DRV_4X);
	}
	ret = s5p_mmc_init(0, 8);
	if (ret)
		error("MMC: Failed to init MMC:0.\n");

	/*
	 * MMC2 -> SD card 1 (T_FLASH) 
	  * MMC2 GPIO
	  * GPG2[0]  SD_0_CLK
	  * GPG2[1]  SD_0_CMD
	  * GPG2[2]  SD_0_CDn
	  * GPG2[3:6]	 SD_0_DATA[0:3]
	 */
	for (i = S5PC110_GPIO_G20; i < S5PC110_GPIO_G27; i++) {
		/* GPG2[0:6] special function 2 */
		gpio_cfg_pin(i, 0x2);
		/* GPG2[0:6] pull disable */
		gpio_set_pull(i, S5P_GPIO_PULL_NONE);
		/* GPG2[0:6] drv 4x */
		gpio_set_drv(i, S5P_GPIO_DRV_4X);
	}
	ret_sd1 = s5p_mmc_init(2, 4);
	if (ret_sd1)
		error("MMC: Failed to init SD card (MMC:2).\n");

	/*
	 * MMC3 -> SD card 2 (T_FLASH) 
	  * MMC3 GPIO
	  * GPG3[0]  SD_0_CLK
	  * GPG3[1]  SD_0_CMD
	  * GPG3[2]  SD_0_CDn
	  * GPG3[3:6]	 SD_0_DATA[0:3]
	 */
	for (i = S5PC110_GPIO_G30; i < S5PC110_GPIO_G37; i++) {
		/* GPG2[0:6] special function 2 */
		gpio_cfg_pin(i, 0x2);
		/* GPG2[0:6] pull disable */
		gpio_set_pull(i, S5P_GPIO_PULL_NONE);
		/* GPG2[0:6] drv 4x */
		gpio_set_drv(i, S5P_GPIO_DRV_4X);
	}
	ret_sd2 = s5p_mmc_init(3, 4);
	if (ret_sd2)
		error("MMC: Failed to init SD card (MMC:3).\n");


	return ret & ret_sd1 & ret_sd2;

}

int board_mmc_init(bd_t *bis)
{
	return setup_hsmmc_gpio(bis);
}

#endif

int board_init(void)
{
#ifdef CONFIG_DRIVER_DM9000
	dm9000_pre_init();
#endif
	gd->bd->bi_arch_number = MACH_TYPE;
	gd->bd->bi_boot_params = PHYS_SDRAM_1 + 0x100;

	return 0;
}

int dram_init(void)
{
	gd->ram_size = get_ram_size((long *)PHYS_SDRAM_1, PHYS_SDRAM_1_SIZE);

	return 0;
}

void dram_init_banksize(void)
{
	gd->bd->bi_dram[0].start = PHYS_SDRAM_1;
	gd->bd->bi_dram[0].size = PHYS_SDRAM_1_SIZE;
}

#ifdef CONFIG_DISPLAY_BOARDINFO
int checkboard(void)
{
	printf("Board:\tSMDKV210\n");
	return 0;
}
#endif

int board_eth_init(bd_t *c)
{
	int rc = 0;
#ifdef CONFIG_DRIVER_DM9000
	rc = dm9000_initialize(c);
#endif

	return rc;
}





#ifdef CONFIG_SPL_BUILD
void copy_bl2_to_ram(void)
{
/*
** ch:  通道
** sb:  起始块
** bs:  块大小
** dst: 目的地
** i: 	是否初始化
*/
#define CopySDMMCtoMem(ch, sb, bs, dst, i) \
	(((unsigned char(*)(int, unsigned int, unsigned short, unsigned int*, unsigned char))\
	(*((unsigned int *)0xD0037F98)))(ch, sb, bs, dst, i))
	
	unsigned int V210_SDMMC_BASE = *(volatile unsigned int *)(0xD0037488);	// V210_SDMMC_BASE
	unsigned char ch = 0;
	void (*BL2)(void);
	
	/* 参考S5PV210手册7.9.1 SD/MMC REGISTER MAP */
	if (V210_SDMMC_BASE == 0xEB000000)		// 通道0
		ch = 0;
	else if (V210_SDMMC_BASE == 0xEB200000)	// 通道2
		ch = 2;

	CopySDMMCtoMem(ch, 32, 500, (unsigned int *)CONFIG_SYS_SDRAM_BASE, 0);
	BL2 = (void *)CONFIG_SYS_SDRAM_BASE;
	(*BL2)();
}

#ifdef CONFIG_SPL_BOARD_INIT
void spl_board_init(void)
{
	s5p_set_cpu_id();
	preloader_console_init();
}
#endif
u32 spl_boot_device(void)
{

	return BOOT_DEVICE_MMC1;
}

#ifdef CONFIG_SPL_DISPLAY_PRINT
void spl_display_print(void)
{
	puts("SMDKV210 SPL is successful!\n");
}
#endif
#ifdef CONFIG_SPL_MMC_SUPPORT
u32 spl_boot_mode(void)
{
	return MMCSD_MODE_RAW;
}
#endif
#endif
