#!/bin/sh
#SBATCH -t 0-01:00
#SBATCH -n 1
#SBATCH --mem 8192M
#SBATCH --licenses sps

FOLDER=$1

TUTO_FOLD=/pbs/home/i/iandriievsky/iandriievsky/vertex-study/tutorial
FAL_FOLD=/sps/nemo/sw/Falaise/install_develop
CONF_FAL=$FAL_FOLD/share/Falaise-4.1.0/resources/snemo/demonstrator/reconstruction
CONF_SEN=/pbs/home/i/iandriievsky/tutorial/MiModule/testing_products

if [ -f ${THRONG_DIR}/config/supernemo_profile.bash ]; then
	source ${THRONG_DIR}/config/supernemo_profile.bash
fi
snswmgr_load_stack base@2024-09-04
snswmgr_load_setup falaise@5.1.2

flsimulate -c $TUTO_FOLD/$FOLDER/simu.conf \
           -o $TUTO_FOLD/$FOLDER/simu.brio

flreconstruct -i $TUTO_FOLD/$FOLDER/simu.brio \
              -p $CONF_FAL/official-2.0.0.conf \
              -o $TUTO_FOLD/$FOLDER/reco.brio

rm $TUTO_FOLD/$FOLDER/simu.brio

flreconstruct -i $TUTO_FOLD/$FOLDER/reco.brio \
              -p $CONF_SEN/p_MiModule_v00.conf

rm $FOLDER/reco.brio

mv Default.root $FOLDER/result.root
