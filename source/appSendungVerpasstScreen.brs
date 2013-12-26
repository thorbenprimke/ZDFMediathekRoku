
'************************************************
' Sets up the Sendung Verpasst screen. This
' screen lists all the content for a day. It uses
' a grid to split up the content by time of the
' day.
'************************************************
Function preShowSendungVerpasstScreen() As Object
    m.rowDescs = [ "Morgens (5:30 - 12:00)", "Mittags (12:00 - 19:00)", "Abends (19:00 - 00:00)", "Nachts (00:00 - 05:30)"]
    
    port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(port)
    screen.setGridStyle("flat-16x9")
    
    screen.SetupLists(m.rowDescs.Count())
    screen.SetListNames(m.rowDescs)
    
    return screen
End Function

'************************************************
' Shows the 'Sending Verpasst' screen. Fetches
' the content for the day and sets up the rows.
'************************************************
Function showSendungVerpasstScreen(screen As Object, day As Object) As Integer
     data = ParseZDFDay(day)

     ' Set up all the data for each row
     for i = 0 to (m.rowDescs.Count() - 1)
        screen.SetContentList(i, data[i])
        if data[i].Count() = 0 then
            screen.SetListVisible(i, false)
        else
            screen.SetListVisible(i, true)
            screen.SetFocusedListItem(i, 0)
        end if
     end for
     ' Always set the focus to the ' Mittags' section
     screen.SetFocusedListItem(1, 0)

    ' Show the screen and go into event mode
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
