/*
_____________________

Cread Library Toolset 
_____________________

Release date: 19th April 2016
UI Design: Alberto Gutierrez | albertogutierrez@estudicread.com
Developer: MastaMan
	
*/


/* UI code START */

--Destroy dialog if it already exists.
try(destroyDialog theRollout)catch()


/* GLOBAL VARIABLES */

global szVersion = "1.0.8"
global szSaveToPath = @"\\nas\library\"
global szSaveImagesToPath = @"\\nas\library\"
global szGoodChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz \\;:1234567890!@#$%^&*()_+~'.,[]{}" 
global szModelID = ""
global szPreviewPath = #()
global BitmapTypes = #(Bitmaptexture, CoronaBitmap)
global szScene = #()
global theRollout
global szModelVerison = "01"

global bReplaceNormal = true
global bReplaceColorCorrect = true


/* GLOBAL FUNCTIONS */

fn getMaxVersion =
(
	v = maxVersion()
	v = (v[1] / 1000) - 2
	
	a = 2000 + v
	
	o = case v of 
	(
		11: #(a - 1, a)
		12: #(a - 2, a - 1, a)
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

fn findRenderer f =
(	
	o = for r in RendererClass.classes where matchPattern (r as string) pattern: ("*" + f + "*") collect r
	return o.count > 0
)

fn getNum n c:2 =
(
	n = n as string
	
	if(n.count < c) do
	(
		d = c - n.count
		
		s = ""
		
		for i in 1 to d do s += "0"
		return s + n
	)
	
	return n
)


fn useSettings k p w =
(	
	settingsFile = getThisScriptFilename() + ".ini"
	
	v = maxVersion()
	v = 2000 + ((v[1] / 1000) - 2)
	
	case w of
	(
		"r":
		(
			s = getINISetting settingsFile (v as string) k
			case p of
			(
				"int": return s as integer
				"float": return s as float
				"bool": if s == "true" or s.count < 1 then true else false
				"bool_not": if s == "true" then true else false
				
				default: return s
			)
		)
		default: return setINISetting settingsFile (v as string) k (p as string)
	)
)

fn isSelected =
(
	if(selection.count < 1) do 
	(
		messageBox "Please select model!" title: "Warning!"
		return false
	)
	
	return true
)

fn polyCount s spaces: true =
(	
	iPoly = 0
	
	a = for i in s collect (getPolygonCount i)[1]
	for i in a do iPoly += i
	
	r = ""
	ii = 1
	
	if(spaces == false) do return iPoly as string
	
	for i in sPoly.count to 1 by -1 do
	(
		space = ""	
			
		if (ii == 3) do 
		(
			space = " "
			ii = 0
		)
		
		ii += 1
		
		r = space + sPoly[i] + r
	)

	return (trimLeft r " ")
)

fn invalidBitmap b = 
(	
	return b == undefined or b.filename == undefined or b.filename == "" or b.filename.count == 0
)

fn validBitmap b = 
(	
	return b != undefined and b.filename != undefined and b.filename != "" and b.filename.count != 0
)

fn getFullPath p = 
(	
	if(doesFileExist p) do return p
	
	return mapPaths.getFullFilePath (filenameFromPath  p)
)

fn round n = ((n * 100) as integer) / 100.0

fn writeFile f s =
(
	f = openFile f mode: "wt"

	format(s as string) to:f

	flush f
	close f
)


fn getMaterialDependence s type =
(
	sceneMaps = #()
	
	for c in type.classes where c != undefined and findItem BitmapTypes c == 0 do 
	(		
		for g in s do
		(
			for m in getClassInstances c target:g where m != undefined do 
			(					
				appendIfUnique sceneMaps m
			)
		)
	)	
	
	return sceneMaps
)


--TAB 1


rollout T1Rollout1 "OBJECTS"(
	
	dropdownList rnObjsMode "" pos:[110,25] width:100 height:40 items:#("Replace with","Add prefix","Add suffix") align:#left
	dropdownList rnObjsType "" pos:[215,25] width:70 height:40 enabled:true items:#("ID Name", "Full name", "Custom") align:#left
	edittext rnObjsCustom "" pos:[290,25] width:80 height:20 enabled:false labelOnTop:true align:#left text:"custom_text"
	dropdownList rnObjsPadding "" pos:[375,25] width:55 height:40 enabled:true items:#("##", "###", "####") align:#right selection:2
	edittext rnObjsPrevName "Objects name preview" pos:[440,7] width:115 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"_001V01"
	checkbox chk1 "Clean layers" tooltip:"Move all objects to 0 (default) layer and remove all layers" pos:[110,55] checked:true

	fn renamerObjects realName num =
	(
		m = rnObjsMode.selection
		t = rnObjsType.selection
		c = rnObjsCustom.text
		p = rnObjsPadding.selected.count
		fullName = getFilenameFile (theRollout.fullname1.text)
		idName = theRollout.ID.text
			
		n = case t of 
		(			
			2: fullName
			3: c
			default: idName
		)
			
		o = case m of
		(
			2: n + "_" + realName
			3: realName + "_" + n 
			default: n
		)
		
		return o + "_" + (getNum num c:p) + "V" + szModelVerison
	)
	
	fn startRenameObjects = 
	(
		g = objects
				
		for i in 1 to g.count where isValidNode g[i] do
		(
			g[i].name = renamerObjects (g[i].name) i
		)
	)
	
	fn replaceNormal = 
	(		
		if(findRenderer "V_Ray" == false) do return false
		if(bReplaceNormal != true) do return false
		
		clearListener()
		for i in getClassInstances VrayMtl do
		(
			b = i.texmap_bump
			
			if(b == undefined or classOf b != Normal_Bump) do continue
			
			nrm = b.normal_map 
						
			replaceInstances b (VRayNormalMap normal_map: nrm)
		)
	)
	
	fn replaceColorCorrect =
	(
		if(findRenderer "V_Ray" == false) do return false
		if(bReplaceColorCorrect != true) do return false
		if(colorcorrect == undefined) do return false
		
		clearListener()
		-- Code by crazy1k
		for m in (getClassinstances colorcorrect) do
		(
			mcc_gamma=1/m.gamma
			mcc_color=m.src_color
			if m.hsl_on==true then 
			(
				mcc_sat=m.hsl_sat_off/1.32+(m.hsl_sat_gain-100)/2.66
				mcc_hue_off=m.hsl_hue_off
			)
			if m.hsv_on==true then 
			(
				mcc_sat=m.hsv_sat_off/1.32+(m.hsv_sat_gain-100)/2.66
				mcc_hue_off=m.hsv_hue_off
			)
			mcc_mono=m.pre_mono
			mcc_invert=m.pre_invert
			if m.pre_on==true and (m.hsl_on==true or m.hsv_on==true) then
			(
				if (mcc_mono==false) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat gammaRGB:mcc_gamma lightnessMode:1)
				if (mcc_mono==true) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat gammaRGB:mcc_gamma rewireMode:1 lightnessMode:1)
				if (mcc_mono==false) and (mcc_invert==true) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat gammaRGB:mcc_gamma rewireMode:2 lightnessMode:1)
			)
			if m.pre_on==true and (m.hsl_on==false and m.hsv_on==false) then 
			(
				if (mcc_mono==false) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) gammaRGB:mcc_gamma lightnessMode:1)
				if (mcc_mono==true) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) gammaRGB:mcc_gamma rewireMode:1 lightnessMode:1)
				if (mcc_mono==false) and (mcc_invert==true) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) gammaRGB:mcc_gamma rewireMode:2 lightnessMode:1)
			)
			if m.pre_on==false and (m.hsl_on==true or m.hsv_on==true) then
				replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat lightnessMode:1)
			if m.pre_on==false and (m.hsl_on==false and m.hsv_on==false) then
					replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) lightnessMode:1)
		)
	)
	
	on rnObjsType selected a do
	(	
		rnObjsCustom.enabled = if(a == 3) then true else false
				
		rnObjsPrevName.text = renamerObjects "obj" 1
	)
	
	on rnObjsMode selected a do rnObjsPrevName.text = renamerObjects "obj" 1
	
	on rnObjsPadding selected a do rnObjsPrevName.text = renamerObjects "obj" 1
		
	on rnObjsCustom changed a do rnObjsPrevName.text = renamerObjects "obj" 1
		
)

