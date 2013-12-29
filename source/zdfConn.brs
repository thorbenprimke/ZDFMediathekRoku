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
    conn.UrlBeitragDetails = conn.UrlPrefix + "beitragsDetails?ak=web&id="

    ' Add timer and regex objects    
    conn.Timer = CreateObject("roTimespan")
    conn.WhiteSpaceSplitter = CreateObject("roRegex", " ", "")
    
    ' Set up the functions
    conn.LoadSendungVerpasstDataForDay = load_sendung_verpasst_data_for_day
    conn.LoadContentDataByAssetId = load_content_data_by_asset_id

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
        o = CreateObject("roAssociativeArray")
        o.Type = "normal"

        info = teaser.information
        details = teaser.details

        airDateTime = details.airtime.getText()
        airTime = conn.WhiteSpaceSplitter.Split(airDateTime)

        o.Title = airTime[1] + " - " + details.originChannelTitle.getText() + " - " + info.title.getText()
        o.Description = info.detail.getText()
        o.AssetId = details.assetId.getText()
        
        findAndSetPosterUrls(o, teaser.teaserimages.teaserimage)

        index = mapDayTimePeriodToRowIndex(teaser@member)
        if index <> -1 then
            dayContentData[index].Push(o)  
        end if
    end for
    Dbg("Data Parse Took: ", conn.Timer)
    return dayContentData
End Function

'**********************************************************
' Loads and parses the detailed data for a content item.
' It uses the assetId to request a specific content.
'**********************************************************
Function load_content_data_by_asset_id(conn As Object, show As Object) As Dynamic

    http = NewHttp(conn.UrlBeitragDetails + show.AssetId)
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
    

    conn.Timer.Mark()
    o = CreateObject("roAssociativeArray")
    o.ContentType = "episode"
    o.Rating = "NR"
    o.StarRating = "75"
    o.StreamBitrates = [0]
    o.StreamQualities = ["HD"]
    o.StreamFormat = "mp4"
    o.minBandwidth = 20 
    
    info = xml.video.information
    details = xml.video.details
    
    o.Title = details.originChannelTitle.getText() + " - " + info.title.getText()
    o.Description = info.detail.getText()
    
    o.AssetId = details.assetId.getText()
    
    findAndSetPosterUrls(o, xml.video.teaserimages.teaserimage)
  
    lengthText = details.length.getText()  
    lengthTexts = conn.WhiteSpaceSplitter.Split(lengthText)
    o.Length =  lengthTexts[0].toint() * 60
    
    if details.hasCaption.getText() = "true"
        o.SubtitleUrl = xml.video.caption.url.getText()
    end if
    
    for each formitaet in xml.video.formitaeten.formitaet
        if formitaet@basetype = "h264_aac_mp4_http_na_na"
            quality = formitaet.quality.getText()
            ratio = formitaet.ratio.getText()
            facet = formitaet.facets.facet[0].getText()
            videoUrl = formitaet.url.getText()
            if quality = "veryhigh" and ratio = "16:9" and facet = "progressive"
                o.StreamUrls = [videoUrl]
            endif
        endif 
    end for
    Dbg("Data Parse Took: ", conn.Timer)
    return o
End Function

'**********************************************************
' Helper function for finding and setting the *PostUrls.
'**********************************************************
Function findAndSetPosterUrls(content As Object, teaserImages As Object) 
    for each teaserimage in teaserImages
        if teaserimage@key = "144x81" then
            content.SDPosterURL = teaserimage.getText()
        else if teaserimage@key = "236x133" then
            content.HDPosterURL = teaserimage.getText()
        end if
    end for
End Function


