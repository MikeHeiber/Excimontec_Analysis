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

