sdas6500 -pogn -I"." -y -s -l demo_sdas6500.o demo_sdas6500.s
sdld6808 -n -i -j -y -w -u -w -b _ZP=0x0000 -b _OAM=0x0200 -b _CODE=0x8000 demo_sdas6500.ihx demo_sdas6500.o
ihxcheck demo_sdas6500.ihx
makebin -s 73728 -o 32752 demo_sdas6500.ihx demo_sdas6500.nes
copy demo_sdas6500.nes ..\
del demo_sdas6500.nes *.o
