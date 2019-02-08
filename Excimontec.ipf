#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 0.2-alpha

// Copyright (c) 2018 Michael C. Heiber
// This source file is part of the Excimontec_Analysis project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec_Analysis project can be found on Github at https://github.com/MikeHeiber/Excimontec_Analysis

#include <KBColorizeTraces>

Menu "Excimontec"
	"Load New Job", /Q, EMT_ImportData()
	"Load Job Arrays", /Q, EMT_ImportJobArraysGUI()
	Submenu "Dynamics Tests"
		"Plot Dynamics Transients", /Q, EMT_GraphDynamicsTransients()
	End
	Submenu "IQE Tests"
		"Plot Charge Extraction Maps", /Q, EMT_GraphExtractionMaps("IQE Tests")
	End
	Submenu "Time of Flight Tests"
		"Plot ToF Transients", /Q, EMT_GraphTOFTransients()
		"Plot ToF Transit Time Distribution", /Q, EMT_GraphTOFTransitDist()
		"Plot Charge Extraction Map", /Q, EMT_GraphExtractionMaps("Time of Flight Tests")
		//"Plot ToF Field Dependence", /Q, FEDMS_PlotTOF_FieldDependences()
		//"Plot ToF Temperature Dependence", /Q, FEDMS_PlotTOF_TempDependence()
	End
End

Window EMT_DynamicsTable() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Excimontec:'Dynamics Tests':
	Edit/W=(420,206.75,1846.5,647) version,job_id,calc_time_min,morphology,kmc_algorithm as "Dynamics Test Table"
	AppendToTable N_variants,lattice_length,lattice_width,lattice_height,unit_size_nm
	AppendToTable z_periodic,disorder_model,correlation_model,correlation_length_nm
	AppendToTable disorder_D_eV,disorder_A_eV,temperature_K,internal_potential_V,R_singlet_hop_D
	AppendToTable R_singlet_hop_A,R_recombination,polaron_delocalization_nm,R_electron_hop
	AppendToTable R_hole_hop
	ModifyTable format(Point)=1,width(Point)=35,width(version)=59,width(job_id)=47,width(calc_time_min)=75
	ModifyTable width(morphology)=97,width(kmc_algorithm)=76,width(N_variants)=57,width(lattice_length)=70
	ModifyTable width(lattice_width)=66,width(lattice_height)=70,width(unit_size_nm)=70
	ModifyTable width(z_periodic)=56,width(disorder_model)=110,width(correlation_model)=89
	ModifyTable width(correlation_length_nm)=107,width(disorder_D_eV)=77,width(disorder_A_eV)=77
	ModifyTable width(temperature_K)=76,width(internal_potential_V)=98,width(R_recombination)=85
	ModifyTable width(polaron_delocalization_nm)=127,width(R_electron_hop)=80,width(R_hole_hop)=63
	SetDataFolder fldrSav0
EndMacro

Window EMT_ToF_Table() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Excimontec:'Time of Flight Tests':
	Edit/W=(81.75,83.75,1512.75,347.75) version,set_num,job_id,kmc_algorithm,morphology as "ToF Table"
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
	Edit/W=(264,46.25,1853.25,368) version,job_id,morphology,kmc_algorithm,N_variants as "IQE Table"
	AppendToTable lattice_length,lattice_width,lattice_height,unit_size_nm,disorder_model
	AppendToTable correlation_model,correlation_length_nm,disorder_D_eV,disorder_A_eV
	AppendToTable polaron_delocalization_nm,temperature_K,internal_potential_V,dissociation_yield
	AppendToTable separation_yield,extraction_yield,IQE,calc_time_min
	ModifyTable format(Point)=1,width(Point)=35,width(version)=59,width(job_id)=47,width(morphology)=97
	ModifyTable width(kmc_algorithm)=76,width(N_variants)=57,width(lattice_length)=70
	ModifyTable width(lattice_width)=66,width(lattice_height)=70,width(unit_size_nm)=70
	ModifyTable width(disorder_model)=110,width(correlation_model)=89,width(correlation_length_nm)=107
	ModifyTable width(disorder_D_eV)=77,width(disorder_A_eV)=77,width(polaron_delocalization_nm)=108
	ModifyTable width(temperature_K)=76,width(internal_potential_V)=98,width(dissociation_yield)=89
	ModifyTable width(IQE)=47,width(calc_time_min)=75
	SetDataFolder fldrSav0
EndMacro