#########################################################################
#                        Add shared_assemblies                          #
#########################################################################

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')      | out-null  
[System.Reflection.Assembly]::LoadFrom('assembly\dev4sys.Tree.dll')      | out-null 

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



# ================== Handle Folders ===========================
foreach ($folder in $AllDirectory){

    $treeViewItem = [Windows.Controls.TreeViewItem]::new()
    $treeViewItem.Header = $folder.Substring($folder.LastIndexOf("\") + 1)
    $treeViewItem.Tag = @("folder",$folder)
    $treeViewItem.Items.Add($dummyNode) | Out-Null
    $treeViewItem.Add_Expanded({
        Write-Host $_.OriginalSource.Header  " is expanded"
        TreeExpanded($_.OriginalSource)
    })
    $FolderTree.Items.Add($treeViewItem)| Out-Null

}

# ================== Handle Files ===========================
foreach ($file in $AllFiles){

    $treeViewItem = [Windows.Controls.TreeViewItem]::new()
    $treeViewItem.Header = $file.Substring($file.LastIndexOf("\") + 1)
    $treeViewItem.Tag = @("file",$file) 
    $FolderTree.Items.Add($treeViewItem)| Out-Null

	$treeViewItem.Add_PreviewMouseLeftButtonDown({
		[System.Windows.Controls.TreeViewItem]$sender = $args[0]
		[System.Windows.RoutedEventArgs]$e = $args[1]
		Write-Host "Left Click: $($sender.Tag)"
	})

	$treeViewItem.Add_PreviewMouseRightButtonDown({
		[System.Windows.Controls.TreeViewItem]$sender = $args[0]
		[System.Windows.RoutedEventArgs]$e = $args[1]
		Write-Host "Right Click: $($sender.Tag)"
	})

}


Function TreeExpanded($sender){
    
    $item = [Windows.Controls.TreeViewItem]$sender
    
    If ($item.Items.Count -eq 1 -and $item.Items[0] -eq $dummyNode)
    {
        $item.Items.Clear();
        Try
        {
            
            foreach ($string in [IO.Directory]::GetDirectories($item.Tag[1].ToString()))
            {
                $subitem = [Windows.Controls.TreeViewItem]::new();
                $subitem.Header = $string.Substring($string.LastIndexOf("\") + 1)
                $subitem.Tag = @("folder",$string)
                $subitem.Items.Add($dummyNode)
                $subitem.Add_Expanded({
                    TreeExpanded($_.OriginalSource)
                })
                $item.Items.Add($subitem) | Out-Null
            }

            foreach ($file in [IO.Directory]::GetFiles($item.Tag[1].ToString())){
                $subitem = [Windows.Controls.TreeViewItem]::new()
                $subitem.Header = $file.Substring($file.LastIndexOf("\") + 1)
                $subitem.Tag = @("file",$file) 
                $item.Items.Add($subitem)| Out-Null

                $subitem.Add_PreviewMouseLeftButtonDown({
		            [System.Windows.Controls.TreeViewItem]$sender = $args[0]
		            [System.Windows.RoutedEventArgs]$e = $args[1]
		            Write-Host "Left Click: $($sender.Tag)"
	            })

	            $subitem.Add_PreviewMouseRightButtonDown({
		            [System.Windows.Controls.TreeViewItem]$sender = $args[0]
		            [System.Windows.RoutedEventArgs]$e = $args[1]
		            Write-Host "Right Click: $($sender.Tag)"
	            })

            }

        }   
        Catch [Exception] { }
    }
     
}

#########################################################################
#                        Show window                                    #
#########################################################################

$Form.ShowDialog() | Out-Null
  