rollout T1rollout2 "MATERIALS" (
	
	dropdownList rnMatsMode "" pos:[110,25] width:100 height:40 items:#("Replace with","Add prefix","Add suffix") align:#left
	dropdownList rnMatsType "" pos:[215,25] width:70 height:40 enabled:true items:#("ID Name", "Full Name", "Custom") align:#left
	edittext rnMatsCustom "" pos:[290,25] width:80 height:20 enabled:false labelOnTop:true align:#left text:"custom_text"
	dropdownList rnMatsPadding "" pos:[375,25] width:55 height:40 enabled:true items:#("##", "###", "####") align:#right selection:2
	edittext rnMatsPrevName "Materials name preview" pos:[440,7] width:115 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"_001V01"

	fn renamerMaterials realName num =
	(
		m = rnMatsMode.selection
		t = rnMatsType.selection
		c = rnMatsCustom.text
		p = rnMatsPadding.selected.count
		fullName = getFilenameFile (theRollout.fullname1.text)
		idName = theRollout.ID.text
			
		n = case t of 
		(			
			2: fullName
			3: c
			default: idName
		)
			
		o = case m of
		(
			2: n + "_" + realName
			3: realName + "_" + n 
			default: n
		)
		
		return o + "_" + (getNum num c:p) + "V" + szModelVerison
	)
	
	fn startRenameMaterials = 
	(
		oldMtl = #()
		iCnt = 1
		p = rnMatsPadding.selected.count
		/*
		for i in selection where i.material != undefined and findItem oldMtl i.material == 0 do
		(
			-- May be chek dub name
			n = i.material.name
			i.material.name = renamerMaterials n iCnt
			
			if(classOf i.material == Multimaterial) do for ii in 1 to i.material.count where i.material[ii] != undefined do i.material[ii].name = i.material.name + "_" + (getNum ii c:p)
			
			append oldMtl i.material
			
			iCnt += 1		
		)*/

		/*for i in material.classes where i != undefined do
		(
			for ii in getClassInstances i do 
			(	
				n = refs.dependentNodes ii
				if(n.count > 0) do
				(
					ii.name = renamerMaterials szModelID iCnt
					iCnt += 1
				)
			)
		)*/
		
		toRename = #()
		mat = getMaterialDependence selection material
		tex = getMaterialDependence selection textureMap	
		
		join toRename mat
		join toRename tex
				
		for i in toRename do 
		(
			i.name = renamerMaterials szModelID iCnt
			iCnt += 1	
		)
	)
	
	on rnMatsType selected a do
	(
		rnMatsCustom.enabled = if(a == 3) then true else false
		
		rnMatsPrevName.text = renamerMaterials "mat" 1
	)
		
	on rnMatsMode selected a do rnMatsPrevName.text = renamerMaterials "mat" 1
	
	on rnMatsPadding selected a do rnMatsPrevName.text = renamerMaterials "mat" 1
		
	on rnMatsCustom changed a do rnMatsPrevName.text = renamerMaterials "mat" 1

)

