#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 1.0-beta.1

// Copyright (c) 2018-2019 Michael C. Heiber
// This source file is part of the Excimontec_Analysis project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec_Analysis project can be found on Github at https://github.com/MikeHeiber/Excimontec_Analysis

#include <KBColorizeTraces>

Menu "Excimontec"
	"Import New Job", /Q, EMT_ImportDataGUI()
	"Import Job Set", /Q, EMT_ImportSetGUI()
	Submenu "Dynamics Tests"
		"Plot Dynamics Transients", /Q, EMT_GraphDynamicsTransients()
	End
	Submenu "IQE Tests"
		"Plot Charge Extraction Maps", /Q, EMT_GraphExtractionMaps("IQE Tests")
	End
	Submenu "Time of Flight Tests"
		"Plot ToF Transients", /Q, EMT_GraphTOFTransients()
		"Plot ToF Job Transit Time Distribution", /Q, EMT_GraphTOFTransitDist()
		"Plot ToF Set Transit Time Distributions", /Q, EMT_GraphTOFTransitDists()
		"Plot Charge Extraction Map", /Q, EMT_GraphExtractionMaps("Time of Flight Tests")
		//"Plot ToF Field Dependence", /Q, FEDMS_PlotTOF_FieldDependences()
		//"Plot ToF Temperature Dependence", /Q, FEDMS_PlotTOF_TempDependence()
	End
End

Window EMT_Exciton_Diffusion_Table() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Excimontec:'Exciton Diffusion Tests':
	Edit/W=(428.25,350.75,1887.75,808.25) version,job_id,set_num,kmc_algorithm,morphology as "Exciton Diffusion Test Table"
	AppendToTable N_tests,N_variants,lattice_length,lattice_width,lattice_height,unit_size_nm
	AppendToTable disorder_model,correlation_model,correlation_length_nm,disorder_eV
	AppendToTable temperature_K,disorder_norm,R_hop,tau_sx,calc_time_min,diffusion_length_avg
	AppendToTable diffusion_length_stdev,hop_distance_avg,hop_distance_stdev
	ModifyTable format(Point)=1,width(Point)=35,width(version)=57,width(job_id)=54,width(set_num)=50
	ModifyTable width(kmc_algorithm)=76,width(morphology)=62,width(N_tests)=46,width(N_variants)=57
	ModifyTable width(lattice_length)=70,width(lattice_width)=66,width(lattice_height)=70
	ModifyTable width(unit_size_nm)=70,width(disorder_model)=110,width(correlation_model)=89
	ModifyTable width(correlation_length_nm)=107,width(disorder_eV)=65,width(temperature_K)=76
	ModifyTable width(disorder_norm)=74,width(R_hop)=53,width(tau_sx)=41,width(calc_time_min)=75
	ModifyTable width(diffusion_length_avg)=98,width(diffusion_length_stdev)=107,width(hop_distance_avg)=89
	ModifyTable width(hop_distance_stdev)=98
	SetDataFolder fldrSav0
EndMacro

Window EMT_Dynamics_Table() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Excimontec:'Dynamics Tests':
	Edit/W=(431.25,47.75,1897.5,488) version,job_id,set_num,morphology,kmc_algorithm as "Dynamics Test Table"
	AppendToTable N_variants,N_tests,initial_conc,lattice_length,lattice_width,lattice_height
	AppendToTable unit_size_nm,z_periodic,disorder_model,correlation_model,correlation_length_nm
	AppendToTable disorder_D_eV,disorder_A_eV,temperature_K,internal_potential_V,singlet_lifetime_D
	AppendToTable singlet_lifetime_A,triplet_lifetime_D,triplet_lifetime_A,R_singlet_hop_D
	AppendToTable R_singlet_hop_A,R_triplet_hop_D,R_triplet_hop_A,R_isc_D,R_isc_A,R_risc_D
	AppendToTable R_risc_A,R_diss_D,R_diss_A,R_recombination,polaron_delocalization_nm
	AppendToTable R_electron_hop,R_hole_hop,calc_time_min
	ModifyTable format(Point)=1,width(Point)=35,width(version)=57,width(job_id)=54,width(set_num)=50
	ModifyTable width(morphology)=62,width(kmc_algorithm)=76,width(N_variants)=57,width(N_tests)=46
	ModifyTable width(initial_conc)=61,width(lattice_length)=70,width(lattice_width)=66
	ModifyTable width(lattice_height)=70,width(unit_size_nm)=70,width(z_periodic)=56
	ModifyTable width(disorder_model)=110,width(correlation_model)=89,width(correlation_length_nm)=107
	ModifyTable width(disorder_D_eV)=77,width(disorder_A_eV)=77,width(temperature_K)=76
	ModifyTable width(internal_potential_V)=98,width(singlet_lifetime_D)=89,width(singlet_lifetime_A)=89
	ModifyTable width(triplet_lifetime_D)=84,width(R_singlet_hop_D)=86,width(R_singlet_hop_A)=86
	ModifyTable width(R_triplet_hop_D)=81,width(R_triplet_hop_A)=81,width(R_isc_D)=49
	ModifyTable width(R_isc_A)=49,width(R_risc_D)=52,width(R_risc_A)=52,width(R_diss_D)=54
	ModifyTable width(R_diss_A)=54,width(R_recombination)=85,width(polaron_delocalization_nm)=127
	ModifyTable width(R_electron_hop)=80,width(R_hole_hop)=63,width(calc_time_min)=75
	SetDataFolder fldrSav0
