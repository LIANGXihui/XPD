#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0	
#pragma hide=1	
#include <New Polar Graphs>
#include <Multi-peak Fitting 2.0>
#include <XYZtoMatrix>

//*********************************************************
//XPD data acquisition, displaying, process, and analysis package.
//Written by LIANG Xihui @ CEA France 2014,
//for any question, please email liangxh@hotmail.com
//Disclaimer: 
//This package is free for non-commercial use; you can redistribute
//it and/or modify it for non-commercial purpose. The commercial right 
//is reserved. 
//This package is distributed in the hope that it will be useful, 
//but WITHOUT ANY WARRANTY; without even the implied warranty of 
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
//*********************************************************

Menu "XPD"
	"Open Acquisition Panel...", InitDAQPanel()
	"Open an XPD Pattern...", OpenXPD()
	"Generate an Angle Scan File...", InitGenStaSerPanel()
	"Import Dispersion Factors...", ImpDispFactors()
	"About...", About()
End

// ========= XPD Data Acquisition and Display ===============//
//
Function InitDAQPanel()
	DFREF dfraq = GetDAQPackageDFREF()
	DoWindow/F DAQPanel
	if(V_Flag == 0) //if no DAQPanel
		NewPanel/N=DAQPanel/k=2/W=(800,50,1055,385) as "XPD Data Acquisition" //W=(15,50,280,360)
		SetVariable CoreLvNum win=DAQPanel, pos={10, 20}, size={170,20}, title="Number of Core Levels:", help={"Input the number of core levels to be measured."}; DelayUpdate
		SetVariable CoreLvNum win=DAQPanel, font="Arial", fsize=12, value=dfraq:ClvNum, limits={1,12,1};DelayUpdate
		SetVariable IntvTimeVar win=DAQPanel, pos={10, 45}, size={210,20}, title="Data Reading Interval time (s):", help={"Input the time how frequently to read the data file."};DelayUpdate
		SetVariable IntvTimeVar win=DAQPanel, font="Arial", fsize=12, value=dfraq:IntvTime, limits={0.5,60,0.1};DelayUpdate
		GroupBox ThtRangeBox win=DAQPanel, pos={10, 70}, size={235,70}, title="Radial Axis Range of Patterns", font="Arial", fsize=12, fStyle=1, help={"Define the radial axis range of the pattern."};DelayUpdate
		CheckBox AutoRangeCk Win=DAQPanel, pos={25, 90}, size={50, 20}, title="Auto", font="Arial", fsize=12, mode=1, value=1, proc=AutoRangeCkProc, help={"Check to let the program determine the radial axis range."};DelayUpdate
		CheckBox ManuRangeCk Win=DAQPanel, pos={25, 113}, size={50, 20}, title="Manual", font="Arial", fsize=12, mode=1, value=0, proc=ManuRangeCkProc, help={"Check to manually set the radial axis range."};DelayUpdate
		SetVariable ThtRanMinVar win=DAQPanel, pos={84, 111}, size={71,20},font="Arial", title="(deg.):", fsize=12, value=dfraq:MinThtRange, limits={0,90,1}, disable=2;DelayUpdate
		SetVariable ThtRanMaxVar win=DAQPanel, pos={160, 111}, size={47,20}, title="->";DelayUpdate
		SetVariable ThtRanMaxVar win=DAQPanel, font="Arial", fsize=12, value=dfraq:MaxThtRange, limits={0,90,1}, disable=2;DelayUpdate
		GroupBox DspModGrBox Win=DAQPanel, pos={10, 145},size={235,150},title="Displaying Mode",font="Arial", fsize=12, fStyle=1, help={"Select the intensity calculation methods for data points."};DelayUpdate
		CheckBox RawCk Win=DAQPanel, pos={25, 170}, size={50, 20}, title="Raw Data", font="Arial", fsize=12,value=0, proc=RawCkProc, help={"Check to calculate the area(intensity) of an XPS spectrum without background subtraction or fitting."};DelayUpdate
		CheckBox MaxCk Win=DAQPanel, pos={25, 195}, size={50, 20}, title="Imax-Imin", font="Arial", fsize=12, value=0, proc=MaxCkProc, help={"Check to calculate the difference of the maximum intensity and minimum intensity of an XPS spectrum and use this difference as the photoelectron intensity."};DelayUpdate
		CheckBox WholeCk Win=DAQPanel, pos={25, 220}, size={50, 20}, title="WholePeak-Background", font="Arial", fsize=12, value=0, proc=WholeCkProc, help={"Check to firstly subtract the background from an XPS spectrum and then calculate the photoelectron intensity of the background-subtracted XPS spectrum."};DelayUpdate
		GroupBox CompGrBox Win=DAQPanel, pos={32, 250},size={205, 35},title="",font="Arial", fsize=12, fStyle=1, help={"Firstly fit the background-subtracted spectrum by using two components, then calculate the intensity of the two components separately, finally project the two intensities onto two patterns respectively."};DelayUpdate
		CheckBox CompCk Win=DAQPanel, pos={25, 242}, size={50, 20}, title="Two Fitted Components", font="Arial", fsize=12, mode=2, value=1;DelayUpdate
		TitleBox ForCLtxt Win=DAQPanel, pos={45, 263}, size={100, 20}, title="Core levels:",font="Arial", fsize=12, frame=0, help={"The first four core levels are supported."};DelayUpdate
		CheckBox Com1Ck Win=DAQPanel, pos={115, 263}, size={20, 20}, title="1", font="Arial", fsize=12, value=0, proc=Com1CkProc, help={"Check/uncheck to select/unselect the 1st core level to use the 'Two Fitted componets' method."};DelayUpdate
		CheckBox Com2Ck Win=DAQPanel, pos={145, 263}, size={20, 20}, title="2", font="Arial", fsize=12, value=0, proc=Com2CkProc, help={"Check/uncheck to select/unselect the 2nd core level to use the 'Two Fitted componets' method."};DelayUpdate
		CheckBox Com3Ck Win=DAQPanel, pos={175, 263}, size={20, 20}, title="3", font="Arial", fsize=12, value=0, proc=Com3CkProc, help={"Check/uncheck to select/unselect the 3rd core level to use the 'Two Fitted componets' method."};DelayUpdate
		CheckBox Com4Ck Win=DAQPanel, pos={205, 263}, size={20, 20}, title="4", font="Arial", fsize=12, value=0, proc=Com4CkProc, help={"Check/uncheck to select/unselect the 4th core level to use the 'Two Fitted componets' method."};DelayUpdate
		Button StartAcqBtn win=DAQPanel, pos={20, 300}, size={100,20}, title="Start Acquisition", help={"Click to start reading the data file and display the pattern."};DelayUpdate
		Button StartAcqBtn win=DAQPanel, font="Arial", fsize=12, disable=0, proc=StartAcqBtnProc;DelayUpdate
		Button StopAcqBtn win=DAQPanel, pos={130, 300}, size={100,20}, title="Stop Acquisition", help={"Click to Stop reading the data file"};DelayUpdate
		Button StopAcqBtn win=DAQPanel, font="Arial", fsize=12, disable=2, proc=StopAcqBtnProc
	endif
End

