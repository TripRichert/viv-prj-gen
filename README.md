# viv-prj-gen

tcl scripts invoked through calls to functions in an included cmake file to generate vivado projects, to build a bit file with vivado nonprject mode, and generate IPXACT component.xml and xgui meta data that IP integrator can understand.

The goal is for this to be crossplatform, but it is untested on windows.

To use it, create your own CMakeLists.txt, include viv-prj-gen/functions.cmake, and use the provided cmake functions.

Vivado's cmake version is too old to work with functions.cmake.  Use your system's /usr/bin/cmake instead of vivado's.  