rollout T1rollout3 "MAPS" (
	
	dropdownList rnMapsMode "" pos:[110,25] width:100 height:40 items:#("Replace with","Add prefix","Add suffix") align:#left
	dropdownList rnMapsType "" pos:[215,25] width:70 height:40 enabled:true items:#("ID Name", "Full Name", "Custom") align:#left
	edittext rnMapsCustom "" pos:[290,25] width:80 height:20 enabled:false labelOnTop:true align:#left text:"custom_text"
	dropdownList rnMapsPadding "" pos:[375,25] width:55 height:40 enabled:true items:#("##", "###", "####") align:#right selection:2
	edittext rnMapsPrevName "Maps name preview" pos:[440,7] width:115 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"_001V01"
	checkbox chk3 "Set Assets Path" tooltip:"Set assets path to RootPath + ID Name" pos:[110,55] checked:true
	
	fn renamerMaps realName num =
	(
		m = rnMapsMode.selection
		t = rnMapsType.selection
		c = rnMapsCustom.text
		p = rnMapsPadding.selected.count
		fullName = getFilenameFile (theRollout.fullname1.text)
		idName = theRollout.ID.text
		realName = getFilenameFile realName
			
		n = case t of 
		(			
			2: fullName
			3: c
			default: idName
		)
			
		o = case m of
		(
			2: n + "_" + realName
			3: realName + "_" + n 
			default: n
		)
		
		return o + "_" + (getNum num c:p) + "V" + szModelVerison
	)
	
	on rnMapsType selected a do
	( 
		rnMapsCustom.enabled = if(a == 3) then true else false
		
		rnMapsPrevName.text = renamerMaps "map" 1
	)
	
	fn startRenameAndCopyMaps szMaps = 
	(
		oldTex = #()
		oldTexPaths = #()
		toRename = #()
		iCnt = 1
		
		for i in selection where i.material != undefined do
		(
			for type in BitmapTypes where classOf type == textureMap do 
			(	
				for b in getClassInstances type target:i where (validBitmap b) and findItem oldTex b == 0 do
				(																	
					f = getFullPath (b.filename)
				
					n = filenameFromPath f
					p = getFilenamePath f
					ext = getFilenameType f
							
					n = (renamerMaps n iCnt) + ext
										
					if(doesFileExist f) do
					( 
						ep = findItem oldTexPaths b.filename
						
						if(ep != 0) then n = toRename[ep][5]
						
						append oldTex b
						append toRename #(b, (p + n), (szMaps + n), f, n) 
				
						if(ep == 0) do iCnt += 1
						append oldTexPaths b.filename
					)												
				)
			)
		)
							
		for t in toRename do
		(
			t[1].filename = t[2]
			t[1].name = getFilenameFile t[5]
			
			if(chk3.checked == true) then copyFile t[4] t[3] else copyFile t[4] t[2]
		)		
	)
	
	fn startRenameAndCopyIES szIES = 
	(	
		global iIesCnt = 1
		
		fn copyIes ies szIES =
		(
			if(ies == undefined) do return undefined
			
			ies = getFullPath ies
			
			if(not doesFileExist ies) do return ies
			
			n = filenameFromPath ies
			ext = getFilenameType ies
			
			f = szIES  + (renamerMaps n iIesCnt) + ext
			
			copyFile ies f
			
			iIesCnt += 1
			
			return f
		)
		
		
		for l in lights where l.isSelected == true do
		(
			if(isProperty l #ies_file) do l.ies_file = copyIes (l.ies_file) szIES
			if(isProperty l #webFile) do l.webFile = copyIes (l.webFile) szIES
			if(isProperty l #iesFile) do l.iesFile = copyIes (l.iesFile) szIES
		)		
	)
	
	fn libAssetsPath szMaps =
	(		
		for type in BitmapTypes where classOf type == textureMap do
		(
			for b in getClassInstances type where (validBitmap b) do b.filename = szMaps + (filenameFromPath b.filename)
		)
	)
	
	on rnMapsMode selected a do rnMapsPrevName.text = renamerMaps "map" 1
	
	on rnMapsPadding selected a do rnMapsPrevName.text = renamerMaps "map" 1
		
	on rnMapsCustom changed a do rnMapsPrevName.text = renamerMaps "map" 1
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
	
	
	-- TAB 2
	fn ungroupRecursive s = for i in s where isGroupHead i and isValidNode i do explodeGroup i
	fn findGroup s = for i in s where isGroupHead i and isValidNode i and findString i.name szModelID == undefined collect i.name
	fn autoRenameGroup s = for i in s where isGroupHead i and isValidNode i do i.name = (uniqueName (szModelID + "_") numDigits: 3) + "V" + szModelVerison
	
	fn setPivot p =
	(
		selection.pivot = selection.center
		selection.pivot.z = p
			
		ForceCompleteRedraw()
	)
	
	on btnXform pressed do
	(
		if(not isSelected()) do return false
		
		for i in selection where superClassOf i == GeometryClass do
		(			
			ResetXForm i
			collapseStack i
		)
	)
	
	on btnGroup pressed do
	(
		if(not isSelected()) do return false
					
		ungroupRecursive selection
		n = (uniqueName (szModelID + "_") numDigits: 3) + "V" + szModelVerison
		group selection name:n select:true		
	)
	
	on btnUngroup pressed do
	(
		if(not isSelected()) do return false
			
		ungroupRecursive selection
	)
	
	on btnPvBottom pressed do
	(
		if(not isSelected()) do return false
			
		setPivot selection.min.z
	)
	
	on btnPvTop pressed do
	(
		if(not isSelected()) do return false
			
		setPivot selection.max.z
	)
	
	on btnPvCenter pressed do
	(
		if(not isSelected()) do return false
			
		selection.pivot = selection.center
	)
	
	on btnCenterGeo pressed do
	(
		if(not isSelected()) do return false
		
		g = group selection
		g.pivot = selection[1].pivot

		g.pos = [0,0,0]
					
		ungroup g		
	)
)

rollout T2Rollout2 "Shaders" 
(
	checkbox cbxReplaceNormal "Replace NormalMap > VrayNormalMap" checked: true pos: [170, 28]
	checkbox cbxReplaceColorCorrect "Replace ColorCorrect > ColorCorrection" checked: true pos: [170, 56]
	
	on cbxReplaceNormal changed s do bReplaceNormal = s
	on cbxReplaceColorCorrect changed s do bReplaceColorCorrect = s
)

--TAB 3
rollout T3rollout1 "Pictures"
(
	bitmap bmpLoader "" pos:[20,17] width:256 height:256 align:#left
	button btnAddPicture "Add New Picture" pos:[350,90] width:153 height:40 align:#left
	dropdownList picList "" pos:[350,135] width:130 height:20 items:#("") align:#left
	button btnDelPicture "X" pos:[482,135] width:20 height:20 align:#left
	--label resolution "" pos:[0,0] witdh:100 height:20 align:#left
	edittext rootpath "Save pictures to" pos:[300,235] width:170 height:20 enabled:false labelOnTop:true align:#left text: szSaveImagesToPath
	button btn14 "Select path" pos:[470,252] width:80 height:22 align:#left enabled:false
	checkbox chk3 "Use RootPath" tooltip:"Path will be 'Path\Pictures'" pos:[460,232] checked:true
	
	on T3rollout1 open do
	(
		n = useSettings "SAVEIMAGETO" "string" "r"
		r = FilterString n szGoodChars
		
		if(n != "" and n != undefined and r.count == 0) do szSaveImagesToPath = n
		rootpath.text = szSaveImagesToPath
	)
	
	fn showPreview f =
	(		
		if(f == undefined or not doesFileExist f) do return false
		
		w = bmpLoader.width
		h = bmpLoader.height
		
		b = bitmapTex filename: f					
		b2 = bitmap w h			
		copy b.bitmap b2
		
		bmpLoader.bitmap = b2
		
		w = b.bitmap.width as string
		h = b.bitmap.height as string			
	)
	
	fn getOpenImage = 
	(
		f = #()
		
		imageDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" 
		imageDialog.title = "Select Pictures"
		imageDialog.Multiselect = true
		imageDialog.Filter = "JPG (*.jpg)|*.jpg|PNG (*.png)|*.png|BMP (*.bmp)|*bmp"
		imageDialog.FilterIndex = 1
		
		result = imageDialog.showDialog() 
		result.ToString() 
		result.Equals result.OK 
		result.Equals result.Cancel 
		
		f = imageDialog.fileNames 
		 
		return f
	)
	
	on btnAddPicture pressed do
	(
		f = getOpenImage()
				
		if(f.count != 0) do
		(
			for i in f do append szPreviewPath i
						
			picList.items = for i in szPreviewPath collect filenameFromPath i

			picList.selection = szPreviewPath.count

			showPreview	f[f.count]							
		)
	)
	
	on picList selected x do
	(
		showPreview szPreviewPath[x]
	)
	
	on btnDelPicture pressed do
	(
		s = picList.selection
		
		bmpLoader.bitmap = bitmap 1 1 color: (color 68 68 68)
		
		if(s != 0) do 
		(
			deleteItem szPreviewPath s
			picList.items = for i in szPreviewPath collect filenameFromPath i
			showPreview	szPreviewPath[1]
		)		
	)
	
	on chk3 changed s do
	(
		rootpath.enabled = not s
		btn14.enabled = not s
	)
	
	on btn14 pressed do 
	(
		
		f = getSavePath  caption: "Select Path" initialDir: szSaveImagesToPath
		
		if(f != undefined) do
		(
			p = FilterString f szGoodChars
			if(p.count > 0) do return messageBox "The paths are not supported by cyrillic characters!\nPlease choose another path!" title: "Warning!"
			
			szSaveImagesToPath = f + @"\"
			rootpath.text = szSaveImagesToPath
									
			useSettings "SAVEIMAGETO" szSaveImagesToPath "w"
		)
	)
	
)

--TAB 4
rollout T4Rollout1 "" (
	/* About */
	
	label lbl0 "Library Toolset" offset:[0,50]
	label lbl3 "Version: "  offset:[0,10]
	label lbl4 "Release date: 19th April 2016" offset:[0,0]
	label lbl6 "UI Design: Alberto Gutierrez | albertogutierrez@estudicread.com" offset:[0,20]
	label lbl7 "Developer: MastaMan" offset:[0,0]
	label lbl8 "---" offset:[0,0]
	label lbl9 "GNU GPL v3.0" offset:[0,0]
	
	on T4Rollout1 open do
	(
		lbl3.caption += szVersion as string
	)
	
)




--Create a rollout
rollout theRollout "Library Toolset" --height:400
(

	edittext ID "ID Name" pos:[26,40] width:100 height:20 enabled:true labelOnTop:true align:#left text:""
	-- format1
	dropdownList format1 "Format" pos:[130,40] width:100 height:40 items:#("3D Studio Max","FBX","OBJ") align:#left
	dropdownList scn1 "Scene version" pos:[235,40] width:70 height:40 enabled:true items:#("none", "2013", "2014", "2015","2016") align:#left 
	dropdownList render1 "Render" pos:[310,40] width:70 height:40 enabled:true items:#("none","VRay", "Corona", "Maxwell") align:#left
	edittext version1 "Version" pos:[386,40] width:34 height:20 enabled:true labelOnTop:true align:#left text:"01"
	button version1add "+" pos:[426,58] width:20 height:20 align:#left
	edittext fullname1 "Full name + ext" pos:[460,40] frame:false width:130 height:20 enabled:true labelOnTop:true align:#left readonly:true text:"_011801V01.max"
	
	-- format2
	checkbox chk2 "" pos:[110,85] height:20
	dropdownList format2 "" pos:[130,84] width:100 height:40 items:#("3D Studio Max","FBX","OBJ") align:#left enabled:false
	dropdownList scn2 "" pos:[235,84] width:70 height:40 enabled:false items:#("2013", "2014", "2015","2016") align:#left 
	dropdownList render2 "" pos:[310,84] width:70 height:40 enabled:false items:#("none","VRay", "Corona", "Maxwell") align:#left
	edittext fullname2 "" pos:[460,84] width:130 height:20 enabled:false labelOnTop:true align:#left readonly:true text:"0000_000000V01.ext"
	
	-- format3
	checkbox chk3 "" pos:[110,111] height:20
	dropdownList format3 "" pos:[130,110] width:100 height:40 items:#("3D Studio Max","FBX","OBJ") align:#left enabled:false
	dropdownList scn3 "" pos:[235,110] width:70 height:40 enabled:false items:#("2013", "2014", "2015","2016") align:#left
	dropdownList render3 "" pos:[310,110] width:70 height:40 enabled:false items:#("none","VRay", "Corona", "Maxwell") align:#left		
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
removeSubRollout theSubRollout T2Rollout2
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
T2Rollout1.height = 170
addSubRollout theSubRollout T2Rollout2
T2Rollout2.height = 95

)

2:
(
try
(
removeSubRollout theSubRollout T1Rollout1
removeSubRollout theSubRollout T1Rollout2
removeSubRollout theSubRollout T1Rollout3
removeSubRollout theSubRollout T2Rollout1
removeSubRollout theSubRollout T2Rollout2
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
removeSubRollout theSubRollout T2Rollout2
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
	
	
	global gFileFormat = #( 
			#("3D Studio Max", "max", "01"),
			#("FBX", "fbx", "02"),
			#("OBJ", "obj", "03")
	)
		
	global gMaxVersion = #(
		#("2011", "13"),
		#("2012", "14"),
		#("2013", "15"),
		#("2014", "16"),
		#("2015", "17"),
		#("2016", "18"),
		#("2017", "19"),
		#("2018", "20")
	)
	
	global gFbxVersion = #(
		#("2011", "13"),
		#("2012", "14"),
		#("2013", "15"),
		#("2014", "16"),
		#("2015", "17"),
		#("2016", "18"),
		#("2017", "19"),
		#("2018", "20")
	)
	
	global gRenderVersion = #(
		#("none", "00"),
		#("VRay", "01"),
		#("Corona", "02"),
		#("Maxwell", "03")
	)
	
	fn findAs a f = for i in a where i[1] == f do return i
	
	fn getControl p = for c in theRollout.controls where matchPattern c.name pattern:p do return c
		
	fn getModelFullName n:1 = 
	(
		n = n as string
		
		i = ID.text
				
		f = getControl ("format" + n)		
		f = f.selected
		f = findAs gFileFormat f
		
		s = getControl ("scn" + n)		
		s = s.selected
		s = findAs gMaxVersion s
		ss = s[2]
		
		if(f[1] == "OBJ") do ss = "00"
		
		r = getControl ("render" + n)
		r = r.selected
		r = findAs gRenderVersion r
		
		v = getControl ("version1")
		v = v.text
		
		return (i + "_" + f[3] + ss + r[2] + "V" + v + "." + f[2])
	)
	
	fn getModelParam n:1 = 
	(
		n = n as string
		
		i = ID.text
				
		f = getControl ("format" + n)		
		f = f.selected
		f = findAs gFileFormat f
		
		v = getControl ("scn" + n)		
		v = v.selected
				
		r = getControl ("render" + n)
		r = r.selected
		
		return #(i, tolower f[2], v, r) -- ID, format, version, render
	)
	
	fn displayModelName n:1 =
	(
		local f = getControl ("fullname" + n as string)		
		f.text = getModelFullName n:n
	)
	
	on theRollout open do
	(
		initTc tc
		
		fillSceneVersion scn1
		fillSceneVersion scn2
		fillSceneVersion scn3
		
		fillRender render1
		--fillRender render2
		--fillRender render3
		
		displayModelName n:1
		displayModelName n:2
		displayModelName n:3
		
		n = useSettings "SAVETO" "string" "r"
		r = FilterString n szGoodChars
		
		if(n != "" and n != undefined and r.count == 0) do szSaveToPath = n
			
		rootpath.text = szSaveToPath
		
		-- Add CoronaBitmap if Corona Renderer installed
		--if(findRenderer "corona") do append BitmapTypes CoronaBitmap
	)

	on ID changed a do
	(
		displayModelName n:1
		displayModelName n:2
		displayModelName n:3
		
		T1Rollout1.rnObjsPrevName.text = T1Rollout1.renamerObjects "obj" 1
		T1rollout2.rnMatsPrevName.text = T1rollout2.renamerMaterials "mat" 1
		T1rollout3.rnMapsPrevName.text = T1rollout3.renamerMaps "map" 1
		
		szModelID = ID.text
	)
	
	on format1 selected a do displayModelName n:1
	on scn1 selected a do displayModelName n:1
	on render1 selected a do displayModelName n:1
	on version1 changed t do 
	(
		szModelVerison = version1.text
		
		displayModelName n:1
		displayModelName n:2
		displayModelName n:3				
	)
	on version1add pressed do
	(
		v = (version1.text as integer) + 1
		
		version1.text = getNum v
		
		szModelVerison = version1.text
		
		displayModelName n:1
		displayModelName n:2
		displayModelName n:3
		
			
		T1Rollout1.rnObjsPrevName.text = T1Rollout1.renamerObjects "obj" 1
		T1rollout2.rnMatsPrevName.text = T1rollout2.renamerMaterials "mat" 1
		T1rollout3.rnMapsPrevName.text = T1rollout3.renamerMaps "map" 1
	)
	on format2 selected a do displayModelName n:2
	on scn2 selected a do displayModelName n:2
	on render2 selected a do displayModelName n:2
	on format3 selected a do displayModelName n:3
	on scn3 selected a do displayModelName n:3
	on render3 selected a do displayModelName n:3
		

	on chk2 changed s do
	(
		format2.enabled = s
		scn2.enabled = s
		render2.enabled = s		
		fullname2.enabled = s
	)
	
	on chk3 changed s do
	(
		format3.enabled = s
		scn3.enabled = s
		render3.enabled = s
		fullname3.enabled = s
	)
	
	-- Select path
	on btn14 pressed do
	(
		f = getSavePath  caption: "Select Path" initialDir: szSaveToPath
		
		if(f != undefined) do
		(
			p = FilterString f szGoodChars
			if(p.count > 0) do return messageBox "The paths are not supported by cyrillic characters!\nPlease choose another path!" title: "Warning!"
			
			szSaveToPath = f + @"\"
			rootpath.text = szSaveToPath
									
			useSettings "SAVETO" szSaveToPath "w"
		)
	)
	
	-- Save Models
	fn getDim s =
	(
		d = s.max - s.min
		
		d = for i in 1 to 3 collect ((d[i] * 100) as integer / 100.0 ) as string
		
		return d[1] + " x " + d[2] + " x " + d[3]
	)
	
	fn getCSV f v sel:geometry =
	(
		if(not isSelected()) do return false
		p = polyCount sel spaces: false
		modelParts = for i in sel where isGroupHead i == false collect i
		m = modelParts.count as string	
		r = getRender()
		u = (trimLeft (units.SystemType as string) "#")
		u[1] = toUpper u[1]
		d = (getDim sel)
		s = (round ((getFileSize f) / 1048576.0))  as string
		
		m = "\"" + v + "\"," + "\"" + u + "\"," + "\"" + d + "\"," + "\"" + p + "\"," + "\"" + m + "\"," + "\"" + r[2] + "\"," + "\"" + s + "\""
		
		return m
	)
	
	-- Fixed !!
	
	fn checkTexturesError =
	(
		errorTex = #()
		oldTex = #()
				
		for i in selection where i.material != undefined do
		(
			for type in BitmapTypes where classOf type == textureMap do
			(
				for b in getClassInstances type target:i where b != undefined do
				(				
					if(invalidBitmap b and findItem oldTex b == 0) then
					(										
						-- Fixed 03.04.2017 
						--append errorTex #("empty file name path! Map: " + b.name, i.name) 
						
						append oldTex b
					)
					else if (validBitmap b and doesFileExist (getFullPath (b.filename)) == false) then
					(
						append errorTex #(b.filename, i.name) 
					)
				)
			)
		)
		
		return errorTex
	)
	
	fn saveMtlLib p =
	(
		for i in 1 to currentMaterialLibrary.count do deleteItem currentMaterialLibrary 1
		for i in geometry where i.material != undefined do append currentMaterialLibrary i.material
		saveMaterialLibrary p
	)
	
	fn resizeImage f size_w: 500 quality: 60 =
	(
		p = getFilenamePath f
		n = getFilenameFile f
		
		b = openBitMap f 
		if(b == undefined) do return false
		i = getBitmapInfo b
		w = renderWidth = i[3]
		h = renderHeight = i[4]
		a = getRendImageAspect()
		
		if(w < size_w) do return false
		oq = JPEG.getQuality()
		JPEG.setQuality quality
		
		makeDir @"C:\temp\"
		tmp = @"C:\temp\tmp_preview_bitmap.jpg"

		size_h = if(w > h) then size_w / a else size_w * a
		
		nb = bitmap size_w size_h filename: tmp gamma: 0.2
		
		cnb = copy b nb
		save nb
		close cnb
		free cnb
		
		JPEG.setQuality oq
		
		deleteFile f
		copyFile tmp (p + n + ".jpg")
	)
	
	on SaveModels pressed do
	(
		fileToLoad = maxFilePath + maxFileName
		if(fileToLoad.count < 1) do return messageBox "Please save scene!" title: "Warning!"
		if(not isSelected()) do return false
		if(szModelID.count < 1) do return messageBox "Please indicate model ID Name!" title: "Warning!"
		
		-- Check for used groups
		grpErr = T2Rollout1.findGroup selection
		if(grpErr.count > 0) do 
		(	
			errGroupMsg = "Found exscess groups!\nPress \"Yes\" for auto rename groups to \"" + szModelID + "\"!\n\nFound groups:\n"
			for i in grpErr do errGroupMsg += i + "\n"
			q = queryBox errGroupMsg title: "Warning!"
			if(q == false) do return false
			
			T2Rollout1.autoRenameGroup selection			
		)
		
		szDir = szSaveToPath + szModelID + "\\"
		szMaps = szDir + "maps\\"
		szIES = szDir + "ies\\"
		szPreview = szDir + "pictures\\"
		szModels = szDir + "models\\"
			
			
		szScene[1] = theRollout.fullname1.text
		if(theRollout.fullname2.enabled) do szScene[2] = theRollout.fullname2.text
		if(theRollout.fullname3.enabled) do szScene[3] = theRollout.fullname3.text
		
		szZip = szSaveToPath + "Please wait, pack files.bat"
		szInfo = szDir + (getFileNameFile szScene[1]) + ".csv"
					
		makeDir szDir	
		makeDir szMaps	
		makeDir szIES
		makeDir szPreview	
		makeDir szModels
		
		-- Chek error textures
		errorTex = #()	
		errorTex = checkTexturesError()
		
		
		if (errorTex.count > 0) do
		(
			m = "[" + localTime + "] : Error! Not found next textures. Please fix model and try again.\n\n"
			
			for er in errorTex do m += "Object: " + er[2] + "\nTexture: " + er[1] + "\n\n"
			
			messageBox m title: "Error!"
			
			return false
		)
		
		-- Preview
		iPreview = 0
		for i in szPreviewPath do
		(
			p = getFilenameType i 
			if(doesFileExist i) do 
			(
				iPreview += 1
				iterator = if(iPreview == 1) then "" else iPreview as string + "_"
				nn = szPreview + iterator + szModelID + p
				copyFile i nn
				resizeImage nn
			)
		)
		
		currentRender = renderers.current

		T1Rollout3.startRenameAndCopyMaps szMaps
		
		T1Rollout3.startRenameAndCopyIES szIES
		
		if(T1Rollout3.chk3.checked == true) do 
		(
			T1Rollout3.libAssetsPath szMaps
		)
				
		-- Add Versions
		saveNodes selection (szModels + "_tmp.max") quiet:true
		resetMaxFile #noPrompt
		mergeMAXFile (szModels + "_tmp.max") #select #mergedups #renameMtlDups #noRedraw quiet:true			
		deleteFile (szModels + "_tmp.max")
		
		try(renderers.current = currentRender)catch()
		
		select objects
		
		T1Rollout1.startRenameObjects()
		T1Rollout2.startRenameMaterials()
		
		T1Rollout1.replaceNormal()
		T1Rollout1.replaceColorCorrect()
			
		-- Remove layers
		if(T1Rollout1.chk1.checked == true) do 
		(
			layer0 = LayerManager.getLayer 0
			for i in objects do layer0.addNode i
		)
			
		savedMax = #()
		-- Fix selection in 3Ds Max 2016		
		for ii in 1 to szScene.count do 
		(
			p = theRollout.getModelParam n:ii
			
			case p[2] of
			(
				"max":
				(
					f = (szModels + szScene[ii])					
					v = getMaxVersion()
					
					if(p[3] != v[v.count]) then
					(
						saveNodes objects f saveAsVersion:(p[3] as integer) quiet:true
					)
					else
					(
						saveNodes objects f quiet:true
					)
					
					savedMax[1] = f				
					savedMax[2] = p[3]
				)
				default: 
				(
					f = (szModels + szScene[ii]) 
					FBXExporterSetParam "FileVersion" "FBX201200"	-- Warning!! This option important!!
					exportFile f #noPrompt  --selectedOnly:true
				)				
			)
		)
				
		
		if(savedMax[1] != undefined) do
		(
			l = getCSV savedMax[1]	savedMax[2]		
			if(theRollout.chk5.checked == true) do writeFile szInfo l
		)
		
		resetMaxFile #noPrompt
		loadMaxFile fileToLoad useFileUnits: true quiet:true
		
		successMessage = "Model " + szModelID + " prepared!\n\nPress OK for open directory with model." 
		q = queryBox successMessage beep: false title: "Success!"
			
		if(q) do shellLaunch szDir ""	
	)
)
createDialog theRollout 610 700

/* UI code END */