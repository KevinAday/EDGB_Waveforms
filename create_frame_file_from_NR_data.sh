## Take in the value of sqrt_alpha as a command-line argument
## replace . in the string with p in order
## to be able to read from the .h5 files
sqrt_alpha=$1
sqrt_alpha=`echo ${sqrt_alpha/./'p'}`

APPROXIMANT=NR_hdf5
DIR="EDGB_"${sqrt_alpha}
h5path=Waveforms/${DIR}/EDGB_sqrt_alpha_${sqrt_alpha}.h5
MASS1=37.386085075316785
MASS2=30.613915574190038
#SPIN1X=3.45812819445e-09                                                                                                                                                                #SPIN1Y=-1.30280350261e-08                                                                                                                                                               
SPIN1Z=0.329894028067
#SPIN2X=1.8249973247e-08                                                                                                                                                                 #SPIN2Y=1.643082404e-08                                                                                                                                                                  
SPIN2Z=-0.439941681413

SNR=$2
INCL=0
PSI=0.310886773011
RA=4.7614763656
DEC=-0.531780006467



PSDs=PSDs/design

# Look up end_time or just 'time' and set 
# geocentric-end-time = 'time'
# gps-start-time = 'time' - 502s
# gps-end-time  = 'time' + 10s
# hwinj-start-time = 'time' - 6s

TIME=1197495364
START_TIME=$(echo "${TIME} - 10" | bc -l)
END_TIME=$(echo "${TIME} + 10" | bc -l)

FLOW=21
SNR_FLOW=21
FHIGH=1024

pycbc_generate_hwinj \
    --numrel-data ${h5path} \
    --instruments H1 L1\
    --approximant ${APPROXIMANT} \
    --order pseudoFourPN \
    --waveform-low-frequency-cutoff $FLOW \
    --mass1 $MASS1 \
    --mass2 $MASS2 \
    --spin1x 0.0 \
    --spin1y 0.0 \
    --spin1z $SPIN1Z \
    --spin2x 0.0 \
    --spin2y 0.0 \
    --spin2z $SPIN2Z \
    --inclination $INCL \
    --polarization $PSI \
    --ra $RA \
    --dec $DEC \
    --sample-rate H1:2048 L1:2048 \
    --channel-name H1:GDS-CALIB_STRAIN L1:GDS-CALIB_STRAIN \
    --taper TAPER_START \
    --network-snr ${SNR} \
    --psd-file H1:${PSDs}/aLIGOZeroDetHighPower-PSD_21Hz.txt L1:${PSDs}/aLIGOZeroDetHighPower-PSD_21Hz.txt \
    --low-frequency-cutoff $SNR_FLOW \
    --high-frequency-cutoff $FHIGH \
    --geocentric-end-time $TIME \
    --gps-start-time $START_TIME \
    --gps-end-time $END_TIME 

   # --psd-low-frequency-cutoff $PSD_FLOW  \
   # --psd-high-frequency-cutoff $FHIGH \   

# pycbc_generate_hwinj will produce a file of indeterminate length. 
# Extract the time from the xml file, since we need it for the
# pycbc_insert_frame_hwinj below.
    
HWINJ_START_TIME=$(ls hwinjcbc_*.xml.gz | sed 's/^.*_\([0-9]*\).xml.gz/\1/')


pycbc_insert_frame_hwinj \
    --fake-strain zeroNoise \
    --gps-start-time $START_TIME \
    --gps-end-time $END_TIME \
    --pad-data 8 \
    --sample-rate 2048 \
    --hwinj-file hwinjcbc_${HWINJ_START_TIME}_H1.txt \
    --hwinj-start-time $HWINJ_START_TIME \
    --ifo H1 \
    --output-file H-H1HWINJ_${NAME}.gwf \
    --strain-high-pass 1

pycbc_insert_frame_hwinj \
    --fake-strain zeroNoise \
    --gps-start-time $START_TIME \
    --gps-end-time $END_TIME \
    --pad-data 8 \
    --sample-rate 2048 \
    --hwinj-file hwinjcbc_${HWINJ_START_TIME}_L1.txt \
    --hwinj-start-time $HWINJ_START_TIME \
    --ifo L1 \
    --output-file L-L1HWINJ_${NAME}.gwf \
    --strain-high-pass 1

#pycbc_insert_frame_hwinj \
#    --fake-strain zeroNoise \
#    --gps-start-time $START_TIME \
#    --gps-end-time $END_TIME \
#    --pad-data 8 \
#    --sample-rate 16384 \
#    --hwinj-file hwinjcbc_${HWINJ_START_TIME}_V1.txt \
#    --hwinj-start-time $HWINJ_START_TIME \
#    --ifo V1 \
#    --output-file ${OUTDIR}/V-V1HWINJ_${NAME}.gwf \
#    --strain-high-pass 1

# Copy xml file
mv hwinjcbc_${HWINJ_START_TIME}.xml.gz Waveforms/${DIR}/hwinjcbc_${HWINJ_START_TIME}_${NAME}.xml.gz
# Move files into directory
mv hwinjcbc_${HWINJ_START_TIME}_H1.txt Waveforms/${DIR}/hwinjcbc_${HWINJ_START_TIME}_${NAME}_H1.txt
mv hwinjcbc_${HWINJ_START_TIME}_L1.txt Waveforms/${DIR}/hwinjcbc_${HWINJ_START_TIME}_${NAME}_L1.txt
mv H-H1HWINJ_${NAME}.gwf Waveforms/${DIR}/H-H1HWINJ_${NAME}.gwf
mv L-L1HWINJ_${NAME}.gwf Waveforms/${DIR}/L-L1HWINJ_${NAME}.gwf
