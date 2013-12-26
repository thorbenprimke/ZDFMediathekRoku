Function preShowSendungVerpasstScreen() As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(port)
    return screen
End Function

Function showSendungVerpasstScreen(screen) As Integer
    rowTitles = CreateObject("roArray", 10, true)
    for j = 0 to 10
        rowTitles.Push("[Row Title " + j.toStr() + " ] ")
    end for
    screen.SetupLists(rowTitles.Count())
    screen.SetListNames(rowTitles)
    for j = 0 to 10
        list = CreateObject("roArray", 10, true)
        for i = 0 to 10
             o = CreateObject("roAssociativeArray")
             o.ContentType = "episode"
             o.Title = "[Title" + i.toStr() + "]"
             o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
             o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
             o.Description = ""
             o.Description = "[Description] "
             o.Rating = "NR"
             o.StarRating = "75"
             o.ReleaseDate = "[<mm/dd/yyyy]"
             o.Length = 5400
             o.Actors = []
             o.Actors.Push("[Actor1]")
             o.Actors.Push("[Actor2]")
             o.Actors.Push("[Actor3]")
             o.Director = "[Director]"
             list.Push(o)
         end for
         screen.SetContentList(j, list)
     end for
     conn = InitCategoryFeedConnection()
     data = conn.LoadCategoryFeed(conn)
     screen.SetContentList(0, data)

     screen.Show()
     while true
         msg = wait(0, screen.GetMessagePort())
         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 return -1
             elseif msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
             elseif msg.isListItemSelected()
                 print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
                 displayShowDetailScreenShow(data[msg.getData()])
                 
             endif
         endif
     end while
End Function

Function displayShowDetailScreenShow(show as Object) As Integer

    if validateParam(show, "roAssociativeArray", "displayShowDetailScreenShow") = false return -1

    show = GetZDFShowData(show)
    
    screen = preShowDetailScreen(show.Title, show.Title)
    showIndex = showDetailScreen(screen, show, 1)

    return showIndex
End Function