EndMacro

Window EMT_ToF_Table() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Excimontec:'Time of Flight Tests':
	Edit/W=(81.75,83.75,1512.75,347.75) version,job_id,set_num,kmc_algorithm,morphology as "ToF Table"
	AppendToTable N_tests,N_variants,lattice_length,lattice_width,lattice_height,unit_size_nm
	AppendToTable localization_nm,disorder_model,correlation_model,correlation_length_nm
	AppendToTable N_carriers,internal_potential_V,temperature_K,disorder_eV,disorder_norm
	AppendToTable field_sqrt,mobility_avg,mobility_stdev,calc_time_min
	ModifyTable format(Point)=1,width(Point)=35,width(version)=68,width(set_num)=50
	ModifyTable width(job_id)=54,width(kmc_algorithm)=76,width(morphology)=97,width(N_tests)=46
	ModifyTable width(N_variants)=57,width(lattice_length)=70,width(lattice_width)=66
	ModifyTable width(lattice_height)=70,width(unit_size_nm)=70,width(localization_nm)=80
	ModifyTable width(disorder_model)=110,width(correlation_model)=89,width(N_carriers)=56
	ModifyTable width(internal_potential_V)=98,width(temperature_K)=76,width(disorder_eV)=65
	ModifyTable width(disorder_norm)=74,width(field_sqrt)=51,width(calc_time_min)=75
	SetDataFolder fldrSav0
EndMacro

Window EMT_IQE_Table() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Excimontec:'IQE Tests':
	Edit/W=(316.5,48.5,1905.75,408.5) version,job_id,set_num,kmc_algorithm,morphology as "IQE Table"
	AppendToTable N_variants,N_tests,lattice_length,lattice_width,lattice_height,unit_size_nm
	AppendToTable disorder_model,correlation_model,correlation_length_nm,disorder_D_eV
	AppendToTable disorder_A_eV,temperature_K,R_singlet_hop_D,R_singlet_hop_A,R_recombination
	AppendToTable polaron_delocalization_nm,internal_potential_V,dissociation_yield
	AppendToTable separation_yield,extraction_yield,IQE,calc_time_min
	ModifyTable format(Point)=1,width(Point)=35,width(version)=57,width(job_id)=59,width(set_num)=50
	ModifyTable width(kmc_algorithm)=76,width(morphology)=75,width(N_variants)=57,width(N_tests)=46
	ModifyTable width(lattice_length)=70,width(lattice_width)=66,width(lattice_height)=70
	ModifyTable width(unit_size_nm)=70,width(disorder_model)=110,width(correlation_model)=89
	ModifyTable width(correlation_length_nm)=107,width(disorder_D_eV)=77,width(disorder_A_eV)=77
	ModifyTable width(temperature_K)=76,width(R_singlet_hop_D)=86,width(R_singlet_hop_A)=86
	ModifyTable width(R_recombination)=85,width(polaron_delocalization_nm)=127,width(internal_potential_V)=98
	ModifyTable width(dissociation_yield)=89,width(IQE)=62,width(calc_time_min)=75
	SetDataFolder fldrSav0
EndMacro
