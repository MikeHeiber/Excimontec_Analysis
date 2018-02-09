#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 0.2-alpha

// Copyright (c) 2018 Michael C. Heiber
// This source file is part of the Excimontec_Analysis project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec_Analysis project can be found on Github at https://github.com/MikeHeiber/Excimontec_Analysis

Function EMT_GraphDynamicsTransients([job_id])
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob("Dynamics Tests")
		if(StringMatch(job_id,""))
			 return NaN
		 endif
	endif
	SetDataFolder root:Excimontec:$"Dynamics Tests":$job_id
	Wave singlets = $("Singlet_Exciton_Density__cm__3_")
	Wave triplets = $("Triplet_Exciton_Density__cm__3_")
	Wave electrons = $("Electron_Density__cm__3_")
	Wave holes = $("Hole_Density__cm__3_")
	Wave exciton_energy = $("Average_Exciton_Energy__eV_")
	Wave electron_energy = $("Average_Electron_Energy__eV_")
	Wave hole_energy = $("Average_Hole_Energy__eV_")
	Wave times = $("Time__s_")
	PauseUpdate; Silent 1		// building window...
	Display /W=(100,100,700,400) singlets vs times
	AppendToGraph triplets vs times
	AppendToGraph electrons vs times
	AppendToGraph/R exciton_energy vs times
	AppendToGraph/R electron_energy vs times
	AppendToGraph/R hole_energy vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker[0]=19,marker[1]=16,marker[2]=17
	ModifyGraph marker[3]=23,marker[4]=46,marker[5]=49
	ModifyGraph useMrkStrokeRGB=1
	ModifyGraph rgb[0]=(0,0,65535), rgb[1]=(65535,0,0), rgb[2]=(2,39321,1)
	ModifyGraph rgb[3]=(65535,0,52428), rgb[4]=(1,52428,52428), rgb[5]=(65535,43690,0)
	ModifyGraph log(left)=1, log(bottom)=1
	ModifyGraph standoff=0, tick=2
	ModifyGraph mirror(bottom)=1
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125,axOffset(right)=-2
	ModifyGraph margin(right)=44
	Label left "Density (cm\\S-3\\M)"
	Label right "Average Normalized Energy (eV)"
	Label bottom "Time (s)"
	SetAxis/A=2 left
	SetAxis right *,0
	SetAxis/A/N=1 bottom
	Legend/C/N=text0/J/F=0/RT/X=5.00/Y=5.00 "Density\r\\s(Singlet_Exciton_Density__cm__3_) Singlets\r\\s(Triplet_Exciton_Density__cm__3_) Triplets"
	AppendText "\\s(Electron_Density__cm__3_) Electrons\r\rEnergy\r\\s(Average_Exciton_Energy__eV_) Excitons\r\\s(Average_Electron_Energy__eV_) Electrons\r\\s(Average_Hole_Energy__eV_) Holes"
	TextBox/C/N=text1/A=MT/F=0/X=0.00/Y=5.00 job_id
	ResumeUpdate
	// Plot Mean Squared Displacement Derivative Data
	//Wave exciton_msdv = $"Exciton_MSDV__cm_2_s__1_"
	//Wave electron_msdv = $"Electron_MSDV__cm_2_s__1_"
	//Wave hole_msdv = $"Hole_MSDV__cm_2_s__1_"
	//PauseUpdate; Silent 1		// building window...
	//Display /W=(720,100,1100,400) exciton_msdv vs times
	//AppendToGraph electron_msdv vs times
	//AppendToGraph hole_msdv vs times
	//ModifyGraph mode=4,msize=2
	//ModifyGraph marker[0]=19,marker[1]=16,marker[2]=17
	//ModifyGraph useMrkStrokeRGB=1
	//ModifyGraph rgb[0]=(0,0,65535), rgb[1]=(65535,0,0), rgb[2]=(2,39321,1)
	//ModifyGraph log=1, standoff=0, tick=2, mirror=1
	//ModifyGraph margin(left)=43, margin(right)=10, margin(top)=10
	//SetAxis/A=2 left
	//SetAxis/A/N=1 bottom
	//Label left "d 〈 r\\S2\\M 〉 / dt (cm\\S2\\Ms\\S-1\\M)"
	//Label bottom "Time (s)"
	//Legend/C/N=text0/J/F=0/E=2/RT/X=5.00/Y=5.00 "\\s(Exciton_MSDV__cm_2_s__1_) Excitons\r\\s(Electron_MSDV__cm_2_s__1_) Electrons\r\\s(Hole_MSDV__cm_2_s__1_) Holes"
	//TextBox/C/N=text1/A=MT/F=0/X=0.00/Y=5.00 job_id
End

Function EMT_GraphExtractionMaps(test_type,[job_id])
	String test_type
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob(test_type)
		if(StringMatch(job_id,""))
			 return NaN
		 endif
	endif
	String variant_id = EMT_ChooseVariant(test_type,job_id)
	if(StringMatch(variant_id,""))
		return NaN
	endif
	SetDataFolder root:Excimontec:$(test_type):$(job_id):$"Extraction Map Data"
	if(StringMatch(test_type,"IQE Tests"))		
		Wave extraction_prob = $("electron_extraction_prob"+variant_id)
		EMT_GraphExtractionMap(extraction_prob)
		Wave extraction_prob = $("hole_extraction_prob"+variant_id)
		EMT_GraphExtractionMap(extraction_prob)
	else
		Wave extraction_prob = $("charge_extraction_prob"+variant_id)
		EMT_GraphExtractionMap(extraction_prob)
	endif
	SetDataFolder original_folder
