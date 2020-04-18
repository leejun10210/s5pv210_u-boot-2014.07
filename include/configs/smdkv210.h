/*
 * (C) Copyright 2009 Samsung Electronics
 * Minkyu Kang <mk7.kang@samsung.com>
 * HeungJun Kim <riverful.kim@samsung.com>
 * Inki Dae <inki.dae@samsung.com>
 *
 * Configuation settings for the SAMSUNG SMDKC100 board.
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#ifndef __CONFIG_H
#define __CONFIG_H


#define CONFIG_SPL
#ifdef CONFIG_SPL
#define CONFIG_SPL_FRAMEWORK
#define CONFIG_SPL_TEXT_BASE		0xD0020010
#define CONFIG_SPL_MAX_SIZE				(16*1024)
#define CONFIG_SPL_STACK				0xD0037D80
#define CONFIG_SPL_LIBCOMMON_SUPPORT
#define CONFIG_SPL_LIBGENERIC_SUPPORT
#define CONFIG_SPL_SERIAL_SUPPORT


#define CONFIG_SPL_BOARD_INIT
#define CONFIG_SPL_DISPLAY_PRINT

/* spl mmc support*/
#ifdef CONFIG_mdkMMC
#define CONFIG_SPL_MMC_SUPPORT
#define CONFIG_GENERIC_MMC
#define CONFIG_SYS_MMCSD_RAW_MODE_U_BOOT_SECTOR	0x300
#endif
#endif /* CONFIG_SPL */






/*
 * High Level Configuration Options
 * (easy to change)
 */
#define CONFIG_SAMSUNG		1	/* in a SAMSUNG core */
#define CONFIG_S5P		1	/* which is in a S5P Family */
#define CONFIG_S5PC110		1	/* which is in a S5PC110 */
#define CONFIG_SMDKV210


#include <asm/arch/cpu.h>		/* get chip and board defs */

#define CONFIG_ARCH_CPU_INIT

#define CONFIG_DISPLAY_CPUINFO
#define CONFIG_DISPLAY_BOARDINFO

/* input clock of PLL: SMDKC100 has 24MHz input clock */
#define CONFIG_SYS_CLK_FREQ		24000000

/* DRAM Base */
#define CONFIG_SYS_SDRAM_BASE		0x30000000

/* Text Base */
#define CONFIG_SYS_TEXT_BASE		0x30000000   

#define CONFIG_SETUP_MEMORY_TAGS
#define CONFIG_CMDLINE_TAG
#define CONFIG_INITRD_TAG
#define CONFIG_CMDLINE_EDITING

/*
 * Size of malloc() pool
 * 1MB = 0x100000, 0x100000 = 1024 * 1024
 */
#define CONFIG_SYS_MALLOC_LEN		(CONFIG_ENV_SIZE + (1 << 20))
/*
 * select serial console configuration
 */
#define CONFIG_SERIAL0			1	/* use SERIAL 0 on SMDKC100 */

/* PWM */
#define CONFIG_PWM			1

/* allow to overwrite serial and ethaddr */
#define CONFIG_ENV_OVERWRITE
#define CONFIG_BAUDRATE			115200

/* MMC */
#define CONFIG_MMC
#define CONFIG_GENERIC_MMC
#define CONFIG_SDHCI
#define CONFIG_S5P_SDHCI

/*
 * Architecture magic and machine type
 */

#define MACH_TYPE		MACH_TYPE_SMDKV210


/*#define CONFIG_BOOTM_LINUX*/



/***********************************************************
 * Command definition
 ***********************************************************/
#include <config_cmd_default.h>

#undef CONFIG_CMD_FLASH
#undef CONFIG_CMD_IMLS
#undef CONFIG_CMD_NAND

#define CONFIG_CMD_MMC
#define CONFIG_CMD_FAT
#define CONFIG_CMD_EXT4
#define CONFIG_CMD_EXT2

#define CONFIG_CMD_CACHE
#define CONFIG_CMD_REGINFO
/*#define CONFIG_CMD_ONENAND*/
#define CONFIG_CMD_ELF
#define CONFIG_CMD_FAT
#define CONFIG_CMD_MTDPARTS
#define CONFIG_CMD_BOOTZ
#define CONFIG_BOOTDELAY	3

