# Vertex Study Simulation & Reconstruction Pipeline

This project contains a structured workflow for simulating and reconstructing SuperNEMO events, with the goal of studying the vertex reconstruction performance of different processes such as **0νββ**, **2νββ**, **Bi214**, and **Tl208**.

## 🔧 Directory Structure

```
vertex-study/
├── data/                         # All process-specific configurations, outputs
│   ├── 0nu/                      # Simulation configuration
│   │   ├── setup.profile         # Geometry + magnetic field profile
│   │   ├── simu.conf             # Simulation configuration
│   │   ├── simu.brio             # Simulated data
│   │   ├── simu_calibrated.brio  # After mock calibration
│   │   ├── reco_ttd.brio         # After TKrec tracking 
│   │   ├── reco_ptd.brio         # After PTD reconstruction 
│   │   └──result_0nu_100.root    # Final ROOT output for analysis
│   └── ...
│
├── pipelines/                    # All reusable pipeline and config files
│   ├── flreconstruct_mockcalibration_template.conf
│   ├── flreconstruct_mockcalibration.pipeline
│   ├── flreconstruct_tkrec.pipeline
│   ├── flreconstruct_ptd_template.conf
│   └── flreconstruct_ptd.pipeline
│
├── full_chain_sim_to_ptd.sh  
└── README.md


````

---

## 🔁 Pipeline Overview

The processing chain consists of the following stages:

1. **Simulation**  
   Performed with `flsimulate` using process-specific `simu.conf` and `setup.profile`.

2. **Mock Calibration**  
   Converts raw simulated tracker and calorimeter hits into calibrated form.  
   **Modules:**
   - `snemo::processing::mock_tracker_s2c_module`
   - `snemo::processing::mock_calorimeter_s2c_module`  
   **Source:** *Standard Falaise modules* by the SuperNEMO software team.

3. **Tracking Reconstruction (TTD)**  
   Performed by **TKrec** module (alternative to CAT+TrackFit), producing tracker trajectories.  
   **Module:** `TKReconstruct`  
   **Author:** *Tomáš Křižák*

4. **PTD Reconstruction**  
   Converts trajectories into fully reconstructed charged particles and γ-clusters.  
   **Modules:**
   - `snemo::reconstruction::charged_particle_tracking_module`
   - `snemo::reconstruction::gamma_clustering_module`  
   **Author:** *François Mauger / SuperNEMO*

4. **ROOT Generate**  
   Uses a lightweight custom analysis module to extract efficiency, event content, and vertex positions.  
   **Module:** `MiModule` (`p_MiModule_v00.conf`)  
   **Author:** *Miroslav Macko*

---

## 📌 How to Run

### Example

```bash
./full_chain_sim_to_ptd.sh 0nu 1000
````

This will:

1. Simulate 1000 events for the `0nu` process.
2. Apply mock calibration.
3. Reconstruct TTD using TKrec.
4. Reconstruct PTD from TTD.
5. Generate a ROOT file with the result:  
    `data/0nu/result_0nu_1000.root`

---

## 📊 Diagram of Processing Pipeline

```
simu.conf + setup.profile
        │
        ▼
┌──────────────────────┐
│     Simulation       │  flsimulate
└──────────────────────┘
        │
        ▼
┌──────────────────────┐
│  Mock Calibration    │  flreconstruct + mock pipeline
└──────────────────────┘
        │
        ▼
┌──────────────────────┐
│  TKrec Tracking      │  flreconstruct + TKrec
└──────────────────────┘
        │
        ▼
┌──────────────────────┐
│    PTD Reconstr.     │  flreconstruct + PTD pipeline
└──────────────────────┘
        │
        ▼
┌──────────────────────┐
│     MiModule         │  flreconstruct + MiModule
└──────────────────────┘
        │
        ▼
result_<reaction>_<nevents>.root
```
