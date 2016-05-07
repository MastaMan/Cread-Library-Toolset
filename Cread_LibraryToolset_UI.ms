/*
_____________________

Cread Library Toolset 
_____________________

Version: 0.01a
Release date: 19th April 2016
UI Design: Alberto Gutierrez | albertogutierrez@estudicread.com
Developer: MastaMan
	
*/


/* UI code START */

--Destroy dialog if it already exists.
try(destroyDialog theRollout)catch()

/* GLOBAL FUNCTIONS */

fn getMaxVersion =
(
	v = maxVersion()
	v = (v[1] / 1000) - 2
	
	a = 2000 + v
	
	o = case v of 
	(
		11: #(2010,2011)
		12: #(2010,2011,2012)
		default: #(a - 3, a - 2, a - 1, a)		
	)
	
	return (for i in o collect i as string)
)


fn getRender =
(
	r = renderers.current as string

	if matchpattern r pattern:"*Corona*" do return #("_corona", "Corona")
	if matchpattern r pattern:"*V_Ray_Adv*" do return #("_vray", "VRay")
	if matchpattern r pattern:"*Default_Scanline*" do return #("_scanline", "Default Scanline")
	if matchpattern r pattern:"*mental_ray*" do return #("_mentalray", "Mental Ray")
	if matchpattern r pattern:"*iray_Renderer*" do return #("_iray", "IRay")
	if matchpattern r pattern:"*maxwell*" do return #("_maxwell", "Maxwell")
		
	return #("", "")
)

--TAB 1

rollout T1Rollout1 "OBJECTS"(
	
	dropdownList rnObjsMode "" pos:[110,25] width:100 height:40 items:#("Replace with","Add prefix","Add suffix") align:#left
	dropdownList rnObjsType "" pos:[215,25] width:70 height:40 enabled:true items:#("ID Name", "Full name", "Custom") align:#left
	edittext rnObjsCustom "" pos:[290,25] width:80 height:20 enabled:false labelOnTop:true align:#left text:"custom_text"
	dropdownList rnObjsPadding "" pos:[375,25] width:55 height:40 enabled:true items:#("##", "###", "####") align:#right selection:2
	edittext rnObjsPrevName "Objects name preview" pos:[440,7] width:115 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"1380_001"
	checkbox chk1 "Clean layers" tooltip:"Move all objects to 0 (default) layer and remove all layers" pos:[110,55] checked:true

)

rollout T1rollout2 "MATERIALS" (
	
	dropdownList rnMatsMode "" pos:[110,25] width:100 height:40 items:#("Replace with","Add prefix","Add suffix") align:#left
	dropdownList rnMatsType "" pos:[215,25] width:70 height:40 enabled:true items:#("ID Name", "Full Name", "Custom") align:#left
	edittext rnMatsCustom "" pos:[290,25] width:80 height:20 enabled:false labelOnTop:true align:#left text:"custom_text"
	dropdownList rnMatsPadding "" pos:[375,25] width:55 height:40 enabled:true items:#("##", "###", "####") align:#right selection:2
	edittext rnMatsPrevName "Materials name preview" pos:[440,7] width:115 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"1380_001"

)

rollout T1rollout3 "MAPS" (
	
	dropdownList rnMapsMode "" pos:[110,25] width:100 height:40 items:#("Replace with","Add prefix","Add suffix") align:#left
	dropdownList rnMapsType "" pos:[215,25] width:70 height:40 enabled:true items:#("ID Name", "Full Name", "Custom") align:#left
	edittext rnMapsCustom "" pos:[290,25] width:80 height:20 enabled:false labelOnTop:true align:#left text:"custom_text"
	dropdownList rnMapsPadding "" pos:[375,25] width:55 height:40 enabled:true items:#("##", "###", "####") align:#right selection:2
	edittext rnMapsPrevName "Maps name preview" pos:[440,7] width:115 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"1380_001"
	checkbox chk3 "Set Assets Path" tooltip:"Set assets path to RootPath + ID Name" pos:[110,55] checked:true
	
)

