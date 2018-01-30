#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function GraphTOFCurrent(job_id) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	SetDataFolder root:KMC_Simulations:$(job_id)
	PauseUpdate; Silent 1		// building window...
	Wave Current__mA_cm__2_, Time__s_
	Display /W=(520.5,419,915,694.25) Current__mA_cm__2_ vs Time__s_
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

Function GraphTOFEnergy(job_id) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	SetDataFolder root:KMC_Simulations:$(job_id)
	PauseUpdate; Silent 1		// building window...
	Wave Average_Energy__eV_, Time__s_
	Display /W=(928.5,420.5,1323,695.75) Average_Energy__eV_ vs Time__s_
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

Function GraphTOFSeries(job_id1,[job_id2,job_id3,job_id4,job_id5,job_id6]) : Graph
	String job_id1, job_id2, job_id3, job_id4, job_id5, job_id6
	String original_folder = GetDataFolder(1)
	// Current Transients
	GraphTOFCurrent(job_id1)
	if(!ParamIsDefault(job_id2))
		SetDataFolder root:KMC_Simulations:$(job_id2)
		AppendToGraph :Current__mA_cm__2_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id3))
		SetDataFolder root:KMC_Simulations:$(job_id3)
		AppendToGraph :Current__mA_cm__2_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id4))
		SetDataFolder root:KMC_Simulations:$(job_id4)
		AppendToGraph :Current__mA_cm__2_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id5))
		SetDataFolder root:KMC_Simulations:$(job_id5)
		AppendToGraph :Current__mA_cm__2_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id6))
		SetDataFolder root:KMC_Simulations:$(job_id6)
		AppendToGraph :Current__mA_cm__2_ vs :Time__s_
	endif
	ModifyGraph mode=0,lsize=2
	ModifyGraph/Z rgb[1]=(65535,0,0), rgb[2]=(2,39321,1), rgb[3]=(0,0,0), rgb[4]=(65535,0,52428), rgb[5]=(1,52428,52428)
	// Carrier Energy Transients
	GraphTOFEnergy(job_id1)
	if(!ParamIsDefault(job_id2))
		SetDataFolder root:KMC_Simulations:$(job_id2)
		AppendToGraph :Average_Energy__eV_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id3))
		SetDataFolder root:KMC_Simulations:$(job_id3)
		AppendToGraph :Average_Energy__eV_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id4))
		SetDataFolder root:KMC_Simulations:$(job_id4)
		AppendToGraph :Average_Energy__eV_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id5))
		SetDataFolder root:KMC_Simulations:$(job_id5)
		AppendToGraph :Average_Energy__eV_ vs :Time__s_
	endif
	if(!ParamIsDefault(job_id6))
		SetDataFolder root:KMC_Simulations:$(job_id6)
		AppendToGraph :Average_Energy__eV_ vs :Time__s_
	endif
	ModifyGraph mode=0,lsize=2
	ModifyGraph/Z rgb[1]=(65535,0,0), rgb[2]=(2,39321,1), rgb[3]=(0,0,0), rgb[4]=(65535,0,52428), rgb[5]=(1,52428,52428)
	SetDataFolder original_folder
End

Function GraphTOFTransients(job_id) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	SetDataFolder root:KMC_Simulations:$(job_id)
	Wave current = $("Current__mA_cm__2_")
	Wave energy = $("Average_Energy__eV_")
	Wave times = $("Time__s_")
	PauseUpdate; Silent 1		// building window...
	Display /W=(520.5,419,915,694.25) current vs times
	AppendToGraph/R energy vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker(Current__mA_cm__2_)=19,marker(Average_Energy__eV_)=16
	ModifyGraph rgb(Current__mA_cm__2_)=(0,0,65535)
	ModifyGraph rgb(Average_Energy__eV_)=(65535,0,0)
	ModifyGraph log(left)=1,log(bottom)=1
	ModifyGraph tick=2
	ModifyGraph zero(bottom)=1
	ModifyGraph mirror(bottom)=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125,axOffset(right)=-2
	Label left "Current Density (mA cm\\S-2\\M)"
	Label bottom "Time (s)"
	Label right "Average Carrier Energy (eV)"
	SetAxis/A left
	SetAxis bottom 1e-10,0.0001
	SetAxis right -5.1,-5
	SetDataFolder original_folder
End