#define CONFIG_ZERO_BOOTDELAY_CHECK

#define CONFIG_MTD_DEVICE
#define CONFIG_MTD_PARTITIONS

#define MTDIDS_DEFAULT		"onenand0=s3c-onenand"
#define MTDPARTS_DEFAULT	"mtdparts=s3c-onenand:256k(bootloader)"\
				",128k@0x40000(params)"\
				",3m@0x60000(kernel)"\
				",16m@0x360000(test)"\
				",-(UBI)"

#define NORMAL_MTDPARTS_DEFAULT MTDPARTS_DEFAULT

#define CONFIG_RAMDISK_BOOT	"root=/dev/ram0 rw rootfstype=ext2" \
				" console=ttySAC0,115200n8" \
				" mem=128M"

#define CONFIG_COMMON_BOOT	"console=ttySAC0,115200n8" \
				" mem=128M " \
				" " MTDPARTS_DEFAULT

#define CONFIG_BOOTARGS	"root=/dev/mtdblock5 ubi.mtd=4" \
			" rootfstype=cramfs " CONFIG_COMMON_BOOT

#define CONFIG_UPDATEB	"updateb=onenand erase 0x0 0x40000;" \
			" onenand write 0x32008000 0x0 0x40000\0"

#define CONFIG_ENV_OVERWRITE
#define CONFIG_EXTRA_ENV_SETTINGS					\
	"loadaddr=0x30008000\0" \
	"image=zImage\0" \
	"baudrate=115200n8\0" \
	"console=ttySAC0\0" \
	"ipaddr=192.168.0.110\0" \
	"gatewayip=192.168.0.1\0" \
	"netmask=255.255.255.0\0" \
	"serverip=192.168.0.101\0" \
	"boot_fdt=no\0" \
	"mmcdev=1\0" \
	"mmcpart=1\0" \
	"mmcroot=/dev/mmcblk1p2 rootwait rw\0" \
	"mmcargs=setenv bootargs console=${console},${baudrate} " \
		"root=${mmcroot}\0" \
	"loadimage=fatload mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}\0" \
	"loadfdt=fatload mmc ${mmcdev}:${mmcpart} ${fdt_addr} ${fdt_file}\0" \
	"mmcboot=echo Booting from mmc ...; " \
		"run mmcargs; " \
		"if test ${boot_fdt} = yes || test ${boot_fdt} = try; then " \
			"if run loadfdt; then " \
				"bootz ${loadaddr} - ${fdt_addr}; " \
			"else " \
				"if test ${boot_fdt} = try; then " \
					"bootz; " \
				"else " \
					"echo WARN: Cannot load the DT; " \
				"fi; " \
			"fi; " \
		"else " \
			"bootz ${loadaddr}; " \
		"fi;\0" \
	"rootpath=/home/lincor/s5pv210/rootfs\0" \
	"nfsroot=${serverip}:${rootpath}\0" \
	"netdev=eth0\0" \
	"nfsargs=setenv bootargs console=${console},${baudrate} " \
		"root=/dev/nfs rootwait rw ${nfsroot} " \
		"ip=${ipaddr}:${serverip}:${gatewayip}:${netmask}:${hostname}:${netdev}:off \0" \
	"nfsboot=echo Booting from net ...; " \
			"run nfsargs; " \
			"tftp ${loadaddr} ${image}; " \
			"if test ${boot_fdt} = yes || test ${boot_fdt} = try; then " \
				"if tftp ${fdt_addr} ${fdt_file}; then " \
					"bootz ${loadaddr} - ${fdt_addr}; " \
				"else " \
					"if test ${boot_fdt} = try; then " \
						"bootz; " \
					"else " \
						"echo WARN: Cannot load the DT; " \
					"fi; " \
				"fi; " \
			"else " \
				"bootz ${loadaddr}; " \
			"fi;\0"

#define CONFIG_BOOTCOMMAND \
	   "mmc dev ${mmcdev};" \
	   "mmc dev ${mmcdev}; if mmc rescan; then " \
		   "if run loadbootscript; then " \
			   "run bootscript; " \
		   "else " \
			   "if run loadimage; then " \
				   "run mmcboot; " \
			   "else run nfsboot; " \
			   "fi; " \
		   "fi; " \
	   "else run nfsboot; fi"


