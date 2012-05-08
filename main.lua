--[[
A sample code to access the Goggle Docs Spreadsheet JSON data

There is no user interface for this code.
The JSON result would be dumped onto the console
You should further process the data using Corona JSON library

Vito Limandibhrata
2012 Krygen Technologies Pte Ltd
www.krygen.com
]]--

-- An array to global variables and functions
local V ={}

-- Store Google Authorization Token
V.auth=""

-- A status to indicate whether the code is in the process to login or to download the JSON data
V.status=1

-- A function to control the sequence of steps
local function nextStep()
	print("nextStep")
	if (V.status==1) then
		V.status=2
		V.getWorksheets()
	end
end
V.nextStep = nextStep

-- Callback function
local function networkListener( event )
        if ( event.isError ) then
                print( "Network error!")
        else
                print ( "RESPONSE: " .. event.response )
                
                -- status = 1 means the code is in the process to login
                -- need to extract the Authorization token
                if (V.status==1) then
					for k, v in string.gmatch(event.response, "(.+)Auth=(.+)") do
       					V.auth=v
       					V.auth=string.sub(V.auth,1,string.len(V.auth)-1)
					end
					
					print("AUTH:"..V.auth.."|")
					V.nextStep()
					
                end
                
        end
end
V.networkListener = networkListener



local function getWorksheets()
	print("WORKSHEET")
	local postData = "Auth="..V.auth
	
	headers = {}
 
 	-- Authorization header to pass the Authorization token to Google Server
	headers["Authorization"] = "GoogleLogin auth="..V.auth
	
	print("GoogleLogin auth="..V.auth)
 
	local params = {}
	params.headers = headers

	--Replace the following information
	--SPREADSHEET.KEY.ID -> the unique key of your spreadsheet
	--WORKSHEET.ID -> the worksheet id within a spreadsheet 
 	network.request( "https://spreadsheets.google.com/feeds/list/SPREADSHEET.KEY.ID/WORKSHEET.ID/private/full?alt=json", "GET", V.networkListener, params)

end 
V.getWorksheets = getWorksheets



local function login()
print("LOGIN")
	--Replace the following information
	--YOUR.EMAIL -> your own Google Account Email
	--YOUR.PASSWORD -> your own Google Account Password
	--Krygen-GData-Demo-1.0 -> to any string to identify the source of the call
	local postData = "accountType=GOOGLE&Email=YOUR.EMAIL&Passwd=YOUR.PASSWORD&service=wise&source=Krygen-GData-Demo-1.0"
 
	local params = {}
	params.body = postData
 
	network.request( "https://www.google.com/accounts/ClientLogin", "POST", V.networkListener, params)
end


if (V.status==1) then
	login()
end
