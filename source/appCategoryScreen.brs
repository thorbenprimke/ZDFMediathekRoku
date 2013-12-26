Function preShowCategoryScreen() As Object

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)

    screen.SetListStyle("flat-category")
    screen.setAdDisplayMode("scale-to-fit")
    return screen

End Function

Function showCategoryScreen(screen As Object) As Integer

    if validateParam(screen, "roPosterScreen", "showCategoryScreen") = false return -1

     filters = CreateObject("roArray", 3, true)
     filters.push("Verpasste Sendungen")
     filters.push("Sendungen A-Z")
     filters.push("Impressum")
     screen.SetListNames(filters)

     list = CreateObject("roArray", 10, true)
     date = CreateObject("roDateTime")
     For i = 0 To 7
         o = CreateObject("roAssociativeArray")
         o.ContentType = "episode"
         o.Title = "[Title]"
         o.ShortDescriptionLine1 = date.asDateString("long-date")
         o.ShortDescriptionLine2 = formatDateForXMLRequest(date)
         o.Description = ""
         o.Description = "[Description] "
         o.Rating = "NR"
         o.StarRating = "75"
         o.ReleaseDate = "[<mm/dd/yyyy]"
         o.Length = 5400
         o.Categories = []
         o.Categories.Push("[Category1]")
         o.Categories.Push("[Category2]")
         o.Categories.Push("[Category3]")
         o.Actors = []
         o.Actors.Push("[Actor1]")
         o.Actors.Push("[Actor2]")
         o.Actors.Push("[Actor3]")
         o.Director = "[Director]"
         o.RequestDate = formatDateForXMLRequest(date)
         list.Push(o)
         date.FromSeconds(date.AsSeconds() - 86400)
     End For
     screen.SetContentList(list)


'    initCategoryList()
'    screen.SetContentList(m.Categories.Kids)
    screen.SetFocusedList(0)
    screen.SetFocusedListItem(0)
    screen.SetFocusToFilterBanner(false)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                print "list focused | index = "; msg.GetIndex(); " | category = "; m.curCategory
            else if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
                showSendungVerpasst(list[msg.GetIndex()])
'                kid = m.Categories.Kids[msg.GetIndex()]
 '               if kid.type = "special_category" then
                    'displaySpecialCategoryScreen()
 '               else
  '                  print "selected clip"
   '                 print kid.AssetId
    '                displayShowDetailScreenSingle(kid)                   
'                    displayCategoryPosterScreen(kid)
                'end if
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while
    return 0
End Function

Function showSendungVerpasst(day As Object) As Dynamic
    screen = preShowSendungVerpasstScreen()
    showSendungVerpasstScreen(screen, day)
End Function


Function formatDateForXMLRequest(date As Object) As Dynamic
    day = date.getDayOfMonth()
    month = date.getMonth()
    year = date.getYear()
    dateString = ""
    if day < 10
        dateString = dateString + "0" + day.toStr()
    else
        dateString = dateString + day.tostr()
    endif
    if month < 10
        dateString = dateString + "0" + month.toStr()
    else
        dateString = dateString + month.tostr()
    endif
    dateString = dateString + (year - 2000).toStr()
    return dateString
End Function

