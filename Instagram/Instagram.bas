B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.2
@EndOfDesignText@
Sub Class_Globals
	Dim App As AWTRIX
	
	Dim followers As String = "-"
	Dim lastShowedFollowers As Int = 0
	Dim actualFollowers As Int = 0
End Sub

' Config your App
Public Sub Initialize() As String
	
	App.Initialize(Me,"App")
	
	'App name (must be unique, avoid spaces)
	App.Name="Instagram"
	
	'Version of the App
	App.Version="1.0.0"
	
	'Description of the App. You can use HTML to format it
	App.Description="Shows your Instagram Business followers count."
		
	'SetupInstructions. You can use HTML to format it
	App.setupDescription= $"
	<b>Profilename:</b>  As the name implies, your twitter profile name.
	"$
	
	App.Author="mapacheverdugo"
	
	App.CoverIcon=58
	
	'How many downloadhandlers should be generated
	App.downloads=1
	
	'IconIDs from AWTRIXER. You can add multiple if you want to display them at the same time
	App.Icons=Array As Int(58)
	
	'Tickinterval in ms (should be 65 by default, for smooth scrolling))
	App.Tick=65
		
	'needed Settings for this App (Wich can be configurate from user via webinterface)
	App.Settings=CreateMap("AccountID":"","Token":"")
	
	App.MakeSettings
	Return "AWTRIX20"
End Sub

' ignore
public Sub GetNiceName() As String
	Return App.Name
End Sub

' ignore
public Sub Run(Tag As String, Params As Map) As Object
	Return App.interface(Tag,Params)
End Sub


'Called with every update from Awtrix
'return one URL for each downloadhandler
Sub App_startDownload(jobNr As Int)
	Select jobNr
		Case 1
			App.Download("https://graph.facebook.com/v13.0/"&App.Get("AccountID")&"?fields=followed_by_count&access_token="&App.Get("Token")$)
	End Select
End Sub

'process the response from each download handler
'if youre working with JSONs you can use this online parser
'to generate the code automaticly
'https://json.blueforcer.de/ 
Sub App_evalJobResponse(Resp As JobResponse)
	Try
		If Resp.success Then
			Select Resp.jobNr
				Case 1
					Try
						Dim parser As JSONParser
						parser.Initialize(Resp.ResponseString)
						Dim root As Map = parser.NextObject
						followers = root.Get("followed_by_count")
						actualFollowers = root.Get("followed_by_count").As(Int)
						If actualFollowers <> 0 And lastShowedFollowers = 0 Then
							'is the first time
							lastShowedFollowers = root.Get("followed_by_count").As(Int)
						End If
					Catch
						Log("Error in: "& App.Name & CRLF & LastException)
						Log("API response: "& CRLF & Resp.ResponseString)
					End Try
			End Select
		End If
	Catch
		Log("Error in: "& App.name & CRLF & LastException)
		Log("API response: " & CRLF & Resp.ResponseString)
	End Try
End Sub


'is called every tick, generates the commandlist (drawingroutines) and send it to awtrix
Sub App_genFrame
	Dim followersDiff As Int = actualFollowers - lastShowedFollowers
	If followersDiff <> 0 And (DateTime.Now < App.startedAt + (App.duration * 1000 / 4)) Then
		Dim symbol As String = "-"
		If followersDiff > 0 Then
			symbol = "+"
		End If
			
		App.genText("" & symbol & followersDiff, True, 1, Null, True)
		App.drawBMP(0, 0, App.getIcon(58), 8, 8)
	Else
		App.genText(followers, True, 1, Null, True)
		App.drawBMP(0, 0, App.getIcon(58), 8, 8)
	End If
	
End Sub

Sub App_Exited
	lastShowedFollowers = actualFollowers
End Sub