Function/DF CreateDAQPackageData() // Called only from GetDAQPackageDFREF
	if (DataFolderRefStatus(root:Packages) != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages // Create Packages Data folder
	endif
	if (DataFolderRefStatus(root:Packages:'XPD') != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages:'XPD' // Create Packages Data folder
	endif
	// Create the Data Acquisition package data folder
	NewDataFolder/O root:Packages:'XPD':DAQ
	// Create a data folder reference variable
	DFREF dfraq= root:Packages:'XPD':DAQ
	// Create and initialize package data
	Variable/G dfraq:Is1st = 1  // Whether it is the 1st time to read the file. 0: no, 1: yes.
	Variable/G dfraq:CLvNum = 1 // the number of core levels
	Variable/G dfraq:ClvCnt = 0 // count the number of core levels
	Variable/G dfraq:ChNum = 128 // the number of detector channnels of an XPS analyzer
	Variable/G dfraq:LNum = 2 // the number of the lines in the data file
	Variable/G dfraq:PreLNum = 0 // the number of the lines in the data file
	Variable/G dfraq:nth = 1 // the sequence number of core levels, start from 1 !
	Variable/G dfraq:StgPosNum = 0 // the number of the stage positions, start from 0 
	Variable/G dfraq:IntvTime = 0.5 // interval time
	Variable/G dfraq:AutoRangeCked = 1 
	Variable/G dfraq:ManuRangeCked = 0
	Variable/G dfraq:MinThtRange = 0 // min theta range
	Variable/G dfraq:MaxThtRange = 90 // max theta range
	Variable/G dfraq:MinThtDat = 0 // min value of the theta data 
	Variable/G dfraq:MaxThtDat = 0 // max value of the theta data 
	Variable/G dfraq:RawCked = 0
	Variable/G dfraq:MaxCked = 0
	Variable/G dfraq:WholeCked = 0
	Variable/G dfraq:Com1Cked = 0
	Variable/G dfraq:Com2Cked = 0
	Variable/G dfraq:Com3Cked = 0
	Variable/G dfraq:Com4Cked = 0
	Variable/G dfraq:CkNum = 0 //the number of the XPD patterns at a stage position
	Variable/G dfraq:CkCnt = 0 //the count of the XPD patterns at a Polar position
	Variable/G dfraq:CrnTht = 0 // Current theta angle
	Variable/G dfraq:CrnPhi = 0 // Current Phi angle
	Variable/G dfraq:AzNum = 0 // the number of azimuthal position at current theta angle
	Variable/G dfraq:Is1stNoData = 1 
	Variable/G dfraq:plstart = 0 // Polar Start angle	
	Variable/G dfraq:plstop = 70 // Polar Stop angle
	Variable/G dfraq:plstep = 1 // Polar Step angle
	Variable/G dfraq:azstart = 0 // Azimuthal Start angle	
	Variable/G dfraq:azstop = 90 // Azimuthal Stop angle
	Variable/G dfraq:azstep0 = 1 // Azimuthal Step angle
	Variable/G dfraq:azbl = 0 // Azimuthal backlash angle
	Variable/G dfraq:PosNum = 0 // Azimuthal Step angle
	
	String/G dfraq:lgstr = ""
	String/G dfraq:FsTrans = ""
	String/G dfraq:AllDispModStr = " (Raw Data); (Max-Min); (WholePeak-Background); (Left Component); (Right Component);"
	return dfraq
End

Function/DF GetDAQPackageDFREF()
	DFREF dfraq = root:Packages:'XPD':DAQ
	if (DataFolderRefStatus(dfraq) != 1) // Data folder does not exist?
		DFREF dfraq = CreateDAQPackageData() // Create DAQ package data folder
	endif
	return dfraq
End

Function/DF CreateFitPackageData() // Called only from GetDAQPackageDFREF
	if (DataFolderRefStatus(root:Packages) != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages // Create Packages Data folder
	endif
	if (DataFolderRefStatus(root:Packages:'XPD') != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages:'XPD' // Create Packages Data folder
	endif
	// Create the Data Acquisition package data folder
	NewDataFolder/O root:Packages:'XPD':Fit
	// Create a data folder reference variable
	DFREF dfrfit= root:Packages:'XPD':Fit
	// Create and initialize package data
	Variable/G dfrfit:FitErrCnt = 0 //the count of the fitting errors	
	return dfrfit
End

Function/DF GetFitPackageDFREF()
	DFREF dfrfit = root:Packages:'XPD':Fit
	if (DataFolderRefStatus(dfrfit) != 1) // Data folder does not exist?
		DFREF dfrfit = CreateFitPackageData() // Create DAQ package data folder
	endif
	return dfrfit
End

Function AutoRangeCkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq AutoRangeCked, ManuRangeCked

	if(Cked)
		AutoRangeCked = 1
		ManuRangeCked = 0
		CheckBox AutoRangeCk value = 1
		CheckBox ManuRangeCk value = 0
		SetVariable ThtRanMinVar disable=2
		SetVariable ThtRanMaxVar disable=2
	else
		AutoRangeCked = 0
		ManuRangeCked = 1
		CheckBox AutoRangeCk value = 0
		CheckBox ManuRangeCk value = 1
		SetVariable ThtRanMinVar disable=0
		SetVariable ThtRanMaxVar disable=0
	endif
End

Function ManuRangeCkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq AutoRangeCked, ManuRangeCked

	if(Cked)
		AutoRangeCked = 0
		ManuRangeCked = 1
		CheckBox AutoRangeCk value = 0
		CheckBox ManuRangeCk value = 1
		SetVariable ThtRanMinVar disable=0
		SetVariable ThtRanMaxVar disable=0
	else
		AutoRangeCked = 1
		ManuRangeCked = 0
		CheckBox AutoRangeCk value = 1
		CheckBox ManuRangeCk value = 0
		SetVariable ThtRanMinVar disable=2
		SetVariable ThtRanMaxVar disable=2
	endif
End

Function RawCkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq RawCked

	if(Cked)
		RawCked = 1
	else
		RawCked = 0
	endif
End

Function MaxCkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq MaxCked

	if(Cked)
		MaxCked = 1
	else
		MaxCked = 0
	endif
End

Function WholeCkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq WholeCked

	if(Cked)
		WholeCked = 1
	else
		WholeCked = 0
	endif
End

Function Com1CkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq Com1Cked

	if(Cked)
		Com1Cked = 1
	else
		Com1Cked = 0
	endif
End

Function Com2CkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq Com2Cked

	if(Cked)
		Com2Cked = 1
	else
		Com2Cked = 0
	endif
End

Function Com3CkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq Com3Cked

	if(Cked)
		Com3Cked = 1
	else
		Com3Cked = 0
	endif
End

Function Com4CkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq Com4Cked

	if(Cked)
		Com4Cked = 1
	else
		Com4Cked = 0
	endif
End

Function StartAcqBtnProc(ctrlName) : ButtonControl
	String ctrlName 
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR/SDFR=dfraq Is1st, ClvNum, ChNum, RawCked, MaxCked, WholeCked, Com1Cked, Com2Cked, Com3Cked, Com4Cked, CkNum, PkSel1, PkSel2, PkSel3, PkSel4
	String DispFactFileName 
	Variable refNum

	CkNum = 0
	Variable cknumtmp
	if(RawCked == 1)
		CkNum += 1
	endif
	if(MaxCked == 1)
		CkNum += 1
	endif
	if(WholeCked == 1)
		CkNum += 1
	endif
	CkNum = CkNum*ClvNum
	cknumtmp = cknum
	if(Com1Cked == 1)
		CkNum += 2
		Variable/G dfraq:PkSel1 = 1
		Variable/G dfrfit:PeakNum1 = 0
		Variable/G dfrfit:Is1stFit1 = 1
		Variable/G dfrfit:IsFitting1 = 0
		Make/O/N=10 dfrfit:PkPosW1 = 0
		Make/O/N=(4,2) dfrfit:cm1//coefficience matrix wave
		Make/O/N=4 dfrfit:cw11, dfrfit:cw21
		Make/O/N=(ChNum) dfrfit:xw1, dfrfit:yw1, dfrfit:ywnbg1, dfrfit:FitW1, dfrfit:Peak1W1, dfrfit:Peak2W1
	endif
	if(Com2Cked == 1)
		CkNum += 2
		Variable/G dfraq:PkSel2 = 1
		Variable/G dfrfit:PeakNum2 = 0
		Variable/G dfrfit:Is1stFit2 = 1
		Variable/G dfrfit:IsFitting2 = 0
		Make/O/N=10 dfrfit:PkPosW2 = 0
		Make/O/N=(4,2) dfrfit:cm2//coefficience matrix wave
		Make/O/N=4 dfrfit:cw12, dfrfit:cw22
		Make/O/N=(ChNum) dfrfit:xw2, dfrfit:yw2, dfrfit:ywnbg2, dfrfit:FitW2, dfrfit:Peak1W2, dfrfit:Peak2W2
	endif
	if(Com3Cked == 1)
		CkNum += 2
		Variable/G dfraq:PkSel3 = 1
		Variable/G dfrfit:PeakNum3 = 0
		Variable/G dfrfit:Is1stFit3 = 1
		Variable/G dfrfit:IsFitting3 = 0
		Make/O/N=10 dfrfit:PkPosW3 = 0
		Make/O/N=(4,2) dfrfit:cm3//coefficience matrix wave
		Make/O/N=4 dfrfit:cw13, dfrfit:cw23
		Make/O/N=(ChNum) dfrfit:xw3, dfrfit:yw3, dfrfit:ywnbg3, dfrfit:FitW3, dfrfit:Peak1W3, dfrfit:Peak2W3
	endif
	if(Com4Cked == 1)
		CkNum += 2
		Variable/G dfraq:PkSel4 = 1
		Variable/G dfrfit:PeakNum4 = 0
		Variable/G dfrfit:Is1stFit4 = 1
		Variable/G dfrfit:IsFitting4 = 0
		Make/O/N=10 dfrfit:PkPosW4 = 0
		Make/O/N=(4,2) dfrfit:cm4//coefficience matrix wave
		Make/O/N=4 dfrfit:cw14, dfrfit:cw24
		Make/O/N=(ChNum) dfrfit:xw4, dfrfit:yw4, dfrfit:ywnbg4, dfrfit:FitW4, dfrfit:Peak1W4, dfrfit:Peak2W4
	endif
	if(Com1Cked == 1 || Com2Cked == 1 || Com3Cked == 1 || Com4Cked == 1)
		Make/O/T/N=10 dfrfit:ConStrW
		Wave/T ConStrW = dfrfit:ConStrW
		ConStrW[2] = {"K1 > 0"}
		ConStrW[3] = {"K2 > 0"}
		ConStrW[4] = {"K3 > 0"}
		ConStrW[7] = {"K5 > 0"}
		ConStrW[8] = {"K6 > 0"}
		ConStrW[9] = {"K7 > 0"}
	endif
	if(cknum == 0 && RawCked == 0)
		Abort "You didn't select any displaying mode.\nPlease select one at least."
	endif
	//Make/O/N=9 dfrfit:cw1
	//Make/O/N=9 dfrfit:cw2
	//Make/O/N=9 dfrfit:cw3
	//Make/O/N=9 dfrfit:cw4
	Make/O/N=(ChNum) dfrfit:ywnbg, dfrfit:bgw

	if(Is1st == 1)
		//import Dispersion factors
		DispFactFileName = SpecialDirPath("Igor Pro User Files", 0, 0, 0) + "Igor Procedures:DispersionFactors.df"
		GetFileFolderInfo /Q/Z=1 DispFactFileName
		if(V_flag != 0)
			StopDAQtask()
			SetVariable CoreLvNum disable=0
			SetVariable IntvTimeVar disable=0
			Abort "I cannot find the Dispersion Factors! \nPlease import it manually by clicking XPD menu -> Import dispersion factors. \n\nStop acqusition."
		elseif(V_flag == 0)
			SetDataFolder dfraq
			LoadWave/B="N=DispW;"/G/N/O/Q DispFactFileName
			Wave/SDFR=dfraq DispW
			Reverse DispW //reverse the DispW so that Channel 128 has the lowest energy
			SetDataFolder ::::
		endif

		//Open the file
		String message = "Select the file into which CASCADE will save data"
		String fileFilters = "CASCADE Data Files (*.csv):.csv;"
		fileFilters += "All Files:.*;"	
		Open/D/R/F=fileFilters/M=message refNum
		if (strlen(S_fileName) == 0)
			print "You did NOT select a file. Abort"
			SetVariable IntvTimeVar disable=0 // make the Interval time input available.
			SetVariable CoreLvNum disable=0 //make the Core Level input available
			Abort
		else
			//Is1st = 0 // A file has been opened, no need to display the open dialogue any more. Move to ReadAndDisplay()
			String/G dfraq:fullFileName=S_fileName
			SVAR/SDFR=dfraq fullFileName
			Make/O/N=(1, ChNum+5) dfraq:RawDataM // make a matrix wave to store the data
			Make/O/N=(CLvNum, ChNum) dfraq:EngM
			Make/O/N=(CkNum) dfraq:SumAzItsW //the first intensity value of an azimuthal circle at a Polar angle

			SetVariable IntvTimeVar disable=2
			SetVariable CoreLvNum disable=2
			CheckBox AutoRangeCk disable=2
			CheckBox ManuRangeCk disable=2
			SetVariable ThtRanMinVar disable=2
			SetVariable ThtRanMaxVar disable=2
			CheckBox RawCk disable=2
			CheckBox MaxCk disable=2
			CheckBox WholeCk disable=2
			CheckBox Com1Ck disable=2
			CheckBox Com2Ck disable=2
			CheckBox Com3Ck disable=2
			CheckBox Com4Ck disable=2
			Button StartAcqBtn disable=2
			Button StopAcqBtn disable=0
			MoveWindow/W=DAQPanel 5,20,195,270 
			StartDAQTask()
		endif
	endif
End

Function StopAcqBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR/SDFR=dfraq LNum, ClvNum, MaxCked, WholeCked, Com1Cked, Com2Cked, Com3Cked, Com4Cked
	NVAR/SDFR=dfrfit FitErrCnt
	
	StopDAQTask()

	if(LNum > 3)
		if(MaxCked == 1)
			DoFinalPolBgSubt("M", ClvNum, -1)
		endif
		if(WholeCked == 1)
			DoFinalPolBgSubt("H", ClvNum, -1)
		endif
		if(Com1Cked == 1)
			DoFinalPolBgSubt("L", ClvNum, 1)
			DoFinalPolBgSubt("R", ClvNum, 1)
		endif
		if(Com2Cked == 1)
			DoFinalPolBgSubt("L", ClvNum, 2)
			DoFinalPolBgSubt("R", ClvNum, 2)
		endif
		if(Com3Cked == 1)
			DoFinalPolBgSubt("L", ClvNum, 3)
			DoFinalPolBgSubt("R", ClvNum, 3)
		endif
		if(Com4Cked == 1)
			DoFinalPolBgSubt("L", ClvNum, 4)
			DoFinalPolBgSubt("R", ClvNum, 4)
		endif
	endif
	Button StopAcqBtn disable=2
	Print "Data acquisition has been stopped.\n"
	if(FitErrCnt>0)
		Print "Total number of fitting errors: ", FitErrCnt
	endif
	Abort //"Data acquisition has been stopped."
End

Function StartDAQTask()
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq IntvTime
	if(intvtime < 0.5)
		Abort "Sorry, Interval time must be greater than 0.5 second. Please input a correct number"
	endif

	Variable numTicks = IntvTime * 60 // Run every ticks
	CtrlNamedBackground DAQ, period=numTicks, proc=ReadAndDisplay
	CtrlNamedBackground DAQ, start
End

Function StopDAQTask()
	CtrlNamedBackground DAQ, stop
End

// ReadAndDisplay(s)
// This function will be called periodically by StartDAQTask()
// The data file to be read must be the data files
//saved by the MATE script of the Omicron's MATRIX.
// The data file format:
//The first two lines are comments.
//From the 3rd line, it's data.
//the data format of every data line:
//Core level name, E_kin, Pass Energy, Polar_Angle, Azimuthal_Angle, Detector_Sum, Ch_1, Ch_2, Ch_3, ..., Ch_128
//the unit of the data of every data line:
//[], [eV], [eV], [deg], [deg], [Cts], [Cts/Ch], [Cts/Ch], [Cts/Ch], ..., [Cts/Ch]
Function ReadAndDisplay(s)
	STRUCT WMBackgroundStruct &s // This is the function that will be called periodically
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR/SDFR=dfraq Is1st, LNum, PreLnum, CLvNum, ClvCnt, ChNum, AutoRangeCked, MinThtDat, MaxThtDat, RawCked, MaxCked, WholeCked, Com1Cked, Com2Cked, Com3Cked, Com4Cked, CkNum, CkCnt, nth, StgPosNum, CrnTht, AzNum, PkSel1, PkSel2, PkSel3, PkSel4, Is1stNoData
	Wave/SDFR=dfraq DispW
	SVAR ams = dfraq:AllDispModStr
	SVAR/SDFR=dfraq FsTrans
	NVAR/SDFR=dfrfit PeakNum1, PeakNum2, PeakNum3, PeakNum4, IsFitting1, IsFitting2, IsFitting3, IsFitting4, FitErrCnt
	String DispFactFileName = "", trans = "", Line="" //trans: transition, core level name
	Variable refNum, len, ridx, dnum, i, Ekc, PE, tht, phi, its, t, FitErr, LstPnt = 0// PE: pass energy, Ekc: center energy

	if(IsFitting1 == 1 || IsFitting2 == 1 || IsFitting3 == 1 || IsFitting4 == 1)
		print "Fitting is in process."
		return 0
	endif
	
	if(PkSel1 == 0 || PkSel2 == 0 || PkSel3 == 0 || PkSel4 == 0 )//If it needs fitting but users have not specified the peak positions
		//print "Please specify two peaks for fitting!"
		return 0
	endif

	SVAR/SDFR=dfraq fullFileName //read the filename if Is1st == 0.
	Open/R/Z refNum as fullFileName //Open with a dialog will return refum=NULL, so open the file again
	for(i = 0; i < LNum; i += 1)
		FReadLine refNum, Line
	endfor
	do
		FReadLine refNum, Line
		LNum += 1 //LNum: the number of lines
		len = strlen(Line)
		if(len == 0 || len == 1) // test end of file, 1 for the end is "\u001a" (SUB displyed in NotePad++)
			LNum -= 1
			if(LNum <= 2)
				if(Is1stNoData)
					print "No data in the file, waiting for data ..."
					Is1stNoData = 0
				endif
				break
			else
				break
			endif
		elseif(LNum > 2) //there are data in the file
			Wave RawDataM = dfraq:RawDataM
			ridx = StgPosNum*CLvNum+nth-1 //ridx: row index of RawDataM, the number of Spectra = ridx + 1
			trans = StringFromList(0, Line, ",") // transition name
			if(cmpstr(FsTrans, "OK") != 0)
				if(LNum == 3)
					FsTrans = trans
					ClvCnt += 1
					PreLnum = Lnum
				elseif(cmpstr(trans, FsTrans) == 0)
					FsTrans = "OK"
					if(ClvCnt != ClvNum)
						Button StopAcqBtn win=DAQPanel, disable=2
						Printf "The number of core levels in the data file is: %g, but the input number of core levels is: %g. ", ClvCnt, ClvNum
						Abort "I found that the number of core levels in the data file is NOT equal the input values. Please restart the Igor Pro and try again.\nSee the command window for details."
					endif
				elseif(PreLnum < Lnum && cmpstr(trans, FsTrans) != 0)
					ClvCnt += 1
					PreLnum = Lnum
				endif
			endif
			tht = str2num(StringFromList(3, Line, ","))
			phi = str2num(StringFromList(4, Line, ","))
			if(ridx != 0 && nth == 1) // if it is NOT the 1st time to read the 1st data line and is at next stage position
				if(RawDataM[ridx-1][2]-tht > 0.001) //in case the program read the wrong lines due to MATE script writing
					LNum = 2+ridx
					break
				elseif(tht - RawDataM[ridx-1][2] < 0.001)
					if(RawDataM[ridx-1][3]-phi > 0.001) //in case the program read the wrong lines due to MATE script writing
						LNum = 2+ridx
						break
					endif
				endif
			endif
			if(ridx != 0 && nth != 1) // if it is NOT the 1st time to read the 1st data line and is at the same stage position
				if(tht - RawDataM[ridx-1][2] > 0.001 || phi - RawDataM[ridx-1][3] > 0.001) //in case the program read the wrong lines due to MATE script writing
					LNum = 2+ridx
					break
				endif
			endif
			dnum = ItemsInList(Line, ",")
			if(ridx != 0) // if it is NOT the 1st time to read the 1st data line; nth != 1 || StgPosNum != 0
				InsertPoints /M=0 (ridx), 1, RawDataM
			endif
			for(i = 0; i < dnum-1; i += 1)
				RawDataM[ridx][i] = str2num(StringFromList(i+1, Line, ",")) // read the data into the wave matrix
					// the 1st item in the data line is transition name, i.g. Ba4d
					// the 2nd is center energy
					// the 3rd is pass energy
					// the 4th is Polar angle
					// the 5th is Azimuthal angle
					// the 6th is the sum of the counts of all channels
					// the 7th ~ 134th are the intensity of each channel
			endfor
			//elimninate the abnormal intensity at Channel 128 (RawDataM[ridx][5], ywp[3])
			if(RawDataM[ridx][5] >= 2*RawDataM[ridx][6])
				RawDataM[ridx][5] = RawDataM[ridx][6]
			endif
			//elimninate the abnormal intensity at Channel 1 (RawDataM[ridx][132], ywp[130])
			if(RawDataM[ridx][ChNum+4] >= 2*RawDataM[ridx][131])
				RawDataM[ridx][ChNum+4] = RawDataM[ridx][131]
			endif
			Ekc = RawDataM[ridx][0]
			PE = RawDataM[ridx][1]
			Wave EngM = dfraq:EngM
			if(StgPosNum == 0)
				EngM[nth-1][] = Ekc + PE*DispW[q]
			endif
			
			tht = RawDataM[ridx][2]
			phi = RawDataM[ridx][3]
			if(Is1st == 1)
				MinThtDat = tht
				MaxThtDat = tht
				Is1st = 0
			else
				if(MinThtDat > tht)
					MinThtDat = tht
				endif
				if(MaxThtDat < tht)
					MaxThtDat = tht
				endif
			endif
			if (numtype(tht) != 0 || numtype(phi) != 0)
				print "Warning: theta or Phi angle is NaN, treat this position as NULL !"
			endif
			
			Make/O/Free/N=(ChNum+3) ywp //ywp: yw prime, contains theta angles, phi angles, sum of counts of all channels, and counts of each channel
			ywp = RawDataM[ridx][p+2]
			DisplaySpectrum(EngM, ywp, StgPosNum, nth, trans)

			if(StgPosNum == 0 && nth == 1 && com1cked == 1 && PeakNum1 == 0) // check if com1cked = 1
				Wave pkposw1 = dfrfit:pkposw1
				PkSel1 = 0
				Textbox /W=$"SpectrumWin"+num2str(nth)/C/N=SelPkTB/F=0/A=LT/X=1.00/Y=1.00 "\\F'Arial Black'Please specify the positions of two peaks for fitting!"
				ModifyGraph mode($("yw"+num2str(nth)))=3, marker($("yw"+num2str(nth)))=8,rgb($("yw"+num2str(nth)))=(8704,8704,8704)
				SetWindow $"SpectrumWin"+num2str(nth), hook(pickpeaks1) = HookCsrToPickPeaks1
				if(ridx > 0)
					DeletePoints /M=0 (ridx), 1, RawDataM //the background task will start again to read the file but here is going to RETURN
				endif
				if(LNum > 3)
					LNum -= 1
				elseif(LNum == 3)
					LNum = 0
				endif
				break
			endif

			if(StgPosNum == 0 && nth == 2 && com2cked == 1 && PeakNum2 == 0) // check if com2cked = 1
				PkSel2 = 0
				Wave pkposw2 = dfrfit:pkposw2
				Textbox /W=$"SpectrumWin"+num2str(nth)/C/N=SelPkTB/F=0/A=LT/X=1.00/Y=1.00 "\\F'Arial Black'Please specify the positions of two peaks for fitting!"
				ModifyGraph mode($("yw"+num2str(nth)))=3, marker($("yw"+num2str(nth)))=8,rgb($("yw"+num2str(nth)))=(8704,8704,8704)
				SetWindow $"SpectrumWin"+num2str(nth), hook(pickpeaks2) = HookCsrToPickPeaks2
				if(ridx > 0)
					DeletePoints /M=0 (ridx), 1, RawDataM //the background task will start again to read the file but here is going to RETURN
				endif
				if(LNum > 3)
					LNum -= 1
				elseif(LNum == 3)
					LNum = 0
				endif
				break
			endif

			if(StgPosNum == 0 && nth == 3 && com3cked == 1 && PeakNum3 == 0) // check if com2cked = 1
				PkSel3 = 0
				Wave pkposw3 = dfrfit:pkposw3
				Textbox /W=$"SpectrumWin"+num2str(nth)/C/N=SelPkTB/F=0/A=LT/X=1.00/Y=1.00 "\\F'Arial Black'Please specify the positions of two peaks for fitting!"
				ModifyGraph mode($("yw"+num2str(nth)))=3, marker($("yw"+num2str(nth)))=8,rgb($("yw"+num2str(nth)))=(8704,8704,8704)
				SetWindow $"SpectrumWin"+num2str(nth), hook(pickpeaks3) = HookCsrToPickPeaks3
				if(ridx > 0)
					DeletePoints /M=0 (ridx), 1, RawDataM //the background task will start again to read the file but here is going to RETURN
				endif
				if(LNum > 3)
					LNum -= 1
				elseif(LNum == 3)
					LNum = 0
				endif
				break
			endif

			if(StgPosNum == 0 && nth == 4 && com4cked == 1 && PeakNum4 == 0) // check if com2cked = 1
				PkSel4 = 0
				Wave pkposw4 = dfrfit:pkposw4
				Textbox /W=$"SpectrumWin"+num2str(nth)/C/N=SelPkTB/F=0/A=LT/X=1.00/Y=1.00 "\\F'Arial Black'Please specify the positions of two peaks for fitting!"
				ModifyGraph mode($("yw"+num2str(nth)))=3, marker($("yw"+num2str(nth)))=8,rgb($("yw"+num2str(nth)))=(8704,8704,8704)
				SetWindow $"SpectrumWin"+num2str(nth), hook(pickpeaks4) = HookCsrToPickPeaks4
				if(ridx > 0)
					DeletePoints /M=0 (ridx), 1, RawDataM //the background task will start again to read the file but here is going to RETURN
				endif
				if(LNum > 3)
					LNum -= 1
				elseif(LNum == 3)
					LNum = 0
				endif
				break
			endif

			Make/O/Free/N=(ChNum) yw
			yw = ywp[p+3]

			if(RawCked == 1)
				CkCnt += 1
				if(ckcnt == cknum)
					ckcnt = 0
				endif
				its = area(yw)
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "C")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "C")
				endif
			endif

			if(MaxCked == 1)
				its = WaveMax(yw) - WaveMin(yw)
				CkCnt += 1
				its = DoPolBgSubt(tht, phi, its, "M") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "M")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "M")
				endif
			endif

			if(WholeCked == 1)
				its = DoShirleyBackgroundSubtr(yw) // do Shirley Background substraction
				CkCnt += 1
				its = DoPolBgSubt(tht, phi, its, "H") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "H")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "H")
				endif
			endif

			if(Com1Cked == 1 && nth == 1)
				Wave/SDFR=dfrfit cw11, cw21, xw1, yw1
				NVAR/SDFR=dfrfit Is1stFit1, IsFitting1
				Cursor /K A
				Cursor /K B
				IsFitting1 = 1
				xw1 = EngM[nth-1][p]
				Duplicate/O yw, yw1
				FitErr = Fit2VoigtPeaks(nth)
				CkCnt += 1
				Wave/SDFR=dfraq ItsW1Lr
				if(WaveExists(ItsW1Lr))
					LstPnt = numpnts(ItsW1Lr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW1Lr[LstPnt]
				else
					DisplayCurves(nth)
					its = cw11[2]*sqrt(pi)/cw11[1] //left component's area, no background
					if(LstPnt !=0 && its >= ItsW1Lr[LstPnt]*10) //abnormal intensity error
						its = ItsW1Lr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "L") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "L")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "L")
				endif
				CkCnt += 1
				Wave/SDFR=dfraq ItsW1Rr
				if(WaveExists(ItsW1Rr))
					LstPnt = numpnts(ItsW1Rr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW1Rr[LstPnt]
				else
					its = cw21[2]*sqrt(pi)/cw21[1] //right component's area, no background
					if(LstPnt !=0 && its >= ItsW1Rr[LstPnt]*10) //abnormal area error
						its = ItsW1Rr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "R") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "R")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "R")
				endif
				IsFitting1 = 0
			endif

			if(Com2Cked == 1 && nth == 2)
				Wave/SDFR=dfrfit cw12, cw22, xw2, yw2
				NVAR/SDFR=dfrfit Is1stFit2, IsFitting2
				NVAR/SDFR=dfraq CkCnt
				Wave/SDFR=dfraq SumAzItsW
				Cursor /K C
				Cursor /K D
				IsFitting2 = 1
				xw2 = EngM[nth-1][p]
				Duplicate/O yw, yw2 
				FitErr = Fit2VoigtPeaks(nth)
				CkCnt += 1
				Wave/SDFR=dfraq ItsW2Lr
				if(WaveExists(ItsW2Lr))
					LstPnt = numpnts(ItsW2Lr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW2Lr[LstPnt]
				else
					DisplayCurves(nth)
					its = cw12[2]*sqrt(pi)/cw12[1] //left component's area, no background
					if(LstPnt !=0 && its >= ItsW2Lr[LstPnt]*10) //abnormal intensity error
						its = ItsW2Lr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "L") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "L")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "L")
				endif
				CkCnt += 1
				Wave/SDFR=dfraq ItsW2Rr
				if(WaveExists(ItsW2Rr))
					LstPnt = numpnts(ItsW2Rr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW2Rr[LstPnt]
				else
					its = cw22[2]*sqrt(pi)/cw22[1] //right component's area, no background
					if(LstPnt !=0 && its >= ItsW2Rr[LstPnt]*10) //abnormal area error
						its = ItsW2Rr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "R") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "R")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "R")
				endif
				IsFitting2 = 0
			endif

			if(Com3Cked == 1 && nth == 3)
				Wave/SDFR=dfrfit cw13, cw23, xw3, yw3
				NVAR/SDFR=dfrfit Is1stFit3, IsFitting3
				Cursor /K E
				Cursor /K F
				IsFitting3 = 1
				xw3 = EngM[nth-1][p]
				Duplicate/O yw, yw3
				FitErr = Fit2VoigtPeaks(nth)
				CkCnt += 1
				Wave/SDFR=dfraq ItsW3Lr
				if(WaveExists(ItsW3Lr))
					LstPnt = numpnts(ItsW3Lr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW3Lr[LstPnt]
				else
					DisplayCurves(nth)
					its = cw13[2]*sqrt(pi)/cw13[1] //left component's area, no background
					if(LstPnt !=0 && its >= ItsW3Lr[LstPnt]*10) //abnormal intensity error
						its = ItsW3Lr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "L") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "L")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "L")
				endif
				CkCnt += 1
				Wave/SDFR=dfraq ItsW3Rr
				if(WaveExists(ItsW3Rr))
					LstPnt = numpnts(ItsW3Rr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW3Rr[LstPnt]
				else
					its = cw23[2]*sqrt(pi)/cw23[1] //right component's area, no background
					if(LstPnt !=0 && its >= ItsW3Rr[LstPnt]*10) //abnormal area error
						its = ItsW3Rr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "R") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "R")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "R")
				endif
				IsFitting3 = 0
			endif
			
			if(Com4Cked == 1 && nth == 4)
				Wave/SDFR=dfrfit cw14, cw24, xw4, yw4
				NVAR/SDFR=dfrfit Is1stFit4, IsFitting4
				Cursor /K G
				Cursor /K H
				IsFitting4 = 1
				xw4 = EngM[nth-1][p]
				Duplicate/O yw, yw4
				FitErr = Fit2VoigtPeaks(nth)
				CkCnt += 1
				Wave/SDFR=dfraq ItsW4Lr
				if(WaveExists(ItsW4Lr))
					LstPnt = numpnts(ItsW4Lr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW4Lr[LstPnt]
				else
					DisplayCurves(nth)
					its = cw14[2]*sqrt(pi)/cw14[1] //left component's area, no background
					if(LstPnt !=0 && its >= ItsW4Lr[LstPnt]*10) //abnormal intensity error
						its = ItsW4Lr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "L") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "L")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "L")
				endif
				CkCnt += 1
				Wave/SDFR=dfraq ItsW4Rr
				if(WaveExists(ItsW4Rr))
					LstPnt = numpnts(ItsW4Rr)-1
				endif
				if(FitErr == 1 && LstPnt != 0)
					its = ItsW4Rr[LstPnt]
				else
					its = cw24[2]*sqrt(pi)/cw24[1] //right component's area, no background
					if(LstPnt !=0 && its >= ItsW4Rr[LstPnt]*10) //abnormal area error
						its = ItsW4Rr[LstPnt]
					endif
				endif
				its = DoPolBgSubt(tht, phi, its, "R") 
				DisplayXPD(tht, phi, its, StgPosNum, nth, trans, ams, "R")
				if(AutoRangeCked == 1)
					UpdateRadAxis(nth, "R")
				endif
				IsFitting4 = 0
			endif
			
			//Display XPD color scale
			if(ridx == 0) //only at the first sprectrum, StgPosNum == 0 && nth == 1
				DoWindow/F XPD_Color_Scale
				if(V_flag == 0)
					Display/W=(4,321,195,401)/N=XPD_Color_Scale/k=2
					DoWindow/T XPD_Color_Scale, "Color scale of patterns"
					ColorScale/W=XPD_Color_Scale/C/N=XPDColorScale/F=0/A=MC/E=2/X=0.00/Y=0.00 ctab={0,100,YellowHot,0},widthPct=100,vert=0, trace={XPDWin1,polarY0}
				endif
			endif	
			print "Read data successfully! Total number of the spectra: ", ridx + 1
			
			if(nth == ClvNum) 
				nth = 1 // count from 1st again
				StgPosNum += 1
			else
				nth += 1
			endif
		endif
	while(1)
	Close refNum
	return 0 // Continue background task
