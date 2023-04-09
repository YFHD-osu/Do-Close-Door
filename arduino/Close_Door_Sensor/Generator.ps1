#操作過程參考: https://blog.jmaker.com.tw/chinese_oled/

$WindowWidth = (Get-Host).UI.RawUI.MaxWindowSize.Width
if ($WindowWidth%2 -eq 1){$WindowWidth -= 1}

function SelectInoList{
    param (
	  [string]$Title = '選擇你的專案名稱',
	  [string]$SelectionLore = '請選擇上方所顯示的選項',
	  [array]$inoFiles,
	  [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 )
    )
  Clear-Host

  Write-Host $titleBar $Title $titleBar
  
	for ($i=0; $i -lt $inoFiles.count; $i=$i+1 ) {
	  $displayNum = $i+1
	  $displayFileName = $inoFiles[$i].Name
	  Write-Host " $displayNum > $displayFileName" ;
	}
    Write-Host " Q > 來取消操做"
	Write-Host $titleBar $Title $titleBar
	
	$selection = Read-Host $SelectionLore
	if ($selection -eq 'Q') {return -1}
	if ($selection -eq '') {
	  SelectInoList -inoFiles $inoFiles
	  return
	}
	
	try {
	  [int]$selection = $selection
	  if ($selection -gt $inoFiles.count) {
	    SelectInoList -inoFiles $inoFiles -SelectionLore "'$selection' 超出了選擇範圍"
	  }
	}catch{
	  SelectInoList -SelectionLore "'$selection' 不是一個有效的選擇" -inoFiles $inoFiles
	  return
	}

	return $selection - 1
}

function ShowAllChinese{
  param (
    [string]$Title = '偵測到的中文字',
    [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 ),
    [array]$ChineseList
  )
	
  Write-Host $titleBar $Title $titleBar

  for ($i = 0; $i -lt $chineseWords.groups.count; $i=$i+1){
    $tmpString = $chineseWords.groups[$i].value
    Write-Host -NoNewline " $tmpString "
	  if (((($i+1)*4) % $WindowWidth) -le ($WindowWidth % 4)){ Write-Host ""}
  }
  
  Write-Host ""
  Write-Host $titleBar $Title $titleBar 

  return
}

