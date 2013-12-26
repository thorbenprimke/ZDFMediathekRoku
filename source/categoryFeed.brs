'******************************************************
'**  Video Player Example Application -- Category Feed 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'******************************************************

'******************************************************
' Set up the category feed connection object
' This feed provides details about top level categories 
'******************************************************
Function InitCategoryFeedConnection() As Object

    conn = CreateObject("roAssociativeArray")

    conn.UrlPrefix   = "http://rokudev.roku.com/rokudev/examples/videoplayer/xml"
    conn.UrlCategoryFeed = conn.UrlPrefix + "/categories.xml"
    
    conn.UrlZDF = "http://www.zdf.de/ZDFmediathek/xmlservice/web/sendungVerpasst?startdate=241213&maxLength=50&enddate=241213"

    conn.Timer = CreateObject("roTimespan")

    conn.LoadCategoryFeed    = load_category_feed
    conn.GetCategoryNames    = get_category_names

    print "created feed connection for " + conn.UrlCategoryFeed
    return conn

End Function

'*********************************************************
'** Create an array of names representing the children
'** for the current list of categories. This is useful
'** for filling in the filter banner with the names of
'** all the categories at the next level in the hierarchy
'*********************************************************
Function get_category_names(categories As Object) As Dynamic

    categoryNames = CreateObject("roArray", 100, true)

    for each category in categories.kids
        'print category.Title
        categoryNames.Push(category.Title)
    next

    return categoryNames

End Function


'******************************************************************
'** Given a connection object for a category feed, fetch,
'** parse and build the tree for the feed.  the results are
'** stored hierarchically with parent/child relationships
'** with a single default node named Root at the root of the tree
'******************************************************************
Function load_category_feed(conn As Object) As Dynamic

    http = NewHttp(conn.UrlCategoryFeed)

    Dbg("url: ", http.Http.GetUrl())

    m.Timer.Mark()
    rsp = http.GetToStringWithRetry()
    Dbg("Took: ", m.Timer)

    m.Timer.Mark()
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         print "Can't parse feed"
        return invalid
    endif
    Dbg("Parse Took: ", m.Timer)

    m.Timer.Mark()
    if xml.category = invalid then
        print "no categories tag"
        return invalid
    endif

    if islist(xml.category) = false then
        print "invalid feed body"
        return invalid
    endif

    if xml.category[0].GetName() <> "category" then
        print "no initial category tag"
        return invalid
    endif

    topNode = MakeEmptyCatNode()
    topNode.Title = "root"
    topNode.isapphome = true

    print "begin category node parsing"

    categories = xml.GetChildElements()
    print "number of categories: " + itostr(categories.Count())
    for each e in categories 
        o = ParseCategoryNode(e)
        if o <> invalid then
            topNode.AddKid(o)
            print "added new child node"
        else
            print "parse returned no child node"
        endif
    next
    Dbg("Traversing: ", m.Timer)

    return ParseZDFDay(conn)

    return topNode

End Function

'******************************************************
'MakeEmptyCatNode - use to create top node in the tree
'******************************************************
Function MakeEmptyCatNode() As Object
    return init_category_item()
End Function

Function GetZDFShowData(show As Object) As Dynamic


    showUrl = "http://www.zdf.de/ZDFmediathek/xmlservice/web/beitragsDetails?ak=web&id=" + show.AssetId

    http = NewHttp(showUrl)

    Dbg("url: ", http.Http.GetUrl())