End

Function Fit2VoigtPeaks(n)
	Variable n
	String FitDF = "root:Packages:XPD:Fit:"
	Wave xw = $(FitDF+"xw"+num2str(n))
	Wave yw = $(FitDF+"yw"+num2str(n))
	Wave ywnbg = $(FitDF+"ywnbg"+num2str(n))
	Wave pkposW = $(FitDF+"pkposW"+num2str(n))
	Wave cm = $(FitDF+"cm"+num2str(n))
	Wave cw1 = $(FitDF+"cw1"+num2str(n))
	Wave cw2 = $(FitDF+"cw2"+num2str(n))
	Wave/T ConStrW = $(FitDF+"ConStrW")
	Wave FitW = $(FitDF+"FitW"+num2str(n))
	Wave peak1W = $(FitDF+"peak1W"+num2str(n))
	Wave peak2W = $(FitDF+"peak2W"+num2str(n))
	NVAR FitErrCnt = $(FitDF+"FitErrCnt")
	Variable t, err, ylen

	ylen = numpnts(yw)
	Make/O/Free/N=(ylen) tmpW
	Wave tmpW = ShirleyBackgroundSubtr(yw) // do Shirley Background substraction
	Duplicate/O tmpW, ywnbg
	MakeMonoWaves(xw, ywnbg)
	SetScale/I x, xw[0], xw[ylen-1], ywnbg
	Make/O/Free/N=(4,2) tmpW
	Wave tmpW = CoefGuess(ywnbg, pkposw)
	Duplicate/O tmpW, cm
	for(t=0; t<4; t += 1)
		cw1[t] = cm[t][0]
		cw2[t] = cm[t][1]
	endfor
	ConStrW[0] = {"K0 < " + num2str(cw1[0]+abs(cw1[0]-cw2[0])/2)}
	ConStrW[1] = {"K0 > " + num2str(cw1[0]-abs(cw1[0]-cw2[0])/2)}
	ConStrW[5] = {"K4 < " + num2str(cw2[0]+abs(cw1[0]-cw2[0])/2)}
	ConStrW[6] = {"K4 > " + num2str(cw2[0]-abs(cw1[0]-cw2[0])/2)}
	String fitSpecStr = "{MPFXVoigtPeak, root:Packages:XPD:Fit:cw1"+num2str(n)+"}, {MPFXVoigtPeak, root:Packages:XPD:Fit:cw2"+num2str(n)+"}"
	FuncFit/Q/N/W=2 {string=fitSpecStr}, ywnbg /C=ConStrW /D=FitW //r=rsdw
		// MPFXVoigtPeak is from the Igor Pro's built-in Multi-peak Fit Package(XOP)
	err = getrterror(0)
	if(err != 0)
		err = getrterror(1)
		String message = GetErrMessage(err)
	    Printf "Fitting error: %s.\r", message
		FitErrCnt += 1
		if(FitErrCnt > 10)
			Abort "Too many Fitting errors (the number of errors > 10). Abort!\r"
		else
			Return 1 //error
		endif
	else
		Print "Fitting is successful."
	endif
	MPFXVoigtPeak(cw1, peak1W, xw)
	MPFXVoigtPeak(cw2, peak2W, xw)
	return 0 // no error
end

Function DisplayCurves(n)
	Variable n
	String FitDF = "root:Packages:XPD:Fit:"
	Wave xw = $(FitDF+"xw"+num2str(n))
	Wave FitW = $(FitDF+"FitW"+num2str(n))
	Wave peak1W = $(FitDF+"peak1W"+num2str(n))
	Wave peak2W = $(FitDF+"peak2W"+num2str(n))
	Wave bgW = $(FitDF+"bgw")
	NVAR Is1stFit = $(FitDF+"Is1stFit"+num2str(n))
	DFREF dfraq = GetDAQPackageDFREF()
	SVAR/SDFR=dfraq lgstr //lgstr: legend string
	
	FitW = FitW+bgW
	FitW[0] = FitW[1]
	FitW[numpnts(FitW)-1] = FitW[numpnts(FitW)-2]

	if(Is1stFit == 1)
		AppendToGraph/W=$"SpectrumWin"+num2str(n) FitW, peak1W, peak2W vs xw
		ModifyGraph/W=$"SpectrumWin"+num2str(n) mode($NameofWave(FitW))=0, lsize($NameofWave(FitW))=2;DelayUpdate
		ModifyGraph/W=$"SpectrumWin"+num2str(n) mode($NameofWave(peak1W))=7, hbFill($NameofWave(peak1W))=2,rgb($NameofWave(peak1W))=(0,15872,65280);DelayUpdate // (16384,48896,65280)
		ModifyGraph/W=$"SpectrumWin"+num2str(n) mode($NameofWave(peak2W))=7, hbFill($NameofWave(peak2W))=2,rgb($NameofWave(peak2W))=(65280,49152,16384)
		Legend/W=$"SpectrumWin"+num2str(n)/A=RT/C/F=0/N=swlgbox/J lgstr
		Is1stFit = 0
	else
		DoUpdate/W=$"SpectrumWin"+num2str(n)
	endif
End

Function DisplaySpectrum(EngM, ywp, sn, n, CLvName)
	Wave EngM, ywp //ywp: yw prime, contains a row of data of CASCADE data format
	Variable sn, n //sn: stage position number; n: the count number of the core levels, 1 <= n <= CLvNum 
	String CLvName
	DFREF dfraq = GetDAQPackageDFREF()
	Variable len, tht, phi

	DoWindow/F $"SpectrumWin"+num2str(n) //test whether the Spectrum window exists and bring the window to the front.
	if (V_Flag == 0) // if the Spectrum window doesn't exists
		GetWindow DAQPanel, wsize
		if(n <= 4)
			Display/N=$"SpectrumWin"+num2str(n)/K=2/W=(V_right+12,V_top+(n-1)*50,V_right+12+380,V_top+(n-1)*50+225)
		else
			Display/N=$"SpectrumWin"+num2str(n)/K=2/W=(V_right+12,V_top+5*50,V_right+12+380,V_top+5*50+225)
		endif
	endif
	
	len = numpnts(ywp)-3
	if( sn == 0 ) // at the beginning
		SetDataFolder dfraq
		Make /O/N=(len) $"xw"+num2str(n), $"yw"+num2str(n)
		Wave xw = dfraq:$"xw"+num2str(n)
		Wave yw = dfraq:$"yw"+num2str(n)
		xw = EngM[n-1][p]
		yw = ywp[p+3]
		AppendtoGraph/W=$"SpectrumWin"+num2str(n) yw vs xw
		SetDataFolder ::::

		ModifyGraph tick(left)=3,tick(bottom)=2,mirror=1,fSize(bottom)=12,noLabel(left)=1;DelayUpdate
		ModifyGraph font(bottom)="Arial", font(left)="Arial";DelayUpdate
		Label left "\\F'Arial'\\Z13Intensity (a.u.)";DelayUpdate
		Label bottom "\\F'Arial'\\Z13Energy (eV)";DelayUpdate
		ModifyGraph lblPosMode(left)=4,lblPos(left)=25, lblPosMode(bottom)=4,lblPos(bottom)=30;DelayUpdate
		ModifyGraph margin(left)=48//, width=520, height=275
	endif
	Wave xw = dfraq:$"xw"+num2str(n)
	Wave yw = dfraq:$"yw"+num2str(n)
	yw = ywp[p+3]

	if(strlen(CLvName) == 0)
		DoWindow/F/T $"SpectrumWin"+num2str(n),"Spectrum "+num2str(n)
	else
		DoWindow/F/T $"SpectrumWin"+num2str(n),"Spectrum: "+CLvName
	endif
	tht = ywp[0]
	phi = ywp[1]
	SVAR/SDFR=dfraq lgstr //lgstr: legend string
	lgstr = "\\F'Arial'("+num2str(tht)+"; "+num2str(phi)+")"
	Legend/A=RT/C/F=0/N=swlgbox/J lgstr
End

Function DisplayXPD(tht, phi, its, sn, n, CLvName, AMS, DMS)
	Variable tht, phi, its, sn, n
		// sn: stage position number; n: the index of the core level, start from 1
	String CLvName, AMS, DMS//AMS: All display Mode String, DMS: Display Mode String
	Variable a
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq MinThtRange, MaxThtRange, MinThtDat, MaxThtDat, AutoRangeCked, ManuRangeCked
	Variable MinTht, MaxTht

	
	if(phi < 0)
		phi = 360+phi
	endif
	if(sn == 0) // at the beginning
		SetDataFolder dfraq
		make /O/N=1 $"rdsw"+num2str(n)+dms, $"phiw"+num2str(n)+dms, $"itsw"+num2str(n)+dms //crude, raw
		SetDataFolder ::::
	endif
	Wave rdsw = dfraq:$"rdsw"+num2str(n)+dms
	Wave phiW = dfraq:$"phiw"+num2str(n)+dms
	Wave itsw = dfraq:$"itsw"+num2str(n)+dms
	if(Sn != 0)
		InsertPoints sn, 1, rdsw, phiw, itsw
	endif
	rdsw[sn] = tht
	phiw[sn] = phi
	itsw[sn] = its

	DoWindow/F $"XPDWin"+num2str(n)+dms //test whether the XPD window exists and bring the window to the front.
	if (V_Flag == 0) // if the XPD window doesn't exists
		if(AutoRangeCked == 1)
			MinTht = (floor(MinThtDat/5)-1)*5
			if(MinTht < 0)
				MinTht = 0
			endif
			MinTht = (floor(MaxThtDat/5)-1)*5
		else
			MinTht = MinThtRange
			MaxTht = MaxThtRange
		endif
		PlotXPD("XPDWin"+num2str(n)+dms, dfraq:$"rdsw"+num2str(n)+dms, dfraq:$"phiw"+num2str(n)+dms, dfraq:$"itsw"+num2str(n)+dms, MinTht, MaxTht)
		DoWindow/HIDE=1 $"XPDWin"+num2str(n)+dms
		if(cmpstr(dms,"C") == 0)
			a = 0
		endif
		if(cmpstr(dms,"M") == 0)
			a = 1
		endif
		if(cmpstr(dms,"H") == 0)
			a = 2
		endif
		if(cmpstr(dms,"L") == 0)
			a = 3
		endif
		if(cmpstr(dms,"R") == 0)
			a = 4
		endif

		if(strlen(CLvName) == 0)
			DoWindow/T $"XPDWin"+num2str(n)+dms, "XPD " + num2str(n)+StringFromList(a,ams)
		else
			DoWindow/T $"XPDWin"+num2str(n)+dms, "XPD " + CLvName +StringFromList(a,ams)
		endif

		GetWindow SpectrumWin1, wsize
		if(n <= 4)
			if(mod(n, 2) != 0) // if n is odd
				MoveWindow/W=$"XPDWin"+num2str(n)+dms V_right+12+a*25, V_top+((n-1)/2)*(225+29)+a*25, V_right+12+225+a*25, V_top+((n-1)/2)*(225+29)+a*25+225
			else
				MoveWindow/W=$"XPDWin"+num2str(n)+dms V_right+47+225+a*25, V_top+((n-2)/2)*(225+29)+a*25, V_right+47+450+a*25, V_top+((n-2)/2)*(225+29)+a*25+225
			endif
		else
			if(mod(n, 2) != 0) // if n is odd
				MoveWindow/W=$"XPDWin"+num2str(n)+dms V_right+12+a*25,V_top+2*(225+29)+a*25,V_right+12+225+a*25,V_top+2*(225+29)+225+a*25
			else
				MoveWindow/W=$"XPDWin"+num2str(n)+dms V_right+47+225+a*25,V_top+2*(225+29)+a*25,V_right+47+600+a*25,V_top+2*(225+29)+225+a*25
			endif
		endif	
		DoWindow/HIDE=0 $"XPDWin"+num2str(n)+dms
		Button ManiButt win=$"XPDWin"+num2str(n)+dms, title="Process",size={55,20},font="Arial", pos+={5, 270}, proc=ProcessPtnBtnProc, help={"Click to process and analyze the current pattern."}
		Button SaveButt win=$"XPDWin"+num2str(n)+dms, title="Save",size={55,20},font="Arial", pos+={200, 0}, proc=SavePtnBtnProc, help={"Click to save the data of the current patten into a file."}
	else
		DoWindow/F $"XPDWin"+num2str(n)+dms //bring the window to the front
	endif
End

Function UpdateRadAxis(n, dms)
	Variable n
	String dms
	DFREF dfraq = GetDAQPackageDFREF()	
	NVAR innRad = $WMPolarTopOrDefaultDFVar("innerRadius")
	NVAR outRad = $WMPolarTopOrDefaultDFVar("outerRadius")
	NVAR/SDFR=dfraq MinThtDat, MaxThtDat

	//Wave rdsw = dfraq:$"rdsw"+num2str(n)+dms
	//Wave phiW = dfraq:$"phiw"+num2str(n)+dms
	//Wave itsw = dfraq:$"itsw"+num2str(n)+dms	
	//MinThtDat = WaveMin(RdsW)
	//MaxThtDat = WaveMax(RdsW)
	if(innRad > MinThtDat)
		innRad = (floor(MinThtDat/5)-1)*5
		if(innRad < 0)
			innRad = 0
		endif
		WMPolarAxesRedrawTopGraph()
	elseif(outRad < MaxThtDat)
		outRad = (floor(MaxThtDat/5)+1)*5
		WMPolarAxesRedrawTopGraph()
	endif
End

//the "Analyze" button is at the bottom left corner of the XPD graph
Function ProcessPtnBtnProc(BtnStrc) : ButtonControl
	STRUCT WMButtonAction &BtnStrc

	if( BtnStrc.eventCode != 1 )
		return 0	                           // Only handle mouse down
	endif

	DFREF dfraq =  GetDAQPackageDFREF()
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfraq RawDataM, EngM
	NVAR/SDFR=dfraq CLvNum
	Variable rownum, colnum, n, qnt, rmd, i //qnt: quotient, rmd: remainder
	String dms//display mode string
	
	SetDataFolder dfrp
	rownum = DimSize(RawDataM, 0)
	colnum = DimSize(RawDataM, 1)
	n = char2num(num2char(BtnStrc.Win[6])) - 48 // ASCII(48) == 0, the XPD window's name is XPDWin1, XPDWin2, ...
	dms = num2char(BtnStrc.Win[7])
	GetWindow $BtnStrc.Win, title

	if(rownum < CLvNum)
		Make /O/N=(rownum, colnum) XPDM
	else
		qnt = trunc(rownum/CLvNum)//quotient
		rmd = mod(rownum, clvnum)//remainder
		if( rmd < n)
			Make /O/N=(qnt, colnum) XPDM
		else
			Make /O/N=(qnt+1, colnum) XPDM
		endif
	endif
	
	i = 0
	do
		XPDM[i][] = RawDataM[i*CLvNum+n-1][q]
		i += 1
	while(i < qnt)
	if( rmd >= n)
		XPDM[i][] = RawDataM[i*CLvNum+n-1][q]
	endif
	
	Make /O/N=(colnum-5) EngW
	EngW = EngM[n-1][p]
	
	//XPDM[][4] = XPDM[p][colnum-1] //copy the counts sum without background to column 6 (replace the sum with background)
	
	//delete the unwanted columns, only leave theta, phi, sum without background, and  channel counts
	//DeletePoints /M=1 (colnum-1), 1, XPDM
	DeletePoints /M=1 0, 2, XPDM
	
	Duplicate/O dfraq:$"rdsw"+num2str(n)+dms, RdsW
	Duplicate/O dfraq:$"phiw"+num2str(n)+dms, PhiW
	Duplicate/O dfraq:$"itsw"+num2str(n)+dms, ItsW
	
	//if the radius in the file is length, transform it to theta angle
	if( WaveMax(RdsW) < 1)
		RdsW = atan(RdsW[p]/2)*2/pi*180
	endif
	NVAR innRad = $WMPolarTopOrDefaultDFVar("innerRadius")
	NVAR outRad = $WMPolarTopOrDefaultDFVar("outerRadius")
	
	DoWindow/F ProcessGraphWin
	if(V_flag == 0)
		PlotXPD("ProcessGraphWin", RdsW, PhiW, ItsW, innRad, outRad)
		DoWindow/T ProcessGraphWin, S_value //S_value from the above command GetWindow
		MoveWindow/W=ProcessGraphWin 400, 50, 630, 280
	endif
	
	SetWindow ProcessGraphWin, hook(pickPixel) = HookCsrToPickPixel
	
	DoWindow/F ProcessPanel

	if(V_flag == 0)
		InitProcessPanel()
	endif
	
	MoveWindow /W=ProcessPanel 669, 50, 827, 475
	
	SetDataFolder ::::
End

//Save the raw data of the XPD pattern
//the Save button is at the bottom right corner of the XPD graph
Function SavePtnBtnProc(BtnStrc) : ButtonControl
	STRUCT WMButtonAction &BtnStrc
	
	if( BtnStrc.eventCode != 1 )
		return 0	                           // Only handle mouse down
	endif
	
	DFREF dfraq =  GetDAQPackageDFREF()
	Wave/SDFR=dfraq RawDataM, EngM
	NVAR/SDFR=dfraq CLvNum
	String message, fileFilters, dms
	Variable refNum, rownum, colnum, EngPnt, qnt, rmd, n, i //qnt: quotient, rmd: remainder

	//Display a save file dialogue to let users input a file name
	message = "Save the XPD data to a file..."
	fileFilters = "XPD data Files (*.xpd):.xpd; All Files:.*;"
	Open/D/F=fileFilters/M=message refNum
	if (strlen(S_fileName) == 0)
		Abort
	else
		rownum = DimSize(RawDataM, 0)
		colnum = DimSize(RawDataM, 1)
		EngPnt = colnum - 5
		n = char2num(num2char(BtnStrc.Win[6])) - 48 // ASCII(48) == 0, the XPD window's name is XPDWin1, XPDWin2, ...
		dms = num2char(BtnStrc.Win[7])//displaying mode string
		if(rownum < CLvNum)
			Make /O/Free/N=(rownum, colnum) tmpm
		else
			qnt = trunc(rownum/CLvNum)
			rmd = mod(rownum, clvnum)
			if( rmd < n)
				Make /O/Free/N=(qnt, colnum) tmpm
			else
				Make /O/Free/N=(qnt+1, colnum) tmpm
			endif
		endif
		i = 0
		do
			tmpm[i][] = RawDataM[i*CLvNum+n-1][q]
			i += 1
		while(i < qnt)
		if( rmd >= n)
			tmpm[i][] = RawDataM[i*CLvNum+n-1][q]
		endif
		
		Make /Free/O/N=(EngPnt) EngW
		EngW = EngM[n-1][p]
		Wave itsw = dfraq:$"itsw"+num2str(n)+dms
		tmpm[][4] = itsw[p] //copy the intensity to column 5 (replace the sum of the counts)
		
		//delete the unwanted columns, only leave theta, phi, sum without background, and channel counts
		DeletePoints /M=1 0, 2, tmpm
		
		Open refNum as S_fileName
		fprintf refNum, "# This is an XPD and the corresponding XPS data file. \r\n"
		fprintf refNum, "# The 7th line is the correponding energy (eV) of each channel, the other lines are XPD data + XPS intensity.\r\n"
		fprintf refNum, "# Starting from the 8th line, the 1st column is Polar Angle.\r\n"
		fprintf refNum, "# The 2nd column is Azimuthal Angle.\r\n"
		fprintf refNum, "# The 3rd column is Intensity for XPD.\r\n"
		fprintf refNum, "# The other columns are photoelectron counts of each channel of the dectector.\r\n"
		for(i = 0; i < colnum-6; i += 1)
			fprintf refNum, num2str(EngW[i])
			if (i != colnum-7)
				fprintf refNum, "\t"
			else
				fprintf refNum, "\r\n"
			endif
		endfor
		Close refNum
		Save /A=2/J/M="\r\n" tmpm as S_fileName
	endif
