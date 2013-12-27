'**********************************************************
'**  ZDF Mediathek - URL Utilities 
'**********************************************************

'**********************************************************
' Formats a dateString that fits the format required by
' ZDF's xmlservice for sendungVerpasst.
'**********************************************************
Function formatDateForSendungVerpasst(date As Object) As Dynamic
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