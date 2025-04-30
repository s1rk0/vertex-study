#!/bin/sh
#SBATCH -t 0-01:00
#SBATCH -n 1
#SBATCH --mem 8192M
#SBATCH --licenses sps


# Usage:
# ./full_chain_sim_to_ptd.sh 0nu 100

# ──────────────── Arguments ────────────────
REACTION_NAME=$1      # Reaction name, e.g., 0nu
NEVENTS=$2            # Number of events to simulate

# ──────────────── Paths ────────────────
BASE_DIR=/pbs/home/i/iandriievsky/iandriievsky/vertex-study                 # Root project directory
DATA_DIR=${BASE_DIR}/data/${REACTION_NAME}                                  # Directory containing config + data for a specific reaction
PIPE_DIR=${BASE_DIR}/pipelines                                              # Directory with all reconstruction pipelines and templates
TMP_MOCKCONF=${PIPE_DIR}/tmp_mockcalib.conf                                 # Temporary config for mock calibration
TMP_PTDCONF=${PIPE_DIR}/tmp_ptd.conf                                        # Temporary config for PTD reconstruction
MIMODULE_CONF=/pbs/home/i/iandriievsky/tutorial/MiModule/testing_products   # Directory where MiModule pipeline config is located

# ──────────────── Load SuperNEMO environment ────────────────
if [ -f ${THRONG_DIR}/config/supernemo_profile.bash ]; then
  source ${THRONG_DIR}/config/supernemo_profile.bash
fi
snswmgr_load_stack base@2024-11-020
snswmgr_load_setup falaise@5.1.5

# ──────────────── Step 1: Run simulation ────────────────
# Uses setup.profile and simu.conf from $DATA_DIR
flsimulate \
  --verbosity "fatal" \
  --mount-directory "vertexstudy@${BASE_DIR}" \
  --config "${DATA_DIR}/simu.conf" \
  --number-events ${NEVENTS} \
  --output-file "${DATA_DIR}/simu.brio"

# ──────────────── Step 2: Mock Calibration ────────────────
# 2a. Replace profile placeholder in template with actual path
PROFILE_PATH="${DATA_DIR}/setup.profile"
sed "s|@PROFILE_PATH@|${PROFILE_PATH}|" "${PIPE_DIR}/flreconstruct_mockcalibration_template.conf" > "${TMP_MOCKCONF}"

# 2b. Run calibration
flreconstruct \
  --verbosity "debug" \
  --mount-directory "vertexstudy@${PIPE_DIR}" \
  --config "${TMP_MOCKCONF}" \
  --input-file "${DATA_DIR}/simu.brio" \
  --output-file "${DATA_DIR}/simu_calibrated.brio"

# 2c. Remove temporary config
rm "${TMP_MOCKCONF}"

# ──────────────── Step 3: TKrec Tracking Reconstruction → TTD ────────────────
flreconstruct \
  -i "${DATA_DIR}/simu_calibrated.brio" \
  -p "${PIPE_DIR}/flreconstruct_tkrec.pipeline" \
  -o "${DATA_DIR}/reco_ttd.brio"

# ──────────────── Step 4: PTD Reconstruction from TTD ────────────────
# 4a. Replace profile in PTD config
sed "s|@PROFILE_PATH@|${PROFILE_PATH}|" "${PIPE_DIR}/flreconstruct_ptd_template.conf" > "${TMP_PTDCONF}"

# 4b. Run PTD reconstruction
flreconstruct \
  --verbosity "debug" \
  --mount-directory "vertexstudy@${BASE_DIR}" \
  --config "${TMP_PTDCONF}" \
  --input-file "${DATA_DIR}/reco_ttd.brio" \
  --output-file "${DATA_DIR}/reco_ptd.brio"

# 4c. Remove temporary PTD config
rm "${TMP_PTDCONF}"

# ──────────────── Step 5: Final ROOT file creation using MiModule ────────────────
# Converts PTD output to ROOT file with custom MiModule analysis
flreconstruct \
  -i "${DATA_DIR}/reco_ptd.brio" \
  -p "${MIMODULE_CONF}/p_MiModule_v00.conf"

# Rename and move ROOT file to match reaction name and event count
mv Default.root "${DATA_DIR}/result_${NEVENTS}.root"