'    conn.Timer.Mark()
    rsp = http.GetToStringWithRetry()
   ' Dbg("Took: ", conn.Timer)

 '   conn.Timer.Mark()
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         print "Can't parse feed"
        return invalid
    endif
  '  Dbg("Parse Took: ", conn.Timer)
    
    print xml.GetName()
    level1 = xml.GetChildElements()
    
    print level1[1].getName()
    teaserRoot = level1[1].GetChildElements()
    'teaserList = teaserRoot[1].GetChildElements()

    o = init_category_item()
    o.ContentType = "episode"
    o.Rating = "NR"
    o.StarRating = "75"
    o.StreamBitrates = [0]
    o.StreamQualities = ["HD"]
    o.StreamFormat = "mp4"
    o.minBandwidth = 20 
    
    for each video in level1[1].getChildElements()
        if video.getName() = "information"
            items = video.GetChildElements()
            for each item in items
                if item.getName() = "title"
                    o.Title = item.getBody()
                    o.ShortDescriptionLine1 = item.getBody()
                    print item.getBody()
                endif
                if item.getName() = "detail"
                    o.Description = item.getBody()
                    o.ShortDescriptionLine2 = item.getBody()
                endif                    
            next
        endif
        if video.getName() = "teaserimages"
            items = video.GetChildElements()
            for each item in items
                attrs = item.GetAttributes()
                for each attr in attrs
                    if attr = "key" and item.GetAttributes()[attr] = "72x54"
                        o.SDPosterURL = item.getBody()
                    endif
                    if attr = "key" and item.GetAttributes()[attr] = "485x273"
                        o.HDPosterURL = item.getBody()
                    endif
                next
            next                
        endif
        if video.getName() = "details"
            items = video.GetChildElements()
            for each item in items
                if item.getName() = "assetId"
                    o.AssetId = item.getBody()
                    print item.getBody()
                endif
                if item.getName() = "airtime"
                    o.Description = item.getBody()
                    o.ShortDescriptionLine2 = item.getBody()
                endif
            next
        endif
        if video.getName() = "formitaeten"
            items = video.GetChildElements()
            for each item in items
                attrs = item.GetAttributes()
                for each attr in attrs
                    if attr = "basetype" and item.GetAttributes()[attr] = "h264_aac_mp4_http_na_na"
                        formatItems = item.GetChildElements()
                        quality = "NA"
                        ratio = "NA"
                        facet = "NA"
                        videoUrl = "NA"
                        for each formatItem in formatItems
                            if formatItem.getName() = "quality"
                                quality = formatItem.getBody()
                            endif
                            if formatItem.getName() = "ratio"
                                ratio = formatItem.getBody()
                            endif
                            if formatItem.getName() = "facets"
                                facet = formatItem.GetChildElements()[0].getBody()
                            endif
                            if formatItem.getName() = "url"
                                videoUrl = formatItem.getBody()
                            endif
                        next
                        
                        print videoUrl
                        if quality = "veryhigh" and ratio = "16:9" and facet = "progressive"
                            o.StreamUrls = [videoUrl]
                        endif
                        print o.StreamUrls
                    endif
                next
            next                

        endif
                
        
    next
    
    
    
    return o


End Function

Function ParseZDFDay(day As Object) As Dynamic
    print "ZDF parsing"
    

    date = day.RequestDate
    print "Request for day: " + date
    dayUrl = "http://www.zdf.de/ZDFmediathek/xmlservice/web/sendungVerpasst?startdate=" + date + "&maxLength=50&enddate=" + date
    http = NewHttp(dayUrl)

    Dbg("url: ", http.Http.GetUrl())

'    conn.Timer.Mark()
    rsp = http.GetToStringWithRetry()
 '   Dbg("Took: ", conn.Timer)

  '  conn.Timer.Mark()
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         print "Can't parse feed"
        return invalid
    endif
   ' Dbg("Parse Took: ", conn.Timer)
    

    'topNode = MakeEmptyCatNode()
    'topNode.Title = "root"
    'topNode.isapphome = true
    topNode = CreateObject("roArray", 4, true)
    topNode[0] = CreateObject("roArray", 10, true)
    topNode[1] = CreateObject("roArray", 10, true)
    topNode[2] = CreateObject("roArray", 10, true)
    topNode[3] = CreateObject("roArray", 10, true)
    
    print xml.GetName()
    level1 = xml.GetChildElements()
    
    print level1[1].getName()
    teaserRoot = level1[1].GetChildElements()
    teaserList = teaserRoot[1].GetChildElements()
    
    for each teaser in teaserList
        properties = teaser.GetChildElements()
        o = init_category_item()
        o.Type = "normal"
        for each property in properties
            print property.getName()
            if property.getName() = "information"
                items = property.GetChildElements()
                for each item in items
                    if item.getName() = "title"
                        o.Title = item.getBody()
                        o.ShortDescriptionLine1 = item.getBody()
                        print item.getBody()
                    endif
                    if item.getName() = "detail"
                      '  o.Description = item.getBody()
                       ' o.ShortDescriptionLine2 = item.getBody()
                    endif                    
                next
            endif
            if property.getName() = "teaserimages"
                items = property.GetChildElements()
                for each item in items
                    attrs = item.GetAttributes()
                    for each attr in attrs
                        if attr = "key" and item.GetAttributes()[attr] = "144x81"
                            o.SDPosterURL = item.getBody()
                        endif
                        if attr = "key" and item.GetAttributes()[attr] = "236x133"
                            o.HDPosterURL = item.getBody()
                        endif
                    next
                next                
            endif
            if property.getName() = "details"
                items = property.GetChildElements()
                for each item in items
                    if item.getName() = "assetId"
                        o.AssetId = item.getBody()
                        print item.getBody()
                    endif
                if item.getName() = "airtime"
                    o.Description = item.getBody()
                    o.ShortDescriptionLine2 = item.getBody()
                endif
                next
            endif
            
        next
        print "adding item"
