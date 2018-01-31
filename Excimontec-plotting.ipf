#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 0.1.1-alpha

// Copyright (c) 2018 Michael C. Heiber
// This source file is part of the Excimontec_Analysis project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec_Analysis project can be found on Github at https://github.com/MikeHeiber/Excimontec_Analysis

Function EMT_GraphTOFCurrent([job_id]) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob("Time of Flight Tests")
	endif
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	PauseUpdate; Silent 1		// building window...
	Display /W=(520.5,419,915,694.25) :Current__mA_cm__2_ vs :Time__s_
	ModifyGraph mode=0,lsize=2
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph log(left)=1,log(bottom)=1
	ModifyGraph tick=2
	ModifyGraph zero(bottom)=1
	ModifyGraph mirror=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125
	Label left "Current Density (mA cm\\S-2\\M)"
	Label bottom "Time (s)"
	SetAxis/A left
	SetAxis/A bottom
	SetDataFolder original_folder
End

Function EMT_GraphTOFEnergy([job_id]) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob("Time of Flight Tests")
	endif
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	PauseUpdate; Silent 1		// building window...
	Display /W=(928.5,420.5,1323,695.75) :Average_Energy__eV_ vs :Time__s_
	ModifyGraph mode=0,lsize=2
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph log(left)=0,log(bottom)=1
	ModifyGraph tick=2
	ModifyGraph zero(bottom)=1
	ModifyGraph mirror=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125
	Label left "Average Carrier Energy (mA cm\\S-2\\M)"
	Label bottom "Time (s)"
	SetAxis/A left
	SetAxis/A bottom
	SetDataFolder original_folder
End

Function EMT_GraphTOFSeries(job_list) : Graph
	String job_list
	String job_id
	String original_folder = GetDataFolder(1)
	// Current Transients
	Variable i
	for(i=0;i<ItemsInList(job_list);i+=1)
		job_id = StringFromList(i,job_list)
		if(i==0)
			EMT_GraphTOFCurrent(job_id=job_id)
		else
			SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
			AppendToGraph :Current__mA_cm__2_ vs :Time__s_
		endif	
	endfor
	ModifyGraph mode=0,lsize=2
	ModifyGraph/Z rgb[1]=(65535,0,0), rgb[2]=(2,39321,1), rgb[3]=(0,0,0), rgb[4]=(65535,0,52428), rgb[5]=(1,52428,52428)
	// Carrier Energy Transients
	for(i=0;i<ItemsInList(job_list);i+=1)
		job_id = StringFromList(i,job_list)
		if(i==0)
			EMT_GraphTOFEnergy(job_id=job_id)
		else
			SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
			AppendToGraph :Average_Energy__eV_ vs :Time__s_
		endif	
	endfor
	ModifyGraph mode=0,lsize=2
	ModifyGraph/Z rgb[1]=(65535,0,0), rgb[2]=(2,39321,1), rgb[3]=(0,0,0), rgb[4]=(65535,0,52428), rgb[5]=(1,52428,52428)
	SetDataFolder original_folder
End

Function EMT_GraphTOFTransients() : Graph
	String job_id = EMT_ChooseJob("Time of Flight Tests")
	String original_folder = GetDataFolder(1)
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	Wave current = $("Current__mA_cm__2_")
	Wave density = $("Carrier_Density__cm__3_")
	Wave mobility = $("Average_Mobility__cm_2_V__1_s__")
	Wave energy = $("Average_Energy__eV_")
	Wave times = $("Time__s_")
	// Current and Charge Carrier Density Transients
	PauseUpdate; Silent 1		// building window...
	Display /W=(520.5,419,915,694.25) current vs times
	AppendToGraph/R density vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker[0]=19,marker[1]=16
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph rgb[1]=(65535,0,0)
	ModifyGraph log=1
	ModifyGraph tick=2
	ModifyGraph zero(bottom)=1
	ModifyGraph mirror(bottom)=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125,axOffset(right)=-2
	Label left "Current Density (mA cm\\S-2\\M)"
	Label bottom "Time (s)"
	Label right "Charge Carrier Density (cm\\S-3\\M)"
	SetAxis/A left
	SetAxis/A right
	SetAxis bottom 1e-9,*
	TextBox/C/N=text0/A=RT/F=0/X=10.00/Y=10.00 job_id
	ResumeUpdate
	// Average Mobility and Average Energy Transients
	PauseUpdate; Silent 1		// building window...
	Display /W=(928.5,419,1323,694.25) mobility vs times
	AppendToGraph/R energy vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker[0]=19,marker[1]=16
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph rgb[1]=(65535,0,0)
	ModifyGraph log(left)=1, log(bottom)=1
	ModifyGraph tick=2
	ModifyGraph zero(bottom)=1
	ModifyGraph mirror(bottom)=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125,axOffset(right)=-2
	Label left "Average Mobility (cm\\S2\\MV\\S-1\\Ms\\S-1\\M)"
	Label bottom "Time (s)"
	Label right "Average Carrier Energy (eV)"
	SetAxis/A left
	SetAxis/A right
	SetAxis bottom 1e-9,*
	TextBox/C/N=text0/A=RT/F=0/X=10.00/Y=10.00 job_id
	ResumeUpdate
	SetDataFolder original_folder
End