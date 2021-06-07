# How to use this software
This software is designed to be used with VASP. Given VASP files containing potential catalysts, the
software uses a Bash script to create nineteen further VASP jobs per catalyst. Each job contains a
reaction intermediate placed 2 ˚A above the active
site of the catalyst.

Each VASP job consists of four files which specify
the parameters of the system to be simulated: the
POSCAR file specifies the positions of the atoms,
the POTCAR file specifies the pseudo-potentials to
be used for each atom, the KPOINTS file specifies
the k-sampling method and the number of k-points
used in each direction, and the INCAR file specifies
other miscellaneous settings. Additionally, a run file
is needed to start the VASP job itself, which is set
by default to be a Portable Batch System (PBS) file. After a
VASP job has been run, additional files are created
which specify the results. Notably, the CONTCAR
file contains the final positions of the atoms.
To use the software, VASP jobs containing catalysts
are placed in a directory called “Surfaces”. The file
“CreateJobs.sh” should be run within a UNIX environment. Nineteen new VASP jobs will then be created for each catalyst. For each of these new jobs,
the KPOINTS file is directly copied from the catalyst. The PBS run file is also copied over, but the
name of the job is changed to follow the format of
“catalyst intermediate”.

A suitable POTCAR file
is made by appending combinations of C, O and H
POTCAR files to the POTCAR file used by the catalyst. By default, PBE pseudo-potentials are
used, but these can easily be replaced by swapping
out the POTCAR files contained in the “IndividualPOTCARs” directory. An INCAR file is then
made by copying over the catalyst’s INCAR file, and
if magnetic moments have been specified in this file,
then the magnetic moments of the intermediates are
added (for CO2 reduction, all of these magnetic moments are zero). Creating the POSCAR file is more
difficult than the previous steps. The lattice constants, scaling factor, and position of the last atom
are read from the catalyst’s CONTCAR file. The
lattice constants and scaling factor are used to adjust
the fractional coordinates of molecules in the intermediate’s unit cell to those in the catalyst’s cell, ensuring that the physical distance between molecules
is preserved.

The resulting VASP jobs are organised by catalyst
name, contained in the “jobs” directory. Also in this
directory will be a “runAllJobs” script for running
every generated job, which by default is written
in C Shell for use in the HPCC. An equivalent
script written in Bash has been included in the
“CreateJobs.sh” file, and needs to be uncommented
if Bash is the preferred shell.
Once the jobs have finished running, the reaction
pathways can be plotted by running “PlotEnergies.sh”. This script makes use of and extends
the “EnergyLeveller” python module [30] to plot
the reaction pathways based on the ground-state
energies calculated by VASP. The links between
intermediates, colour schemes, and balanced equations are specified in the “PlotEnergies.sh” file.

The resulting graphs will be placed in the “plots”
directory in the form of PDF files, along with a
corresponding “.inp” file which can be used to make
adjustments to the graphs. A few extra features
have been added manually to the EnergyLeveller
Python module, which extend it’s ability to format
the resulting graphs. In particular, if any of the
labels on the graph are overlapping, then the “Move
Up = true” or “Move Down = true” tag can be
added to the relevant states in the “.inp” file,
followed by running the “EnergyLeveller.py” script.
Other features that have been added include the
ability to configure the diagram widths, and options
to adjust the size of fonts on axis labels.
