'**********************************************************
'**  ZDF Mediathek - Sendung Verpasst day screen. It lists
'**  all content for a single day split up by time periods.
'**********************************************************

'**********************************************************
' Sets up the Sendung Verpasst day screen. This  screen 
' lists all the content for a day. It uses  a grid to split
' up the content by time of the day.
'**********************************************************
Function preShowSendungVerpasstDayScreen() As Object
    if m.conn = invalid then
        m.conn = InitZDFConnection()
    end if
    port = CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(port)
    screen.setGridStyle("flat-16x9")
    screen.SetBreadcrumbEnabled(true)
    initListRows(screen)    
    return screen
End Function

'**********************************************************
' Shows the 'Sending Verpasst' day screen. Fetches the content
' for the day and sets up the rows.
'**********************************************************
Function showSendungVerpasstDayScreen(screen As Object, day As Object) As Integer
    setupListData(screen, day)
    ' Always set the focus to the ' Mittags' section
    screen.SetFocusedListItem(1, 0)
    ' Sets the breadcrumb information to indicate for which day the content is
    screen.SetBreadcrumbText("Sendung Verpasst", day.breadcrumbDate)
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
                displayShowDetailScreenShow(m.data[msg.getIndex()][msg.getData()])
            endif
        endif
    end while
End Function

'**********************************************************
'**  The methods below are only intended to be used      **
'**  within this screen file.                            **
'**********************************************************

'**********************************************************
' Initializes the rowDescriptions
'**********************************************************
Function initListRows(screen As Object)
    ' If another item is added to this array, the function
    ' convertDayTimePeriodToIndex needs to be updated as
    ' well.
    m.rowDescs = [ 
        "Morgens (5:30 - 12:00)",
        "Mittags (12:00 - 19:00)",
        "Abends (19:00 - 00:00)",
        "Nachts (00:00 - 05:30)"]
    screen.SetupLists(m.rowDescs.Count())
    screen.SetListNames(m.rowDescs)
End Function

'**********************************************************
' Returns the number of list (title) rows.
'**********************************************************
Function getRowCount() As Integer
    return m.rowDescs.Count()
End Function

'**********************************************************
' Maps a dayTimePeriod (such as "morgens" or "abends" to
' the index that matches the row index.
'**********************************************************
Function mapDayTimePeriodToRowIndex(dayTimePeriod As String) As Integer
    if dayTimePeriod = "morgens" then
        return 0
    elseif dayTimePeriod = "mittags" then
        return 1
    elseif dayTimePeriod = "abends" then
        return 2
    elseif dayTimePeriod = "nachts" then
        return 3
    else 
        return -1
    end if
End Function

'**********************************************************
' Helper to set up the list data. It loads the data for the
' day first and then sets up the rows based on if there is
' content for each dayTimePeriod.
'**********************************************************
Function setupListData(screen As Object, day As Object) 
    m.data = m.conn.LoadSendungVerpasstDataForDay(m.conn, day, getRowCount(), mapDayTimePeriodToRowIndex)
    ' Set up the data for each row
    for i = 0 to (m.rowDescs.Count() - 1)
       screen.SetContentList(i, m.data[i])
       ' If a row doesn't have any data, sets the row to invisible
       if m.data[i].Count() = 0 then
           screen.SetListVisible(i, false)
       else
           screen.SetListVisible(i, true)
           screen.SetFocusedListItem(i, 0)
       end if
    end for
End Function

'**********************************************************
' Handles the show detail data fetching, creating the
' detail screen and showing the detail screen.
'**********************************************************
Function displayShowDetailScreenShow(show as Object) As Integer
    if validateParam(show, "roAssociativeArray", "displayShowDetailScreenShow") = false return -1

    show = m.conn.LoadContentDataByAssetId(m.conn, show)
    screen = preShowDetailScreen()
    showIndex = showDetailScreen(screen, show)
    return showIndex
End Function