End
// ========= XPD Data Acquisition and Display End ===============//

// ========= Analyze XPD pattern ===============//

//Initialize XPD Manipulation Panel
Function InitProcessPanel()
	//CreateXPDPackageData()
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	NVAR/SDFR=dfrp ThtAng, PhiAng, CrnIts
	PauseUpdate; Silent 1		// building window...
	Dowindow/F Processpanel
	if(!V_flag)
		GetWindow ProcessGraphWin, wsize
		NewPanel/N=ProcessPanel/K=2/W=(V_right+200, V_top+12, V_right+409, V_bottom+280) as "Process & Analysis"
	endif

	Button ModifyGraphBtn,Win=Processpanel, pos={20,452},size={90,20},proc=ModifyGraphBtnProc,title="Modify Graph...", help={"Click to modify the appearance of the current graph."}
	Button ModifyGraphBtn,Win=Processpanel, font="Arial",fStyle=0
	Button SaveBtn,Win=Processpanel, pos={120,452},size={70,20},proc=SaveDataBtnProc,title="Save Data..."
	Button SaveBtn,Win=Processpanel, font="Arial",fStyle=0, help={"Click to save the data of the current pattern into a file."}

	GroupBox CrnAngBox,Win=Processpanel, pos={5,475},size={202,85},title="Current Clicked Point",font="Arial",fStyle=1, labelBack=(65535,65535,65535), help={"Display the coordinates of the current clicked data point."}
	ValDisplay CrnThtVal,Win=Processpanel, pos={20,495},size={120,16},title="Theta (deg):"
	ValDisplay CrnThtVal,Win=Processpanel, font="Arial", valueBackColor=(65535,65535,65535), frame = 0
	ValDisplay CrnThtVal,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:ThtAng
	ValDisplay CrnPhiVal,Win=Processpanel, pos={20,515},size={120,16},title="Phi (deg):"
	ValDisplay CrnPhiVal,Win=Processpanel, font="Arial",valueBackColor=(65535,65535,65535), frame = 0
	ValDisplay CrnPhiVal,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:PhiAng
	ValDisplay CrnItsVal,Win=Processpanel, pos={20,535},size={150,16},title="Intensity (a.u.):"
	ValDisplay CrnItsVal,Win=Processpanel, font="Arial",valueBackColor=(65535,65535,65535),frame = 0
	ValDisplay CrnItsVal,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:CrnIts
	
	TabControl ManTab,Win=Processpanel, pos={5,7},size={202,443},font="Arial",fStyle=1, proc=TabSwitchProc
	TabControl ManTab,Win=Processpanel, tabLabel(0)="    Process    "
	TabControl ManTab,Win=Processpanel, tabLabel(1)="     Analysis   "
	TabSwitch(0)
End

