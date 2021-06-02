#!/bin/bash
#This program uses the Energy-Leveler python script to plot energy level diagrams for all of the created jobs.
#IN EVENT OF CONFLICT:
#USE MOVE UP = TRUE AND MOVE DOWN = TRUE
#Helper function to extract the ground state energy from an OSZICAR file given as input
getGibbs() {
    E=$1
    E=$(echo $E | grep -o 'E0=.*d')
    E=$(echo $E | sed 's/E0= //g')
    E=$(echo $E | sed 's/\s*d//g')
    E=$(echo $E | sed "s/E+/*10^/")
    E=$(echo $E | bc)
    echo $E
}
#Energies of lone molecules
for MOL in $(ls LoneMolecules)
do
    declare "LONE_${MOL}_ENERGY"=$(getGibbs "`tail -1 LoneMolecules/${MOL}/OSZICAR`")
done
#Energies of atoms on surface
for SURFACE in $(ls Surfaces)
do
    SURFACE_ENERGY=$(getGibbs "`tail -1 Surfaces/${SURFACE}/OSZICAR`")
    BASE_ENERGY=$(echo "$SURFACE_ENERGY + $LONE_CO2_ENERGY + (4 * $LONE_H2_ENERGY)" | bc)

    #Energies of surfaces
    for MOL in $(ls Molecules)
    do
        declare "${MOL}_ENERGY"=$(getGibbs "`tail -1 jobs/${SURFACE}/${MOL}/OSZICAR`")
    done
    
    echo "${COOH_ENERGY} - ${BASE_ENERGY} + (3.5 * ${LONE_H2_ENERGY})" 
    cat > EnergyLeveller-master/${SURFACE}_Energy_Plot.inp <<EOF
output-file     = ${SURFACE}_Energy_Plot.pdf
width           = 10
height          = 10
energy-units    = Gibbs Free Energy (\$\Delta G/eV\$)
font size       = 10
graphwidth = 2
#   start at zero
############################################################################# COLUMN 1
{
    name        = CO2
    text-colour = black
    label       = *+CO\$_2\$
    energy      = 0.00
    labelColour = black
    linksto     = OCHO:black, COOH:black
    column      = 1
}
############################################################################## COLUMN 2
{
    name        = OCHO
    text-colour = black
    label       = O*CHO
    energy      = $(printf %.3f $(echo "${OCHO_ENERGY} - ${BASE_ENERGY} + (3.5 * ${LONE_H2_ENERGY})"| bc)) 
    labelColour = black
    linksto     = OCHOH:black
    column      = 2
}

{
    name        = COOH
    text-colour = black
    label       = C*OOH
    energy      = $(printf %.3f $(echo "${COOH_ENERGY} - ${BASE_ENERGY} + (3.5 * ${LONE_H2_ENERGY})" | bc)) 
    labelColour = black
    linksto     = CO:black
    column      = 2
}
############################################################################## COLUMN 3
{
    name        = CO
    text-colour = black
    label       = C*O
    energy      = $(printf %.3f $(echo "${CO_ENERGY} - ${BASE_ENERGY} ${LONE_H2O_ENERGY} + (3 * ${LONE_H2_ENERGY})"| bc)) 
    labelColour = black
    linksto     = CHO:black, COH:orange, +CO:pink
    column      = 3
}

{
    name        = OCHOH
    text-colour = black
    label       = O*CHOH
    energy      = $(printf %.3f $(echo "${OCHOH_ENERGY} - ${BASE_ENERGY} + (3 * ${LONE_H2_ENERGY})"| bc)) 
    labelColour = black
    linksto	= OCH:purple, CHO:black
    column      = 3
}
############################################################################## COLUMN 4
{
    name        = COH
    text-colour = orange
    label       = C*OH
    energy      = $(printf %.3f $(echo "${COH_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (2.5 * ${LONE_H2_ENERGY})"| bc)) 
    labelColour = black
    column      = 4
}

{
    name        = OCH
    text-colour = purple
    label       = O*CH
    energy      = $(printf %.3f $(echo "${OCH_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (2.5 * ${LONE_H2_ENERGY})" | bc)) 
    labelColour = black
    column      = 4
}

{
    name        = +CO
    text-colour = pink
    label       = *+CO
    energy      = $(printf %.3f $(echo "${SURFACE_ENERGY} + ${LONE_CO_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (3 * ${LONE_H2_ENERGY})" | bc)) 
    labelColour = black
    column      = 4
}