'        teaser.getAttributes()["member"]
        topNode[timeOfDayToIndex(teaser.getAttributes()["member"])].Push(o)  
 '       topNode.Push(o)
    next
    
    print "ZDF parsing done"
    return topNode
End Function
    
Function timeOfDayToIndex(time As String) As Integer
    if time = "morgens" then
        return 0
    elseif time = "mittags" then
        return 1
    elseif time = "abends" then
        return 2
    else
        return 3
    end if
End Function    


'***********************************************************
'Given the xml element to an <Category> tag in the category
'feed, walk it and return the top level node to its tree
'***********************************************************
Function ParseCategoryNode(xml As Object) As dynamic
    o = init_category_item()

    print "ParseCategoryNode: " + xml.GetName()
    'PrintXML(xml, 5)

    'parse the curent node to determine the type. everything except
    'special categories are considered normal, others have unique types 
    if xml.GetName() = "category" then
        print "category: " + xml@title + " | " + xml@description
        o.Type = "normal"
        o.Title = xml@title
        o.Description = xml@Description
        o.ShortDescriptionLine1 = xml@Title
        o.ShortDescriptionLine2 = xml@Description
        'o.SDPosterURL = xml@sd_img
        'o.HDPosterURL = xml@hd_img
    elseif xml.GetName() = "categoryLeaf" then
        o.Type = "normal"
    elseif xml.GetName() = "specialCategory" then
        if invalid <> xml.GetAttributes() then
            for each a in xml.GetAttributes()
                if a = "type" then
                    o.Type = xml.GetAttributes()[a]
                    print "specialCategory: " + xml@type + "|" + xml@title + " | " + xml@description
                    o.Title = xml@title
                    o.Description = xml@Description
                    o.ShortDescriptionLine1 = xml@Title
                    o.ShortDescriptionLine2 = xml@Description
                    o.SDPosterURL = xml@sd_img
                    o.HDPosterURL = xml@hd_img
                endif
            next
        endif
    else
        print "ParseCategoryNode skip: " + xml.GetName()
        return invalid
    endif

    'only continue processing if we are dealing with a known type
    'if new types are supported, make sure to add them to the list
    'and parse them correctly further downstream in the parser 
    while true
        if o.Type = "normal" exit while
        if o.Type = "special_category" exit while
        print "ParseCategoryNode unrecognized feed type"
        return invalid
    end while 

    'get the list of child nodes and recursed
    'through everything under the current node
    for each e in xml.GetBody()
        name = e.GetName()
        if name = "category" then
            print "category: " + e@title + " [" + e@description + "]"
            kid = ParseCategoryNode(e)
            kid.Title = e@title
            kid.Description = e@Description
            kid.ShortDescriptionLine1 = xml@Description
            'kid.SDPosterURL = xml@sd_img
            'kid.HDPosterURL = xml@hd_img
            o.AddKid(kid)
        elseif name = "categoryLeaf" then
            print "categoryLeaf: " + e@title + " [" + e@description + "]"
            kid = ParseCategoryNode(e)
            kid.Title = e@title
            kid.Description = e@Description
            kid.Feed = e@feed
            o.AddKid(kid)
        elseif name = "specialCategory" then
            print "specialCategory: " + e@title + " [" + e@description + "]"
            kid = ParseCategoryNode(e)
            kid.Title = e@title
            kid.Description = e@Description
            kid.sd_img = e@sd_img
            kid.hd_img = e@hd_img
            kid.Feed = e@feed
            o.AddKid(kid)
        endif
    next

    return o
End Function


'******************************************************
'Initialize a Category Item
'******************************************************
Function init_category_item() As Object
    o = CreateObject("roAssociativeArray")
    o.Title       = "dummy"
    o.Type        = "normal"
    o.Description = "dummy desc"
    o.Kids        = CreateObject("roArray", 100, true)
    o.Parent      = invalid
    o.Feed        = ""
    o.IsLeaf      = cn_is_leaf
    o.AddKid      = cn_add_kid
    o.SDPosterUrl = "file://pkg:/artwork/AlGore.jpg"
    o.HDPosterUrl = "file://pkg:/artwork/AlGore.jpg"
    return o
End Function


'********************************************************
'** Helper function for each node, returns true/false
'** indicating that this node is a leaf node in the tree
'********************************************************
Function cn_is_leaf() As Boolean
    if m.Kids.Count() > 0 return true
    if m.Feed <> "" return false
    return true
End Function


'*********************************************************
'** Helper function for each node in the tree to add a 
'** new node as a child to this node.
'*********************************************************
Sub cn_add_kid(kid As Object)
    if kid = invalid then
        print "skipping: attempt to add invalid kid failed"
        return
     endif
    
    kid.Parent = m
    m.Kids.Push(kid)
End Sub
