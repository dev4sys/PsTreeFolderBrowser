

#########################################################################
# Author:  Kevin RAHETILAHY                                             #   
# Blog: dev4sys.blogspot.fr                                             #
#########################################################################

#########################################################################
#                        Add shared_assemblies                          #
#########################################################################

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')      | out-null  

#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition
function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
$XamlMainWindow=LoadXaml($pathPanel+"\Treeview.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)


$okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
   


$FolderTree = $Form.FindName("TreeView")
#########################################################################
#                        Stuff                                          #
#########################################################################

$dummyNode = $null



$AllFiles  = [IO.Directory]::GetFiles('.\Test')
$AllDirectory = [IO.Directory]::GetDirectories('.\Test')

foreach ($folder in $AllDirectory){

    $treeViewItem = [Windows.Controls.TreeViewItem]::new()
    $treeViewItem.Header = $folder.Substring($folder.LastIndexOf("\") + 1)
    $treeViewItem.Tag = $folder
    $treeViewItem.Items.Add($dummyNode) | Out-Null
    $treeViewItem.Add_Expanded({
        Write-Host $_.OriginalSource.Header  " 0 is expanded"
        TreeExpanded($_.OriginalSource)
    })
    $FolderTree.Items.Add($treeViewItem)| Out-Null

}


Function TreeExpanded($sender){
    
    $item = [Windows.Controls.TreeViewItem]$sender
    
    If ($item.Items.Count -eq 1 -and $item.Items[0] -eq $dummyNode)
    {
        $item.Items.Clear();
        Try
        {
            
            foreach ($string in [IO.Directory]::GetDirectories($item.Tag.ToString()))
            {
                $subitem = [Windows.Controls.TreeViewItem]::new();
                $subitem.Header = $string.Substring($string.LastIndexOf("\") + 1)
                $subitem.Tag = $string
                $subitem.Items.Add($dummyNode)
                $subitem.Add_Expanded({
                    TreeExpanded($_.OriginalSource)
                })
                $item.Items.Add($subitem) | Out-Null
            }
        }   
        Catch [Exception] { }
    }
     
}

#########################################################################
#                        Show window                                    #
#########################################################################

$Form.ShowDialog() | Out-Null
  