Function TabSwitchProc(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	
	TabSwitch(tabNum)
	
	return 0
End

Function TabSwitch(TabNum)
	Variable TabNum

	TabControl ManTab Win=Processpanel, value=TabNum
	Switch(TabNum)
		case 0:
			ProcessTab(1)
			AnalysisTab(0)
			break
		case 1:
			ProcessTab(0)
			AnalysisTab(1)
			break
	endswitch
End

Function ProcessTab(show)
	Variable show
	Variable state = show ? 0 : 1 //0 is enable (shown), 1 is hidden, 2 is disable
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp RdsW, PhiW
	NVAR/SDFR=dfrp StartPhi, EndPhi, StartTht, EndTht
	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	StartTht = truncateDP(WaveMin(RdsW), 1)
	EndTht = truncateDP(WaveMax(RdsW), 1)
	GroupBox RotGrBox,Win=Processpanel, pos={15,30},size={177,95},title="Rotate",font="Arial",fStyle=1, disable=state, help={"Rotate the pattern in azimuthal direction."}
	TitleBox CCW,Win=Processpanel, pos={34,50},size={29,15},title="CCW",font="Arial",frame=0, disable=state, help={"Counter ClockWise direction."}
	TitleBox CW,Win=Processpanel, pos={153,50},size={20,15},title="CW",font="Arial",frame=0, disable=state, help={"Clockwise direction."}
	TitleBox Step,Win=Processpanel, pos={75,50},size={36,15},title="Step(deg.)",font="Arial",fsize=13, frame=0, disable=state, help={"Input the step size of rotation of single click."}
	SetVariable StepValBox,Win=Processpanel, pos={73,68},size={55,16}, disable=state
	SetVariable StepValBox,Win=Processpanel, help={"Input the step size of Phi angle (in Degree) when clicking the CW or CCW buttons."}
	SetVariable StepValBox,Win=Processpanel, fColor=(60928,60928,60928)
	SetVariable StepValBox,Win=Processpanel, limits={0,180,0.1},value= dfrp:sv
	Button CCWBtn,Win=Processpanel, pos={34,65},size={30,20},proc=CCWBtnProc,title="<<", disable=state, help={"Click to rotate the pattern in counter clockwish direction."}
	Button CCWBtn,Win=Processpanel, font="Times New Roman"
	Button CWBtn,Win=Processpanel, pos={149,65},size={30,20},proc=CWBtnProc,title=">>", disable=state
	Button CWBtn,Win=Processpanel, font="Times New Roman", help={"Click to rotate the pattern in clockwise direction."}
	
	ValDisplay AzimAngSt,Win=Processpanel, pos={20,87},size={125,16},title="Azimuthal (deg.):", disable=state, help={"Current azimuthal angle range of the pattern"}
	ValDisplay AzimAngSt,Win=Processpanel, font="Arial",valueBackColor=(65535,65535,65535), frame = 0
	ValDisplay AzimAngSt,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:StartPhi
	TitleBox DashlineA,Win=Processpanel, pos={148,87},size={5,5},title="-",font="Arial",fsize=13, frame=0, disable=state
	ValDisplay AzimAngEnd,Win=Processpanel, pos={153,87},size={33,16},title="", disable=state, frame = 0
	ValDisplay AzimAngEnd,Win=Processpanel, font="Arial",valueBackColor=(65535,65535,65535), frame = 0
	ValDisplay AzimAngEnd,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:EndPhi
	
	ValDisplay PolarAngSt,Win=Processpanel, pos={44,102},size={86,16},title="Polar (deg.):", disable=state
	ValDisplay PolarAngSt,Win=Processpanel, font="Arial",valueBackColor=(65535,65535,65535), frame = 0, help={"Current polar angle range of the pattern."}
	ValDisplay PolarAngSt,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:StartTht
	TitleBox DashlineP,Win=Processpanel, pos={148,102},size={5,5},title="-",font="Arial",fsize=13, frame=0, disable=state
	ValDisplay PolarAngEnd,Win=Processpanel, pos={153,102},size={33,16},title="", disable=state
	ValDisplay PolarAngEnd,Win=Processpanel, font="Arial",valueBackColor=(65535,65535,65535), frame = 0
	ValDisplay PolarAngEnd,Win=Processpanel, limits={0,0,0},barmisc={0,1000},value= _NUM:EndTht
	
	GroupBox AzimCrop,Win=Processpanel, pos={15,130},size={177,90},title="Azimuthal Crop",font="Arial",fStyle=1, disable=state, help={"Crop the pattern azimuthally in CCW direction."}
	SetVariable CropIncPhiBox,Win=Processpanel, pos={20,150},size={165,18},title="Angular Range (deg.):", disable=state
	SetVariable CropIncPhiBox,Win=Processpanel, help={"Input the azimuthal angular range of the cropped pattern."}
	SetVariable CropIncPhiBox,Win=Processpanel, font="Arial"
	SetVariable CropIncPhiBox,Win=Processpanel, limits={0,180,0.5},value= dfrp:CropIncPhi
	SetVariable CropStPhiBox,Win=Processpanel, pos={26,170},size={160,18},title="Starting Angle (deg.):", disable=state
	SetVariable CropStPhiBox,Win=Processpanel, help={"Input the starting Phi angle to crop the pattern. The starting angle will be remained. The patten within the range will be remained and the other parts will be cut off."}
	SetVariable CropStPhiBox,Win=Processpanel, font="Arial"
	SetVariable CropStPhiBox,Win=Processpanel, limits={0,180,0.5},value= dfrp:StartCropPhi
	Button AzimCropBtn,Win=Processpanel, pos={53,193},size={40,20},proc=AzimCropBtnProc,title="Crop", disable=state
	Button AzimCropBtn,Win=Processpanel, font="Arial",fStyle=0, help={"Click to crop the pattern."}
	Button UndoAzimCropBtn,Win=Processpanel, pos={115,193},size={40,20},proc=UndoAzimCropBtnProc,title="Undo"
	Button UndoAzimCropBtn,font="Arial",fStyle=0, help={"Click to undo the cropping."}
	
	GroupBox PolarCrop,Win=Processpanel, pos={15,225},size={177,90},title="Polar Crop",font="Arial",fStyle=1, disable=state, help={"Crop the pattern in polar direction."}
	SetVariable CropIncPolarBox,Win=Processpanel, pos={22,245},size={165,18},title="Angular Range (deg.):", disable=state
	SetVariable CropIncPolarBox,Win=Processpanel, help={"Input the polar angular range of the cropped pattern."}
	SetVariable CropIncPolarBox,Win=Processpanel, font="Arial"
	SetVariable CropIncPolarBox,Win=Processpanel, limits={0,180,0.5},value= dfrp:CropIncTht
	SetVariable CropStPolarBox,Win=Processpanel, pos={28,265},size={160,18},title="Starting Angle (deg.):", disable=state
	SetVariable CropStPolarBox,Win=Processpanel, help={"Input the starting Polar angle to crop the pattern. The starting angle will be remained. The patten within the range will be remained and the other parts will be cut off."}
	SetVariable CropStPolarBox,Win=Processpanel, font="Arial"
	SetVariable CropStPolarBox,Win=Processpanel, limits={0,180,0.5},value= dfrp:StartCropTht
	Button PolarCropBtn,Win=Processpanel, pos={53,288},size={40,20},proc=PolarCropBtnProc,title="Crop", disable=state
	Button PolarCropBtn,Win=Processpanel, font="Arial",fStyle=0, help={"Click to crop the pattern."}
	Button UndoPolarCropBtn,Win=Processpanel, pos={115,288},size={40,20},proc=UndoPolarCropBtnProc,title="Undo"
	Button UndoPolarCropBtn,font="Arial",fStyle=0, help={"Click to undo the cropping."}
	
	GroupBox MakeFullPtnGrBox,Win=Processpanel, pos={15,318},size={176,45},title="Make A Full Pattern", disable=state, help={"A full pattern has an azimuthal range of 360 degrees."}
	GroupBox MakeFullPtnGrBox,Win=Processpanel, font="Arial",fStyle=1
	Button MakeBtn,Win=Processpanel, pos={53,337},size={50,20},proc=MakeBtnProc,title="Make", disable=state
	Button MakeBtn,Win=Processpanel, font="Arial",fStyle=0, help={"Click to make an azimuthal 360 deg. full pattern."}
	Button UndoMakeBtn,Win=Processpanel, pos={122,337},size={40,20},proc=UndoMakeBtnProc,title="Undo", disable=state
	Button UndoMakeBtn,Win=Processpanel, font="Arial",fStyle=0, help={"Click to undo making a full pattern."}

	GroupBox SmImgGrBox,Win=Processpanel, pos={12,366},size={188,81},title="Smooth into Image", disable=state
	GroupBox SmImgGrBox,Win=Processpanel, font="Arial",fStyle=1, help={"Smooth the pattern by interpolation. The smoothed pattern will be displayed as an image whose dimensions can be set by users."}
	SetVariable DimX,Win=Processpanel, pos={16,385},size={120,18},title="Dimensions:", disable=state, help={"Input the image's dimensions of the smoothed pattern."}
	SetVariable DimX,Win=Processpanel, font="Arial",limits={10,1000,10},value= dfrp:Xdim
	SetVariable DimY,Win=Processpanel, pos={136,385},size={56,18},title="X", disable=state
	SetVariable DimY,Win=Processpanel, font="Arial",limits={10,1000,10},value= dfrp:Ydim
	CheckBox UseSP,Win=Processpanel, pos={18,405},size={50,15},title="Use stereographic projection",font="Arial",frame=0, disable=state, proc=UseStereoCkProc, help={"If this check is selected, the pattern will be transformed to a pattern used stereographic projection method firstly and then be converted to an image."}
	Button DoSmImgBtn,Win=Processpanel, pos={80,424},size={40,20},proc=DoSmImgBtnProc,title="Do It", disable=state, help={"Click to smooth the pattern and convert it to an image."}
	Button DoSmImgBtn,Win=Processpanel, font="Arial",fStyle=0

	if(show)
		if(WaveExists(dfrp:RdsW_NoAzimCrop))
			Button UndoAzimCropBtn,Win=Processpanel, disable = 0
		else
			Button UndoAzimCropBtn,Win=Processpanel, disable = 2
		endif
		
		if(WaveExists(dfrp:RdsW_NoPolarCrop))
			Button UndoPolarCropBtn,Win=Processpanel, disable = 0
		else
			Button UndoPolarCropBtn,Win=Processpanel, disable = 2
		endif
		
		if(WaveExists(dfrp:RdsW_BfExt))
			Button UndoMakeBtn,Win=Processpanel, disable = 0
		else
			Button UndoMakeBtn,Win=Processpanel, disable = 2
		endif
	else
		Button UndoAzimCropBtn,Win=Processpanel, disable = 1
		Button UndoPolarCropBtn,Win=Processpanel, disable = 1
		Button UndoMakeBtn,Win=Processpanel, disable = 1
	endif
End

Function AnalysisTab(show)
	Variable show
	Variable state = show ? 0 : 1 //0 is enable (shown), 1 is hidden, 2 is disable
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	
	GroupBox AziProfGpBox,Win=Processpanel, pos={15, 37},size={180,105},title="Azimuthal Profiles", disable=state, help={"Display the azimuthal profiles of the pattern."}
	GroupBox AziProfGpBox,Win=Processpanel, font="Arial",fStyle=1
	SetVariable SelThtAngSetVal,Win=Processpanel, pos={35,60},size={140,18},title="Polar Angle (deg.):", disable=state, help={"Input the polar angle at which an azimuthal profile will be displayed. Tips: Click a data point of the pattern to automatically input the polar angle of the point."}
	SetVariable SelThtAngSetVal,Win=Processpanel, font="Arial", proc=DrawCircProcPos
	SetVariable SelThtAngSetVal,Win=Processpanel, limits={0,90,1.0},value= dfrp:SelThtAng
	SetVariable SelThtWidSetVal,Win=Processpanel, pos={35,85},size={140,18},title="Stripe Width(deg.):", disable=state, help={"Input the width of an azimuthal stripe from which the azimuthal profile will be calculated."}
	SetVariable SelThtWidSetVal,Win=Processpanel, font="Arial", proc=DrawCircProcWid
	SetVariable SelThtWidSetVal,Win=Processpanel, limits={0,20,1.0},value= dfrp:SelThtWid
	Button DispAzimProfBtn, Win=Processpanel, pos={79,112},size={50,20},proc=DispAzimProfBtnProc,title="Display", disable=state, help={"Click to display the azimuthal profile."}
	Button DispAzimProfBtn,Win=Processpanel, font="Arial",fStyle=0	
	GroupBox RadProfGpBox,Win=Processpanel, pos={15,150},size={181,105},title="Radial Profiles", disable=state, help={"Display the polar profiles of the pattern."}
	GroupBox RadProfGpBox,Win=Processpanel, font="Arial",fStyle=1
	SetVariable SelPhiAngSetVal,Win=Processpanel, pos={22,175},size={169,18},title="Azimuthal Angle (deg.):", disable=state, help={"Input the azimuthal angle at which an polar profile will be displayed. Tips: Click a data point of the pattern to automatically input the azimuthal angle of the point."}
	SetVariable SelPhiAngSetVal,Win=Processpanel, font="Arial", proc=DrawRadLineProc
	SetVariable SelPhiAngSetVal,Win=Processpanel, limits={0,360,1.0},value= dfrp:SelPhiAng
	SetVariable SelPhiWidSetVal,Win=Processpanel, pos={43,200},size={148,18},title="Stripe Width (deg.):", disable=state, help={"Input the width of a polar stripe from which the polar profile will be calculated."}
	SetVariable SelPhiWidSetVal,Win=Processpanel, font="Arial", proc=DrawRadStripeProc
	SetVariable SelPhiWidSetVal,Win=Processpanel, limits={0,180,1.0},value= dfrp:SelPhiWid
	Button DispRadProfBtn,Win=Processpanel, pos={81,227},size={50,20},proc=DispRadProfBtnProc,title="Display", disable=state, help={"Click to display the polar profile."}
	Button DispRadProfBtn,Win=Processpanel, font="Arial",fStyle=0
	GroupBox CoreLvGpBox,Win=Processpanel, pos={15,265},size={180,105},title="Core Level Spectra", disable=state, help={"Display the core levle (XPS) spectrum from which the intensity of a data point was calculated."}
	GroupBox CoreLvGpBox,Win=Processpanel, font="Arial",fStyle=1
	SetVariable SelThtAngSetValCLS,Win=Processpanel, pos={44,290},size={146,18},title="Polar Angle (deg.):", disable=state, help={"Input the polar angle of a data point. Tips: Click a data point of the pattern to automatically input the polar angle of the point."}
	SetVariable SelThtAngSetValCLS,Win=Processpanel, font="Arial"
	SetVariable SelThtAngSetValCLS,Win=Processpanel, limits={0,90,1},value= dfrp:SelThtAng
	SetVariable SelPhiAngSetValCLS,Win=Processpanel, pos={20,315},size={170,18},title="Azimuthal Angle (deg.):", disable=state, help={"Input the azimuthal angle of a data point. Tips: Click a data point of the pattern to automatically input the azimuthal angle of the point."}
	SetVariable SelPhiAngSetValCLS,Win=Processpanel, font="Arial"
	SetVariable SelPhiAngSetValCLS,Win=Processpanel, limits={0,360,1},value= dfrp:SelPhiAng
	Button DispCorLevSpecBtn,Win=Processpanel, pos={79,340},size={50,20},proc=DispCorLevSpecBtnProc,title="Display", disable=state, help={"Click to display the core levle (XPS) spectrum from which the intensity of a data point was calculated."}
	Button DispCorLevSpecBtn,Win=Processpanel, font="Arial",fStyle=0
	GroupBox ClearAuxLineBox,Win=Processpanel, pos={15,375},size={180,55},title="Clear Auxiliary Lines", disable=state, help={"Clear the auxiliary cursor, lines on the pattern."}
	GroupBox ClearAuxLineBox,Win=Processpanel, font="Arial",fStyle=1
	Button ClearAuxLineBtn,Win=Processpanel, pos={79,400},size={50,20},proc=ClearAuxLineBtnProc,title="Do it", disable=state, help={"Click to clear the auxiliary cursor, lines on the pattern."}
	Button ClearAuxLineBtn,Win=Processpanel, font="Arial",fStyle=0
End

Function PlotXPD(GraphName, rdsw, phiw, itsw, MinRds, MaxRds)
	//Display XPD patterns
	string GraphName // the string name of the graph
	wave rdsw, phiw, itsw
		//rdsw: radius wave; phiw: phi angles wave; itsw: intensity (Z) wave
	Variable minrds, maxrds
	string yn //string to accept the ShadowYName from WMPolarAppendTrace()
	WMNewPolarGraph("", GraphName)
	yn = WMPolarAppendTrace(GraphName, rdsw, phiw, 360)
	ModifyGraph mode($yn)=3,marker($yn)=19,msize($yn)=1.2, rgb($yn)=(0,0,0);DelayUpdate
	ModifyGraph zColor($yn)={itsw,*,*,YellowHot,0}
	//change the radius displaying range
	DFREF dfrgn = root:Packages:WMPolarGraphs:$GraphName
	NVAR/SDFR=dfrgn innerRadius, outerRadius
	SVAR/SDFR=dfrgn doRadiusRange
	innerRadius = minrds
	outerRadius = maxrds
	doRadiusRange = "manual"
	DoWindow/F $GraphName
	WMPolarAxesRedrawTopGraph()
End

Function/DF CreateXPDPackageData() // Called only from GetPackageDFREF
	if (DataFolderRefStatus(root:Packages) != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages // Create Packages Data folder
	endif
		
	if (DataFolderRefStatus(root:Packages:'XPD') != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages:'XPD' // Create Packages Data folder
	endif
	
	// Create the package data folder
	if (DataFolderRefStatus(root:Packages:'XPD':Process) != 1) // Packages Data folder does not exist?
		NewDataFolder/O root:Packages:'XPD':Process
	endif
	
	// Create a data folder reference variable
	DFREF dfrp = root:Packages:'XPD':Process
	
	// Create and initialize package data
	Variable/G dfrp:ThtAng = 0  // Rotate step theta angle Value
	Variable/G dfrp:PhiAng = 0  // Rotate step Phi angle Value
	Variable/G dfrp:CrnIts = 0  // current intensity value
	Variable/G dfrp:sv = 1.0  // Rotate step Phi angle Value
	Variable/G dfrp:StartPhi = 0 //Display Rotate start Phi angle
	Variable/G dfrp:EndPhi = 0 //Display Rotate end Phi angle
	Variable/G dfrp:StartTht = 0 //Display Rotate start Polar angle
	Variable/G dfrp:EndTht = 0 //Display Rotate end Polar angle
	Variable/G dfrp:StartCropPhi = 0 //Crop Start Phi angle
	Variable/G dfrp:CropIncPhi = 90 //Crop include Phi Angle
	Variable/G dfrp:StartCropTht = 0 //Crop Start Polar angle
	Variable/G dfrp:CropIncTht = 70 //Crop include Polar Angle
	Variable/G dfrp:SelPhiAng = 0 // Select a Phi Angle (for radial profiles) to display
	Variable/G dfrp:SelPhiWid = 0 // Stripe width
	Variable/G dfrp:SelThtAng = 0 // Select a Theta Angle (for azimuthal profiles) to display
	Variable/G dfrp:SelThtWid = 0 // Stripe width
	Variable/G dfrp:Xdim = 100 // X dimension
	Variable/G dfrp:Ydim = 100 // Y dimension
	Variable/G dfrp:Is1stAzimCrop = 1 // 
	Variable/G dfrp:Is1stPolCrop = 1 // 
	Variable/G dfrp:UseStereo = 0 // 
	return dfr
End

Function/DF GetXPDPackageDFREF()
	DFREF dfrp = root:Packages:'XPD':Process
	if (DataFolderRefStatus(dfrp) != 1) // Data folder does not exist?
		DFREF dfr = CreateXPDPackageData() // Create XPD package data folder
	endif
	DFREF dfr = root:Packages:'XPD'
	return dfr
End

// Display the azimuthal profiles of the XPD pattern
Function DispAzimProf()
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp RdsW, PhiW, ItsW
	NVAR/SDFR=dfrp SelThtAng, SelThtWid
	Variable SelRds, vmin, CentTht, RowNum, IncPhi, tf, tht, k, l, a, b, c

	SelRds = SelThtAng

	if(WaveMin(PhiW)<5 && WaveMax(PhiW)>355)
		Duplicate/O/Free dfrp:RdsW_bfExt, NotExtRdsW
		Duplicate/O/Free dfrp:PhiW_bfExt, NotExtPhiW
		Duplicate/O/Free dfrp:ItsW_bfExt, NotExtItsW
	else
		Duplicate/O/Free RdsW, NotExtRdsW
		Duplicate/O/Free PhiW, NotExtPhiW
		Duplicate/O/Free ItsW, NotExtItsW
	endif

	Duplicate/Free NotExtRdsW, tmpw
	FastOp tmpw = NotExtRdsW - (SelRds)
	MatrixOp /O tmpw = abs(tmpw)
	
	vmin = WaveMin(tmpw)
	FindValue /V=(vmin) tmpw

	RowNum = DimSize(NotExtRdsW, 0)
	Make/O/N=(RowNum) dfrp:ItsW_Azim, dfrp:PhiW_Azim
	Wave/SDFR=dfrp ItsW_Azim, PhiW_Azim

	l = 0
	k = 0
	do
		if(abs(NotExtRdsW[l] - SelRds) - WaveMin(tmpw) < 0.00001)
			ItsW_Azim[k] = NotExtItsW[l]
			PhiW_Azim[k] = NotExtPhiW[l]
			k += 1
			if(l == RowNum-1)
				break
			elseif(NotExtRdsW[l+1] != NotExtRdsW[l])
				break
			endif
		endif
		l += 1
	while(l<RowNum)
	Redimension /N=(k) ItsW_Azim, PhiW_Azim

	if(SelThtWid >= 0.5)
		a = 0
		b = 0
		do
			tht = NotExtRdsW[a]
			if(tht <= SelRds+SelThtWid/2 && tht >= SelRds-SelThtWid/2 && tht != CentTht)
				c = 1
				do
					a += 1
					c += 1
					if(a == RowNum)
						break
					endif
				while(NotExtRdsW[a] == tht)	
				Make/Free/N=(c-1) tmpPhiW, tmpItsW
				tmpPhiW = NotExtPhiW[p+a-c+1]
				tmpItsW = NotExtItsW[p+a-c+1]
				Sort tmpPhiW, tmpPhiW, tmpItsW
				for(l=0; l<k; l += 1)
					ItsW_Azim[l] += Interp(PhiW_Azim[l], tmpPhiW, tmpItsW)
				endfor
				b += 1
			else
				a += 1
			endif
		while(a < RowNum)
		ItsW_Azim = ItsW_Azim/b
	endif
		
	if(WaveMin(PhiW)<5 && WaveMax(PhiW)>355)
		RowNum = numpnts(PhiW_Azim)
		IncPhi = WaveMax(PhiW_Azim) - WaveMin(PhiW_Azim) + 1
		tf = floor(360/IncPhi)
		//extend the Not extended profile to full profile of 360 degrees
		Redimension/N=(RowNum*tf) PhiW_Azim, ItsW_Azim
		for(k=1;k<tf;k+=1) // only need to duplicate the data for k-1 times
			for(l=0;l<RowNum;l+=1)
				PhiW_Azim[l+RowNum*k] = PhiW_Azim[l]+IncPhi*k
				ItsW_Azim[l+RowNum*k] = ItsW_Azim[l]
			endfor
		endfor
		for(k=0; k<numpnts(PhiW_Azim); k += 1)
			if(PhiW_Azim[k] >= 360)
				PhiW_Azim[k] = PhiW_Azim[k]-360
			endif
		endfor
		Sort PhiW_Azim, PhiW_Azim, ItsW_Azim
	endif

	Wave/SDFR=dfrp ItsW_Azim, PhiW_Azim
	DoWindow/F AzimProfWin //test whether the Azimuthal Profile window exists and bring the window to the front.
	if (V_Flag == 0) // if the Azimuthal Profile window doesn't exists
		Display/N=AzimProfWin /K=2 ItsW_Azim vs PhiW_Azim
		MoveWindow/W=AzimProfWin 4,430,364,630//50,500,445,709
		DoWindow/T AzimProfWin,"Azimuthal Profile";DelayUpdate
		ModifyGraph mode=4,marker=8,opaque=1,lsize=1.5,rgb=(0,0,39168);DelayUpdate
		ModifyGraph tick(left)=3,tick(bottom)=2,mirror=1,fSize(bottom)=12,noLabel(left)=1;DelayUpdate
		ModifyGraph font(bottom)="Arial";DelayUpdate
		Label left "\\F'Arial'\\Z13Intensity (a.u.)";DelayUpdate
		Label bottom "\\F'Arial'\\Z13Azimuthal Angle (deg.)";DelayUpdate
		ModifyGraph lblPosMode(left)=4,lblPos(left)=25, lblPosMode(bottom)=4,lblPos(bottom)=30
	endif
End

Function DrawCircProcPos(ctrlName, varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr // value of variable as string
	String varName // name of variable

	DrawCircles()
	DispAzimProf()
end

Function DrawCircProcWid(ctrlName, varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr // value of variable as string
	String varName // name of variable

	DrawCircles()
	DispAzimProf()
end

Function DrawCircles()
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp RdsW, AzimW, PolarInnW, PolarOutW
	NVAR/SDFR=dfrp SelThtAng, SelThtWid
	String list
	Variable RowNum, MinTht, MaxTht, tht, TraceNum //MinPhi: Minimum Phi angle; MaxPhi: Maximum Phi angle; tht: theta angle
	Variable k, a, b, c, d, stidx, endidx //stidx: start index; endidx: end index

	Cursor /K I
	MinTht = WaveMin(RdsW)
	MaxTht = WaveMax(RdsW)	
	if ( SelThtAng<MinTht || SelThtAng>MaxTht)
		Abort "The place ahead is outer space, please go back!"
	endif
	
	if (SelThtWid >= 0.1 && (SelThtAng-SelThtWid/2 < MinTht || SelThtAng+SelThtWid/2 > MaxTht))
		Abort "The strie width is too large to be in the Theta range, please decrease the width."
	endif
	if(WaveExists(AzimW) == 0)
		Make /N=360 dfrp:AzimW, dfrp:PolarInnW, dfrp:PolarOutW	
		Wave/SDFR=dfrp AzimW, PolarInnW, PolarOutW
		AzimW = p
	endif		
	PolarInnW = SelThtAng-SelThtWid/2
	PolarOutW = SelThtAng+SelThtWid/2

	SetDrawLayer /K/W=ProcessGraphWin UserFront
	ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY1)=0
	ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY2)=0
	//Test whether there have been circle traces
	list = TraceNameList("ProcessGraphWin", ";", 1)
	TraceNum = ItemsInList(list, ";")
	if(TraceNum <= 2)
		WMPolarAppendTrace("ProcessGraphWin", PolarInnW, AzimW, 360)
		ModifyGraph /W=ProcessGraphWin/Z mode(polarY1)=0, lsize(polarY1)=1, rgb(polarY1)=(0,0,65535)
	endif
	if(TraceNum <= 3 && SelThtWid > 0.1)
			WMPolarAppendTrace("ProcessGraphWin", PolarOutW, AzimW, 360)
			ModifyGraph /W=ProcessGraphWin/Z mode(polarY2)=0, lsize(polarY2)=1, rgb(polarY2)=(0,0,65535)
	endif
end

// Display the azimuthal profiles of the XPD pattern
Function DispAzimProfBtnProc(ctrlName) : ButtonControl
	String ctrlName

	DrawCircles()
	DispAzimProf()
End

Function DrawRadLineProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr // value of variable as string
	String varName // name of variable

	DrawRadLines()
	DispRadProf()	
End

Function DrawRadStripeProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr // value of variable as string
	String varName // name of variable

	DrawRadLines()
	DispRadProf()	
End

Function DrawRadLines()
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp PhiW
	NVAR/SDFR=dfrp SelPhiAng, SelPhiWid
	Variable MinPhi, MaxPhi
	//String TraceList
	//Variable tht, TraceNum //MinPhi: Minimum Phi angle; MaxPhi: Maximum Phi angle; tht: theta angle

	MinPhi = Wavemin(PhiW)
	MaxPhi = Wavemax(PhiW)
	if(MinPhi>5 && MaxPhi<365)
		if (SelPhiAng < MinPhi || SelPhiAng > MaxPhi)
			Abort "I cannot find the angle in the Phi range, please input another Azimuthal Angle."
		endif
		if (SelPhiWid != 0 && (SelPhiAng-SelPhiWid/2 < MinPhi || SelPhiAng+SelPhiWid/2 > MaxPhi))
			Abort "The strie width is too large to be in the Phi range, please decrease the width."
		endif
	endif

	Cursor /K I
	//Test whether there have been circle traces
//	TraceList = TraceNameList("ProcessGraphWin", ";", 1)
//	TraceNum = ItemsInList(TraceList, ";")
//	if(TraceNum > 2)
		ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY1)=1
//	endif
//	if(TraceNum > 3)
		ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY2)=1
//	endif

	SetDrawLayer /K/W=ProcessGraphWin UserFront
	SetDrawEnv /W=ProcessGraphWin save, linefgc= (0,0,65535), linethick=1.2
	if(SelPhiWid < 0.1)
		DrawLine /W=ProcessGraphWin 0.508,0.5, 0.508+cos(SelPhiAng*pi/180), 0.5-sin(SelPhiAng*pi/180)
	else
		DrawLine /W=ProcessGraphWin 0.508,0.5, 0.508+cos((SelPhiAng-SelPhiWid/2)*pi/180), 0.5-sin((SelPhiAng-SelPhiWid/2)*pi/180)
		DrawLine /W=ProcessGraphWin 0.508,0.5, 0.508+cos((SelPhiAng+SelPhiWid/2)*pi/180), 0.5-sin((SelPhiAng+SelPhiWid/2)*pi/180)
	endif
End

// Display radial profiles of the XPD pattern
Function DispRadProf()
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp RdsW, PhiW, ItsW, PhiW_BfExt, RdsW_BfExt, ItsW_BfExt 
	NVAR/SDFR=dfrp SelPhiAng, SelPhiWid
	Variable RowNum, MinPhi, MaxPhi, tht //MinPhi: Minimum Phi angle; MaxPhi: Maximum Phi angle; tht: theta angle
	Variable k, a, b, c, d, stidx, endidx, IncAng, trsPhiAng //stidx: start index; endidx: end index

	MinPhi = Wavemin(PhiW)
	MaxPhi = Wavemax(PhiW)
	if(MinPhi<5 && MaxPhi>355)
		Duplicate/O/Free RdsW_BfExt, NotExtThtW
		Duplicate/O/Free PhiW_BfExt, NotExtPhiW
		Duplicate/O/Free ItsW_BfExt, NotExtItsW
	else
		Duplicate/O/Free RdsW, NotExtThtW
		Duplicate/O/Free PhiW, NotExtPhiW
		Duplicate/O/Free ItsW, NotExtItsW
	endif
	
	RowNum = DimSize(NotExtThtW, 0)
	Make/O/N=(RowNum) dfrp:ItsW_Rad, dfrp:ThtW_Rad
	Wave/SDFR=dfrp ItsW_Rad, ThtW_Rad

	MinPhi = Wavemin(NotExtPhiW)
	MaxPhi = Wavemax(NotExtPhiW)
	IncAng = MaxPhi-MinPhi

	//if(WaveMin(PhiW)<2 && WaveMax(PhiW)>358) // if the pattern has been transformed to a full 360 pattern
	if(SelPhiAng < MinPhi) //Because SelPhiAng may be in the extended pattern and out of the range of PhiW_BfExt
		trsPhiAng = (1-(MinPhi-SelPhiAng)/IncAng)*IncAng+MinPhi
	elseif(SelPhiAng > MaxPhi)
		trsPhiAng = ((SelPhiAng-MinPhi)/IncAng-floor((SelPhiAng-MinPhi)/IncAng))*IncAng+MinPhi
	else
		trsPhiAng = SelPhiAng
	endif
	Duplicate/Free/O NotExtPhiW, tmpW
	FastOp tmpw = NotExtPhiW - (trsPhiAng) // the phi angles of the edge of every azim circle have been interplated to be the same
	MatrixOp /O tmpw = abs(tmpw)
	
	k = 0
	a = 0
	do
		tht = NotExtThtW[a]
		stidx = a
		do
			endidx = a
			a += 1
			if(a == RowNum)
				break
			endif
		while(NotExtThtW[a] == tht)
		if(endidx-stidx == 0)
			Make/O/free/N=1 testPhiW //test Partial Phi Wave, the center origin point
			Make/O/free/N=1 tmpPhiW //Partial Phi Wave
			Make/O/free/N=1 tmpThtW //Partial Phi Wave
			Make/O/free/N=1 tmpItsW //Partial Phi Wave
		else
			Make/O/free/N=(endidx-stidx+1) testPhiW //tested Partial Phi Wave
			Make/O/free/N=(endidx-stidx+1) tmpPhiW //Partial Phi Wave
			Make/O/free/N=(endidx-stidx+1) tmpThtW //Partial Phi Wave
			Make/O/free/N=(endidx-stidx+1) tmpItsW //Partial Phi Wave
		endif
		for(b=stidx; b<=endidx; b+=1)
			testPhiW[b-stidx] = tmpw[b]
			tmpPhiw[b-stidx] = NotExtPhiW[b]
			tmpThtw[b-stidx] = NotExtThtW[b]
			tmpItsw[b-stidx] = NotExtItsW[b]
		endfor
		FindValue /V=(WaveMin(testPhiW)) testPhiW//find the value that is the most close to the SelPhiAng at every azimuthal circle
		ItsW_Rad[k] = tmpItsW[V_value]
		ThtW_Rad[k] = tmpThtW[V_value]
		c = 1 //the number of the data points within the stripe
		if(SelPhiWid != 0 && endidx-stidx != 0)
			if(SelPhiWid >= MaxPhi-MinPhi)
				ItsW_Rad[k] = mean(tmpItsW)
			elseif(trsPhiAng-SelPhiWid/2 > MinPhi && trsPhiAng+SelPhiWid/2 < MaxPhi)
				for(d=0; d<endidx-stidx; d+=1)
					if(tmpPhiW[d] >=trsPhiAng-SelPhiWid/2 && tmpPhiW[d] <= trsPhiAng+SelPhiWid/2 && d != V_value)	
						ItsW_Rad[k] += tmpItsW[d]
						c += 1
					endif
				endfor
				ItsW_Rad[k] = ItsW_Rad[k]/c
			elseif(trsPhiAng-SelPhiWid/2 < MinPhi && trsPhiAng+SelPhiWid/2 < MaxPhi)
				for(d=0; d<endidx-stidx; d+=1)
					if(tmpPhiW[d] >= (1-(MinPhi-(trsPhiAng-SelPhiWid/2))/IncAng)*IncAng+MinPhi && tmpPhiW[d] <= trsPhiAng+SelPhiWid/2 && d != V_value)	
						ItsW_Rad[k] += tmpItsW[d]
						c += 1
					endif
				endfor
				ItsW_Rad[k] = ItsW_Rad[k]/c
			elseif(trsPhiAng-SelPhiWid/2 > MinPhi && trsPhiAng+SelPhiWid/2 > MaxPhi)
				for(d=0; d<endidx-stidx; d+=1)
					if(tmpPhiW[d] <= (trsPhiAng+SelPhiWid/2-MinPhi)/IncAng-floor((trsPhiAng+SelPhiWid/2-MinPhi)/IncAng)*IncAng+MinPhi && tmpPhiW[d] >= trsPhiAng-SelPhiWid/2 && d != V_value)	
						ItsW_Rad[k] += tmpItsW[d]
						c += 1
					endif
				endfor
				ItsW_Rad[k] = ItsW_Rad[k]/c
			endif
		endif
		k += 1
		if(a == RowNum)
			break
		endif
	while(a<=RowNum)
	Redimension/N=(k) ItsW_Rad, ThtW_Rad //delete the redundant data after k-1
	
	DoWindow/F RadProfWin //test whether the Azimuthal Profile window exists and bring the window to the front.
	if (V_Flag == 0) // if the Azimuthal Profile window doesn't exists
		Display/N=RadProfWin /K=2 ItsW_Rad vs ThtW_Rad
		MoveWindow/W=RadProfWin 376,430,736,630
		DoWindow/F/T RadProfWin,"Radial Profile";DelayUpdate
		ModifyGraph mode=4,marker=8,opaque=1,lsize=1.5,rgb=(19712,0,39168);DelayUpdate
		ModifyGraph tick(left)=3,tick(bottom)=2,mirror=1,fSize(bottom)=12,noLabel(left)=1;DelayUpdate
		ModifyGraph font(bottom)="Arial";DelayUpdate
		Label left "\\F'Arial'\\Z13Intensity (a.u.)";DelayUpdate
		Label bottom "\\F'Arial'\\Z13Polar Angle (deg.)";DelayUpdate
		ModifyGraph lblPosMode(left)=4,lblPos(left)=25, lblPosMode(bottom)=4,lblPos(bottom)=30
	endif
End

// Display radial profiles of the XPD pattern
Function DispRadProfBtnProc(ctrlName) : ButtonControl
	String ctrlName
	
	DrawRadLines()
	DispRadProf()
End

//Display Core-level curve
Function DispCorLevSpecBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, EngW, RdsW, PhiW
	NVAR/SDFR=dfrp SelThtAng, SelPhiAng
	Variable RowNum, ColNum, MinPhi, MaxPhi, MinTht, MaxTht, MinThttmp, MinPhitmp, IsFound, a, b, c
		//MinPhi: Minimum Phi angle; MinTht: Minimum Theta angle
		// RowLoc: Row Location; LayLoc: Layer Location; ColLoc: Column Location
	String message, fileFilters

	RowNum = DimSize(RdsW, 0)
	
	if( WaveMax(RdsW) < 1)
		MinTht = atan(WaveMin(RdsW)/2)*2/pi*180
	else
		MinTht = WaveMin(RdsW)
	endif
	
	if( WaveMax(RdsW) < 1)
		MaxTht = atan(WaveMax(RdsW)/2)*2/pi*180
	else
		MaxTht = WaveMax(RdsW)
	endif

	if (SelThtAng<MinTht || SelThtAng>MaxTht)
		Abort "I cannot find the angle in the Theta range, please input another Polar Angle."
	endif
	
	MinPhi = Wavemin(PhiW)
	MaxPhi = Wavemax(PhiW)
	if (SelPhiAng<MinPhi || SelPhiAng>MaxPhi)
		Abort "I cannot find the angle in the Phi range, please input another Azimuthal Angle."
	endif

	RowNum = DimSize(XPDM, 0)
	Make/Free/N=(RowNum) ThtW_tmp = XPDM[p][0]
	
	FastOp ThtW_tmp = ThtW_tmp - (SelThtAng)
	MatrixOp /O ThtW_tmp = abs(ThtW_tmp)
	MinThttmp = WaveMin(ThtW_tmp)

	for(a = 0; a < RowNum; a += 1)
		if(ThtW_tmp[a] == MinThttmp)
			b = 0
			do
				b += 1
				a += 1
				if(a == RowNum)
					break
				endif
			while(ThtW_tmp[a] == MinThttmp)
			break
		endif
	endfor

	Make/Free/N=(b) PhiW_tmp = XPDM[a-b+p][1]
	FastOp PhiW_tmp = PhiW_tmp - (SelPhiAng)
	MatrixOp /O PhiW_tmp = abs(PhiW_tmp)
	MinPhitmp = WaveMin(PhiW_tmp)

	IsFound = 0
	for(c = 0; c < b; c += 1)
		if(PhiW_tmp[c] == MinPhitmp )
			IsFound = 1
			break
		endif
	endfor
	
	if(IsFound)
		ColNum = DimSize(XPDM, 1)
		Make/O/N=(ColNum-3) dfrp:XPSW = XPDM[a-b+c][p+3]
	else
		Abort "I cannot find the corresponding Core-level spectrum. Abort."
	endif
	Wave XPSW = dfrp:XPSW
	if(XPSW[0] == 0 && XPSW[floor(numpnts(XPSW)/2)] == 0 && XPSW[numpnts(XPSW)-1] == 0)
		Abort "This data point is artificially inserted. It has no XPS data.\nPlease try another point."
	endif
	
	DoWindow/F XPSspecWin //test whether the Azimuthal Profile window exists and bring the window to the front.
	if (V_Flag == 0) // if the Azimuthal Profile window doesn't exists
		Display/N=XPSspecWin/K=2 XPSW vs EngW
		MoveWindow/W=XPSspecWin 748,430,1108,630
		DoWindow/F/T XPSspecWin,"Core-level Spectra";DelayUpdate
		ModifyGraph lsize=2, tick(left)=3,tick(bottom)=2,mirror=1,fSize(bottom)=12,noLabel(left)=1;DelayUpdate
		ModifyGraph font(bottom)="Arial";DelayUpdate
		Label left "\\F'Arial'\\Z13Intensity (a.u.)";DelayUpdate
		Label bottom "\\F'Arial'\\Z13Energy (eV)";DelayUpdate
		ModifyGraph lblPosMode(left)=4,lblPos(left)=25, lblPosMode(bottom)=4,lblPos(bottom)=30;DelayUpdate
		//SetAxis/A/R bottom
		Button CallFitButt win=XPSspecWin, title="Fit it",size={30,20},font="Arial", pos+={10, 240}, proc=CallFitItBtnProc, help={"Click to fit the current sprectrum in a new window."}
		Button SaveCorLvSpecBtn win=XPSspecWin, title="Save it",size={45,20},font="Arial", pos+={380,0}, proc=SaveCorLvSpecBtnProc, help={"Click to save the data of the current spectrum into a file."}
	endif
End

Function ClearAuxLineBtnProc(ctrlName) : ButtonControl
	String ctrlName
	
	SetDrawLayer /K/W=ProcessGraphWin UserFront
	ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY1)=1
	ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY2)=1
	Cursor /K I
