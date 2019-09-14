#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 1.0-beta.1

// Copyright (c) 2018-2019 Michael C. Heiber
// This source file is part of the Excimontec_Analysis project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec_Analysis project can be found on Github at https://github.com/MikeHeiber/Excimontec_Analysis

Function/S EMT_ChooseJob(test_type)
	String test_type
	String original_folder = GetDataFolder(1)
	// Build the sample list
	String job_id
	SetDataFolder root:Excimontec:$test_type
	String job_list = ""
	DFREF dfr1 = GetDataFolderDFR()
	Variable N_jobs = CountObjectsDFR(dfr1,4)
	String folder_name
	Variable i
	for(i=0;i<N_jobs;i+=1)
		folder_name = GetIndexedObjNameDFR(dfr1,4,i)
		job_list = AddListItem(folder_name,job_list)
	endfor
	job_list = SortList(job_list,";",16)
	// Prompt user to choose the sample
	Prompt job_id, "Choose the job id:", popup, job_list
	DoPrompt "Make Selections",job_id
	// User cancelled operation
	if(V_flag!=0)
		SetDataFolder original_folder
		return ""
	endif
	SetDataFolder original_folder
	return job_id
End

Function/S EMT_ChooseSet(test_type)
	String test_type
	String original_folder = GetDataFolder(1)
	// Build the set list
	SetDataFolder root:Excimontec:$test_type
	Wave set_num
	String set_list = ""
	Variable i
	for(i=0;i<numpnts(set_num);i+=1)
		if(WhichListItem(num2str(set_num[i]),set_list)==-1)
			set_list = AddListItem(num2str(set_num[i]),set_list)
		endif
	endfor
	set_list = SortList(set_list,";",16)
	// Prompt user to choose the set
	String set_id
	Prompt set_id, "Choose the set number:", popup, set_list
	DoPrompt "Make Selection",set_id
	// User cancelled operation
	if(V_flag!=0)
		SetDataFolder original_folder
		return ""
	endif
	SetDataFolder original_folder
	return set_id
End

Function/S EMT_ChooseVariant(test_type,job_id)
	String test_type
	String job_id
	String original_folder = GetDataFolder(1)
	// Build the variant list
	SetDataFolder root:Excimontec:$(test_type)
	Wave/T jobs = $("job_id")
	Wave N_variants
	Variable index
	FindValue /TEXT=(job_id) /TXOP=2 jobs
	if(V_value<0)
		SetDataFolder original_folder
		Print "Error: Job data not found."
		return ""
	else
		index = V_value
	endif
	String variant_list = ""
	Variable i
	for(i=0;i<N_variants[index];i++)
		variant_list = AddListItem(num2str(i),variant_list)
	endfor
	// Prompt user to choose the sample
	String variant_id
	Prompt variant_id, "Choose the variant:", popup, variant_list
	DoPrompt "Make Selections",variant_id
	// User cancelled operation
	if(V_flag!=0)
		SetDataFolder original_folder
		return ""
	endif
	SetDataFolder original_folder
	return variant_id
End

Function EMT_ImportDataGUI()
	String original_folder = GetDataFolder(1)
	NewDataFolder/O/S root:Excimontec
	// Open new job folder
	NewPath/O/Q folder_path
	if(V_flag!=0)
		SetDataFolder original_folder
		return NaN
	endif
	PathInfo folder_path
	Print "•EMT_ImportData(\""+S_path+"\",0)"
	EMT_ImportData(S_path,NaN)	
End

