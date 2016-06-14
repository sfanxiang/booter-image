_all:
	cd clear_cmos && make
	cd cmos_boot_disk && make
	cd direct_boot && make
	cd direct_boot2 && make
	cd install_ahci_and_boot && make
	cd int0x19 && make
	cd int0x19_hook && make
	cd stop_pci && make