End

Function EMT_GraphExtractionMap(prob_matrix) : Graph
	Wave prob_matrix
	Display; AppendMatrixContour prob_matrix; DelayUpdate
	ModifyContour '' update=0,autoLevels={0,*,15},ctabLines={0,*,BlueHot256,0}
	ModifyContour '' fill=1,ctabFill={0,*,BlueHot256,0},boundary=0,labels=0
	ModifyGraph margin(left)=56,margin(top)=14,margin(right)=70,margin(bottom)=42
	ModifyGraph width=600,height=450
	ModifyGraph mirror=1,standoff=0,tick=1
	ColorScale/C/N=text0/F=0/A=RT/X=1/Y=1/E=2  ctab={0,1,BlueHot256,0}
	ColorScale/C/N=text0 fsize=12
	DoUpdate
End

Function EMT_GraphTOFCurrent([job_id]) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob("Time of Flight Tests")
		if(StringMatch(job_id,""))
			 return NaN
		 endif
	endif
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	PauseUpdate; Silent 1		// building window...
	Display /W=(520.5,419,915,694.25) :Current__mA_cm__2_ vs :Time__s_
	ModifyGraph mode=0,lsize=2
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph log=1, tick=2, mirror=1, standoff=0
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
		if(StringMatch(job_id,""))
			 return NaN
		 endif
	endif
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	PauseUpdate; Silent 1		// building window...
	Display /W=(928.5,420.5,1323,695.75) :Average_Energy__eV_ vs :Time__s_
	ModifyGraph mode=0,lsize=2
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph log(left)=0,log(bottom)=1
	ModifyGraph tick=2, mirror=1, standoff=0
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

Function EMT_GraphTOFTransients([job_id]) : Graph
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob("Time of Flight Tests")
		if(StringMatch(job_id,""))
			 return NaN
		 endif
	endif
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	Wave current = $("Current__mA_cm__2_")
	Wave density = $("Carrier_Density__cm__3_")
	Wave mobility = $("Average_Mobility__cm_2_V__1_s__")
	Wave energy = $("Average_Energy__eV_")
	Wave times = $("Time__s_")
	// Current and Charge Carrier Density Transients
	PauseUpdate; Silent 1		// building window...
	Display /W=(100,100,520,400) current vs times
	AppendToGraph/R density vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker[0]=19,marker[1]=16
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph rgb[1]=(65535,0,0)
	ModifyGraph log=1, tick=2, standoff=0
	ModifyGraph mirror(bottom)=1
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125,axOffset(right)=-2
	Label left "Current Density (mA cm\\S-2\\M)"
	Label bottom "Time (s)"
	Label right "Charge Carrier Density (cm\\S-3\\M)"
	SetAxis/A left
	SetAxis/A right
	TextBox/C/N=text0/A=RT/F=0/X=8.00/Y=8.00 job_id
	ResumeUpdate
	// Average Mobility and Average Energy Transients
	PauseUpdate; Silent 1		// building window...
	Display /W=(550,100,970,400) mobility vs times
	AppendToGraph/R energy vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker[0]=19,marker[1]=16
	ModifyGraph rgb[0]=(0,0,65535)
	ModifyGraph rgb[1]=(65535,0,0)
	ModifyGraph log(left)=1, log(bottom)=1
	ModifyGraph standoff=0, tick=2
	ModifyGraph mirror(bottom)=1
	ModifyGraph axOffset(left)=-3,axOffset(bottom)=-0.3125,axOffset(right)=-2
	Label left "Average Mobility (cm\\S2\\MV\\S-1\\Ms\\S-1\\M)"
	Label bottom "Time (s)"
	Label right "Average Carrier Energy (eV)"
	SetAxis/A left
	SetAxis right *,0
	TextBox/C/N=text0/A=RT/F=0/X=8.00/Y=8.00 job_id
	ResumeUpdate
	SetDataFolder original_folder
End

Function EMT_GraphTOFTransitDist([job_id])
	String job_id
	String original_folder = GetDataFolder(1)
	if(ParamIsDefault(job_id))
		job_id = EMT_ChooseJob("Time of Flight Tests")
		if(StringMatch(job_id,""))
			 return NaN
		 endif
	endif
	SetDataFolder root:Excimontec:$"Time of Flight Tests":$job_id
	Display /W=(100,100,520,400) :Probability vs :Transit_Time__s_
	ModifyGraph mirror=1, standoff=0, tick=2
	ModifyGraph log(bottom)=1
	ModifyGraph mode=4,msize=2,marker=19
	ModifyGraph useMrkStrokeRGB=1
	ModifyGraph margin(right)=7, margin(top)=10, margin(left)=43
	Label left "Probability Density"
	Label bottom "Transit Time (s)"
	TextBox/C/N=text0/A=RT/F=0/X=8.00/Y=8.00 job_id
	SetDataFolder original_folder
End