Function EMT_ImportData(folder_pathname,set_num,[set_index])
	String folder_pathname
	Variable set_num
	Variable set_index
	String original_folder = GetDataFolder(1)
	NewDataFolder/O/S root:Excimontec
	// Check that path exists
	GetFileFolderInfo/Q/Z=1 folder_pathname
	if(V_Flag!=0)
		Print "Error! Job folder not found."
		return NaN
	endif
	NewPath/O/Q folder_path folder_pathname
	String job_name = StringFromList(ItemsInList(folder_pathname,":")-1,folder_pathname,":")
	// Load analysis summary file to extract version number
	LoadWave/J/A=analysisWave/P=folder_path/K=0/Q "analysis_summary.txt"
	Wave/T analysisWave0
	String version_used = StringFromList(1,StringFromList(0,analysisWave0[0]," Results"),"tec ")
	Variable major_version_num = str2num(StringFromList(0,StringFromList(1,version_used,"v"),"."))
	Variable minor_version_num = str2num(StringFromList(1,StringFromList(1,version_used,"v"),"."))
	Variable version_num = major_version_num+0.1*minor_version_num
	// Load parameter file
	String file_list = IndexedFile(folder_path,-1,".txt")
	String parameter_filename
	if(ItemsInList(file_list))
		parameter_filename = StringFromList(0,ListMatch(file_list,"parameters*"))
	else
		Print "Error! Parameter file not found!"
		return NaN
	endif
	LoadWave/A=parameterWave/J/Q/K=2/V={""," $",0,0}/P=folder_path parameter_filename
	Wave/T parameterWave0
	// Check for exciton diffusion test
	Variable Exciton_Diff_Test = 0
	if(StringMatch(StringFromList(0,parameterWave0[35]," //"),"true"))
		NewDataFolder/O/S $("Exciton Diffusion Tests")
		Exciton_Diff_Test = 1
	endif
	Variable TOF_Test = 0
	Variable IQE_Test = 0
	Variable Dynamics_Test = 0
	Variable Steady_Test = 0
	// Check for ToF test
	if(StringMatch(StringFromList(0,parameterWave0[36]," //"),"true"))
		NewDataFolder/O/S $("Time of Flight Tests")
		TOF_Test = 1
	// Check for IQE test
	elseif(StringMatch(StringFromList(0,parameterWave0[45]," //"),"true"))
		NewDataFolder/O/S $("IQE Tests")
		IQE_Test = 1
	// Check for Dynamics test
	elseif(StringMatch(StringFromList(0,parameterWave0[48]," //"),"true"))
		NewDataFolder/O/S $("Dynamics Tests")
		Dynamics_Test = 1
	// Check for Steady transport test
	elseif(StringMatch(StringFromList(0,parameterWave0[54]," //"),"true"))
		NewDataFolder/O/S $("Steady Transport Tests")
		Steady_Test = 1
	endif
	// Open Data Waves
	Wave/T/Z version
	if(!WaveExists(version))
		Make/N=1/T version
	endif
	Wave/Z set_nums = $"set_num"
	if(!WaveExists(set_nums))
		Make/N=1 $"set_num"/WAVE=set_nums
	endif
	Wave/T/Z job_id
	if(!WaveExists(job_id))
		Make/N=1/T job_id
	endif
	Wave/T/Z morphology
	if(!WaveExists(morphology))
		Make/N=1/T morphology
	endif
	Wave/T/Z kmc_algorithm
	if(!WaveExists(kmc_algorithm))
		Make/N=1/T kmc_algorithm
	endif
	Wave/Z lattice_length
	if(!WaveExists(lattice_length))
		Make/N=1 lattice_length
	endif
	Wave/Z lattice_width
	if(!WaveExists(lattice_width))
		Make/N=1 lattice_width
	endif
	Wave/Z lattice_height
	if(!WaveExists(lattice_height))
		Make/N=1 lattice_height
	endif
	Wave/Z unit_size_nm
	if(!WaveExists(unit_size_nm))
		Make/N=1 unit_size_nm
	endif
	Wave/Z temperature_K
	if(!WaveExists(temperature_K))
		Make/N=1 temperature_K
	endif
	Wave/Z internal_potential_V
	if(!WaveExists(internal_potential_V))
		Make/N=1 internal_potential_V
	endif
	Wave/Z N_tests
	if(!WaveExists(N_tests))
		Make/N=1 N_tests
	endif
	Wave/Z N_variants
	if(!WaveExists(N_variants))
		Make/N=1 N_variants
	endif
	Wave/T/Z disorder_model
	if(!WaveExists(disorder_model))
		Make/N=1/T disorder_model
	endif
	Wave/T/Z correlation_model
	if(!WaveExists(correlation_model))
		Make/N=1/T correlation_model
	endif
	Wave/Z correlation_length_nm
	if(!WaveExists(correlation_length_nm))
		Make/N=1 correlation_length_nm
	endif
	Wave/Z calc_time_min
	if(!WaveExists(calc_time_min))
		Make/N=1 calc_time_min
	endif
	NewDataFolder/O/S $job_name
	Duplicate/O/T parameterWave0 Parameters
	Duplicate/O/T analysisWave0 AnalysisSummary
	KillWaves parameterWave0 analysisWave0
	FindValue /TEXT=(job_name) /TXOP=2 job_id
	Variable index = V_value
	if(index==-1)
		if(StringMatch(job_id[0],""))
			index = 0
		else
			index = numpnts(job_id)
		endif	
	endif
	if(!ParamIsDefault(set_index))
		FindValue /V=(set_num) set_nums
		index = V_value + set_index
	endif
	set_nums[index] = {set_num}
	version[index] = {version_used}
	job_id[index] = {job_name}
	// Record morphology used
	// Neat
	if(StringMatch(StringFromList(0,Parameters[20]," //"),"true"))
		morphology[index] = {"Neat"}
	// Bilayer	
	elseif(StringMatch(StringFromList(0,Parameters[21]," //"),"true"))
		morphology[index] = {"Bilayer - "+StringFromList(0,Parameters[22]," //")+"/"+StringFromList(0,Parameters[23]," //")}
	// Random blend
	elseif(StringMatch(StringFromList(0,Parameters[24]," //"),"true"))
		morphology[index] = {"Random blend - "+StringFromList(0,Parameters[25]," //")}
	// Imported morphology
	elseif(StringMatch(StringFromList(0,Parameters[26]," //"),"true") || StringMatch(StringFromList(0,Parameters[28]," //"),"true"))
		file_list = IndexedFile(folder_path,-1,".txt")
		if(ItemsInList(file_list))
			morphology[index] = {StringFromList(1,ListMatch(file_list,"morphology_*"),"_")}
		else
			morphology[index] = {""}
		endif
	endif
	// Record KMC event recalculation method used
	if(StringMatch(StringFromList(0,Parameters[3]," //"),"true"))
		kmc_algorithm[index] = {"FRM"}
	elseif(StringMatch(StringFromList(0,Parameters[4]," //"),"true"))
		kmc_algorithm[index] = {"selective"}
	elseif(StringMatch(StringFromList(0,Parameters[6]," //"),"true"))
		kmc_algorithm[index] = {"full"}
	endif
	// Record disorder model used
	// Gaussian
	if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
		// Correlated
		if(StringMatch(StringFromList(0,Parameters[117]," //"),"true"))
			disorder_model[index] = {"Gaussian-correlated"}
			correlation_length_nm[index] = {str2num(StringFromList(0,Parameters[118]," //"))}
			// Gaussian kernel
			if(StringMatch(StringFromList(0,Parameters[119]," //"),"true"))
				correlation_model[index] = {"Gaussian kernel"}
			// Power kernel
			else
				String power_kernel_exponent = StringFromList(0,Parameters[121]," //")
				correlation_model[index] = {"Power kernel, "+power_kernel_exponent}
			endif
		// Uncorrelated
		else
			disorder_model[index] = {"Gaussian-uncorrelated"}
			correlation_model[index] = {"none"}
			correlation_length_nm[index] = {0}
		endif
	// Exponential
	elseif(StringMatch(StringFromList(0,Parameters[115]," //"),"true"))
		Disorder_model[index] = {"Exponential-uncorrelated"}
		Correlation_model[index] = {"none"}
	// None
	else
		Disorder_model[index] = {"None"}
		Correlation_model[index] = {"none"}
	endif
	lattice_length[index] = {str2num(StringFromList(0,Parameters[12]," //"))}
	lattice_width[index] = {str2num(StringFromList(0,Parameters[13]," //"))}
	lattice_height[index] = {str2num(StringFromList(0,Parameters[14]," //"))}
	unit_size_nm[index] = {str2num(StringFromList(0,Parameters[15]," //"))}
	temperature_K[index] = {str2num(StringFromList(0,Parameters[16]," //"))}
	internal_potential_V[index] = {str2num(StringFromList(0,Parameters[17]," //"))}
	N_tests[index] = {str2num(StringFromList(0,Parameters[34]," //"))}
	N_variants[index] = {str2num(StringFromList(4,analysisSummary[1]," "))}
	calc_time_min[index] = {str2num(StringFromList(4,analysisSummary[2]," "))}
	// Perform Exciton Diffusion Test Specific Operations
	if(Exciton_Diff_Test)
		SetDataFolder root:Excimontec:$("Exciton Diffusion Tests")
		Wave/Z disorder_eV
		if(!WaveExists(disorder_eV))
			Make/N=1 disorder_eV
		endif
		Wave/Z R_hop
		if(!WaveExists(R_hop))
			Make/N=1 R_hop
		endif
		Wave/Z tau_sx
		if(!WaveExists(tau_sx))
			Make/N=1 tau_sx
		endif
		Wave/Z diffusion_length_avg
		if(!WaveExists(diffusion_length_avg))
			Make/N=1 diffusion_length_avg
		endif
		Wave/Z diffusion_length_stdev
		if(!WaveExists(diffusion_length_stdev))
			Make/N=1 diffusion_length_stdev
		endif
		Wave/Z hop_distance_avg
		if(!WaveExists(hop_distance_avg))
			Make/N=1 hop_distance_avg
		endif
		Wave/Z hop_distance_stdev
		if(!WaveExists(hop_distance_stdev))
			Make/N=1 hop_distance_stdev
		endif
		// Determine relevant disorder model used
		// Gaussian
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
			// donor disorder
			disorder_eV[index] = {str2num(StringFromList(0,parameters[112]," //"))}
		// Exponential
		elseif(StringMatch(StringFromList(0,Parameters[114]," //"),"true"))
			// donor disorder
			disorder_eV[index] = {str2num(StringFromList(0,parameters[115]," //"))}
		endif
		// create normalized disorder
		Duplicate/O disorder_ev disorder_norm
		disorder_norm = disorder_ev/(8.6173e-5*temperature_K)
		R_hop[index] = {str2num(StringFromList(0,parameters[65]," //"))}
		tau_sx[index] = {str2num(StringFromList(0,parameters[63]," //"))}
		diffusion_length_avg[index] = {str2num(StringFromList(4,AnalysisSummary[6]," "))}
		diffusion_length_stdev[index] = {str2num(StringFromList(6,AnalysisSummary[6]," "))}
		hop_distance_avg[index] = {str2num(StringFromList(4,AnalysisSummary[7]," "))}
		hop_distance_stdev[index] = {str2num(StringFromList(6,AnalysisSummary[7]," "))}
	endif
	// Perform TOF Test Specific Operations
	if(TOF_Test)
		SetDataFolder root:Excimontec:$("Time of Flight Tests")
		// Open TOF Data Waves
		Wave/Z disorder_eV
		if(!WaveExists(disorder_eV))
			Make/N=1 disorder_eV
		endif
		Wave/Z N_carriers
		if(!WaveExists(N_carriers))
			Make/N=1 N_carriers
		endif
		Wave/Z mobility_avg
		if(!WaveExists(mobility_avg))
			Make/N=1 mobility_avg
		endif
		Wave/Z mobility_stdev
		if(!WaveExists(mobility_stdev))
			Make/N=1 mobility_stdev
		endif
		Wave/Z localization_nm
		if(!WaveExists(localization_nm))
			Make/N=1 localization_nm
		endif
		// Load TOF Files
		SetDataFolder $job_name
		LoadWave/J/W/N/O/K=0/P=folder_path/Q "ToF_average_transients.txt"
		LoadWave/J/W/N/O/K=0/P=folder_path/Q "ToF_transit_time_hist.txt"
		LoadWave/J/Q/A=resultsWave/P=folder_path/K=2/V={""," $",0,0} "ToF_results.txt"
		// Determine absolute value of the current density
		Wave current = $"Current__mA_cm__2_"
		current = abs(current)
		// Determine absolute value of the mobility
		Wave mobility = $"Average_Mobility__cm_2_V__1_s__"
		mobility = abs(mobility)
		// Load charge extraction map data
		if(StringMatch(StringFromList(0,Parameters[44]," //"),"true"))
			NewDataFolder/O/S :$"Extraction Map Data"
			Variable i
			Variable j
			for(i=0;i<N_variants[index];i++)
				LoadWave/J/W/N/O/K=0/P=folder_path/Q "Charge_extraction_map"+num2str(i)+".txt"
				Wave X_Position, Y_Position, Extraction_Probability
				WaveStats/Q X_Position
				Variable X_max = V_max+1
				WaveStats/Q Y_Position
				Variable Y_max = V_max+1
				Make/O/N=(X_max,Y_max) $("charge_extraction_prob"+num2str(i))/WAVE=extraction_prob
				for(j=0;j<numpnts(X_Position);j++)
					extraction_prob[X_Position[j]][Y_Position[j]] = Extraction_Probability[j]
				endfor
				// Cleanup
				KillWaves X_Position Y_Position Extraction_Probability
			endfor
			SetDataFolder ::
		endif
		Wave/T resultsWave0
		// Determine relevant disorder model used
		// Gaussian
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
			// Electron transport
			if(StringMatch(StringFromList(0,Parameters[37]," //"),"electron"))
				disorder_eV[index] = {str2num(StringFromList(0,parameters[113]," //"))}
			// Hole transport
			else
				disorder_eV[index] = {str2num(StringFromList(0,parameters[112]," //"))}
			endif
			// Create normalized energy waves
			Wave Average_Energy__eV_
			Duplicate/O Average_Energy__eV_ Average_Energy_Normalized
			Average_Energy_Normalized /= disorder_eV[index]^2/(8.6173e-5*temperature_K[index])
		// Exponential
		elseif(StringMatch(StringFromList(0,Parameters[114]," //"),"true"))
			// Electron transport
			if(StringMatch(StringFromList(0,parameters[37]," //"),"electron"))
				disorder_eV[index] = {str2num(StringFromList(0,parameters[116]," //"))}
			// Hole transport
			else
				disorder_eV[index] = {str2num(StringFromList(0,parameters[115]," //"))}
			endif
		endif
		// Determine relevant localization
		// Electron transport
		if(StringMatch(StringFromList(0,parameters[37]," //"),"electron"))
			localization_nm[index] = {1/str2num(StringFromList(0,parameters[96]," //"))}
		// Hole transport
		else
			localization_nm[index] = {1/str2num(StringFromList(0,parameters[95]," //"))}
		endif
		N_carriers[index] = {str2num(StringFromList(0,Parameters[38]," //"))}
		mobility_avg[index] = {str2num(StringFromList(3,resultsWave0[1],","))}
		mobility_stdev[index] = {str2num(StringFromList(4,resultsWave0[1],","))}
		// Clean Up
		KillWaves resultsWave0
		// Update Analysis
		SetDataFolder ::
		Duplicate/O mobility_avg field field_sqrt disorder_norm
		field = abs(internal_potential_V)/(1e-7*lattice_height*unit_size_nm)
		field_sqrt = sqrt(abs(internal_potential_V)/(1e-7*lattice_height*unit_size_nm))
		// Calculate effective disorder for Gaussian DOS
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
			disorder_norm = disorder_eV/(8.617e-5*temperature_K)
		endif
	// Perform IQE test specific operations
	elseif(IQE_Test)
		SetDataFolder root:Excimontec:$("IQE Tests")
		// Open IQE Data Waves
		Wave/Z disorder_D_eV
		if(!WaveExists(disorder_D_eV))
			Make/N=1 disorder_D_eV
		endif
		Wave/Z disorder_A_eV
		if(!WaveExists(disorder_A_eV))
			Make/N=1 disorder_A_eV
		endif
		Wave/Z R_singlet_hop_D
		if(!WaveExists(R_singlet_hop_D))
			Make/N=1 R_singlet_hop_D
		endif
		Wave/Z R_singlet_hop_A
		if(!WaveExists(R_singlet_hop_A))
			Make/N=1 R_singlet_hop_A
		endif
		Wave/Z polaron_delocalization_nm
		if(!WaveExists(polaron_delocalization_nm))
			Make/N=1 polaron_delocalization_nm
		endif
		Wave/Z R_recombination
		if(!WaveExists(R_recombination))
			Make/N=1 R_recombination
		endif
		Wave/Z IQE
		if(!WaveExists(IQE))
			Make/N=1 IQE
		endif
		Wave/Z dissociation_yield
		if(!WaveExists(dissociation_yield))
			Make/N=1 dissociation_yield
		endif
		Wave/Z separation_yield
		if(!WaveExists(separation_yield))
			Make/N=1 separation_yield
		endif
		Wave/Z extraction_yield
		if(!WaveExists(extraction_yield))
			Make/N=1 extraction_yield
		endif
		// Load charge extraction map data
		if(StringMatch(StringFromList(0,parameters[44]," //"),"true"))
			NewDataFolder/O/S :$(job_name):$"Extraction Map Data"
			for(i=0;i<N_variants[index];i++)
				// Electrons
				LoadWave/J/W/N/O/K=0/P=folder_path/Q "Electron_extraction_map"+num2str(i)+".txt"
				Wave X_Position, Y_Position, Extraction_Probability
				WaveStats/Q X_Position
				X_max = V_max+1
				WaveStats/Q Y_Position
				Y_max = V_max+1
				Make/O/N=(X_max,Y_max) $("electron_extraction_prob"+num2str(i))/WAVE=extraction_prob
				for(j=0;j<numpnts(X_Position);j++)
					extraction_prob[X_Position[j]][Y_Position[j]] = Extraction_Probability[j]
				endfor
				// Holes
				LoadWave/J/W/N/O/K=0/P=folder_path/Q "Hole_extraction_map"+num2str(i)+".txt"
				Make/O/N=(X_max,Y_max) $("hole_extraction_prob"+num2str(i))/WAVE=extraction_prob
				for(j=0;j<numpnts(X_Position);j++)
					extraction_prob[X_Position[j]][Y_Position[j]] = Extraction_Probability[j]
				endfor
				// Cleanup
				KillWaves X_Position Y_Position Extraction_Probability
			endfor
			SetDataFolder ::
		endif
		R_singlet_hop_D[index] = {str2num(StringFromList(0,parameters[65]," //"))}
		R_singlet_hop_A[index] = {str2num(StringFromList(0,parameters[66]," //"))}
		R_recombination[index] = {str2num(StringFromList(0,parameters[101]," //"))}
		// Record disorder info
		// Gaussian
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
			disorder_D_eV[index] = {str2num(StringFromList(0,parameters[112]," //"))}
			disorder_A_eV[index] = {str2num(StringFromList(0,parameters[113]," //"))}
		// Exponential
		elseif(StringMatch(StringFromList(0,Parameters[114]," //"),"true"))
			disorder_D_eV[index] = {str2num(StringFromList(0,parameters[115]," //"))}
			disorder_A_eV[index] = {str2num(StringFromList(0,parameters[116]," //"))}
		endif
		if(StringMatch(StringFromList(0,Parameters[103]," //"),"true"))
			polaron_delocalization_nm[index] = {str2num(StringFromList(0,Parameters[104]," //"))}
		else
			polaron_delocalization_nm[index] = {0}
		endif
		dissociation_yield[index] = {str2num(StringFromList(0,analysisSummary[8],"%"))/100}
		separation_yield[index] = {(100-str2num(StringFromList(0,analysisSummary[16],"%")))/100}
		extraction_yield[index] = {str2num(StringFromList(0,analysisSummary[18],"%"))/100}
		IQE[index] = {str2num(StringFromList(1,StringFromList(0,analysisSummary[19],"%"),"= "))/100}
		Duplicate/O internal_potential_V electric_field electric_field_sqrt
		electric_field = abs(internal_potential_V/(lattice_height*1e-7))
		electric_field_sqrt = sqrt(abs(internal_potential_V)/(1e-7*lattice_height*unit_size_nm))
	// Perform dynamics test specific operations
	elseif (Dynamics_test)
		SetDataFolder root:Excimontec:$("Dynamics Tests")
		// Open Dynamics Data Waves
		Wave/T/Z z_periodic
		if(!WaveExists(z_periodic))
			Make/N=1/T z_periodic
		endif
		Wave/Z initial_conc
		if(!WaveExists(initial_conc))
			Make/N=1 initial_conc
		endif
		Wave/Z disorder_D_eV
		if(!WaveExists(disorder_D_eV))
			Make/N=1 disorder_D_eV
		endif
		Wave/Z disorder_A_eV
		if(!WaveExists(disorder_A_eV))
			Make/N=1 disorder_A_eV
		endif
		Wave/Z polaron_delocalization_nm
		if(!WaveExists(polaron_delocalization_nm))
			Make/N=1 polaron_delocalization_nm
		endif
		Wave/Z R_recombination
		if(!WaveExists(R_recombination))
			Make/N=1 R_recombination
		endif
		Wave/Z R_electron_hop
		if(!WaveExists(R_electron_hop))
			Make/N=1 R_electron_hop
		endif
		Wave/Z R_hole_hop
		if(!WaveExists(R_hole_hop))
			Make/N=1 R_hole_hop
		endif
		Wave/Z singlet_lifetime_D
		if(!WaveExists(singlet_lifetime_D))
			Make/N=1 singlet_lifetime_D
		endif
		Wave/Z singlet_lifetime_A
		if(!WaveExists(singlet_lifetime_A))
			Make/N=1 singlet_lifetime_A
		endif
		Wave/Z triplet_lifetime_D
		if(!WaveExists(triplet_lifetime_D))
			Make/N=1 triplet_lifetime_D
		endif
		Wave/Z triplet_lifetime_A
		if(!WaveExists(triplet_lifetime_A))
			Make/N=1 triplet_lifetime_A
		endif
		Wave/Z R_singlet_hop_D
		if(!WaveExists(R_singlet_hop_D))
			Make/N=1 R_singlet_hop_D
		endif
		Wave/Z R_singlet_hop_A
		if(!WaveExists(R_singlet_hop_A))
			Make/N=1 R_singlet_hop_A
		endif
		Wave/Z R_triplet_hop_D
		if(!WaveExists(R_triplet_hop_D))
			Make/N=1 R_triplet_hop_D
		endif
		Wave/Z R_triplet_hop_A
		if(!WaveExists(R_triplet_hop_A))
			Make/N=1 R_triplet_hop_A
		endif
		Wave/Z R_isc_D
		if(!WaveExists(R_isc_D))
			Make/N=1 R_isc_D
		endif
		Wave/Z R_isc_A
		if(!WaveExists(R_isc_A))
			Make/N=1 R_isc_A
		endif
		Wave/Z R_risc_D
		if(!WaveExists(R_risc_D))
			Make/N=1 R_risc_D
		endif
		Wave/Z R_risc_A
		if(!WaveExists(R_risc_A))
			Make/N=1 R_risc_A
		endif
		Wave/Z R_diss_D
		if(!WaveExists(R_diss_D))
			Make/N=1 R_diss_D
		endif
		Wave/Z R_diss_A
		if(!WaveExists(R_diss_A))
			Make/N=1 R_diss_A
		endif
		// Record boundary condition
		if(StringMatch(StringFromList(0,Parameters[11]," //"),"true"))
			z_periodic[index] = {"Yes"}
		else
			z_periodic[index] = {"No"}
		endif
		initial_conc[index] = {str2num(StringFromList(0,Parameters[50]," //"))}
		// Record disorder info
		// Gaussian
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
			disorder_D_eV[index] = {str2num(StringFromList(0,Parameters[112]," //"))}
			disorder_A_eV[index] = {str2num(StringFromList(0,Parameters[113]," //"))}
		// Exponential
		elseif(StringMatch(StringFromList(0,Parameters[114]," //"),"true"))
			disorder_D_eV[index] = {str2num(StringFromList(0,Parameters[115]," //"))}
			disorder_A_eV[index] = {str2num(StringFromList(0,Parameters[116]," //"))}
		endif
		if(StringMatch(StringFromList(0,Parameters[103]," //"),"true"))
			polaron_delocalization_nm[index] = {str2num(StringFromList(0,Parameters[104]," //"))}
		else
			polaron_delocalization_nm[index] = {0}
		endif
		singlet_lifetime_D[index] = {str2num(StringFromList(0,Parameters[61]," //"))}
		singlet_lifetime_A[index] = {str2num(StringFromList(0,Parameters[62]," //"))}
		triplet_lifetime_D[index] = {str2num(StringFromList(0,Parameters[63]," //"))}
		triplet_lifetime_A[index] = {str2num(StringFromList(0,Parameters[64]," //"))}
		R_singlet_hop_D[index] = {str2num(StringFromList(0,Parameters[65]," //"))}
		R_singlet_hop_A[index] = {str2num(StringFromList(0,Parameters[66]," //"))}
		R_triplet_hop_D[index] = {str2num(StringFromList(0,Parameters[69]," //"))}
		R_triplet_hop_A[index] = {str2num(StringFromList(0,Parameters[70]," //"))}
		R_isc_D[index] = {str2num(StringFromList(0,Parameters[84]," //"))}
		R_isc_A[index] = {str2num(StringFromList(0,Parameters[84]," //"))}
		R_risc_D[index] = {str2num(StringFromList(0,Parameters[86]," //"))}
		R_risc_A[index] = {str2num(StringFromList(0,Parameters[87]," //"))}
		R_diss_D[index] = {str2num(StringFromList(0,Parameters[81]," //"))}
		R_diss_A[index] = {str2num(StringFromList(0,Parameters[82]," //"))}
		R_recombination[index] = {str2num(StringFromList(0,Parameters[101]," //"))}
		R_electron_hop[index] = {str2num(StringFromList(0,Parameters[94]," //"))}
		R_hole_hop[index] = {str2num(StringFromList(0,Parameters[93]," //"))}
		// Import transient data
		SetDataFolder $job_name
		LoadWave/J/W/N/O/K=0/P=folder_path/Q "dynamics_average_transients.txt"
		Wave exciton_msdv = $"Exciton_MSDV__cm_2_s__1_"
		Wave electron_msdv = $"Electron_MSDV__cm_2_s__1_"
		Wave hole_msdv = $"Hole_MSDV__cm_2_s__1_"
		Duplicate/O exciton_msdv Exciton_Diffusion_Coef Electron_Mobility Hole_Mobility
		Exciton_Diffusion_Coef = exciton_msdv/6
		Electron_Mobility = electron_msdv/(6*8.61733e-5*temperature_K[index])
		Hole_Mobility = hole_msdv/(6*8.61733e-5*temperature_K[index])
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
 			Wave exciton_energy = $"Average_Exciton_Energy__eV_"
 			Wave electron_energy = $"Average_Electron_Energy__eV_"
 			Wave hole_energy = $"Average_Hole_Energy__eV_"
			Duplicate/O exciton_energy exciton_energy_norm
			Duplicate/O electron_energy electron_energy_norm
			Duplicate/O hole_energy hole_energy_norm
			exciton_energy_norm /= disorder_D_eV[index]^2/(8.6173e-5*temperature_K[index])
			electron_energy_norm /= disorder_A_eV[index]^2/(8.6173e-5*temperature_K[index])
			hole_energy_norm /= disorder_D_eV[index]^2/(8.6173e-5*temperature_K[index])
		endif
	// Perform steady transport test specific operations
	elseif(Steady_Test)
		SetDataFolder root:Excimontec:$("Steady Transport Tests")
		// Open steady transport test data waves
		Wave/Z carrier_density
		if(!WaveExists(carrier_density))
			Make/N=1 carrier_density
		endif
		Wave/Z disorder_D_eV
		if(!WaveExists(disorder_D_eV))
			Make/N=1 disorder_D_eV
		endif
		Wave/Z disorder_A_eV
		if(!WaveExists(disorder_A_eV))
			Make/N=1 disorder_A_eV
		endif
		Wave/Z R_hole_hop
		if(!WaveExists(R_hole_hop))
			Make/N=1 R_hole_hop
		endif
		Wave/Z localization_nm
		if(!WaveExists(localization_nm))
			Make/N=1 localization_nm
		endif
		Wave/Z N_equilibration_events
		if(!WaveExists(N_equilibration_events))
			Make/N=1 N_equilibration_events
		endif
		Wave/Z mobility_avg
		if(!WaveExists(mobility_avg))
			Make/N=1 mobility_avg
		endif
		Wave/Z mobility_stdev
		if(!WaveExists(mobility_stdev))
			Make/N=1 mobility_stdev
		endif
		Wave/Z equilibration_energy_noC_avg
		if(!WaveExists(equilibration_energy_noC_avg))
			Make/N=1 equilibration_energy_noC_avg
		endif
		Wave/Z equilibration_energy_noC_stdev
		if(!WaveExists(equilibration_energy_noC_stdev))
			Make/N=1 equilibration_energy_noC_stdev
		endif
		Wave/Z equilibration_energy_avg
		if(!WaveExists(equilibration_energy_avg))
			Make/N=1 equilibration_energy_avg
		endif
		Wave/Z equilibration_energy_stdev
		if(!WaveExists(equilibration_energy_stdev))
			Make/N=1 equilibration_energy_stdev
		endif
		Wave/Z transport_energy_noC_avg
		if(!WaveExists(transport_energy_noC_avg))
			Make/N=1 transport_energy_noC_avg
		endif
		Wave/Z transport_energy_noC_stdev
		if(!WaveExists(transport_energy_noC_stdev))
			Make/N=1 transport_energy_noC_stdev
		endif
		Wave/Z transport_energy_avg
		if(!WaveExists(transport_energy_avg))
			Make/N=1 transport_energy_avg
		endif
		Wave/Z transport_energy_stdev
		if(!WaveExists(transport_energy_stdev))
			Make/N=1 transport_energy_stdev
		endif
		Wave/Z mobility_stdev
		if(!WaveExists(mobility_stdev))
			Make/N=1 mobility_stdev
		endif
		carrier_density[index] = {str2num(StringFromList(0,Parameters[55]," //"))}
		// Record disorder info
		// Gaussian
		if(StringMatch(StringFromList(0,Parameters[111]," //"),"true"))
			disorder_D_eV[index] = {str2num(StringFromList(0,Parameters[112]," //"))}
			disorder_A_eV[index] = {str2num(StringFromList(0,Parameters[113]," //"))}
		// Exponential
		elseif(StringMatch(StringFromList(0,Parameters[114]," //"),"true"))
			disorder_D_eV[index] = {str2num(StringFromList(0,Parameters[115]," //"))}
			disorder_A_eV[index] = {str2num(StringFromList(0,Parameters[116]," //"))}
		endif
		R_hole_hop[index] = {str2num(StringFromList(0,Parameters[93]," //"))}
		localization_nm[index] = {1/str2num(StringFromList(0,parameters[95]," //"))}
		N_equilibration_events[index] = {1/str2num(StringFromList(0,parameters[56]," //"))}
		// Record results from analysis summary
		mobility_avg[index] = {str2num(StringFromList(4,analysisSummary[11]," "))}
		mobility_stdev[index] = {str2num(StringFromList(6,analysisSummary[11]," "))}
		equilibration_energy_noC_avg[index] = {str2num(StringFromList(6,analysisSummary[12]," "))}
		equilibration_energy_noC_stdev[index] = {str2num(StringFromList(8,analysisSummary[12]," "))}
		equilibration_energy_avg[index] = {str2num(StringFromList(6,analysisSummary[13]," "))}
		equilibration_energy_stdev[index] = {str2num(StringFromList(8,analysisSummary[13]," "))}
		transport_energy_noC_avg[index] = {str2num(StringFromList(6,analysisSummary[14]," "))}
		transport_energy_noC_stdev[index] = {str2num(StringFromList(8,analysisSummary[14]," "))}
		transport_energy_avg[index] = {str2num(StringFromList(6,analysisSummary[15]," "))}
		transport_energy_stdev[index] = {str2num(StringFromList(8,analysisSummary[15]," "))}
		// Load DOS and DOOS data
		SetDataFolder $job_name
		LoadWave/J/W/N/O/K=0/P=folder_path/Q "DOS_data.txt"
		Duplicate/O $"Energy__eV_" DOS_energy
		Duplicate/O $"Density__cm__3_eV__1_" DOS_density
		KillWaves/Z $"Energy__eV_" $"Density__cm__3_eV__1_"
		
		
	endif
	SetDataFolder original_folder
