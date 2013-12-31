'**********************************************************
'**  ZDF Mediathek - Content detail screen. It lists the
'**  details for a content object.
'**  Adopted from the video player example - detail screen
'**********************************************************

'**********************************************************
' Sets up the detail screen. The detail screen is a
' roSpringboardScreen with style video and without the
' star rating indicator.
'**********************************************************
Function preShowDetailScreen() As Object
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video") 
    screen.SetStaticRatingEnabled(false)
    screen.SetMessagePort(port)
    return screen
End Function


'**********************************************************
' Shows the detail screen about a content. This runs the
' main event loop and either starts a video from the
' beginning or resumes at a previous position. 
'**********************************************************
Function showDetailScreen(screen As Object, show As Object) As Integer
    if validateParam(screen, "roSpringboardScreen", "showDetailScreen") = false return -1
    if validateParam(show, "roAssociativeArray", "showDetailScreen") = false return -1

    updateShowDetail(screen, show)

    while true
        msg = wait(0, screen.GetMessagePort())

        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isButtonPressed() 
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                if msg.GetIndex() = 1
                    PlayStart = RegRead(show.AssetId)
                    if PlayStart <> invalid then
                        show.PlayStart = PlayStart.ToInt()
                    endif
                    showVideoScreen(show)
                    updateShowDetail(screen, show)
                endif
                if msg.GetIndex() = 2
                    show.PlayStart = 0
                    showVideoScreen(show)
                    updateShowDetail(screen, show)
                endif
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while

    return showIndex

End Function

'**********************************************************
' Updates the contents of the detail screen with the
' passed roAssociativeArray with the content information.
'**********************************************************
Function updateShowDetail(screen As Object, show As Object) As Integer
    if validateParam(screen, "roSpringboardScreen", "refreshShowDetail") = false return -1
    if validateParam(show, "roAssociativeArray", "refreshShowDetail") = false return -1

    screen.ClearButtons() 
    if show.StreamUrls <> invalid and show.StreamUrls.Count() = 0
        ' Adds a message to let the user know that the asset does not have video content
        ' This could also be a dialog window
        show.Description = "ASSET DOES NOT HAVE VIDEO CONTENT - " + show.Description
    else
        progress = regread(show.AssetId)
        if progress <> invalid and progress.toint() >=10 then
            screen.AddButton(1, "Resume playing")    
            screen.AddButton(2, "Play from beginning")
        else
            screen.addbutton(1, "Play")
        end if
    end if
    screen.SetContent(show)
    screen.Show()
End Function

