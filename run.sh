#!/bin/bash

if [ $1 == "sd" ];then
	cd sd_fusing
	sudo ./sd_fusing.sh /dev/sdb	
	cd ..
	exit
elif [ $1 == "cp" ];then

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/Makefile ./
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/boards.cfg ./
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/include/configs/smdkv210.h ./include/configs/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/board/samsung/smdkv210/smdkv210.c ./board/samsung/smdkv210/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/board/samsung/smdkv210/lowlevel_init.S ./board/samsung/smdkv210/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/lib/vectors.S ./arch/arm/lib/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/lib/crt0.S ./arch/arm/lib/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/lib/spl.c ./arch/arm/lib/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/lib/board.c ./arch/arm/lib/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/lib/bootm.c ./arch/arm/lib/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/drivers/mtd/onenand/onenand_uboot.c ./drivers/mtd/onenand/


	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/cpu/armv7/start.S ./arch/arm/cpu/armv7/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/cpu/armv7/s5pc1xx/clock.c ./arch/arm/cpu/armv7/s5pc1xx/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/cpu/armv7/s5p-common/timer.c ./arch/arm/cpu/armv7/s5p-common/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/include/asm/arch-s5pc1xx/cpu.h ./arch/arm/include/asm/arch-s5pc1xx/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/include/asm/arch-s5pc1xx/clock.h ./arch/arm/include/asm/arch-s5pc1xx/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/arch/arm/include/asm/arch-s5pc1xx/s5pv210 ./arch/arm/include/asm/arch-s5pc1xx/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/tools/Makefile ./tools/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/tools/mksamungspl.c ./tools/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/common/spl/spl.c ./common/spl/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/common/image.c ./common/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/common/cmd_bootm.c ./common/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/common/bootm.c ./common/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/drivers/serial/serial.c ./drivers/serial/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/drivers/serial/serial_s5p.c ./drivers/serial/
	cp -rf /mnt/hgfs/shared/u-boot-2014.07/drivers/mmc/mmc.c ./drivers/mmc/

	cp -rf /mnt/hgfs/shared/u-boot-2014.07/scripts/Makefile.spl ./scripts/
else
	echo "smdkv210_config"		
fi
	make ARCH=arm distclean
	make ARCH=arm smdkv210_config
#	make ARCH=arm CROSS_COMPILE=/home/lincor/toolchains/arm-2009q3/bin/arm-none-linux-gnueabi- spl/u-boot-spl.bin
	make ARCH=arm CROSS_COMPILE=/home/lincor/toolchains/arm-2009q3/bin/arm-none-linux-gnueabi-

