Function preShowSendungVerpasstScreen() As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(port)
    screen.setGridStyle("flat-16x9")
    return screen
End Function

Function showSendungVerpasstScreen(screen) As Integer
     rowDesc = [ "Morgens (5:30 - 12:00)", "Mittags (12:00 - 19:00)", "Abends (19:00 - 00:00)", "Nachts (00:00 - 05:30)"]
     rowTitles = [ "morgens", "mittags", "abends", "nachts"]
     screen.SetupLists(rowDesc.Count())
     screen.SetListNames(rowDesc)
     conn = InitCategoryFeedConnection()
     data = conn.LoadCategoryFeed(conn)

     index = 0
     for each item in data
         For i=0 To rowTitles.Count() Step 1
            if rowTitles[i] = item
                screen.SetContentList(i, data[item])
            endif
            print i
        End For
     end for
     screen.SetFocusedListItem(3, 0)
     screen.SetFocusedListItem(2, 0)
     screen.SetFocusedListItem(1, 0)
     screen.SetFocusedListItem(0, 0)
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