/*
 * Miscellaneous configurable options
 */
#define CONFIG_SYS_LONGHELP		/* undef to save memory */
#define CONFIG_SYS_HUSH_PARSER		/* use "hush" command parser	*/
#define CONFIG_SYS_PROMPT		"SMDKV210 # "
#define CONFIG_SYS_CBSIZE	256	/* Console I/O Buffer Size */
#define CONFIG_SYS_PBSIZE	384	/* Print Buffer Size */
#define CONFIG_SYS_MAXARGS	16	/* max number of command args */
/* Boot Argument Buffer Size */
#define CONFIG_SYS_BARGSIZE		CONFIG_SYS_CBSIZE
/* memtest works on */

#define CONFIG_SYS_MEMTEST_START	CONFIG_SYS_SDRAM_BASE
#define CONFIG_SYS_MEMTEST_END		(CONFIG_SYS_SDRAM_BASE + 0x5e00000)
#define CONFIG_SYS_LOAD_ADDR		CONFIG_SYS_SDRAM_BASE

/* SMDKC100 has 1 banks of DRAM, we use only one in U-Boot */
#define CONFIG_NR_DRAM_BANKS	1
#define PHYS_SDRAM_1		CONFIG_SYS_SDRAM_BASE	/* SDRAM Bank #1 */
#define PHYS_SDRAM_1_SIZE	(512 << 20)	/* 0x8000000, 512 MB Bank #1 */

#define CONFIG_SYS_MONITOR_BASE	0x00000000

/*-----------------------------------------------------------------------
 * FLASH and environment organization
 */
#define CONFIG_SYS_NO_FLASH		1

#define CONFIG_SYS_MONITOR_LEN		(256 << 10)	/* 256 KiB */
#define CONFIG_IDENT_STRING		" for SMDKV210"

#if !defined(CONFIG_NAND_SPL) && (CONFIG_SYS_TEXT_BASE >= 0xc0000000)
#define CONFIG_ENABLE_MMU
#endif

#ifdef CONFIG_ENABLE_MMU
#define CONFIG_SYS_MAPPED_RAM_BASE	0xc0000000
#else
#define CONFIG_SYS_MAPPED_RAM_BASE	CONFIG_SYS_SDRAM_BASE
#endif

/*-----------------------------------------------------------------------
 * Boot configuration
 */
/* FLASH and environment organization */
#define CONFIG_MMC_DEFAULT_DEV	0
#define CONFIG_ENV_IS_IN_MMC	
#define CONFIG_SYS_MMC_ENV_DEV		CONFIG_MMC_DEFAULT_DEV
/* #define CONFIG_ENV_IS_NOWHERE	1 */
#define CONFIG_ENV_SIZE			(0x4000)	/* 128KiB, 0x20000 */
#define CONFIG_ENV_OFFSET		(17*512)	/* 256KiB, 0x40000 */
#define CONFIG_ENV_OVERWRITE

/*
#define CONFIG_USE_ONENAND_BOARD_INIT
#define CONFIG_SAMSUNG_ONENAND		1
#define CONFIG_SYS_ONENAND_BASE		0xE7100000
*/
#define CONFIG_DOS_PARTITION		1

#define CONFIG_SYS_INIT_SP_ADDR	0x50000000 /*(CONFIG_SYS_LOAD_ADDR - 0x1000000)*/


/*
 * Ethernet Contoller driver
 */
#ifdef CONFIG_CMD_NET
#define CONFIG_DRIVER_DM9000
#ifdef CONFIG_DRIVER_DM9000
#define CONFIG_DM9000_BASE		(0x88000300)
#define DM9000_IO			(CONFIG_DM9000_BASE)
#define DM9000_16BIT_DATA
#if defined(DM9000_16BIT_DATA)
#define DM9000_DATA			(CONFIG_DM9000_BASE+4)
#else
#define DM9000_DATA			(CONFIG_DM9000_BASE+1)
#endif /* DM9000_16BIT_DATA */
#endif /* CONFIG_DRIVER_DM9000 */

#define CONFIG_ENV_SROM_BANK   1       /* Select SROM Bank-3 for Ethernet*/
#endif /* CONFIG_CMD_NET */

#endif	/* __CONFIG_H */
