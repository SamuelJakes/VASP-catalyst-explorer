#!/bin/bash
#ONLY WORKS WITH FRACTIONAL COORDINATES
#ONLY WORKS WITH RECTANGULAR LATTICE VECTORS
#Set the name of the molecule
#SET RUN FILE EXTENSION USED ON MACHINE - Default set to .csh for USYD physics cluster
EXT="csh"
mkdir jobs
MAGMOM=-1
for ATOM in $(ls Surfaces)
do
    mkdir jobs/${ATOM}
    for MOL in $(ls Molecules)
    do
        #Create the right POTCAR file
        mkdir jobs/${ATOM}/${MOL}
        cat Surfaces/${ATOM}/POTCAR >> jobs/${ATOM}/${MOL}/POTCAR
        if [[ "$MOL" == *"C"* ]]
        then
            cat IndividualPOTCARs/C-POTCAR >> jobs/${ATOM}/${MOL}/POTCAR
        fi
        if [[ "$MOL" == *"O"* ]]
        then
            cat IndividualPOTCARs/O-POTCAR >> jobs/${ATOM}/${MOL}/POTCAR
        fi 
        if [[ "$MOL" == *"H"* ]]
        then
            cat IndividualPOTCARs/H-POTCAR >> jobs/${ATOM}/${MOL}/POTCAR
        fi 

        #Use same KPOINTS as in surface
        cp Surfaces/${ATOM}/KPOINTS jobs/${ATOM}/${MOL}/KPOINTS

        #Create INCAR File
        MOLLENGTH=`wc -l Molecules/${MOL} | awk '{print $1}'`
        cat Surfaces/${ATOM}/INCAR  | sed 's/!.*//g' | sed 's/#.*//g' | sed '/^[[:space:]]*$/d' \
        | sed 's/MAGMOM.*/& '"${MOLLENGTH}*0.0/" > jobs/${ATOM}/${MOL}/INCAR
            
        #Create run.csh file
        cat Surfaces/${ATOM}/run.${EXT} | sed 's/-N .*/'"-N ${ATOM}_${MOL}/" > jobs/${ATOM}/${MOL}/run.${EXT}

        #Create POSCAR
        #Count number of each atom in files
        CS=0
        OS=0
        HS=0
        while read line || [ -n "$line" ]
        do
            LETTER=`echo $line | awk '{print $1}'`
            if [[ $LETTER == C ]]
            then
                let "CS+=1"
            fi
            if [[ $LETTER == O ]]
            then
                let "OS+=1"
            fi
            if [[ $LETTER == H ]]
            then
                let "HS+=1"
            fi
        done < Molecules/$MOL
        NUMS=""
        if [[ $CS > 0 ]]
        then
            NUMS="$NUMS $CS"
        fi
        if [[ $OS > 0 ]]
        then
            NUMS="$NUMS $OS"
        fi
        if [[ $HS > 0 ]]
        then
            NUMS="$NUMS $HS"
        fi
        #Insert first part of POSCAR
        #This takes the CONTCAR and removes the last section - based on the empty line that separates
        #The molecule positions from 
        cat Surfaces/${ATOM}/CONTCAR | sed '/^ *$/Q' | sed '6d' | sed '6s/.*/&'"${NUMS}/" > jobs/${ATOM}/${MOL}/POSCAR 
        lastChar=`tail -c1 jobs/${ATOM}/${MOL}/POSCAR`                                                        

        #Get cell shape from surface
        Scale=`sed -n 2p Surfaces/$ATOM/CONTCAR | awk '{print $1}'`
        XC=`sed -n 3p Surfaces/$ATOM/CONTCAR | awk '{print $1}'`
        YC=`sed -n 4p Surfaces/$ATOM/CONTCAR | awk '{print $2}'`
        ZC=`sed -n 5p Surfaces/$ATOM/CONTCAR | awk '{print $3}'`

        #Get the last molecule coordinates
        X=`tail -1 jobs/${ATOM}/${MOL}/POSCAR | awk '{print $1}'`
        Y=`tail -1 jobs/${ATOM}/${MOL}/POSCAR | awk '{print $2}'`
        Z=`tail -1 jobs/${ATOM}/${MOL}/POSCAR | awk '{print $3}'`

        #Please note that the constant values of 10.16, 11.76, and 15 are the x, y, z lattice constants
        #for the intermediate molecules. If another chemical reaction scheme is to be defined,
        #These can be changed to match whichever lattice constants are used.
        #This code converts fractional coordinates of intermediates and places them on top of surface (last atom)
        while read line || [ -n "$line" ]
        do
            echo $line | awk -v X=$X -v Y=$Y -v Z=$Z -v XC=$XC -v YC=$YC -v ZC=$ZC -v Scale=$Scale \
            '{printf "  %1.5f %1.5f %1.5f\n", ($2*(10.16/(XC*Scale)))+X, ($3*(11.76/(YC*Scale)))+Y,\
             ($4*(15/(ZC*Scale)))+Z+(2/(ZC*Scale))}' >> jobs/${ATOM}/${MOL}/POSCAR
        done < Molecules/$MOL
    done
done
#Create a run file with csh syntax. This can easily be adjusted for other shell types.
cat > jobs/runAllJobs.csh <<-EOF
#!/bin/csh
module load PBS
foreach d (\`ls -d */\`)
    cd \$d
    foreach e (\`ls -d */\`)
        cd "\$e"
        qsub run.csh
        cd ..
    end
    cd ..
end
EOF
#This is a run file for bash that would work equally well, still assuming PBS is used.
# cat > jobs/runAllJobs.sh <<-EOF
# #!/bin/sh
# module load PBS
# for d \$(ls -d */)
#     cd "\$d"
#     for e \$(ls -d */)
#         cd "\$e"
#         qsub run.sh
#         cd ..
#     end
#     cd ..
# end
# EOF