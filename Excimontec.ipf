#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 1.0-beta.2

// Copyright (c) 2018 Michael C. Heiber
// This source file is part of the Excimontec project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec project can be found on Github at https://github.com/MikeHeiber/Excimontec

#include <KBColorizeTraces>

Menu "Excimontec"
	"Load New Job", /Q, EMT_ImportData()
	Submenu "Time of Flight"
		"Plot ToF Transients", /Q, EMT_PlotTOFTransients()
		//"Plot ToF Field Dependence", /Q, FEDMS_PlotTOF_FieldDependences()
		//"Plot ToF Temperature Dependence", /Q, FEDMS_PlotTOF_TempDependence()
	End
End