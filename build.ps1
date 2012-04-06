$dmdPath	= "c:\Development\D\Dmd\windows\bin"

function addDmdToPath() {
	if( $env:path.IndexOf($dmdPath) -eq -1 ) {
		$env:path += ";" + $dmdPath
	}
}

function checkDmdVersion() {
	$dmdOutput = & dmd
	$dmdVer = $dmdOutput[0][$dmdOutput[0].indexof('v') + 1]
}

$spiritd_Dir	= ".\spiritd"
$spiritdFiles	= dir ($spiritd_Dir + "\*.d")
$spiritdFiles2	= dir ($spiritd_Dir + "\impl\*.d")
$spiritdFiles3	= dir ($spiritd_Dir + "\composite\*.d")
$spiritdFiles4	= dir ($spiritd_Dir + "\utility\*.d")
$spiritdFiles5	= dir ($spiritd_Dir + "\meta\*.d")
$spiritdVer1		= dir ($spiritd_Dir + "\ver\*v1.d")
$spiritdVer2		= dir ($spiritd_Dir + "\ver\*v2.d")

$flags		= "-g"

cls

if(!$args[0]) {
	echo "provide name of top level .d file."
	exit
}

addDmdToPath
. checkDmdVersion

if($dmdVer -eq "2") {
	$spiritdVer = $spiritdVer2
} else {
	if($dmdVer -eq "1") {
		$spiritdVer = $spiritdVer1
	} else {
		echo "Couldn't determine dmd version. outta here."
		exit 1
	}
}

$blurb = "======== Building with: " + $dmdOutput[0] + " ===="
echo $blurb 

dmd $flags "-I.\\" $args[0] $spiritdFiles $spiritdFiles2 $spiritdFiles3 $spiritdFiles4 $spiritdFiles5 $spiritdVer

echo "=== Done =="
