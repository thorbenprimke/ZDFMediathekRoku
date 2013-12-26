Function preShowSendungVerpasstScreen() As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(port)
    screen.setGridStyle("flat-16x9")
    return screen
End Function

Function showSendungVerpasstScreen(screen As Object, day As Object) As Integer
     rowDesc = [ "Morgens (5:30 - 12:00)", "Mittags (12:00 - 19:00)", "Abends (19:00 - 00:00)", "Nachts (00:00 - 05:30)"]
     rowTitles = [ "morgens", "mittags", "abends", "nachts"]
     screen.SetupLists(rowDesc.Count())
     screen.SetListNames(rowDesc)
     data = ParseZDFDay(day)


     index = 0
     for each item in data
        screen.SetContentList(index, data[index])
        screen.SetFocusedListItem(index, 0)
        index = index + 1
     end for
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
                 displayShowDetailScreenShow(data[msg.getIndex()][msg.getData()])
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