--TAB 2
rollout T2Rollout1 "Geometry" (
	
	button btnXform "Reset XForm" pos:[20,40] width:100 height:34 align:#left
	button btnGroup "Group" pos:[150,40] width:100 height:34 align:#left
	button btnUngroup "Ungroup" pos:[150,80] width:100 height:34 align:#left
	
	groupBox grpPivot "Pivot" pos:[286,20] width:128 height:125
	button btnPvTop "Top" pos:[300,40] width:100 height:30 align:#left
	button btnPvCenter "Center" pos:[300,70] width:100 height:30 align:#left
	button btnPvBottom "Bottom" pos:[300,100] width:100 height:30 align:#left
	
	button btnCenterGeo "Center in Scene" pos:[450,40] width:100 height:34 align:#left
	
)

--TAB 3
rollout T3rollout1 "Pictures"
(
	bitmap bmpLoader "" pos:[20,17] width:256 height:256 align:#left
	button btnAddPicture "Add New Picture" pos:[350,90] width:153 height:40 align:#left
	dropdownList picList "" pos:[350,135] width:130 height:20 items:#("") align:#left
	button btnDelPicture "X" pos:[482,135] width:20 height:20 align:#left
	--label resolution "" pos:[0,0] witdh:100 height:20 align:#left
	edittext rootpath "Save pictures to" pos:[300,235] width:170 height:20 enabled:false labelOnTop:true align:#left text:"\\\\nas\\library\\"
	button btn14 "Select path" pos:[470,252] width:80 height:22 align:#left enabled:false
	checkbox chk3 "Use RootPath" tooltip:"Path will be 'Path\Pictures'" pos:[460,232] checked:true
	
)

--TAB 4
rollout T4Rollout1 "" (
	/* About */
	/*
	label 'lbl0' "Library Toolset" offset:[0,50]
	label 'lbl3' "Version: 0.01a" offset:[0,10]
	label 'lbl4' "Release date: 19th April 2016" offset:[0,0]
	label 'lbl6' "UI Design: Alberto Gutierrez | albertogutierrez@estudicread.com" offset:[0,20]
	label 'lbl7' "Developer: MastaMan" offset:[0,0]
	label 'lbl8' "---" offset:[0,0]
	label 'lbl9' "GNU GPL v3.0" offset:[0,0]
	*/
)




