'**********************************************************
'**  ZDF Mediathek - Category screen with sections such as
'**  Sendung Verpasst, Live Sendungen, Impressum, ...
'**********************************************************

'**********************************************************
' Sets up the screen, port and executes the init functions
' to set up the filters (headers) and list content.
'**********************************************************
Function preShowCategoryScreen() As Object
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    screen.SetListStyle("arced-square")
    initFilters(screen)
    initSenungVerpasstSection(screen)
    return screen
End Function

'**********************************************************
' Sets up the screen, port and executes the init functions
' to set up the filters (headers) and list content.
'**********************************************************
Function showCategoryScreen(screen As Object) As Integer
    if validateParam(screen, "roPosterScreen", "showCategoryScreen") = false return -1

    resetSelection(screen)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showCategoryScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                print "list focused | index = "; msg.GetIndex(); " | category = "; m.curCategory
                if msg.GetIndex() = 1 then
                    ShowDialog1Button("Impressum", "Hacked up by Thorben with no endorsement, support or approval by the ZDF.", "Got it!")
                    resetSelection(screen)
                end if
            else if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
                showSendungVerpasst(m.SendungVerpasstList[msg.GetIndex()])
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
' Add more filter sections here.
'**********************************************************
Function initFilters(screen As Object)
    m.filters = CreateObject("roArray", 2, true)
    m.filters.push("Verpasste Sendungen")
    m.filters.push("Impressum")
    screen.SetListNames(m.filters)
End Function

'**********************************************************
' Sets up the list for the Sendung Verpasst filter section.
'**********************************************************
Function initSenungVerpasstSection(screen As Object)
    m.SendungVerpasstList = CreateObject("roArray", 10, true)
    requestDate = CreateObject("roDateTime")
    for i = 0 to 7
        day = CreateObject("roAssociativeArray")
        day.ShortDescriptionLine1 = requestDate.asDateString("long-date")
        day.RequestDate = formatDateForSendungVerpasst(requestDate)
        ' It uses Unshift instead of Push because the list should
        ' be in reverse order for scrolling.
        m.SendungVerpasstList.Unshift(day)
        requestDate.FromSeconds(requestDate.AsSeconds() - 86400)
    end for
    screen.setContentList(m.SendungVerpasstList)
End Function

'**********************************************************
' Resets the selection to the first filter and last item.
' This work for the Sendung Verpasst list. It may need to
' be changed if other sections get content as well.
' It sets it to the last index because this puts the
' selection on the current day and allows the user to
' scroll backwards for previous days (instead of forward).
'**********************************************************
Function resetSelection(screen As Object)
    screen.SetFocusedList(0)
    screen.SetFocusedListItem(m.SendungVerpasstList.Count() - 1)
    screen.SetFocusToFilterBanner(false)
End Function

'**********************************************************
' Inits and shows the Sendung Verpasst screen.
'**********************************************************
Function showSendungVerpasst(day As Object) As Dynamic
    screen = preShowSendungVerpasstScreen()
    showSendungVerpasstScreen(screen, day)
End Function
