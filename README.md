# mitysom5csx-dart-evdk project
This project includes the ARM software, FPGA code, and yocto recipes used to
build the reference SD card image for the [MitySOM-5CSX Embedded Vision Dev
Kit for Basler dart BCON Cameras](http://www.criticallink.com/product/mitysom-5csx-vdk-basler-dart/).

Additional resources:
* [Critical Link Project Support Site](https://support.criticallink.com/redmine/projects/5csx_vdk_basler/wiki)
* [Project at Imagehub]()

# Directory Layout

* **/fpga** : source / project files for fpga build
* **/sw**   : source files for embedded ARM software build
* **/meta-mitysom-5csx-vdk** : meta layer for yocto filesystem build.

# About the Yocto Layer
The current SD card image provided with the development kit is based on the krogoth 
poky build from yocto.  There are several additional layers required to build the
full image:

* [meta-mitysom-5csx](https://support.criticallink.com/gitweb/?p=meta-mitysom-5csx.git;a=summary)
* [meta-ti](git://git.yoctoproject.org/meta-ti)

The yocto layer is still a work in progress as it is being mitgrated form an
internal server. If you are trying to generate a full yocto image and run
into problems, you can post an issue here or on the [Critical Link Forms Page](https://support.criticallink.com/redmine/projects/5csx_vdk_basler/boards) for this project.

