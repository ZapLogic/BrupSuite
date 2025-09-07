# Show signature message in console
Write-Host "`n=============================================" -ForegroundColor Yellow
Write-Host " This Script is Created By AbdulQadeer" -ForegroundColor Cyan
Write-Host " Founder of ZapLogic" -ForegroundColor Cyan
Write-Host " Visit Website: www.zaplogic.shop" -ForegroundColor Green
Write-Host " WhatsApp: https://bit.ly/contact-to-abdul" -ForegroundColor Green
Write-Host "=============================================`n" -ForegroundColor Yellow
# Set Wget Progress to Silent, Becuase it slows down Downloading by 50x
echo "Setting Wget Progress to Silent, Becuase it slows down Downloading by 50x`n"
$ProgressPreference = 'SilentlyContinue'

# Check JDK-21 Availability or Download JDK-21
$jdk21 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java(TM) SE Development Kit 21*"
if (!($jdk21)){
    echo "`t`tDownnloading Java JDK-21 ...."
    wget "https://download.oracle.com/java/21/archive/jdk-21_windows-x64_bin.exe" -O jdk-21.exe  
    echo "`n`t`tJDK-21 Downloaded, lets start the Installation process"
    start -wait jdk-21.exe
}else{
    echo "Required JDK-21 is Installed"
    $jdk21
}

# Check JRE-8 Availability or Download JRE-8
$jre8 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java 8 Update *"
if (!($jre8)){
    echo "`n`t`tDownloading Java JRE ...."
    wget "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247947_0ae14417abb444ebb02b9815e2103550" -O jre-8.exe
    echo "`n`t`tJRE-8 Downloaded, lets start the Installation process"
    start -wait jre-8.exe
}else{
    echo "`n`nRequired JRE-8 is Installed`n"
    $jre8
}

# Download Burpsuite Professional
$version = "2025"
$jarName = "burpsuite_pro_v$version.jar"

if (Test-Path $jarName) {
    Write-Host "Burp Suite Pro version $version is already present ($jarName). Skipping download.`n"
} else {
    Write-Host "Downloading Burp Suite Professional v$version..."
    Invoke-WebRequest -Uri "https://portswigger.net/burp/releases/download?product=pro&type=Jar" `
      -OutFile $jarName
}

# Creating Burp.bat file with command for execution
if (Test-Path burp.bat) {rm burp.bat}
$path = "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:`"$pwd\loader.jar`" -noverify -jar `"$pwd\burpsuite_pro_v$version.jar`""
$path | add-content -path Burp.bat
echo "`nBurp.bat file is created"

# Creating Burp-Suite-Pro.vbs File for background execution
if (Test-Path "$pwd\Burp-Suite-Pro.vbs") {
   Remove-Item "$pwd\Burp-Suite-Pro.vbs"
}

Add-Content -Path "$pwd\Burp-Suite-Pro.vbs" -Value "Set WshShell = CreateObject(""WScript.Shell"")"
Add-Content -Path "$pwd\Burp-Suite-Pro.vbs" -Value "WshShell.Run Chr(34) & ""$($pwd.Path)\Burp.bat"" & Chr(34), 0"
Add-Content -Path "$pwd\Burp-Suite-Pro.vbs" -Value "Set WshShell = Nothing"

Write-Host "`nBurp-Suite-Pro.vbs file is created."


# Create Shortcut on Desktop with custom icon
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Burp Suite Pro.lnk"
$wsh = New-Object -ComObject WScript.Shell

$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$($pwd.Path)\Burp-Suite-Pro.vbs"
$shortcut.WorkingDirectory = $pwd.Path
$shortcut.IconLocation = "$($pwd.Path)\burp_suite.ico"
$shortcut.Save()

Write-Host "`nShortcut 'Burp Suite' created on Desktop"

# Download loader if it not exists
if (!(Test-Path loader.jar)){
    echo "`nDownloading Loader ...."
    Invoke-WebRequest -Uri "https://github.com/xiv3r/Burpsuite-Professional/raw/refs/heads/main/loader.jar" -OutFile loader.jar
    echo "`nLoader is Downloaded"
}else{
    echo "`nLoader is already Downloaded"
}

# Lets Activate Burp Suite Professional with keygenerator and Keyloader
echo "Reloading Environment Variables ...."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
echo "`n`nStarting Keygenerator ...."
start-process java.exe -argumentlist "-jar loader.jar"
echo "`n`nStarting Burp Suite Professional"
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:"loader.jar" -noverify -jar "burpsuite_pro_v$version.jar"

# Show popup message
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "This Script is Created By AbdulQadeer`nFounder of ZapLogic`n`nVisit: www.zaplogic.shop`nWhatsApp: https://bit.ly/contact-to-abdul",
    "ZapLogic Installer",
    'OK',
    'Information'
)
# Auto-open links in default browser
Start-Process "https://www.github.com/zaplogic"
Start-Process "https://bit.ly/contact-to-abdul"