End

Function EMT_ImportSetGUI()
	String original_folder = GetDataFolder(1)
	NewDataFolder/O/S root:Excimontec
	// Open new set folder
	NewPath/O/Q set_path
	if(V_flag!=0)
		SetDataFolder original_folder
		return NaN
	endif
	PathInfo set_path
	// Prompt user for the desired set_num
	Variable set_num
	Prompt set_num, "Enter the desired set_num to be associated with this job set:"
	DoPrompt "Enter job set info", set_num
	Print "•EMT_ImportSet(\""+S_path+"\","+num2str(set_num)+")"
	EMT_ImportSet(S_path,set_num)
End

Function EMT_ImportSet(set_pathname,set_num)
	String set_pathname
	Variable set_num
	String original_folder = GetDataFolder(1)
	NewDataFolder/O/S root:Excimontec
	// Check that path exists
	GetFileFolderInfo/Q/Z=1 set_pathname
	if(V_Flag!=0)
		Print "Error! Set folder not found."
		SetDataFolder original_folder
		return NaN
	endif
	NewPath/O/Q set_path set_pathname
	// Get list of all job folder paths
	String job_path_list = IndexedDir(set_path,-1,1)
	// Sort list by job array index
	// Get list of indices
	Make/N=(ItemsinList(job_path_list))/T/O job_path_wave
	Variable i
	for(i=0;i<ItemsinList(job_path_list);i+=1)
		String job_path = StringFromList(i,job_path_list)
		String job_id = StringFromList(ItemsInList(job_path,":")-1,job_path,":")
		Variable job_array_index = str2num(StringFromList(1,job_id,"_"))
		job_path_wave[job_array_index] = job_path
	endfor
	for(i=0;i<numpnts(job_path_wave);i+=1)
		EMT_ImportData(job_path_wave[i],set_num,set_index=i)
	endfor
	//Cleanup
	KillWaves/Z job_path_wave
	SetDataFolder original_folder
End

Function EMT_DifferentiateLog(wave_y,wave_x,)
	// Numerically calculates dy/dx given x values are distributed on a log scale
	Wave wave_y
	Wave wave_x
	String outputName = NameOfWave(wave_y)+"_DIF"
	Duplicate/O wave_y $outputName
	Wave wave_y_DIF = $outputName
	WaveStats/Q wave_y
	Variable length = V_npnts
	Variable x
	for(x=0;x<length;x+=1)
		if(x<7)
			wave_y_DIF[x] = (wave_y[x+3]-wave_y[x])/(wave_x[x+3]-wave_x[x])
		elseif(x<(length-3))
			CurveFit/N/Q/W=2/NTHR=0/TBOX=0 line wave_y[x-7,x+3] /X=wave_x[x-7,x+3]
			Wave W_coef
			wave_y_DIF[x] = W_coef[1]
		else
			CurveFit/N/Q/W=2/NTHR=0/TBOX=0 line wave_y[x-7,length-1] /X=wave_x[x-7,length-1]
			Wave W_coef
			wave_y_DIF[x] = W_coef[1]
		endif
	endfor
	KillWaves W_coef $"W_sigma"
End