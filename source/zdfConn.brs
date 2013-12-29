'**********************************************************
'**  ZDF Mediathek - Connection / data loading class
'**********************************************************

'**********************************************************
' Initializes the ZDF connection object. 
'**********************************************************
Function InitZDFConnection() As Object
    ' Everything to be stored for the connection
    conn = CreateObject("roAssociativeArray")

    ' Set up the urls
    conn.UrlPrefix = "http://www.zdf.de/ZDFmediathek/xmlservice/web/"
    conn.UrlSendungVerpasst = conn.UrlPrefix + "sendungVerpasst?maxLength=50"
    conn.UrlSendungVerpasstStart = "&startdate="
    conn.UrlSendungVerpasstEnd = "&enddate="

    ' Add timer and regex objects    
    conn.Timer = CreateObject("roTimespan")
    conn.WhiteSpaceSplitter = CreateObject("roRegex", " ", "")
    
    ' Set up the functions
    conn.LoadSendungVerpasstDataForDay = load_sendung_verpasst_data_for_day

    return conn
End Function

'**********************************************************
' Loads and parses the data for a specific day via the
' sendungVerpasst api request and extracts the data needed
' for the SendungVerpasstScreen.
'**********************************************************
Function load_sendung_verpasst_data_for_day(conn As Object, day As Object, dayTimePeriods As Integer, mapDayTimePeriodToRowIndex As Function) As Dynamic
    
    date = day.RequestDate
    dayUrlStart = conn.UrlSendungVerpasstStart + date
    dayUrlEnd = conn.UrlSendungVerpasstEnd + date
    dayUrl = conn.UrlSendungVerpasst + dayUrlStart + dayUrlEnd
    http = NewHttp(dayUrl)

    Dbg("url: ", http.Http.GetUrl())

    conn.Timer.Mark()
    rsp = http.GetToStringWithRetry()
    Dbg("Took: ", conn.Timer)

    conn.Timer.Mark()
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         print "Can't parse feed"
        return invalid
    endif
    Dbg("Parse Took: ", conn.Timer)
    
    dayContentData = CreateObject("roArray", dayTimePeriods, true)
    for i = 0 to dayTimePeriods - 1
        dayContentData[i] = CreateObject("roArray", 10, true)
    end for

    conn.Timer.Mark()
    ' Go through each teaser (content) element in the list    
    for each teaser in xml.teaserlist.teasers.teaser
        properties = teaser.GetChildElements()
        o = init_category_item()
        o.Type = "normal"

        info = teaser.information
        details = teaser.details

        airDateTime = details.airtime.getText()
        airTime = conn.WhiteSpaceSplitter.Split(airDateTime)

        o.Title = airTime[1] + " - " + details.originChannelTitle.getText() + " - " + info.title.getText()
        o.Description = info.detail.getText()
        o.AssetId = details.assetId.getText()
        
        for each teaserimage in teaser.teaserimages.teaserimage
            if teaserimage@key = "144x81" then
                o.SDPosterURL = teaserimage.getText()
            else if teaserimage@key = "236x133" then
                o.HDPosterURL = teaserimage.getText()
            end if
        end for

        index = mapDayTimePeriodToRowIndex(teaser@member)
        if index <> -1 then
            dayContentData[index].Push(o)  
        end if
    end for
    Dbg("Data Parse Took: ", conn.Timer)
    return dayContentData
End Function

