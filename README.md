# HiSARM (High-level Specification, Automatic code generation, and Retargetable deployment for Multi-robot systems)

## Prerequisite

- Java 8 or higher
- ant
- python 3.8 or higher
- ibmcloudant
- pyyaml
- paramiko
- scp
- Visual Studio Code (Optional)

## Installation

  1. Clone this repository recursively.
```
git clone --recurse-submodules <the current repository path>

```
  2. Build HOPES translator
```
cd HOPES/UEMTranslator
ant
```

  3. Construct a database with JSON files

## Execution


### Run HiSARM on Visual Studio Code

  1. Run Visual Studio Code in the root directory of this repository.

  2. Click "Run and Debug" button.

  3. Select "Execute Software Framework" and press F5 button.

  4. After the execution is done, Select "Execute Robots" and press F5 button.

### Run HiSARM on Command-line


- To run HiSARM, the following parameters are needed.

```
python3 bdl_runner.py <yaml file path> <bdl file path>

```

where
  - `<yaml file path>` : Framework/Application configuration file
  - `<bdl file path>` : HiSARM script file


- Example commands of running HiSARM
```
python3 bdl_runner.py valuable_retrieval_scenario.yaml valuable_retrieval_scenario.bdl
```
- After execution is done, the following command can be used to run robots.

```
python3 robotsw_executer.py

```


## Configuration and Script File Information

| Script file name | Description |
| --- | --- |
| valuable_retrieval_scenario.bdl | Motivational example experimented in the paper of Fig. 17. |
| extinguish_only_scenario.bdl | Extinguish-only example shown in the paper of Fig. 19 (b). |
| mineral_collection_scenario_simulation.bdl | Mineral mining example shown in Fig. 21 (a). |
| mineral_collection_scenario_real_robot.bdl | Mineral mining example shown in Fig. 21 (b). |

| Configuration file name | Description |
| --- | --- |
| valuable_retrieval_scenario.yaml | Basic configuration file for testing the motivational example of _valuable_retrieval_scenario.bdl_. |
| valuable_retrieval_scenario_mixed_robust_dta.yaml | Configuration file used for testing the robustness of DTA shown in Fig. 20. |
| valuable_retrieval_scenario_mixed_robust_sta.yaml | Configuration file used for testing the robustness of STA shown in Fig. 20. |
| valuable_retrieval_scenario_mixed_robust_leader.yaml | Configuration file used for testing the robustness of leader election described in Section 8.1.3. |
| valuable_retrieval_scenario_nearby_search.yaml | Configuration file used for testing 'Prioritize search for nearby' shown in Fig. 18 (b). |
| valuable_retrieval_scenario_random_without_map_search.yaml | Configuration file used for testing 'Without map' shown in Fig. 18 (b). |
| extinguish_only_scenario.yaml | Configuration file of extinguish-only example shown in the paper of Fig. 19 (b). |
| mineral_collection_scenario_sim.yaml | Software-in-the-loop simulation configuration file of mineral mining example shown in Fig. 22. |
| mineral_collection_scenario_hils.yaml | Hardware-in-the-loop simulation configuration file of mineral mining example shown in Fig. 22. |
| mineral_collection_scenario_real_robot.yaml | Real robot configuration file of mineral mining example shown in Fig. 22. |



