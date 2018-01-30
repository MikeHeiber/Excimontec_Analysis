#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.3 // Minimum Igor version required
#pragma version = 1.0-beta.2

// Copyright (c) 2018 Michael C. Heiber
// This source file is part of the Excimontec project, which is subject to the MIT License.
// For more information, see the LICENSE file that accompanies this software.
// The Excimontec project can be found on Github at https://github.com/MikeHeiber/Excimontec

Function EMT_ImportData()
	String original_folder = GetDataFolder(1)
	NewDataFolder/O/S root:Excimontec
	// Open new job folder
	NewPath/O/Q folder_path
	if(V_flag==1)
		return NaN
	endif
	PathInfo folder_path
	String job_name = StringFromList(ItemsInList(S_path,":")-1,S_path,":")
	// Load analysis summary file to extract version number
	LoadWave/J/A=analysisWave/P=folder_path/K=0/Q "analysis_summary.txt"
	Wave/T analysisWave0
	String version_used = StringFromList(1,StringFromList(0,analysisWave0[0]," Results"),"tec ")
	Variable major_version_num = str2num(StringFromList(0,StringFromList(1,version_used,"v"),"."))
	Variable minor_version_num = str2num(StringFromList(1,StringFromList(1,version_used,"v"),"."))
	Variable version_num = major_version_num+0.1*minor_version_num
	// Load parameter file
	LoadWave/A/J/Q/K=2/V={""," $",0,0}/P=folder_path "parameters.txt"
	Wave/T wave0
	// Check for ToF test
	Variable TOF_Test = 0
	if(StringMatch(StringFromList(0,wave0[35]," //"),"true"))
		NewDataFolder/O/S $("Time of Flight Tests")
		TOF_Test = 1
	// Check for IQE test
	Variable IQE_Test = 0
	elseif(StringMatch(StringFromList(0,wave0[41]," //"),"true"))
		NewDataFolder/O/S $("IQE Tests")
		IQE_Test = 1
	// Check for Dynamics test
	Variable Dynamics_Test = 0
	elseif(StringMatch(StringFromList(0,wave0[43]," //"),"true"))
		NewDataFolder/O/S $("Dynamics Tests")
		Dynamics_Test = 1
	endif
	// Open Data Waves
	Wave/T/Z version
	if(!WaveExists(version))
		Make/N=1/T $"version"
		Wave/T version
	endif
	Wave/T/Z job_id
	if(!WaveExists(job_id))
		Make/N=1/T $"job_id"
		Wave/T job_id
	endif
	Wave/T/Z morphology_id
	if(!WaveExists(morphology_id))
		Make/N=1/T $"morphology_id"
		Wave/T morphology_id
	endif
	Wave/Z lattice_length
	if(!WaveExists(lattice_length))
		Make/N=1/D $"lattice_length"
		Wave lattice_length
	endif
	Wave/Z lattice_width
	if(!WaveExists(lattice_width))
		Make/N=1/D $"lattice_width"
		Wave lattice_width
	endif
	Wave/Z lattice_height
	if(!WaveExists(lattice_height))
		Make/N=1/D $"lattice_height"
		Wave lattice_height
	endif
	Wave/Z unit_size_nm
	if(!WaveExists(unit_size_nm))
		Make/N=1/D $"unit_size_nm"
		Wave unit_size_nm
	endif
	Wave/Z temperature_K
	if(!WaveExists(temperature_K))
		Make/N=1/D $"temperature_K"
		Wave temperature_K
	endif
	Wave/Z internal_potential_V
	if(!WaveExists(internal_potential_V))
		Make/N=1/D $"internal_potential_V"
		Wave internal_potential_V
	endif
	Wave/T/Z disorder_model
	if(!WaveExists(disorder_model))
		Make/N=1/T $"disorder_model"
		Wave/T disorder_model
	endif
	Wave/T/Z correlation_model
	if(!WaveExists(correlation_model))
		Make/N=1/T $"correlation_model"
		Wave/T correlation_model
	endif
	Wave/Z N_carriers
	if(!WaveExists(N_carriers))
		Make/N=1/D $"N_carriers"
		Wave N_carriers
	endif
	Wave/Z N_variants
	if(!WaveExists(N_variants))
		Make/N=1/D $"N_variants"
		Wave N_variants
	endif
	Wave/Z calc_time_min
	if(!WaveExists(calc_time_min))
		Make/N=1/D $"calc_time_min"
		Wave calc_time_min
	endif
	NewDataFolder/O/S $job_name
	Duplicate/O/T wave0 Parameters
	KillWaves wave0
	Variable index
	FindValue /TEXT=(job_name) job_id
	index = V_value
	if(index==-1)
		if(StringMatch(job_id[0],""))
			index = 0
		else
			index = numpnts(job_id)
		endif	
	endif
	version[index] = {version_used}
	job_id[index] = {job_name}
	// Record morphology used
	// Neat
	if(StringMatch(StringFromList(0,Parameters[19]," //"),"true"))
		morphology_id[index] = {"Neat"}
	// Bilayer	
	elseif(StringMatch(StringFromList(0,Parameters[20]," //"),"true"))
		morphology_id[index] = {"Bilayer"}
	// Random blend
	elseif(StringMatch(StringFromList(0,Parameters[23]," //"),"true"))
		morphology_id[index] = {"Random blend"}
	// Imported morphology
	elseif(StringMatch(StringFromList(0,Parameters[25]," //"),"true") || StringMatch(StringFromList(0,Parameters[27]," //"),"true"))
		String file_list = IndexedFile(folder_path,-1,".txt")
		if(ItemsInList(file_list))
			morphology_id[index] = {StringFromList(1,ListMatch(file_list,"morphology_*"),"_")}
		else
			morphology_id[index] = {""}
		endif
	endif
	lattice_length[index] = {str2num(StringFromList(0,Parameters[10]," //"))}
	lattice_width[index] = {str2num(StringFromList(0,Parameters[11]," //"))}
	lattice_height[index] = {str2num(StringFromList(0,Parameters[12]," //"))}
	unit_size_nm[index] = {str2num(StringFromList(0,Parameters[13]," //"))}
	temperature_K[index] = {str2num(StringFromList(0,Parameters[14]," //"))}
	internal_potential_V[index] = {str2num(StringFromList(0,Parameters[16]," //"))}
	N_carriers[index] = {str2num(StringFromList(0,Parameters[37]," //"))}
	N_variants[index] = {str2num(StringFromList(0,StringFromList(1,analysisWave0[1]," on ")," proc"))}
	// Record disorder model used
	// Gaussian
	if(StringMatch(StringFromList(0,Parameters[101]," //"),"true"))
		// Correlated
		if(StringMatch(StringFromList(0,Parameters[107]," //"),"true"))
			Disorder_model[index] = {"Gaussian-correlated"}
			// Gaussian kernel
			if(StringMatch(StringFromList(0,Parameters[109]," //"),"true"))
				Correlation_model[index] = {"Gaussian kernel"}
			// Power kernel
			else
				String power_kernel_exponent = StringFromList(0,Parameters[111]," //")
				Correlation_model[index] = {"Power kernel, "+power_kernel_exponent}
			endif
		// Uncorrelated
		else
			Disorder_model[index] = {"Gaussian-uncorrelated"}
			Correlation_model[index] = {"none"}
		endif
	// Exponential
	elseif(StringMatch(StringFromList(0,Parameters[104]," //"),"true"))
		Disorder_model[index] = {"Exponential-uncorrelated"}
		Correlation_model[index] = {"none"}
	// None
	else
		Disorder_model[index] = {"None"}
		Correlation_model[index] = {"none"}
	endif
	// Perform TOF Test Specific Operations
	if(TOF_Test)
		SetDataFolder root:Excimontec:$("Time of Flight Tests")
		// Open TOF Data Waves
		Wave/Z mobility_avg
		if(!WaveExists(mobility_avg))
			Make/N=1/D $"mobility_avg"
			Wave mobility_avg
		endif
		Wave/Z mobility_stdev
		if(!WaveExists(mobility_stdev))
			Make/N=1/D $"mobility_stdev"
			Wave mobility_stdev
		endif
		Wave/Z disorder_eV
		if(!WaveExists(disorder_eV))
			Make/N=1/D $"disorder_eV"
			Wave disorder_eV
		endif
		Wave/Z localization_nm
		if(!WaveExists(localization_nm))
			Make/N=1/D $"localization_nm"
			Wave localization_nm
		endif
		// Load TOF Files
		SetDataFolder $job_name
		LoadWave/J/D/W/N/O/K=0/P=folder_path/Q "ToF_average_transients.txt"
		LoadWave/J/D/W/N/O/K=0/P=folder_path/Q "ToF_transit_time_dist.txt"
		LoadWave/J/Q/A=resultsWave/P=folder_path/K=2/V={""," $",0,0} "ToF_results.txt"
		Wave/T resultsWave0
		// Determine relevant disorder
		// Gaussian DOS
		if(StringMatch(StringFromList(0,Parameters[101]," //"),"true"))
			// Electron transport
			if(StringMatch(StringFromList(0,parameters[35]," //"),"electron"))
				disorder_eV[index] = {str2num(StringFromList(0,parameters[103]," //"))}
			// Hole transport
			else
				disorder_eV[index] = {str2num(StringFromList(0,parameters[102]," //"))}
			endif
		// Exponential DOS
		elseif(StringMatch(StringFromList(0,Parameters[104]," //"),"true"))
			// Electron transport
			if(StringMatch(StringFromList(0,parameters[35]," //"),"electron"))
				disorder_eV[index] = {str2num(StringFromList(0,parameters[106]," //"))}
			// Hole transport
			else
				disorder_eV[index] = {str2num(StringFromList(0,parameters[105]," //"))}
			endif
		endif
		// Determine relevant localization
		// Electron transport
		if(StringMatch(StringFromList(0,parameters[35]," //"),"electron"))
			localization_nm[index] = {1/str2num(StringFromList(0,parameters[86]," //"))}
		// Hole transport
		else
			localization_nm[index] = {1/str2num(StringFromList(0,parameters[85]," //"))}
		endif
		if(version_num<1)
			mobility_avg[index] = {str2num(StringFromList(2,resultsWave0[1],","))}
			mobility_stdev[index] = {NaN}
		else
			mobility_avg[index] = {str2num(StringFromList(3,resultsWave0[1],","))}
			mobility_stdev[index] = {str2num(StringFromList(4,resultsWave0[1],","))}
		endif
		calc_time_min[index] = {str2num(StringFromList(4,analysisWave0[2]," "))}
		// Clean Up
		KillWaves resultsWave0
		// Update Analysis
		SetDataFolder ::
		Duplicate/O mobility_avg field field_sqrt disorder_norm
		field = abs(internal_potential_V)/(1e-7*lattice_height*unit_size_nm)
		field_sqrt = sqrt(abs(internal_potential_V)/(1e-7*lattice_height*unit_size_nm))
		// Calculate effective disroder for Gaussian DOS
		if(StringMatch(StringFromList(0,Parameters[101]," //"),"true"))
			disorder_norm = disorder_eV/(8.617e-5*temperature_K)
		endif
	endif
	KillWaves analysisWave0
	SetDataFolder original_folder
End