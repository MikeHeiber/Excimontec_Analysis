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
	Label left "Species Density (cm\\S-3\\M)"
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
	Wave exciton_msdv = $"Exciton_MSDV__cm_2_s__1_"
	Wave electron_msdv = $"Electron_MSDV__cm_2_s__1_"
	Wave hole_msdv = $"Hole_MSDV__cm_2_s__1_"
	PauseUpdate; Silent 1		// building window...
	Display /W=(720,100,1100,400) exciton_msdv vs times
	AppendToGraph electron_msdv vs times
	AppendToGraph hole_msdv vs times
	ModifyGraph mode=4,msize=2
	ModifyGraph marker[0]=19,marker[1]=16,marker[2]=17
	ModifyGraph useMrkStrokeRGB=1
	ModifyGraph rgb[0]=(0,0,65535), rgb[1]=(65535,0,0), rgb[2]=(2,39321,1)
	ModifyGraph log=1, standoff=0, tick=2, mirror=1
	ModifyGraph margin(left)=43, margin(right)=10, margin(top)=10
	SetAxis/A=2 left
	SetAxis/A/N=1 bottom
	Label left "d 〈 r\\S2\\M 〉 / dt (cm\\S2\\Ms\\S-1\\M)"
	Label bottom "Time (s)"
	Legend/C/N=text0/J/F=0/E=0/RT/X=5.00/Y=5.00 "\\s(Exciton_MSDV__cm_2_s__1_) Excitons\r\\s(Electron_MSDV__cm_2_s__1_) Electrons\r\\s(Hole_MSDV__cm_2_s__1_) Holes"
	TextBox/C/N=text1/A=MT/F=0/X=0.00/Y=5.00 job_id
End

Function EMT_GraphEnergiesCrossSection(slice_num,unit_size) : Graph
	Variable slice_num
	Variable unit_size
	String original_folder = GetDataFolder(1)
	LoadWave/N=tempWave/D/J/K=1/L={0,0,0,0,0}/O/Q 
	Wave tempWave0 = $("tempWave0")
	WaveStats/Q tempWave0
	Variable size = V_npnts
	Variable Length = tempWave0[0]
	Variable Width = tempWave0[1]
	Variable Height = tempWave0[2]
	Make/O/I/N=(Width*Height) $("y_data_"+num2str(slice_num))
	Make/O/I/N=(Width*Height) $("z_data_"+num2str(slice_num))
	Make/O/D/N=(Width*Height) $("energy_data_"+num2str(slice_num))
	Wave y_data = $("y_data_"+num2str(slice_num))
	Wave z_data = $("z_data_"+num2str(slice_num))
	Wave energy_data = $("energy_data_"+num2str(slice_num))
	Variable x
	Variable y
	Variable z
	Variable i = 0
	Variable j = 3
	for(x=0;x<Length;x+=1)
		for(y=0;y<Width;y+=1)
			for(z=0;z<Height;z+=1)
				if(x==slice_num)
					y_data[i] = y
					z_data[i] = z
					energy_data[i] = tempWave0[j]
					i += 1
				endif
				j += 1
				if(x>slice_num)
					break
				endif
			endfor
			if(x>slice_num)
				break
			endif
		endfor
		if(x>slice_num)
			break
		endif
	endfor
	KillWaves tempWave0
	SetDataFolder original_folder
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
	SetDataFolder root:Excimontec:$(test_type):$(job_id)
	if(DataFolderExists("Extraction Map Data")==0)
		Print "Error! Job "+job_id+" does not have extraction map data."
		return NaN
	endif
	SetDAtaFolder $"Extraction Map Data"
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

Function EMT_GraphTOFMobilityF(set_start,set_end) : Graph
	int set_start
	int set_end
	int i
	int set_counter = 0
	String set_list = ""
	for(i=set_start;i<=set_end;i++)
		set_list = AddListItem(num2str(i),set_list,",",ItemsInList(set_list,","))
	endfor
	EMT_GraphTOFMobilityF_List(set_list)
End

Function EMT_GraphTOFMobilityF_List(set_list) : Graph
	String set_list
	String original_folder = GetDataFolder(1)
	SetDataFolder root:Excimontec:$"Time of Flight Tests":
	Wave mobility_avg
	Wave field_sqrt
	Wave set_num
	Variable i
	Variable set_counter = 0
	for(i=0;i<ItemsInList(set_list,",");i++)
		Variable index_start = -1
		Variable index_end = -1
		Variable j
		Variable set_number = str2num(StringFromList(i,set_list,","))
		for(j=0;j<numpnts(set_num);j++)
			if(index_start==-1 && set_num[j]==set_number)
				index_start = j
			elseif(index_start!=-1 && set_num[j]!=set_number)
				index_end = j-1
				break
			elseif(index_start!=-1 && j==numpnts(set_num)-1)
				index_end = j
				break
			endif
		endfor
		if(index_start==-1 || index_end==-1)
			Print "Error! Set "+num2str(i)+" could not be found."
			return NaN
		endif
		if(set_counter==0)
			PauseUpdate;
			Display/W=(100,100,500,350) mobility_avg[index_start,index_end] vs field_sqrt[index_start,index_end]
		else
			AppendToGraph mobility_avg[index_start,index_end] vs field_sqrt[index_start,index_end]
		endif
		set_counter++
	endfor
	for(i=0;i<set_counter;i++)
		if(i==0)
			ModifyGraph marker[i] = 19
			ModifyGraph rgb[i] = (0,0,65535)
		elseif(i==1)
			ModifyGraph marker[i] = 16
			ModifyGraph rgb[i] = (52428,1,1)
		elseif(i==2)
			ModifyGraph marker[i] = 17
			ModifyGraph rgb[i] = (2,39321,1)
		elseif(i==3)
			ModifyGraph marker[i] = 23
			ModifyGraph rgb[i] = (0,0,0)
		elseif(i==4)
			ModifyGraph marker[i] = 46
			ModifyGraph rgb[i] = (1,52528,52428)
		elseif(i==5)
			ModifyGraph marker[i] = 49
			ModifyGraph rgb[i] = (65535,0,52428)
		elseif(i==6)
			ModifyGraph marker[i] = 26
			ModifyGraph rgb[i] = (65535,43690,0)
		endif
	endfor
	ModifyGraph margin(top)=10, margin(right)=14, margin(bottom)=36, margin(left)=46
	ModifyGraph mode=4, msize=2, log(left)=1, tick=2, mirror=1, standoff=0
	ModifyGraph logHTrip(left)=100,logLTrip(left)=0.01
	Label left "Charge Carrier Mobility (cm\\S2\\MV\\S-1\\Ms\\S-1\\M)"
	Label bottom "Electric Field, F\\S1/2\\M (V/cm)\\S1/2\\M"
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
	ModifyGraph lowTrip(right)=0.01
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