function CheckDownload{
  param (
    $ResetChineseMap = $true
  )
	
  if ((Test-Path -Path ”.\u8g2Files\”) -ne $true) {mkdir u8g2Files > $null}
	
  if ((Test-Path -Path ”.\u8g2Files\unifont.bdf” -PathType Leaf) -ne $true) {
    $bdfconvURL = 'https://github.com/olikraus/u8g2/raw/master/tools/font/bdf/unifont.bdf'
    $Path=”.\u8g2Files\unifont.bdf”
    Write-Host " | 未偵測到unifont.bdf，正在下載!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }

  if ((Test-Path -Path ”.\u8g2Files\bdfconv.exe” -PathType Leaf) -ne $true) {
    $bdfconvURL = 'https://github.com/olikraus/u8g2/raw/master/tools/font/bdfconv/bdfconv.exe'
    $Path=”.\u8g2Files\bdfconv.exe”
    Write-Host " | 未偵測到bdfconv.exe，正在下載!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }

  if ((Test-Path -Path ”.\u8g2Files\7x13.bdf” -PathType Leaf) -ne $true) {
    $bdfconvURL = 'https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/bdf/7x13.bdf'
    $Path=”.\u8g2Files\7x13.bdf”
    Write-Host " | 未偵測到7x13.bdf，正在下載!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }
	
  if((Test-Path -Path ”.\u8g2Files\chinese1.map.BAK” -PathType Leaf) -ne $true){
    $bdfconvURL = 'https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/build/chinese1.map'
    $Path=”.\u8g2Files\chinese1.map.BAK”
    Write-Host " | 未偵測到chinese1.map，正在下載!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }else{
	Write-Host " | 正在重製chinese1.map!"
  }
  Copy-Item ".\u8g2Files\chinese1.map.BAK" -Destination ".\u8g2Files\chinese1.map" -Recurse
  
  return
}

function StartConvert{
  param (
    [string]$Title = '轉換中',
    [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 ),
    [array]$ChineseList
  )
	
  Write-Host $titleBar $Title $titleBar""

  for ($i = 0; $i -lt $chineseWords.groups.count ; $i = $i+1){
    $character = '${0:X},' -f [int][char]$chineseWords.groups[$i].value
    Add-Content ".\u8g2Files\chinese1.map" $character
  }
  ./u8g2Files/bdfconv.exe -v ./u8g2Files/unifont.bdf -b 0 -f 1 -M ./u8g2Files/chinese1.map -d ./u8g2Files/7x13.bdf -n ./u8g2Files/u8g2_font_unifont -o ./u8g2Files/u8g2_font_unifont.c
  
  Write-Host $titleBar $Title $titleBar
	
  Remove-Item ./bdf.tga
  
  return
}

function WriteFile{
  param (
    $user = $env:UserProfile,
    $u8g2FontsPath = ”$user\Documents\Arduino\libraries\U8g2\src\clib\u8g2_fonts.c”
  )

  $UnicodeArray = Get-Content -Path .\u8g2Files\u8g2_font_unifont.c -Raw -Encoding UTF8
  $arrayCount = [regex]::matches($UnicodeArray, '\[\d+\]')
  $arrayContext = [regex]::matches($UnicodeArray, '"\) [\s\S]+"')
  $WriteContext = "const uint8_t u8g2_font_unifont_t_chinese1{0} U8G2_FONT_SECTION(`"u8g2_font_unifont_t_chinese1{1};" -f $arrayCount.groups[0].value, $arrayContext.groups[0].value

  [string]$u8g2FontsContext = Get-Content -Path $u8g2FontsPath -Raw
  [int64]$startPostion = $u8g2FontsContext.IndexOf('const uint8_t u8g2_font_unifont_t_chinese1')
  [int64]$endPostion = $u8g2FontsContext.IndexOf('";',$startPostion)

  if (($startPostion -ne -1) -and ($endPostion -ne -1)){
    Write-Host " | 已在 u8g2_fonts.c 檔案中找到 u8g2_font_unifont_t_chinese1 ，覆蓋中..."
    [int]$removeCount = $endPostion - $startPostion + 2
    $u8g2FontsContext.Remove($startPostion,$removeCount).Insert($startPostion, $WriteContext) | Set-Content -Encoding UTF8 -Path $u8g2FontsPath #.Insert($startPostion,$WriteContext)
  }else{
    Write-Host " | 無法在 u8g2_fonts.c 檔案中找到 u8g2_font_unifont_t_chinese1 ，無法覆蓋檔案，也許重新安裝u8g2可以解決?"
    return
    # $u8g2FontsContext.Insert(40, $WriteContext) | Set-Content -Encoding UTF8 -Path ”$user\Documents\u8g2_fonts.c”
  }

  return
}

function EndMessage{
  param (
    [string]$Title = '程式執行完畢，已更新中文字型',
    [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 ),
    [bool]$printSampleCode = $true
  )
	
  Write-Host $titleBar $Title $titleBar""
  Write-Host "以下為範例程式:"
  Write-Host ""

  if ($printSampleCode){
    Write-Host '#include <U8g2lib.h>'
    Write-Host ''
    Write-Host 'U8G2_SSD1306_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);'
    Write-Host ''
    Write-Host 'void setup() {'
    Write-Host '  u8g2.begin();'
    Write-Host '  u8g2.enableUTF8Print();  //啟用UTF8文字的功能  '
    Write-Host '}'
    Write-Host ''
    Write-Host 'void loop() {'
    Write-Host '  u8g2.setFont(u8g2_font_unifont_t_chinese1);'
    Write-Host '  u8g2.firstPage();'
    Write-Host '  do {'
    Write-Host '  u8g2.setCursor(0, 14);'
    Write-Host '  u8g2.print("中文1");'
    Write-Host '  u8g2.setCursor(0, 35);'
    Write-Host '  u8g2.print("中文2");'
    Write-Host '  u8g2.setCursor(0, 56);'
    Write-Host '  u8g2.print("中文3");'
    Write-Host '  } while (u8g2.nextPage());'
    Write-Host '}'
  }

  Write-Host ""
  Write-Host $titleBar $Title $titleBar
	
  return
}

$inoFiles = @(Get-Childitem .\* -Include *.ino | Select-Object Name,Extension -Unique)
# $inoFiles = @(Get-Childitem -Recurse -Filter .\*.ino | Select-Object Name,Extension -Unique)

$FileName = ""
if ( $inoFiles.count -gt 1 ){
  $select = SelectInoList -inoFiles $inoFiles
  $FileName = $inoFiles[$select].Name
  Write-Host " | 已手動選取檔案: '$FileName'"
}elseif ($inoFiles.Count -eq 0) {
  Write-Host " | 未偵測到同目錄下的.ino檔案"
  Write-Host " | 程式即將結束..."
  return
}else{
  $FileName = $inoFiles[0].Name
  Write-Host " | 已自動選取檔案: '$FileName'"
}

$raw = (Get-Content -Path .\$FileName -Raw -Encoding UTF8) -replace '\r?\n', ''
$chineseWords = [regex]::matches($raw, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]') | select -Unique

if ($chineseWords.count -ne 1) {
  ShowAllChinese -ChineseList $chineseWords
}else{
  Write-Host " | 未偵測到需要轉譯的中文字，程式即將退出!"
  return
}

CheckDownload
StartConvert -ChineseList $chineseWords

# $WriteContext | Set-Content -Encoding UTF8 -NoNewline -Path ”$user\Documents\u8g2_fonts.c” 

$user = $env:UserProfile
if ((Test-Path -Path $user\Documents\Arduino\libraries\U8g2\src\clib\u8g2_fonts.c -PathType Leaf) -eq $true) {
  Write-Host " | 已在預設資料夾中找到: u8g2_fonts.c"
  WriteFile
}else{
  Write-Host " | 未在預設資料夾中找到: u8g2_fonts.c"
  while($true){
    Write-Host " | 請手動定位 u8g2_fonts.c 的位置 (通常在 ...\Arduino\libraries\U8g2\src\clib\u8g2_fonts.c)"
    $customPath = Read-Host " | 請輸入文件的完整位置或將文件拖曳至此視窗`n"
    if ((Test-Path -Path $customPath) -eq $true){
      WriteFile -u8g2FontsPath $customPath
      break
    }
  }
}

EndMessage

Pause 
#Write-Host $arrayCount
#Write-Host $arrayContext