{
    name        = CHO
    text-colour = black
    label       = C*HO
    energy      = $(printf %.3f $(echo "${CHO_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (2.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= CHOH:blue, OCH2:black
    column      = 4
}
############################################################################## COLUMN 5
{
    name        = CHOH
    text-colour = blue
    label       = C*HOH
    energy      = $(printf %.3f $(echo "${CHOH_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (2 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= CH2OH:blue, CH+H2O:cyan
    column      = 5
}

{
    name        = OCH2
    text-colour = black
    label       = O*CH\$_2\$
    energy      = $(printf %.3f $(echo "${OCH2_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (2 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= OCH3:black, OHCH2:green
    column      = 5
}
############################################################################## COLUMN 6
{
    name        = OHCH2
    text-colour = green
    label       = O*HCH\$_2\$
    energy      = $(printf %.3f $(echo "${OHCH2_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (1.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    column      = 6
}

{
    name        = CH+H2O
    text-colour = cyan
    label       = C*H+H\$_2\$O
    energy      = $(printf %.3f $(echo "${CH_ENERGY} + ${LONE_H2O_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (1.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    column      = 6
}

{
    name        = CH2OH
    text-colour = blue
    label       = C*H\$_2\$OH
    energy      = $(printf %.3f $(echo "${CH2OH_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (1.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= CH2:blue
    column      = 6
}

{
    name        = OCH3
    text-colour = black
    label       = O*CH\$_3\$
    energy      = $(printf %.3f $(echo "${OCH3_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (1.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= O+CH4:black, HOCH3:black
    column      = 6
}
############################################################################## COLUMN 7
{
    name        = CH2
    text-colour = blue
    label       = C*H\$_2\$
    energy      = $(printf %.3f $(echo "${CH2_ENERGY} - ${BASE_ENERGY} + (2 * ${LONE_H2O_ENERGY}) + ${LONE_H2_ENERGY}" | bc))
    labelColour = black
    linksto	= CH3:blue
    column      = 7
}

{
    name        = O+CH4
    text-colour = black
    label       = O*+CH\$_4\$
    energy      = $(printf %.3f $(echo "${O_ENERGY} + ${LONE_CH4_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + ${LONE_H2_ENERGY}" | bc))
    labelColour = black
    linksto	= OH+CH4:black
    column      = 7
}

{
    name        = HOCH3
    text-colour = black
    label       = HO*CH\$_3\$
    energy      = $(printf %.3f $(echo "${HOCH3_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + ${LONE_H2_ENERGY}" | bc))
    labelColour = black
    linksto	= OH+CH4:black, +CH3OH:red
    column      = 7
}
############################################################################## COLUMN 8
{
    name        = CH3
    text-colour = blue
    label       = C*H\$_3\$
    energy      = $(printf %.3f $(echo "${CH3_ENERGY} - ${BASE_ENERGY} + (2 * ${LONE_H2O_ENERGY}) + (0.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= *+CH4+H2O
    column      = 8
}

{
    name        = +CH3OH
    text-colour = red
    label       = *+CH\$_3\$OH
    energy      = $(printf %.3f $(echo "${SURFACE_ENERGY} + ${LONE_CH3OH_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + ${LONE_H2_ENERGY}" | bc))
    labelColour = black
    column      = 8
}

{
    name        = OH+CH4
    text-colour = black
    label       = O*H+CH\$_4\$
    energy      = $(printf %.3f $(echo "${OH_ENERGY} + ${LONE_CH4_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY} + (0.5 * ${LONE_H2_ENERGY})" | bc))
    labelColour = black
    linksto	= *+CH4+H2O:black
    column      = 8
}
############################################################################## COLUMN 9
{
    name        = *+CH4+H2O
    text-colour = blue
    label       = +CH\$_4\$+H\$_2\$O
    energy      = $(printf %.3f $(echo "${SURFACE_ENERGY} + ${LONE_CH4_ENERGY} + ${LONE_H2O_ENERGY} - ${BASE_ENERGY} + ${LONE_H2O_ENERGY}" | bc))
    labelColour = black
    column      = 9
}
EOF
    #Run the energy level plotter
    python3 EnergyLeveller-master/EnergyLeveller.py EnergyLeveller-master/${SURFACE}_Energy_Plot.inp
    mv "${SURFACE}_Energy_Plot.pdf" ./plots #2>/dev/null
    mv "EnergyLeveller-master/${SURFACE}_Energy_Plot.inp" ./plots #2>/dev/null
done
