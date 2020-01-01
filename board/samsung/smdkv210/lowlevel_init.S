/*
 * Copyright (C) 2009 Samsung Electronics
 * Kyungmin Park <kyungmin.park@samsung.com>
 * Minkyu Kang <mk7.kang@samsung.com>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <config.h>
#include <version.h>
#include <asm/arch/cpu.h>
#include <asm/arch/power.h>
#include <asm/arch/s5pv210/syscfg.inc>

/*
 * Register usages:
 * S5PV210 and S5PC110 is compatible
 * r5 has zero always
 */

	.globl lowlevel_init
lowlevel_init:
	mov	r9, lr

	/* r5 has always zero */
	mov	r5, #0

	ldr	r8, =S5PC110_GPIO_BASE

	/* Disable Watchdog */
	ldr	r0, =S5PC110_WATCHDOG_BASE		@0xE2700000
	orr	r0, r0, #0x0
	str	r5, [r0]

	/* setting SRAM */
	ldr	r0, =S5PC110_SROMC_BASE
	ldr	r1, =0x9
	str	r1, [r0]

	/* S5PC100 has 3 groups of interrupt sources */
	ldr	r0, =S5PC110_VIC0_BASE			@0xE2000000
	ldr	r1, =S5PC110_VIC1_BASE			@0xE2000000
	ldr	r2, =S5PC110_VIC2_BASE			@0xE2000000

	/* Disable all interrupts (VIC0, VIC1 and VIC2) */
	mvn	r3, #0x0
	str	r3, [r0, #0x14]				@INTENCLEAR
	str	r3, [r1, #0x14]				@INTENCLEAR
	str	r3, [r2, #0x14]				@INTENCLEAR

	/* Set all interrupts as IRQ */
	str	r5, [r0, #0xc]				@INTSELECT
	str	r5, [r1, #0xc]				@INTSELECT
	str	r5, [r2, #0xc]				@INTSELECT

	/* Pending Interrupt Clear */
	str	r5, [r0, #0xf00]			@INTADDRESS
	str	r5, [r1, #0xf00]			@INTADDRESS
	str	r5, [r2, #0xf00]			@INTADDRESS

#ifdef CONFIG_SPL_BUILD

	/* for CLOCK */
	bl system_clock_init

	/* for CLOCK */
	bl mem_ctrl_init
#endif
	/* for DDR */
	bl uart_asm_init

	ldr	r0, =0xE2900820
	ldr	r1, =0x4F4F4F4F
	str	r1, [r0]


	/* for TZPC */
	bl tzpc_asm_init

	bl ps_hold
	ldr	r0, =0xE2900820
	ldr	r1, =0x4B4B4B4B
	str	r1, [r0]

1:
	mov	lr, r9
	mov	pc, lr

/*
 * system_clock_init: Initialize core clock and bus clock.
 * void system_clock_init(void)
 */
system_clock_init:
	ldr	r0, =S5PC110_CLOCK_BASE		@ 0xE0100000
		
	mov r1, #0xe00
	orr r1, r1, #0x10
	str r1, [r0, #0x00]
	str r1, [r0, #0x04]
	str r1, [r0, #0x08]
	str r1, [r0, #0x0c]
	
	ldr r1, =CLK_DIV0_VAL
	str r1, [r0, #0x300]
	
	ldr r1, =CLK_DIV1_VAL
	str r1, [r0, #0x304]
	
	ldr r1, =CLK_DIV2_VAL
	str r1, [r0, #0x308]
	
	ldr r1, =APLL_VAL
	str r1, [r0, #0x0100]
	
	ldr r1, =MPLL_VAL
	str r1, [r0, #0x0108]
	
	ldr r1, =EPLL_VAL
	str r1, [r0, #0x0110]
	
	ldr r1, =VPLL_VAL
	str r1, [r0, #0x0120]



	/* wait at least 200us to stablize all clock */
	mov	r2, #0x10000
1:	subs	r2, r2, #1
	bne	1b

	mov	pc, lr

/*
 * uart_asm_init: Initialize UART's pins
 */
uart_asm_init:
	mov	r0, r8
	ldr	r1, =0x22222222
	str	r1, [r0, #0x0]			@ GPA0_CON
	ldr	r1, =0x00022222
	str	r1, [r0, #0x20]			@ GPA1_CON

	mov	pc, lr

/*
 * tzpc_asm_init: Initialize TZPC
 */
tzpc_asm_init:
	ldr	r0, =S5PC110_TZPC0
	mov	r1, #0x0
	str	r1, [r0]
	mov	r1, #0xff
	str r1, [r0, #0x804]
	str r1, [r0, #0x810]
	str r1, [r0, #0x81C]
	
	ldr r0, =S5PC110_TZPC1
	str r1, [r0, #0x804]
	str r1, [r0, #0x810]
	str r1, [r0, #0x81C]
	
	ldr r0, =S5PC110_TZPC2
	str r1, [r0, #0x804]
	str r1, [r0, #0x810]
	str r1, [r0, #0x81C]
	str r1, [r0, #0x828]
	
	ldr r0, =S5PC110_TZPC3
	str r1, [r0, #0x804]
	str r1, [r0, #0x810]
	str r1, [r0, #0x81C]


	mov	pc, lr

ps_hold:
	/* ps_hold pin (gph0_0) set to high 电源上锁*/
	ldr	r0, =0xe010e81c
	ldr	r1, [r0]
	orr	r1, r1, #0x300
	orr	r1, r1, #0x1
	str	r1, [r0]	

	mov	pc, lr

led_light:

	/* 设置GPJ2CON的bit[0:15]，配置GPJ2_0/1/2/3引脚为输出功能*/
	ldr r1, =0xE0200240
	ldr r0, =0x00001111
	str r0, [r1]

	mov r2, #0x1000

	/* 设置GPJ2DAT的bit[0:3]，使GPJ2_0/1/2/3引脚输出低电平，LED亮*/
	ldr r1, =0xE0200244
	mov r0, #0
	str r0, [r1]

	mov	pc, lr	


/*
 * memory controller initial.
 */
mem_ctrl_init:
	ldr r0, =0xf1e00000
	ldr r1, =0x0
	str r1, [r0, #0x0]

	/*
	 * dmc0 drive strength (setting 2x)
	 */
	ldr r0, =0xe0200000

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x3cc]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x3ec]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x40c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x42c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x44c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x46c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x48c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x4ac]

	ldr r1, =0x00002aaa
	str r1, [r0, #0x4cc]

	/*
	 * dmc1 drive strength (setting 2x)
	 */
	ldr r0, =0xe0200000

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x4ec]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x50c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x52c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x54c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x56C]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x58c]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x5ac]

	ldr r1, =0x0000aaaa
	str r1, [r0, #0x5cc]

	ldr r1, =0x00002aaa
	str r1, [r0, #0x5ec]

	/*
	 * dmc0 initialization at single type
	 */
	ldr r0, =0xf0000000

	ldr r1, =0x00101000 			/* phycontrol0 dll parameter setting */
	str r1, [r0, #0x18]

	ldr r1, =0x00000086 			/* phycontrol1 dll parameter setting */
	str r1, [r0, #0x1c]

	ldr r1, =0x00101002 			/* phycontrol0 dll on */
	str r1, [r0, #0x18]

	ldr r1, =0x00101003 			/* phycontrol0 dll start */
	str r1, [r0, #0x18]

dmc0_lock:
	ldr r1, [r0, #0x40] 			/* load phystatus register value */
	and r2, r1, #0x7
	cmp r2, #0x7					/* loop until dll is locked */
	bne dmc0_lock

	and r1, #0x3fc0
	mov r2, r1, LSL #18
	orr r2, r2, #0x100000
	orr r2 ,r2, #0x1000

	orr r1, r2, #0x3				/* force value locking */
	str r1, [r0, #0x18]

	/* setting ddr2 */
	ldr r1, =0x0FFF2010 			/* concontrol auto refresh off */
	str r1, [r0, #0x00]

	ldr r1, =0x00202430 			/* memcontrol bl=4, 2 chip, ddr2 type, dynamic self refresh, force precharge, dynamic power down off */
	str r1, [r0, #0x04]

	ldr r1, =DMC0_MEMCONFIG_0		/* memconfig0 256MB config, 8 banks, mapping method[12:15] 0:linear, 1:linterleaved, 2:mixed */
	str r1, [r0, #0x08]

	ldr r1, =DMC0_MEMCONFIG_1		/* memconfig1 */
	str r1, [r0, #0x0c]

	ldr r1, =0xFF000000 			/* prech config */
	str r1, [r0, #0x14]

	ldr r1, =DMC0_TIMINGA_REF		/* timing aref */
	str r1, [r0, #0x30]

	ldr r1, =DMC0_TIMING_ROW		/* timingRow */
	str r1, [r0, #0x34]

	ldr r1, =DMC0_TIMING_DATA		/* timing data CL=3 */
	str r1, [r0, #0x38]

	ldr r1, =DMC0_TIMING_PWR		/* timing power */
	str r1, [r0, #0x3c]

	ldr r1, =0x07000000 			/* chip0 deselect */
	str r1, [r0, #0x10]

	ldr r1, =0x01000000 			/* chip0 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x00020000 			/* chip0 emrs2 */
	str r1, [r0, #0x10]

	ldr r1, =0x00030000 			/* chip0 emrs3 */
	str r1, [r0, #0x10]

	ldr r1, =0x00010400 			/* chip0 emrs1 (mem dll on, dqs disable) */
	str r1, [r0, #0x10]

	ldr r1, =0x00000542 			/* chip0 mrs (mem dll reset) cl=4, bl=4 */
	str r1, [r0, #0x10]

	ldr r1, =0x01000000 			/* chip0 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x05000000 			/* chip0 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x05000000 			/* chip0 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x00000442 			/* chip0 mrs (mem dll unreset) */
	str r1, [r0, #0x10]

	ldr r1, =0x00010780 			/* chip0 emrs1 (ocd default) */
	str r1, [r0, #0x10]

	ldr r1, =0x00010400 			/* chip0 emrs1 (ocd exit) */
	str r1, [r0, #0x10]

	ldr r1, =0x07100000 			/* chip1 deselect */
	str r1, [r0, #0x10]

	ldr r1, =0x01100000 			/* chip1 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x00120000 			/* chip1 emrs2 */
	str r1, [r0, #0x10]

	ldr r1, =0x00130000 			/* chip1 emrs3 */
	str r1, [r0, #0x10]

	ldr r1, =0x00110400 			/* chip1 emrs1 (mem dll on, dqs disable) */
	str r1, [r0, #0x10]

	ldr r1, =0x00100542 			/* chip1 mrs (mem dll reset) cl=4, bl=4 */
	str r1, [r0, #0x10]

	ldr r1, =0x01100000 			/* chip1 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x05100000 			/* chip1 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x05100000 			/* chip1 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x00100442 			/* chip1 mrs (mem dll unreset) */
	str r1, [r0, #0x10]

	ldr r1, =0x00110780 			/* chip1 emrs1 (ocd default) */
	str r1, [r0, #0x10]

	ldr r1, =0x00110400 			/* chip1 emrs1 (ocd exit) */
	str r1, [r0, #0x10]

	ldr r1, =0x0FF02030 			/* concontrol auto refresh on */
	str r1, [r0, #0x00]

	ldr r1, =0xFFFF00FF 			/* pwrdn config */
	str r1, [r0, #0x28]

/*			ldr r1, =0x00202400 			 memcontrol bl=4, 2 chip, ddr2 type, dynamic self refresh, force precharge, dynamic power down off 
			str r1, [r0, #0x04]*/

	/*
	 * dmc1 initialization at single type
	 */
	ldr r0, =0xf1400000

	ldr r1, =0x00101000 			/* phycontrol0 dll parameter setting */
	str r1, [r0, #0x18]

	ldr r1, =0x00000086 			/* phycontrol1 dll parameter setting */
	str r1, [r0, #0x1c]

	ldr r1, =0x00101002 			/* phycontrol0 dll on */
	str r1, [r0, #0x18]

	ldr r1, =0x00101003 			/* phycontrol0 dll start */
	str r1, [r0, #0x18]

dmc1_lock:
	ldr r1, [r0, #0x40] 			/* load phystatus register value */
	and r2, r1, #0x7
	cmp r2, #0x7					/* loop until dll is locked */
	bne dmc1_lock

	and r1, #0x3fc0
	mov r2, r1, LSL #18
	orr r2, r2, #0x100000
	orr r2 ,r2, #0x1000

	orr r1, r2, #0x3				/* force value locking */
	str r1, [r0, #0x18]

	/* setting ddr2 */
	ldr r1, =0x0FFF2010 			/* concontrol auto refresh off */
	str r1, [r0, #0x00]

	ldr r1, =0x00202430 			/* memcontrol bl=4, 2 chip, ddr2 type, dynamic self refresh, force precharge, dynamic power down off */
	str r1, [r0, #0x04]

	ldr r1, =DMC1_MEMCONFIG_0		/* memconfig0 256MB config, 8 banks, mapping method[12:15] 0:linear, 1:linterleaved, 2:mixed */
	str r1, [r0, #0x08]

/*	ldr r1, =DMC1_MEMCONFIG_1		 memconfig1 
	str r1, [r0, #0x0c]*/

	ldr r1, =0xFF000000 			/* prech config */
	str r1, [r0, #0x14]

	ldr r1, =DMC1_TIMINGA_REF		/* timing aref */
	str r1, [r0, #0x30]

	ldr r1, =DMC1_TIMING_ROW		/* timingRow */
	str r1, [r0, #0x34]

	ldr r1, =DMC1_TIMING_DATA		/* timing data CL=3 */
	str r1, [r0, #0x38]

	ldr r1, =DMC1_TIMING_PWR		/* timing power */
	str r1, [r0, #0x3c]

	ldr r1, =0x07000000 			/* chip0 deselect */
	str r1, [r0, #0x10]

	ldr r1, =0x01000000 			/* chip0 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x00020000 			/* chip0 emrs2 */
	str r1, [r0, #0x10]

	ldr r1, =0x00030000 			/* chip0 emrs3 */
	str r1, [r0, #0x10]

	ldr r1, =0x00010400 			/* chip0 emrs1 (mem dll on, dqs disable) */
	str r1, [r0, #0x10]

	ldr r1, =0x00000542 			/* chip0 mrs (mem dll reset) cl=4, bl=4 */
	str r1, [r0, #0x10]

	ldr r1, =0x01000000 			/* chip0 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x05000000 			/* chip0 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x05000000 			/* chip0 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x00000442 			/* chip0 mrs (mem dll unreset) */
	str r1, [r0, #0x10]

	ldr r1, =0x00010780 			/* chip0 emrs1 (ocd default) */
	str r1, [r0, #0x10]

	ldr r1, =0x00010400 			/* chip0 emrs1 (ocd exit) */
	str r1, [r0, #0x10]

	ldr r1, =0x07100000 			/* chip1 deselect */
	str r1, [r0, #0x10]

	ldr r1, =0x01100000 			/* chip1 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x00120000 			/* chip1 emrs2 */
	str r1, [r0, #0x10]

	ldr r1, =0x00130000 			/* chip1 emrs3 */
	str r1, [r0, #0x10]

	ldr r1, =0x00110400 			/* chip1 emrs1 (mem dll on, dqs disable) */
	str r1, [r0, #0x10]

	ldr r1, =0x00100542 			/* chip1 mrs (mem dll reset) cl=4, bl=4 */
	str r1, [r0, #0x10]

	ldr r1, =0x01100000 			/* chip1 pall */
	str r1, [r0, #0x10]

	ldr r1, =0x05100000 			/* chip1 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x05100000 			/* chip1 refa */
	str r1, [r0, #0x10]

	ldr r1, =0x00100442 			/* chip1 mrs (mem dll unreset) */
	str r1, [r0, #0x10]

	ldr r1, =0x00110780 			/* chip1 emrs1 (ocd default) */
	str r1, [r0, #0x10]

	ldr r1, =0x00110400 			/* chip1 emrs1 (ocd exit) */
	str r1, [r0, #0x10]

	ldr r1, =0x0FF02030 			/* concontrol auto refresh on */
	str r1, [r0, #0x00]

	ldr r1, =0xFFFF00FF 			/* pwrdn config */
	str r1, [r0, #0x28]

/*			ldr r1, =0x00202400 			 memcontrol bl=4, 2 chip, ddr2 type, dynamic self refresh, force precharge, dynamic power down off 
			str r1, [r0, #0x04]*/

	mov pc, lr







	
