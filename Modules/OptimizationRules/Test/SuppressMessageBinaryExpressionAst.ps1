[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
     "ForStatementCanBeImproved",
     "",
     Justification="’New-ReportObject’ do not change the system state, only the application 'context'")]
     
param()
 For($i=0; $i -lt $Range.Count-1; $i++) 
 { $i }
 
 For($i=0; $i -lt $Range.Count-1; $i++) 
 { $i }

 $RangeCount = $Range.Count
 For($i=0; $i -lt $RangeCount; $i++) { $i }