End

//Function CCWBtnProc(ctrlName)
//Rotate the XPD pattern in Counter-Clockwise direction
Function CCWBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	NVAR/SDFR=dfrp sv, StartPhi, EndPhi
	Wave/SDFR=dfrp PhiW // Phi angle Matrix wave
	
	PhiW  += sv
	if(WaveMin(PhiW)>360)
		PhiW -= 360
	endif

	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
End

//Function CWBtnProc(ctrlName)
//Rotate the XPD pattern in Clockwise direction
Function CWBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	NVAR/SDFR=dfrp sv, StartPhi, EndPhi
	Wave/SDFR=dfrp PhiW // Phi angle Matrix wave
	
	PhiW  -= sv
	if(WaveMax(PhiW)<0)
		PhiW += 360
	endif

	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
End

//Function AzimCropBtnProc(ctrlName)
// Crop the XPD pattern
Function AzimCropBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW
		//Rds: Radius; Phi: Phi Angle (in Degree); Its: Intensity; M: Matrix wave
	NVAR Azim0=dfrp:StartCropPhi, IncAng=dfrp:CropIncPhi, Is1stCrop=dfrp:Is1stAzimCrop
		// Phi0: the starting Phi angle to crop the pattern, in Degree, not in rad
		// IncAng: the Included Angle of the pattern after cropped, in Degree, e.g. 90
	NVAR/SDFR=dfrp StartPhi, EndPhi
	Variable DelVal1, DelVal2, maxaz, k, len, crntht
	
	maxaz = Azim0+IncAng-1
	delval1=Azim0-WaveMin(PhiW)// Note the diffrence between disaplay value and real value 
	delval2=WaveMax(PhiW)-(maxaz+1)
	len = numpnts(phiw)
	
	if (delval1<0 || delval2<0)
		Abort "The input Angular range is out of XPD pattern, Please input a correct Angular range."
		return -1
	endif
	
	//Backup the XPD data
	if (Is1stCrop == 1) // in case the users click the crop for two times, which will duplicate the croped data to NoCrop!
		Duplicate /O XPDM dfrp:XPDM_NoAzimCrop
		Duplicate /O RdsW dfrp:RdsW_NoAzimCrop
		Duplicate /O PhiW dfrp:PhiW_NoAzimCrop
		Duplicate /O ItsW dfrp:ItsW_NoAzimCrop
	endif
	
	//Crop the XPD pattern
	k=0
	do
		if(PhiW[k]<Azim0 || PhiW[k]>Azim0+IncAng-1)
			DeletePoints /M=0 k,1, XPDM, RdsW, PhiW, ItsW
			len -= 1
		else
			k += 1
		endif
	while(k < len)

	//interplate data points at both edges of the pattern
	k = 0
	crntht = rdsw[k]
	do
		if(rdsw[k] != 0 && crntht != rdsw[k])
			if(abs(phiw[k]-Azim0) > 0.001)
				InsertPoints /M=0 k,1, XPDM, RdsW, PhiW, ItsW
				phiw[k] = azim0
				rdsw[k] = rdsw[k+1]
				itsw[k] = itsw[k+1]+(phiw[k]-phiw[k+1])*(itsw[k+1]-itsw[k+2])/(phiw[k+1]-phiw[k+2])
				len += 1
				crntht = rdsw[k]
			endif
			if(k != 0 && rdsw[k-1] != 0 && abs(phiw[k-1] - maxaz) > 0.001)
				InsertPoints /M=0 k,1, XPDM, RdsW, PhiW, ItsW
				phiw[k] = maxaz
				rdsw[k] = rdsw[k-1]
				itsw[k] = itsw[k-1]+(phiw[k]-phiw[k-1])*(itsw[k-1]-itsw[k-2])/(phiw[k-1]-phiw[k-2])
				len += 1
				crntht = rdsw[k+1]
			endif
		endif
		if( k == len-1 && abs(phiw[k]-maxaz) > 0.001 )
			InsertPoints /M=0 k+1,1, XPDM, RdsW, PhiW, ItsW
			phiw[k+1] = maxaz
			rdsw[k+1] = rdsw[k]
			itsw[k+1] = itsw[k]+(phiw[k+1]-phiw[k])*(itsw[k]-itsw[k-1])/(phiw[k]-phiw[k-1])
		endif
		k += 1
	while(k < len)

	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
	
	Is1stCrop = 0
	Button UndoAzimCropBtn disable=0
End

//Function UndoAzimCropBtnProc(ctrlName) 
// Undo Crop the XPD Pattern
Function UndoAzimCropBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW, XPDM_NoAzimCrop, RdsW_NoAzimCrop, PhiW_NoAzimCrop, ItsW_NoAzimCrop
	NVAR/SDFR=dfrp StartPhi, EndPhi
	
	Duplicate /O XPDM_NoAzimCrop XPDM
	Duplicate /O RdsW_NoAzimCrop RdsW
	Duplicate /O PhiW_NoAzimCrop PhiW
	Duplicate /O ItsW_NoAzimCrop ItsW

	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
End

//Function PolarCropBtnProc(ctrlName)
// Crop the XPD pattern
Function PolarCropBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW
		//Rds: Radius; Phi: Phi Angle (in Degree); Its: Intensity; M: Matrix wave
	NVAR/SDFR=dfrp StartTht, EndTht
	NVAR Polar0=dfrp:StartCropTht, IncAng=dfrp:CropIncTht, Is1stCrop = dfrp:Is1stPolCrop
		// Phi0: the starting Phi angle to crop the pattern, in Degree, not in rad
		// IncAng: the Included Angle of the pattern after cropped, in Degree, e.g. 90
	Variable DelVal1, DelVal2, k
	
	delval1=Polar0-WaveMin(RdsW)// Note the diffrence between disaplay value and real value 
	delval2=WaveMax(RdsW)-(Polar0+IncAng-1)
	
	if (delval1<0)
		Abort "The input Starting Polar Angle is out of XPD pattern, Please input a right Angle."
		return -1
	endif
	if (delval2<0)
		Abort "The input Include Polar Angle is out of XPD pattern, Please input a right Angle."
		return -1
	endif
	
	//Backup the XPD data
	if (Is1stCrop == 1) // in case the users click the crop for two times, which will duplicate the croped data to NoCrop!
		Duplicate /O XPDM dfrp:XPDM_NoPolarCrop
		Duplicate /O RdsW dfrp:RdsW_NoPolarCrop
		Duplicate /O PhiW dfrp:PhiW_NoPolarCrop
		Duplicate /O ItsW dfrp:ItsW_NoPolarCrop
	endif
	
	//Crop the XPD pattern
	k=0
	do
		if(RdsW[k]<Polar0 || RdsW[k]>Polar0+IncAng-1)
			DeletePoints /M=0 k,1, XPDM, RdsW, PhiW, ItsW
		else
			k += 1
		endif
	while(k < numpnts(RdsW))

	StartTht = truncateDP(WaveMin(RdsW), 1)
	EndTht = truncateDP(WaveMax(RdsW), 1)
	ValDisplay PolarAngSt, value =_NUM: StartTht
	ValDisplay PolarAngEnd, value =_NUM: EndTht

	Button UndoPolarCropBtn disable=0
	Is1stCrop = 0
End

//Function UndoPolarCropBtnProc(ctrlName) 
// Undo Crop the XPD Pattern
Function UndoPolarCropBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW, XPDM_NoPolarCrop, RdsW_NoPolarCrop, PhiW_NoPolarCrop, ItsW_NoPolarCrop
	NVAR/SDFR=dfrp StartTht, EndTht
	
	Duplicate /O XPDM_NoPolarCrop XPDM
	Duplicate /O RdsW_NoPolarCrop RdsW
	Duplicate /O PhiW_NoPolarCrop PhiW
	Duplicate /O ItsW_NoPolarCrop ItsW
	
	StartTht = truncateDP(WaveMin(RdsW), 1)
	EndTht = truncateDP(WaveMax(RdsW), 1)
	ValDisplay PolarAngSt, value =_NUM: StartTht
	ValDisplay PolarAngEnd, value =_NUM: EndTht
End

// Make a full 360 deg. pattern
Function MakeBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW
	NVAR/SDFR=dfrp StartPhi, EndPhi
	Variable IncPhi, RowNum, ColNum, k, l, tf

	//Backup the XPD data
	Duplicate /O XPDM dfrp:XPDM_BfExt //BfExt: Before Extending
	Duplicate /O RdsW dfrp:RdsW_BfExt 
	Duplicate /O PhiW dfrp:PhiW_BfExt
	Duplicate /O ItsW dfrp:ItsW_BfExt

	RowNum = DimSize(XPDM, 0)
	ColNum = DimSize(XPDM, 1)
	StartPhi = WaveMin(PhiW)
	EndPhi = WaveMax(PhiW)
	IncPhi = EndPhi - StartPhi + 1
	if( mod(360, IncPhi) != 0 )
		Abort "Please crop the pattern to a sector by whose central angle 360 deg. can be divided with no remainder."
	endif
	tf = floor(360/IncPhi)

	//extend the cropped XPD pattern to 360 degrees
	Redimension/N=(RowNum*tf) RdsW, PhiW, ItsW
	Redimension/N=(RowNum*tf, ColNum) XPDM
	for(k=1;k<tf;k+=1) // only need to duplicate the data for k-1 times
		for(l=0;l<RowNum;l+=1)
			XPDM[l+RowNum*k][] = XPDM[l][q]
			PhiW[l+RowNum*k] = PhiW[l]+IncPhi*k
			RdsW[l+RowNum*k] = RdsW[l]
			ItsW[l+RowNum*k] = ItsW[l]
		endfor
	endfor
	for(k=0; k<numpnts(phiw); k += 1)
		if(phiw[k] >= 360)
			phiw[k] = phiw[k]-360
		endif
	endfor
	XPDM[][1] = PhiW[p] //copy the correct Phi angles to XPDM
	
	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
	
	Button MakeBtn disable = 2 // make undo Make button unavailable
	Button UndoMakeBtn disable = 0 // make undo Make button available
End

// Undo the extension
Function UndoMakeBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW
	NVAR/SDFR=dfrp StartPhi, EndPhi
	Variable RowNum
	
	Duplicate /O dfrp:XPDM_BfExt, XPDM
	Duplicate /O dfrp:RdsW_BfExt, RdsW
	Duplicate /O dfrp:PhiW_BfExt, PhiW
	Duplicate /O dfrp:ItsW_BfExt, ItsW

	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	Button MakeBtn disable = 0 // make Make button available
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
End

Function UseStereoCkProc(ctrlName, Cked) : CheckBoxControl
	String ctrlName
	Variable Cked
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	NVAR/SDFR=dfrp UseStereo

	if(Cked)
		UseStereo = 1
	else
		UseStereo = 0
	endif
End

Function DoSmImgBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, RdsW, PhiW, ItsW
	NVAR/SDFR=dfrp Xdim, Ydim, UseStereo

	if(UseStereo == 1)
		Duplicate/O RdsW dfrp:RdsW_AEPP
		Duplicate/O RdsW dfrp:RdsW_SP
		Wave/SDFR=dfrp RdsW_SP, RdsW_AEPP
		RdsW_SP = 2*tan(RdsW[p]*pi/180/2)
		Duplicate/O RdsW_SP, RdsW

		String cmdstr
		SetDataFolder dfrp
		Make/O/N=(numpnts(itsw)) xwct, ywct
		xwct = -rdsw[p]*cos(phiw[p]*pi/180)
		ywct = rdsw[p]*sin(phiw[p]*pi/180)
		sprintf cmdstr, "XYZtoMatrix(\"xwct\",\"SmthImgStgPrj\",\"ywct\",%u,\"ItsW\",%u,2,1)", Xdim, Ydim 
		Execute cmdstr
		cmdstr = StringByKey("RECREATION", TraceInfo("ProcessGraphWin","polarY0",0))
		cmdstr = ReplaceString("zColor(x)={ItsW,", cmdstr, "")
		cmdstr = "ModifyImage SmthImgStgPrj ctab = {"+ cmdstr
		Execute cmdstr
		//ModifyImage ImgM ctab= {*,*,YellowHot,0}
		ModifyGraph axThick=0, noLabel=2
		DoWindow/T kwTopWin, "Stereographic projection pattern image"
		//Wave SmthImgStgPrj
		//MatrixFilter/N=14 gauss SmthImgStgPrj
		SetDataFolder ::::

		Duplicate/O RdsW_AEPP, RdsW //Recover to AEPP projection method
	else	
		String cmdstr2
		SetDataFolder dfrp
		Make/O/N=(numpnts(itsw)) xwct, ywct
		xwct = -rdsw[p]*cos(phiw[p]*pi/180)
		ywct = rdsw[p]*sin(phiw[p]*pi/180)
		sprintf cmdstr2, "XYZtoMatrix(\"xwct\",\"SmthImgEqPrj\",\"ywct\",%u,\"ItsW\",%u,2,1)", Xdim, Ydim 
		Execute cmdstr2
		cmdstr2 = StringByKey("RECREATION", TraceInfo("ProcessGraphWin","polarY0",0))
		cmdstr2 = ReplaceString("zColor(x)={ItsW,", cmdstr2, "")
		cmdstr2 = "ModifyImage SmthImgEqPrj ctab = {"+ cmdstr2
		Execute cmdstr2
		//ModifyImage ImgM ctab= {*,*,YellowHot,0}
		ModifyGraph axThick=0, noLabel=2
		DoWindow/T kwTopWin, "XPD pattern (AEP projection)"
		//Wave SmthImgEqPrj
		//MatrixFilter/N=14 gauss SmthImgEqPrj
		SetDataFolder ::::
	endif
End

Function ModifyGraphBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DoWindow/F ProcessGraphWin
	WMPolarGraphs(0)
	WMPolarTabProc("", 2) //Tab 2 is Axis tab
	MoveWindow/W=WMPolarGraphPanel 840, 50, 1076.25, 394.25
End