--Create a rollout
rollout theRollout "Library Toolset" --height:400
(

	edittext ID "ID Name" pos:[26,40] width:100 height:20 enabled:true labelOnTop:true align:#left text:"1380"
	-- format1
	dropdownList format1 "Format" pos:[130,40] width:100 height:40 items:#("3D Studio Max","FBX","OBJ") align:#left
	dropdownList scn1 "Scene version" pos:[235,40] width:70 height:40 enabled:true items:#("none", "2013", "2014", "2015","2016") align:#left 
	dropdownList render1 "Render" pos:[310,40] width:70 height:40 enabled:true items:#("none","VRay", "Corona", "Maxwell") align:#left
	edittext version1 "Version" pos:[386,40] width:34 height:20 enabled:true labelOnTop:true align:#left text:"01"
	button version1add "+" pos:[426,58] width:20 height:20 align:#left
	edittext fullname1 "Full name + ext" pos:[460,40] frame:false width:130 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"1380_011801V01.max"
	
	-- format2
	checkbox chk2 "" pos:[110,85] height:20
	dropdownList format2 "" pos:[130,84] width:100 height:40 items:#("3D Studio Max","FBX","OBJ") align:#left enabled:false
	dropdownList scn2 "" pos:[235,84] width:70 height:40 enabled:false items:#("2013", "2014", "2015","2016") align:#left 
	dropdownList render2 "" pos:[310,84] width:70 height:40 enabled:false items:#("none","VRay", "Corona", "Maxwell") align:#left
	edittext version2 "" pos:[386,84] width:34 height:20 enabled:false labelOnTop:true align:#left text:"01"
	button version2add "+" pos:[426,84] width:20 height:20 align:#left enabled:false
	edittext fullname2 "" pos:[460,84] width:130 height:20 enabled:false labelOnTop:true align:#left readonly:true text:"0000_000000V01.ext"
	
	-- format3
	checkbox chk3 "" pos:[110,111] height:20
	dropdownList format3 "" pos:[130,110] width:100 height:40 items:#("3D Studio Max","FBX","OBJ") align:#left enabled:false
	dropdownList scn3 "" pos:[235,110] width:70 height:40 enabled:false items:#("2013", "2014", "2015","2016") align:#left
	dropdownList render3 "" pos:[310,110] width:70 height:40 enabled:false items:#("none","VRay", "Corona", "Maxwell") align:#left
	edittext version3 "" pos:[386,110] width:34 height:20 enabled:false labelOnTop:true align:#left text:"01"
	button version3add "+" pos:[426,110] width:20 height:20 align:#left enabled:false
	edittext fullname3 "" pos:[460,110] width:130 height:20 enabled:false labelOnTop:true align:#left readonly:true text:"0000_000000V01.ext"
	
	
	edittext rootpath "Save model to (RootPath)" pos:[26,150] width:420 height:20 enabled:true labelOnTop:true align:#left text:"\\\\nas\\library\\"
	button btn14 "Select path" pos:[448,167] width:80 height:22 align:#left
	
	
--Create the dotNet TabControl control
dotNetControl tc "system.windows.forms.tabcontrol" height:25 offset:[0,30]

--Create our subrollout that we can use to hide and reveal our different rollout choices
subRollout theSubRollout height:320



--Create a setup function for the DOT Net elements
fn initTc thetc=
(
--Create 3 Tab Pages
t1 = dotNetObject "System.Windows.Forms.TabPage" "Renamer"
t2 = dotNetObject "System.Windows.Forms.TabPage" "Tools"
t3 = dotNetObject "System.Windows.Forms.TabPage" "Pictures"
t4 = dotNetObject "System.Windows.Forms.TabPage" "About"


--Add the rollout to be initialise on the first Tabpage
addSubRollout theSubRollout T1Rollout1
T1Rollout1.height = 80
addSubRollout theSubRollout T1Rollout2
T1Rollout2.height = 80
addSubRollout theSubRollout T1Rollout3
T1Rollout3.height = 80
	
--Add the Tabpages to the TabControl
thetc.controls.add t1
thetc.controls.add t2
thetc.controls.add t3
thetc.controls.add t4
)

on tc mousedown arg do
(
--Check which Tab is selected, and reveal the appropriate rollouts!
case tc.SelectedTab.TabIndex of
(

0:
(
try
(
removeSubRollout theSubRollout T2Rollout1
removeSubRollout theSubRollout T3Rollout1
removeSubRollout theSubRollout T4Rollout1
)
catch()
addSubRollout theSubRollout T1Rollout1
T1Rollout1.height = 80
addSubRollout theSubRollout T1Rollout2
T1Rollout2.height = 80
addSubRollout theSubRollout T1Rollout3
T1Rollout3.height = 80
)

1:
(
try
(
removeSubRollout theSubRollout T1Rollout1
removeSubRollout theSubRollout T1Rollout2
removeSubRollout theSubRollout T1Rollout3
removeSubRollout theSubRollout T3Rollout1
removeSubRollout theSubRollout T4Rollout1
)
catch()
addSubRollout theSubRollout T2Rollout1
T2Rollout1.height = 290
)

2:
(
try
(
removeSubRollout theSubRollout T1Rollout1
removeSubRollout theSubRollout T1Rollout2
removeSubRollout theSubRollout T1Rollout3
removeSubRollout theSubRollout T2Rollout1
removeSubRollout theSubRollout T4Rollout1

)
catch()
addSubRollout theSubRollout T3Rollout1
T3Rollout1.height = 290
)

3:
(
try
(
removeSubRollout theSubRollout T1Rollout1
removeSubRollout theSubRollout T1Rollout2
removeSubRollout theSubRollout T1Rollout3
removeSubRollout theSubRollout T2Rollout1
removeSubRollout theSubRollout T3Rollout1

)
catch()
addSubRollout theSubRollout T4Rollout1
T4Rollout1.height = 290
)
)

)--End if mousedown

checkbox chk5 "Create Statistics CSV File" pos:[20,595] height:20 checked:true
button SaveModels "Save Models" pos:[210,595] width:200 height:60 align:#left

/* EVENTS */

	fn fillSceneVersion ddl =
	(		
		v = getMaxVersion()
		
		ddl.items = v
		ddl.selection = v.count
	)

	fn fillRender ddl =
	(
		r = getRender()
				
		i = findItem (ddl.items) r[2]
		
		if(i != 0) do ddl.selection = i
	)
	
	on theRollout open do
	(
		initTc tc
		
		fillSceneVersion scn1
		fillSceneVersion scn2
		fillSceneVersion scn3
		
		fillRender render1
		fillRender render2
		fillRender render3
	)

	on ID changed a do
	(
		print a
	)
	

)
createDialog theRollout 610 680

/* UI code END */