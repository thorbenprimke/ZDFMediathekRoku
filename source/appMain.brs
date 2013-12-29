'********************************************************************
'**  Video Player Example Application - Main
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'********************************************************************

Sub Main()

    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    'prepare the screen for display and get ready to begin
    screen=preShowSendungVerpasstOverviewScreen()
    if screen=invalid then
        print "unexpected error in preShowHomeScreen"
        return
    end if

    'set to go, time to get started
    showSendungVerpasstOverviewScreen(screen)

End Sub


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")
    
    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"
    theme.OverhangLogoSD  = "pkg:/images/Overhang_Logo_SD.png"

    theme.OverhangOffsetHD_X = "125"
    theme.OverhangOffsetHD_Y = "35"
    theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"
    theme.OverhangLogoHD  = "pkg:/images/Overhang_Logo_HD.png"
    
    theme.BackgroundColor = "#9f9f9f"

    theme.GridScreenLogoHD = "pkg:/images/Overhang_Logo_HD.png"
    theme.GridScreenLogoSD = "pkg:/images/Overhang_Logo_SD.png"
    theme.GridScreenOverhangHeightHD = "129"
    theme.GridScreenOverhangHeightSD = "129"
    theme.GridScreenOverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"
    theme.GridScreenOverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"
    theme.GridScreenLogoOffsetHD_X = "125"
    theme.GridScreenLogoOffsetHD_Y = "35"
    theme.GridScreenLogoOffsetSD_X = "72"
    theme.GridScreenLogoOffsetSD_Y = "31"
    theme.GridScreenBackgroundColor = "#9f9f9f"

    app.SetTheme(theme)

End Sub