Function SaveDataBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp XPDM, EngW, RdsW, PhiW, ItsW
	
	String message, fileFilters
	Variable refNum, rownum, ColNum, i
	
	//Display a save file dialogue to let users input a file name
	message = "Save the XPD data to a file..."
	fileFilters = "XPD data Files (*.xpd):.xpd; All Files:.*;"
	Open/D/F=fileFilters/M=message refNum
	if (strlen(S_fileName) == 0)
		Abort
	else
		rownum = DimSize(XPDM, 0)
		colnum = DimSize(XPDM, 1)
		XPDM[][0] = RdsW[p]
		XPDM[][1] = PhiW[p]
		XPDM[][2] = ItsW[p]
		
		Open refNum as S_fileName
		fprintf refNum, "# This is an XPD and the corresponding XPS data file. \r\n"
		fprintf refNum, "# The 7th line is the correponding energy (eV) of each channel, the other lines are XPD data + XPS intensity.\r\n"
		fprintf refNum, "# Start from the 8th line, The 1st column is Polar Angle.\r\n"
		fprintf refNum, "# The 2nd column is Azimuthal Angle.\r\n"
		fprintf refNum, "# The 3rd column is Intensity for XPD.\r\n"
		fprintf refNum, "# The other columns are photoelectron counts of each channel of the dectector.\r\n"
		
		for(i = 0; i < colnum-3; i += 1)
			fprintf refNum, num2str(EngW[i])
			if (i != colnum-4)
				fprintf refNum, "\t"
			else
				fprintf refNum, "\r\n"
			endif
		endfor
		Close refNum
		Save /A=2/J/M="\r\n" XPDM as S_fileName
	endif
End

Function CallFitItBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp EngW, XPSW
	
	SetDataFolder root:
	Duplicate/O EngW, EngW_toFit
	Duplicate/O XPSW, XPSW_toFit
	//Wave/SDFR=root: EngW_toFit, XPSW_toFit
	if( !isMono(EngW_toFit))
		MakeMonoWaves(EngW_toFit, XPSW_toFit)
	endif
	
	//open Multipeak Fitting Package
	MultiPeakFit2_Initialize()
	Killwindow MultiPeak2StarterPanel
	MPF2_StartNewMPFit(0, "New Graph", GetWavesDataFolder(XPSW_toFit, 2), GetWavesDataFolder(EngW_toFit, 2), 1, 0)
End

Function SaveCorLvSpecBtnProc(ctrlName) : ButtonControl
	String ctrlName
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	Wave/SDFR=dfrp EngW, XPSW
	Variable len, refNum
	String message, fileFilters

	//Display a save file dialogue to let users input a file name
	message = "Save the Core Level Spectrum data to a file..."
	fileFilters = "XPS data Files (*.xy):.xy; All Files:.*;"
	Open/D/F=fileFilters/M=message refNum
	if (strlen(S_fileName) == 0)
		Abort
	else
		len = numpnts(EngW)
		Make/Free/O/N=(len, 2) XPSM
		XPSM[][0] = EngW[p]
		XPSM[][1] = XPSW[p]
		
		Open refNum as S_fileName
		fprintf refNum, "# This is an XPS data file. \r\n"
		fprintf refNum, "# The 1st conlumn is energy (eV), the 2nd colunm is intensity (kcts/s). \r\n"
		Close refNum
		Save /A=2/J/M="\r\n" XPSM as S_fileName
	endif	
End
// ========= Analyze XPD pattern End ===============//

Function truncateDP(inValue, targetDP)
// targetDP is the number of decimal places we want
	Variable inValue, targetDP
	targetDP = round(targetDP)
	inValue = round(inValue * (10^targetDP)) / (10^targetDP)
	return inValue
end

Function HookCsrToPickPeaks1(s)
	STRUCT WMWinHookStruct &s
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR n = dfraq:nth
	NVAR pksel = dfraq:PkSel1
	NVAR pknum = dfrfit:PeakNum1
	Wave yw1 = dfraq:$"yw1"//+num2str(n)
	Wave hpw = dfrfit:PkPosW1 //hpw: Hit Point Wave, the wave of the positions (point index) of the peaks 
	Variable hookResult = 0, hpNb // hpnb: the Point Number of the hitted point 
	String HitPntStr
	switch(s.eventCode)
		case 3: // mouse down
			HitPntStr = TraceFromPixel(s.MouseLoc.h, s.MouseLoc.v, "ONLY:yw1") 
			hpnb = NumberByKey("HITPOINT", HitPntStr)
			if (numtype(hpnb) == 2) // hpnb = NaN
				abort "You didn't click any data point of the trace. Please try again."
				break
			endif
			hpw[pknum] = hpnb
			pknum += 1
			switch(pknum)
				case 1:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) A yw1 hpnb
					break
				case 2:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) B yw1 hpnb
					TextBox /N=SelPkTB/K
					print "You have selected two peaks. Fiting is being processed."
					pksel = 1
					break
			endswitch
			break
	endswitch
	return hookResult // 0 if nothing done, else 1
End

Function HookCsrToPickPeaks2(s)
	STRUCT WMWinHookStruct &s
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR n = dfraq:nth
	NVAR pksel = dfraq:PkSel2
	NVAR pknum = dfrfit:PeakNum2
	Wave yw2 = dfraq:$"yw2"//+num2str(n)
	Wave hpw = dfrfit:PkPosW2 //hpw: Hit Point Wave, the wave of the positions (point index) of the peaks 
	Variable hookResult = 0, hpNb // hpnb: Hit Point Number
	String HitPntStr
	switch(s.eventCode)
		case 3: // mouse down
			HitPntStr = TraceFromPixel(s.MouseLoc.h, s.MouseLoc.v, "ONLY:yw2") 
			hpnb = NumberByKey("HITPOINT", HitPntStr)
			if (numtype(hpnb) == 2) // hpnb = NaN
				abort "You didn't click any data point of the trace. Please try again."
				break
			endif
			hpw[pknum] = hpnb
			pknum += 1
			switch(pknum)
				case 1:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) C yw2 hpnb
					break
				case 2:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) D yw2 hpnb
					TextBox /N=SelPkTB/K
					print "You have selected two peaks. Fiting is being processed."
					pksel = 1
					break
			endswitch
			break
	endswitch
	return hookResult // 0 if nothing done, else 1
End

Function HookCsrToPickPeaks3(s)
	STRUCT WMWinHookStruct &s
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR n = dfraq:nth
	NVAR pksel = dfraq:PkSel3
	NVAR pknum = dfrfit:PeakNum3
	Wave yw3 = dfraq:$"yw3"//+num2str(n)
	Wave hpw = dfrfit:PkPosW3 //hpw: Hit Point Wave, the wave of the positions (point index) of the peaks 
	Variable hookResult = 0, hpNb // hpnb: Hit Point Number
	String HitPntStr
	switch(s.eventCode)
		case 3: // mouse down
			HitPntStr = TraceFromPixel(s.MouseLoc.h, s.MouseLoc.v, "ONLY:yw3") 
			hpnb = NumberByKey("HITPOINT", HitPntStr)
			if (numtype(hpnb) == 2) // hpnb = NaN
				abort "You didn't click any data point of the trace. Please try again."
				break
			endif
			hpw[pknum] = hpnb
			pknum += 1
			switch(pknum)
				case 1:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) E yw3 hpnb
					break
				case 2:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) F yw3 hpnb
					TextBox /N=SelPkTB/K
					print "You have selected two peaks. Fiting is being processed."
					pksel = 1
					break
			endswitch
			break
	endswitch
	return hookResult // 0 if nothing done, else 1
End

Function HookCsrToPickPeaks4(s)
	STRUCT WMWinHookStruct &s
	DFREF dfraq = GetDAQPackageDFREF()
	DFREF dfrfit = GetFitPackageDFREF()
	NVAR n = dfraq:nth
	NVAR pksel = dfraq:PkSel4
	NVAR pknum = dfrfit:PeakNum4
	Wave yw4 = dfraq:$"yw4"//+num2str(n)
	Wave hpw = dfrfit:PkPosW4 //hpw: Hit Point Wave, the wave of the positions (point index) of the peaks 
	Variable hookResult = 0, hpNb // hpnb: Hit Point Number
	String HitPntStr
	switch(s.eventCode)
		case 3: // mouse down
			HitPntStr = TraceFromPixel(s.MouseLoc.h, s.MouseLoc.v, "ONLY:yw4") 
			hpnb = NumberByKey("HITPOINT", HitPntStr)
			if (numtype(hpnb) == 2) // hpnb = NaN
				abort "You didn't click any data point of the trace. Please try again."
				break
			endif
			hpw[pknum] = hpnb
			pknum += 1
			switch(pknum)
				case 1:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) G yw4 hpnb
					break
				case 2:
					Cursor /P/A=1/H=0/S=2/W=$"SpectrumWin"+num2str(n) H yw4 hpnb
					TextBox /N=SelPkTB/K
					print "You have selected two peaks. Fiting is being processed."
					pksel = 1
					break
			endswitch
			break
	endswitch
	return hookResult // 0 if nothing done, else 1
End

//Function ShirleybackgrounSubtr(yw)
//Calculate the Shirley background (interative calculating) 
//By using FastOp, the program can speed up, for numpts(yw)=60, about 0.012-seconds faster than no FastOp (0.067 seconds)
Function/Wave ShirleyBackgroundSubtr(yw)
	Wave yw //yw: inputted wave
	DFREF dfrfit = GetFitPackageDFREF()	
	Variable ylen, is_rvs, maxidx, lmidx, rmidx, ylmin, yrmin, kappa, ysum, i, lmx, rmx, rysum
	Variable it, MaxIt=20, tol=1e-5, maxdif, timerRefNum, microSeconds, its, p

	ylen = numpnts(yw) //ylen: the length (number of points) of the input wave (yw)
	Wave/SDFR=dfrfit ywnbg, bgw

	//Locate the highest peak.
	FindValue /V=(WaveMax(yw)) yw
	maxidx = V_Value // the position (point number index) of the maximum peak
	// It's possible that maxidx is 0 or ylen-1. If that is the case,
	// we can't use this algorithm, we return a zero background.
	if (maxidx == 0 || maxidx >= (ylen-1))
		print "Shirley background Calculation: Boundaries too high for algorithm: returning a zero background."
		ywnbg = 0
		return ywnbg
	endif
	ylmin = WaveMin(yw, pnt2x(yw,0), pnt2x(yw, maxidx)) // left y min
	yrmin = WaveMin(yw, pnt2x(yw, maxidx), pnt2x(yw,ylen-1)) // it is equal to the minimum value of yw

	//ensure ylmin > yrmin, if not, reverse them.
	if (ylmin < yrmin)
		Reverse yw
		is_rvs = ylmin // use is_rvs as tmp
		ylmin = yrmin
		yrmin = is_rvs
		is_rvs = 1 // is_rvs: is_reversed
		maxidx = ylen-maxidx-1
		else
			is_rvs = 0
	endif
		
	// Locate the minima of the either side of maxloc.
	FindValue /V=(ylmin) yw
	lmidx = v_value // Left Minima index Location
	FindValue /S=(maxidx)/V=(yrmin) yw
	rmidx = v_value //Right Minima Location
	kappa = ylmin-yrmin
	
	Duplicate /O yw, bgw //bgw: background wave
	Duplicate /Free/O yw, tmpw, difw //difw: diffrence Wave
	Duplicate /Free/O bgw, bgnew //new background wave
	ysum = area(tmpW)
	bgW[0] = yw[0]
	bgw[ylen-1] = yw[ylen-1]
	p = 0
	for(i=1; i<ylen-1; i+=1) //not-interative Shirley Background
		p += yw[i-1]
		bgW[i] = yrmin+kappa*(ysum-p)/ysum
	endfor
	bgnew[0] = bgW[0]//the interative process doesn't contain [0] 
	bgnew[ylen-1] = bgW[ylen-1]//the interative process doesn't contain [ylen-1]
	FastOp tmpw = yw-bgw
	it = 0
	Do
		ysum = area(tmpw) //Calculate all area of the yw subtracted background
		for (i=1; i<ylen-1; i+=1) //Interative Shirley Background
			rysum = area(tmpw, pnt2x(tmpw, i), pnt2x(tmpw, ylen-1)) //ysum of the right side
			bgnew[i] = yrmin+kappa*rysum/ysum
		endfor
		difw = abs(bgnew-bgw)
		maxdif = WaveMax(difw)
		if (maxdif<tol)
			break
		endif
		FastOp bgw = bgnew
		FastOp tmpw = yw-bgw
		it += 1
	While (it<MaxIt)
	if (it>=MaxIt)
		print "Shirley background Calculation: Max iterations exceeded before convergence. "
	endif
	FastOp bgw = bgnew
	FastOp ywnbg = yw-bgw // wave without background
	if (is_rvs)
		Reverse bgw
		Reverse ywnbg
	endif
	return ywnbg
End

//Function DoShirleybackgrounSubtr(yw)
//Calculate the Shirley background (interative calculating) 
Function DoShirleyBackgroundSubtr(yw)
	Wave yw //yw: inputted wave
	Variable its
	Duplicate/O/Free yw, tmpW
	Wave tmpW = ShirleyBackgroundSubtr(yw)
	its = area(tmpW)
	return its
End

Function DoPolBgSubt(tht, phi, its, dms) 
	Variable tht, phi, its
	String dms //Display Mode String
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq CkNum, CkCnt, Crntht, CrnPhi, AzNum, nth, ClvNum, StgPosNum
	Wave/SDFR=dfraq SumAzItsW
	Variable a, azmean

	//polar background substraction by using the average value of azimuthal data as polar background at a polar angle
	if(StgPosNum == 0) // assign the value to CrnTht angle when the acquisition begins
		CrnTht = tht
		CrnPhi = phi
		AzNum = 1
		SumAzItsW[ckcnt-1] = its

		SetDataFolder dfraq
		Make /O/N=1 $"itsw"+num2str(nth)+dms+"r" //r: raw
		SetDataFolder ::::
		Wave itsw = dfraq:$"itsw"+num2str(nth)+dms+"r"
		itsw[0] = its

		if(ckcnt == cknum)
			ckcnt = 0
		endif
	elseif(tht == CrnTht && phi != CrnPhi) //when the sample moves to next azimuthal position
		aznum += 1
		CrnPhi = Phi
		Wave itswr = dfraq:$"itsw"+num2str(nth)+dms+"r"
		InsertPoints StgPosNum, 1, itswr
		itswr[StgPosNum] = its
		SumAzItsW[ckcnt-1] += its
		if(aznum > 1)
			azmean = SumAzItsW[ckcnt-1]/aznum
			Wave iw = dfraq:$"itsw"+num2str(nth)+dms
			for(a = StgPosNum+1-aznum; a < StgPosNum; a += 1)
				iw[a] = (itswr[a] - azmean)*50/azmean + 50
			endfor
			its = (its - azmean)*50/azmean + 50
		endif
		if(ckcnt == cknum) //in case there is only one core level to be read
			ckcnt = 0
		endif
	elseif(tht == CrnTht && phi == CrnPhi)//when it's the next core level spectrum or the next displaying mode for the same core level spectrum (at the same position)
		Wave itswr = dfraq:$"itsw"+num2str(nth)+dms+"r"
		InsertPoints StgPosNum, 1, itswr
		itswr[StgPosNum] = its
		SumAzItsW[ckcnt-1] += its
		if(aznum > 1)
			azmean = SumAzItsW[ckcnt-1]/aznum
			Wave iw = dfraq:$"itsw"+num2str(nth)+dms
			for(a = StgPosNum+1-aznum; a < StgPosNum; a += 1)
				iw[a] = (itswr[a] - azmean)*50/azmean + 50
			endfor
		endif
		its = (its - azmean)*50/azmean + 50
		if(ckcnt == cknum)
			ckcnt = 0
		endif
	elseif(tht != crntht)//when the sample moves to next polar position (next azimuthal circle)
		Wave itswr = dfraq:$"itsw"+num2str(nth)+dms+"r"
		InsertPoints StgPosNum, 1, itswr
		itswr[StgPosNum] = its
		if(aznum > 1)
			azmean = SumAzItsW[ckcnt-1]/aznum
			Wave iw = dfraq:$"itsw"+num2str(nth)+dms
			for(a = StgPosNum+1-aznum; a < StgPosNum; a += 1)
				iw[a] = (itswr[a] - azmean)*50/azmean + 50
			endfor
		endif
		SumAzItsW[ckcnt-1] = its
		if(mod(CkCnt, CkNum) == 0)//when it reaches the last XPD patten of the last core level at the new polar position (the new azimuthal circle)
			crntht = tht
			crnphi = phi
			aznum = 1
			CkCnt = 0
		endif
	endif
	if(tht < 0.001)//tht == 0
		its = NaN
	endif
	return its
End

Function DoFinalPolBgSubt(dms, ClvNum, clv) 
	String dms //display mode string
	Variable ClVNum, clv//clv: -1: all core level; >=1: the specified core level
	Variable a, b, c, MinIts, SpanIts
	DFREF dfraq = GetDAQPackageDFREF()
	if(clv < 0)
		clv = ClvNum
		b = 1
	else
		b = clv
	endif
	for(a = b; a <= clv; a += 1)
		Wave itsw = dfraq:$"itsw"+num2str(a)+dms
		MinIts = WaveMin(itsW)
		SpanIts = WaveMax(itsW)-MinIts
		itsW = (itsW-MinIts)*100/SpanIts
	endfor
End

//test if the input wave is monotonic
Function isMono(wx)
	Wave wx
	Variable smallestXIncrement
	Variable isMonotonic=0
	
	Duplicate/O/Free wx, diff
	Differentiate/DIM=0/EP=0/METH=1/P diff 
	WaveStats/Q/M=0 diff
	isMonotonic= (V_min >= 0) == (V_max >= 0)
	return isMonotonic
End

//force xw to be monotonic, and interpolate the yw correspondingly
Function MakeMonoWaves(xw, yw)
	Wave xw, yw
	Variable len, Step, a

	Duplicate/Free/O xw, xwtmp
	Duplicate/Free/O yw, ywtmp
	len = numpnts(xw)
	step = (xw[len-1]-xw[0])/(len-1)	
	xw = xw[0]+step*p

	for(a = 1; a < len-1; a += 1)
		if(xw[a] < xwtmp[a] && xwtmp[a] != xwtmp[a-1])
			yw[a] = ywtmp[a-1] + (ywtmp[a]-ywtmp[a-1])*(xw[a]-xwtmp[a-1])/(xwtmp[a]-xwtmp[a-1])
		endif
		if(xw[a] > xwtmp[a] && xwtmp[a+1]-xwtmp[a])
			yw[a] = ywtmp[a] + (ywtmp[a+1]-ywtmp[a])*(xw[a]-xwtmp[a])/(xwtmp[a+1]-xwtmp[a])
		endif
	endfor
End

// Automatically Make Initial Coefficients guess for Voigt peak
Function/Wave CoefGuess(w, pkposw)
	Wave w, pkposw //w: the wave of the trace, pkposw1: the wave of the positions (point index) of the peaks 
	Variable pknum = 2, sqrtln2 = 0.8325546111576977563531646448952, sqrtln2pi=1.4756646266356058893888176904811 // the number of peaks
	//do
	//	pknum += 1
	//while(pkposw1[pknum-1] != 0)
	//pknum -= 1
	Make /Free/O/N=(4, pknum) cm //Output Matix to be stored the Coefficiens
		// outputted parameters, every column for storing one peak's coefficients guess
		// the 1st row to store the positions (x) of the peaks
		// the 2nd row to store the Voight Width
		// the 3rd row to store the height of the peaks
		// the 4th row to store the shape "1" for Voigt profile
	
	// guess the Gaussian width and Lorentizian width empirically
	FindLevels /P/Q/D=lvpw w, WaveMax(w)/2
		//lvpw: wave to contain the positions of the level crossings
	cm[1][0] = 2*sqrtln2/abs(pnt2x(w, lvpw[0]) - pnt2x(w, lvpw[1])) // wV
	
	if (pknum >= 2)
		cm[0][] = pnt2x(w, pkposw[q]) //position
		cm[1][] = cm[1][0] //width
		cm[2][] = sqrtln2pi*w[pkposw[q]] //height 
		cm[3][] = 1 //shape
	endif
	KillWaves lvpw
	return cm
