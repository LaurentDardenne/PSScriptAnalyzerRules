#http://keithhill.spaces.live.com/Blog/cns!5A8D2641E0963A97!7132.entry
function Using-Culture ([System.Globalization.CultureInfo]$culture =(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
                        [ScriptBlock]$script=(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
{    
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    $OldUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
    try {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture        
        Invoke-Command $script    
    }    
    finally {        
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture        
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $OldUICulture    
    }    
}


