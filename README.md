# viv-prj-gen

Vivado projects can be hard to version control. The goal of this project is to make that easier by automating generation of vivado projects, to have a similar process for nonproject builds using vivado, and to automate generation of the ipxact meta data (components.xml and xgui).  This is meant to be crossplatform, but only has been tested on linux.

tcl scripts invoked through calls to functions in an included cmake file.

Check out the tutorial

[tutorial](docs/tutorial.adoc)

For more detail, look at the api

[vivgen_functions](docs/vivgen_functions.adoc)
[util_functions](docs/util_functions.adoc)

There are examples in the demos directory.