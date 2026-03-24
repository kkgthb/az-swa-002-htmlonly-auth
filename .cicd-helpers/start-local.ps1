$web_src_folder_path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'src', 'web'))
$swa_config_file_path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'configfile', 'staticwebapp.config.json'))

swa start $web_src_folder_path `
    --config $swa_config_file_path