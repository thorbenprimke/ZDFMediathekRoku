'**********************************************************
'**  ZDF Mediathek - Overview screen with the previous
'**  days for viewing the content of each day.
'**********************************************************

'**********************************************************
' Sets up the screen, port and executes the init functions
' to set up the filters (headers) and list content.
'**********************************************************
Function preShowSendungVerpasstOverviewScreen() As Object
    port = CreateObject("roMessagePort")
    screen = CreateObject("roListScreen")
    screen.SetMessagePort(port)
    screen.SetHeader("Sendung Verpasst")
    initSendungVerpasstDayNameList(screen)
    return screen
End Function

'**********************************************************
' Shows the Sendung Verpasst overview screen and handles
' click events / opens the Sendung Verpasst day screen.
'**********************************************************
Function showSendungVerpasstOverviewScreen(screen As Object) As Integer
    if validateParam(screen, "roListScreen", "showCategoryScreen") = false return -1

    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roListScreenEvent" then
            print "showCategoryScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
                showSendungVerpasstDay(m.SendungVerpasstList[msg.GetIndex()])
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while
    return 0
End Function

'**********************************************************
'**  The methods below are only intended to be used      **
'**  within this screen file.                            **
'**********************************************************

'**********************************************************
' Sets up the list day name list.
'**********************************************************
Function initSendungVerpasstDayNameList(screen As Object)
    m.SendungVerpasstList = CreateObject("roArray", 10, true)
    requestDate = CreateObject("roDateTime")
    for i = 0 to 7
        day = CreateObject("roAssociativeArray")
        if i = 0 then
            day.Title = "Heute"
        else if i = 1 then
            day.Title = "Gestern"
        else
            day.Title = requestDate.GetWeekday()
        endif
        day.HDBackgroundImageUrl = "pkg:/images/SendungVerpasstDefaultDayLogo_HD.png"
        day.SDBackgroundImageUrl = "pkg:/images/SendungVerpasstDefaultDayLogo_SD.png"
        day.ShortDescriptionLine1 = requestDate.asDateString("long-date")
        day.breadcrumbDate = requestDate.asDateString("short-month-no-weekday")
        day.RequestDate = formatDateForSendungVerpasst(requestDate)
        m.SendungVerpasstList.Push(day)
        requestDate.FromSeconds(requestDate.AsSeconds() - 86400)
    end for
    screen.setContent(m.SendungVerpasstList)
End Function

'**********************************************************
' Inits and shows the Sendung Verpasst day screen.
'**********************************************************
Function showSendungVerpasstDay(day As Object) As Dynamic
    screen = preShowSendungVerpasstDayScreen()
    showSendungVerpasstDayScreen(screen, day)
End Function