End

//SetIgorHook AfterCompiledHook = InitDAQPanel
//SetIgorHook IgorStartOrNewHook = InitDAQPanel
Function AfterCompiledHook() 
//Function IgorStartOrNewHook() 
	InitDAQPanel()
End

Function InitGenStaSerPanel()
	DFREF dfraq = GetDAQPackageDFREF()
	DoWindow/F GenStaSerPanel
	if(V_Flag == 0) //if no GenStaSerPanel
		NewPanel/N=GenStaSerPanel/k=1/W=(800,50,1130,305) as "Generate Angle Scan File"
		TitleBox PolarTxt win=GenStaSerPanel, pos={20, 20}, size={150,20}, title="Polar angles (deg.):",font="Arial", fsize=12, frame=0;DelayUpdate
		SetVariable PlStart win=GenStaSerPanel, pos={30, 40}, size={70,20}, title="Start:";DelayUpdate
		SetVariable PlStart win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:plstart, limits={0,90,1};DelayUpdate
		SetVariable PlStop win=GenStaSerPanel, pos={110, 40}, size={70,20}, title="Stop:";DelayUpdate
		SetVariable PlStop win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:plstop, limits={0,90,1};DelayUpdate
		SetVariable PlStep win=GenStaSerPanel, pos={190, 40}, size={70,20}, title="Step:";DelayUpdate
		SetVariable PlStep win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:plstep, limits={0,90,0.1};DelayUpdate
		
		TitleBox AzimTxt win=GenStaSerPanel, pos={20, 65}, size={150,20}, title="Azimuthal angles (deg.):",font="Arial", fsize=12, frame=0;DelayUpdate
		SetVariable azStart win=GenStaSerPanel, pos={30, 85}, size={70,20}, title="Start:";DelayUpdate
		SetVariable azStart win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:azstart, limits={0,90,1};DelayUpdate
		SetVariable azStop win=GenStaSerPanel, pos={110, 85}, size={70,20}, title="Stop:";DelayUpdate
		SetVariable azStop win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:azstop, limits={0,180,1};DelayUpdate
		SetVariable azStep win=GenStaSerPanel, pos={190, 85}, size={100,20}, title="Initial step:";DelayUpdate
		SetVariable azStep win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:azstep0, limits={0,90,0.1};DelayUpdate

		//SetVariable azbl win=GenStaSerPanel, pos={20, 110}, size={210,20}, title="Azimuthal backlash angle (deg.):";DelayUpdate
		//SetVariable azbl win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:azbl, limits={0,10,0.1};DelayUpdate

		SetVariable PosNumVal win=GenStaSerPanel, pos={20, 115}, size={200,20}, title="The number of the positons:";DelayUpdate
		SetVariable PosNumVal win=GenStaSerPanel, font="Arial", fsize=12, value=dfraq:PosNum, limits={0,0,0};DelayUpdate
		Button CalNumBtn win=GenStaSerPanel, pos={225, 115}, size={60,20}, title="Calculate";DelayUpdate
		Button CalNumBtn win=GenStaSerPanel, font="Arial", fsize=12, disable=0, proc=CalNumBtnProc;DelayUpdate
	
		Button GenStaSerBtn win=GenStaSerPanel, pos={125, 150}, size={60,20}, title="Generate";DelayUpdate
		Button GenStaSerBtn win=GenStaSerPanel, font="Arial", fsize=12, disable=0, proc=GenStaSerBtnProc;DelayUpdate
		
		TitleBox NoteTxt win=GenStaSerPanel, pos={20, 175}, size={150,20}, title="Note:",font="Arial", fsize=12, frame=0;DelayUpdate
		TitleBox Note1Txt win=GenStaSerPanel, pos={20, 190}, size={150,20}, title="1. Initial step is the azimuthal step at largest polar angle.",font="Arial", fsize=12, frame=0;DelayUpdate
		//TitleBox Note2Txt win=GenStaSerPanel, pos={20, 225}, size={150,20}, title="2. The backlash angle will be added to the two",font="Arial", fsize=12, frame=0;DelayUpdate
		//TitleBox Note2Txt2 win=GenStaSerPanel, pos={20, 240}, size={150,20}, title="    sides of azimuthal range. ",font="Arial", fsize=12, frame=0;DelayUpdate
		TitleBox Note3Txt win=GenStaSerPanel, pos={20, 205}, size={150,20}, title="2. Only 1 point when Polar = 0 (normal emission). ",font="Arial", fsize=12, frame=0;DelayUpdate
		TitleBox Note4Txt win=GenStaSerPanel, pos={20, 220}, size={150,20}, title="3. For azimuthal equidistant polar projection method. ",font="Arial", fsize=12, frame=0
	endif
End

//Import Dispersion factors data to the DispWave
Function ImpDispFactors()
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq ChNum
	//Open the file
	DoAlert 1, "Do you really want to import dispersion factors? It will overwrite the current dispersion factors!"
	if(V_flag == 2)
		Abort
	elseif(V_flag == 1)
		String DispFactFileName
		DispFactFileName = SpecialDirPath("Igor Pro User Files", 0, 0, 0) + "Igor Procedures:DispersionFactors.df"
		CopyFile /M="Select the dispersion data file:"/O/Z=2 as DispFactFileName
		if(V_flag != 0)
			Abort
		endif
		SetDataFolder dfraq
		LoadWave/B="N=DispW;"/G/N/O/Q DispFactFileName
		Wave/SDFR=dfraq DispW
		Reverse DispW //reverse the DispW so that Channel 128 has the lowest energy
		SetDataFolder ::::
		Variable err = GetRTError(0)
		if(err != 0)
			err = GetRTError(1)
			DeleteFile/Z=1 DispFactFileName
			Abort "The file you opened may not be a correct dispersion factors file. Please doulbe check and try again."
		endif
		if(numpnts(DispW) != ChNum)
			DeleteFile/Z=1 DispFactFileName
			Abort "The number of the dispersion factors in the file you opened does not equal the number of the channels of the detector. \nPlease doulbe check and try again."
		endif
		Print "The default dispersion factors have been changed."
		Abort "The default dispersion factors have been changed."
	endif
End

Function About()
	String disclaimer
	disclaimer = "XPD data acquisition, displaying, process, and analysis package.\n"
	disclaimer += "Written by LIANG Xihui @ CEA Saclay.\n"
	disclaimer += "For any question, please email: liangxh@hotmail.com."
	Abort disclaimer
End

//GenStaSer()
//Generate a stage series file for CASCADE
Function GenStaSerBtnProc(ctrlName): ButtonControl
	String ctrlName
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq plstart, plstop, plstep, azstart, azstop, azstep0, azbl
	
	if(plstep == 0 || azstep0 == 0)
		abort "Step cannot be 0. Please input another value."
	endif
	
	if(plstart < 0 || plstop < 0 || azstart <0 || azstop < 0)
		abort "The Polar angles or Azimuthal angles should be positive or 0. Please input another value."
	endif
	
	if(plstart > plstop)
		abort "Polar stop anlge should be larger than start angle. Please input another value."
	endif
	if(azstart > azstop)
		abort "Azimuthal stop anlge should be larger than start angle. Please input another value."
	endif
	if(azbl < 0)
		abort "Azimuthal backlash angle should be =0 or >0. Please input another value."
	endif
	
	String message, fileFilters, FileNameStr
	Variable refNum
	
	//Save the Stage Series file
	message = "Save the Stage Series file..."
	fileFilters = "Stage Series Files (*.stage):.stage; All Files:.*;"
	Open/D/F=fileFilters/M=message refNum
	if (strlen(S_fileName) == 0)
		Abort
	endif
	
	FileNameStr = S_fileName
	Open/A refNum as FileNameStr
	fprintf refNum, "<?xml version=\"1.0\" standalone=\"yes\"?>\r\n"
	fprintf refNum, "<Stage_x0020_Positions>\r\n"
	fprintf refNum, "  <xs:schema id=\"Stage_x0020_Positions\" xmlns=\"\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:msdata=\"urn:schemas-microsoft-com:xml-msdata\">\r\n"
	fprintf refNum, "    <xs:element name=\"Stage_x0020_Positions\" msdata:IsDataSet=\"true\" msdata:UseCurrentLocale=\"true\">\r\n"
	fprintf refNum, "       <xs:complexType>\r\n"
	fprintf refNum, "         <xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\">\r\n"
	fprintf refNum, "           <xs:element name=\"Stage_x0020_Positions\">\r\n"
	fprintf refNum, "             <xs:complexType>\r\n"
	fprintf refNum, "               <xs:sequence>\r\n"
     fprintf refNum, "                 <xs:element name=\"Cycles\" type=\"xs:int\" default=\"1\" />\r\n"
     fprintf refNum, "                 <xs:element name=\"Polar\" type=\"xs:float\" minOccurs=\"0\" />\r\n"
     fprintf refNum, "                 <xs:element name=\"Azimuth\" type=\"xs:float\" minOccurs=\"0\" />\r\n"
     fprintf refNum, "                 <xs:element name=\"Z\" type=\"xs:float\" minOccurs=\"0\" />\r\n"
     fprintf refNum, "              </xs:sequence>\r\n"
     fprintf refNum, "            </xs:complexType>\r\n"
     fprintf refNum, "          </xs:element>\r\n"
     fprintf refNum, "        </xs:choice>\r\n"
     fprintf refNum, "      </xs:complexType>\r\n"
     fprintf refNum, "    </xs:element>\r\n"
	fprintf refNum, "  </xs:schema>\r\n"
	
	Variable pl, az, azstep, c = 0
	
	for(pl = plstart; pl <= plstop; pl += plstep)
		if(pl == 0)
			fprintf refNum, "  <Stage_x0020_Positions>\r\n"
			fprintf refNum, "    <Cycles>1</Cycles>\r\n"
			fprintf refNum, "    <Polar>"+num2str(pl)+"</Polar>\r\n"
			fprintf refNum, "    <Azimuth>"+num2str(azstart-azbl)+"</Azimuth>\r\n"
			fprintf refNum, "  </Stage_x0020_Positions>\r\n"
			c += 1
		endif
		if(pl != 0)
			azstep = azstep0 * (plstop/pl)
			for(az = azstart; az <= azstop; az += azstep)
				if(az == azstart && azbl != 0) // force the motor to ratate to the az-backlash
					fprintf refNum, "  <Stage_x0020_Positions>\r\n"
					fprintf refNum, "    <Cycles>1</Cycles>\r\n"
					fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
					fprintf refNum, "    <Azimuth>" + num2str(az-azbl) + "</Azimuth>\r\n"
					fprintf refNum, "  </Stage_x0020_Positions>\r\n"
					c += 1	
				endif
				fprintf refNum, "  <Stage_x0020_Positions>\r\n"
				fprintf refNum, "    <Cycles>1</Cycles>\r\n"
				fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
				fprintf refNum, "    <Azimuth>" + num2str(az) + "</Azimuth>\r\n"
				fprintf refNum, "  </Stage_x0020_Positions>\r\n"
				c += 1
			endfor
			if(az-azstep != azstop) //force the sample to rotate to the azstop and azstop+backslash
				fprintf refNum, "  <Stage_x0020_Positions>\r\n"
				fprintf refNum, "    <Cycles>1</Cycles>\r\n"
				fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
				fprintf refNum, "    <Azimuth>" + num2str(azstop) + "</Azimuth>\r\n"
				fprintf refNum, "  </Stage_x0020_Positions>\r\n"
				c += 1
			endif
			if(azbl != 0)
				fprintf refNum, "  <Stage_x0020_Positions>\r\n"
				fprintf refNum, "    <Cycles>1</Cycles>\r\n"
				fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
				fprintf refNum, "    <Azimuth>" + num2str(azstop+azbl) + "</Azimuth>\r\n"
				fprintf refNum, "  </Stage_x0020_Positions>\r\n"
				c += 1
			endif
		endif
	endfor
	fprintf refNum, "</Stage_x0020_Positions>\r\n"
	Close refNum
	S_fileName = ""
	Abort "Total " + num2str(c) + " positions have been generated and saved to\n\n" +FileNameStr
End

Function CalNumBtnProc(ctrlName): ButtonControl
	String ctrlName
	DFREF dfraq = GetDAQPackageDFREF()
	NVAR/SDFR=dfraq plstart, plstop, plstep, azstart, azstop, azstep0, azbl, PosNum
	
	if(plstep == 0 || azstep0 == 0)
		abort "Step cannot be 0. Please input another value."
	endif
	
	if(plstart < 0 || plstop < 0 || azstart <0 || azstop < 0)
		abort "The Polar angles or Azimuthal angles should be positive. Please input another value."
	endif
	
	if(plstart > plstop)
		abort "Polar stop anlge should be larger than start angle. Please input another value."
	endif
	if(azstart > azstop)
		abort "Azimuthal stop anlge should be larger than start angle. Please input another value."
	endif
	if(azbl < 0)
		abort "The azimuthal backlash angle should be = or > 0. Please input another value."
	endif
	
	Variable pl, az, azstep, c = 0
	
	for(pl = plstart; pl <= plstop; pl += plstep)
		if(pl == 0)
			//fprintf refNum, "    <Polar>"+num2str(pl)+"</Polar>\r\n"
			//fprintf refNum, "    <Azimuth>"+num2str(azstart-azbl)+"</Azimuth>\r\n"
			c += 1
		endif
		if(pl != 0)
			azstep = azstep0 * (plstop/pl)
			for(az = azstart; az <= azstop; az += azstep)
				if(az == azstart && azbl != 0) // force the motor to ratate to the az-backlash
					//fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
					//fprintf refNum, "    <Azimuth>" + num2str(az-azbl) + "</Azimuth>\r\n"
					c += 1	
				endif
				//fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
				//fprintf refNum, "    <Azimuth>" + num2str(az) + "</Azimuth>\r\n"
				c += 1
			endfor
			if(az-azstep != azstop) //force the sample to rotate to the azstop and azstop+backslash
				//fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
				//fprintf refNum, "    <Azimuth>" + num2str(azstop) + "</Azimuth>\r\n"
				c += 1
			endif
			if(azbl != 0)
				//fprintf refNum, "    <Polar>" + num2str(pl) + "</Polar>\r\n"
				//fprintf refNum, "    <Azimuth>" + num2str(azstop+azbl) + "</Azimuth>\r\n"
				c += 1
			endif
		endif
	endfor
	PosNum = c
End

// OpenXPD()
//Open diffractogram data file and open manipulate XPD panel
Function OpenXPD()
	String message, fileFilters, FileNameStr
	Variable MinTht, MaxTht
	
	//Open XPD pattern data file
	message = "Select an XPD data file..."
	fileFilters = "XPD data Files (*.xpd):.xpd; All Files:.*;"
	Open/D/R/F=fileFilters/M=message refNum
	if (strlen(S_fileName) == 0)
		Abort
	else
		FileNameStr = S_fileName
		DFREF dfr = GetXPDPackageDFREF()
		DFREF dfrp = dfr:Process
		SetDataFolder dfrp
		LoadWave/G/J/M/L={0,7,0,0,0}/B="N=XPDM;"/O/Q S_fileName
	endif
	
	String EngLine
	Variable refNum, itNum, i
	DFREF dfraq = GetDAQPackageDFREF()
	
	Open/R refNum as FileNameStr
	for(i = 0; i < 7; i += 1)
		FReadLine refNum, EngLine
	endfor
	Close refNum
	//print EngLine
	itnum = ItemsInList(EngLine, "\t")
	if(itnum != 0)
		Make /O/N=(itnum) EngW
		for(i = 0; i < itnum; i +=1)
			EngW[i] = str2num(StringFromList(i, EngLine, "\t"))
		endfor
	endif
	
	Wave/SDFR=dfrp XPDM
	Variable RowNum, ColNum
	rownum = DimSize(XPDM, 0)
	colnum =  DimSize(XPDM, 1)
	
	Make/O/N=(rownum) RdsW_raw, PhiW_raw, ItsW_raw
		
	RdsW_raw = XPDM[p][0]
	PhiW_raw = XPDM[p][1]
	ItsW_raw = XPDM[p][2]
	Duplicate/O RdsW_raw, RdsW
	Duplicate/O PhiW_raw, PhiW
	Duplicate/O ItsW_raw, ItsW
	
	//if the radius in the file is length, transform it to theta angle
	if( WaveMax(RdsW) < 1)
		RdsW = atan(XPDM[p]/2)*2/pi*180
	endif
	
	MinTht = (floor(WaveMin(RdsW)/5)-1)*5
	if(MinTht<0)
		MinTht = 0
	endif
	MaxTht = (floor(WaveMax(RdsW)/5)+1)*5
	DoWindow/F ProcessGraphWin
	if(V_flag == 0)
		PlotXPD("ProcessGraphWin", RdsW, PhiW, ItsW, MinTht, MaxTht)
		DoWindow/T ProcessGraphWin, "X-ray Photoelectron Diffractogram"
		MoveWindow/W=ProcessGraphWin 400, 100, 525, 325
	endif
	
	SetWindow ProcessGraphWin, hook(pickPixel) = HookCsrToPickPixel
	
	DoWindow/F ProcessPanel
	if(V_flag == 0)
		InitProcessPanel()
	endif
	MoveWindow /W=ProcessPanel 660, 100, 818, 525
	
	NVAR/SDFR=dfrp StartPhi, EndPhi, StartTht, EndTht
	StartPhi =  truncateDP(WaveMin(PhiW), 1)
	EndPhi = truncateDP(WaveMax(PhiW), 1)
	StartTht = truncateDP(WaveMin(RdsW), 1)
	EndTht = truncateDP(WaveMax(RdsW), 1)
	ValDisplay AzimAngSt, value =_NUM: StartPhi
	ValDisplay AzimAngEnd, value =_NUM: EndPhi
	ValDisplay PolarAngSt, value =_NUM: StartTht
	ValDisplay PolarAngEnd, value =_NUM: EndTht
	
	SetDataFolder ::::
End

//Hook the cursor to pick a pixel in XPD pattern
Function HookCsrToPickPixel(s)
	STRUCT WMWinHookStruct &s
	DFREF dfr = GetXPDPackageDFREF()
	DFREF dfrp = dfr:Process
	DFREF dfrwm = root:Packages:WMPolarGraphs:ProcessGraphWin
	Wave polarY = dfrwm:polarY0 
	Wave/SDFR=dfrp RdsW, PhiW, ItsW
	NVAR/SDFR=dfrp ThtAng, PhiAng, CrnIts, StartCropPhi, StartCropTht, SelThtAng, SelPhiAng
	
	Variable hookResult = 0, hpNb // hpnb: Hit Point Number
	String HitPntStr
	
	switch(s.eventCode)
		case 3: // mouse down
			HitPntStr = TraceFromPixel(s.MouseLoc.h, s.MouseLoc.v, "ONLY:polarY0") 
			hpnb = NumberByKey("HITPOINT", HitPntStr)
			if (numtype(hpnb) == 0) // hpnb is a normal number
				SelThtAng = truncateDP(RdsW[hpnb], 1)
				SelPhiAng =  truncateDP(PhiW[hpnb], 1)
				StartCropPhi =  truncateDP(PhiW[hpnb], 1)
				StartCropTht =  truncateDP(RdsW[hpnb], 1)
				thtAng = selthtAng
				phiAng = selphiAng
				crnits = truncateDP(itsw[hpnb], 2)
				ValDisplay CrnThtVal,Win=Processpanel, value= _NUM:ThtAng
				ValDisplay CrnPhiVal,Win=Processpanel, value= _NUM:PhiAng
				ValDisplay CrnItsVal,Win=Processpanel, value= _NUM:CrnIts

				SetDrawLayer /K/W=ProcessGraphWin UserFront
				ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY1)=1
				ModifyGraph /W=ProcessGraphWin/Z hideTrace(polarY2)=1
				Cursor /P/A=1/H=0/S=2/W=ProcessGraphWin I polarY0 hpnb
			else // hpnb = NaN or += INF, i.e., User didn't hit any data point of the trace.
				break
			endif
			break
	endswitch
	return hookResult // 0 if nothing done, else 1
End
