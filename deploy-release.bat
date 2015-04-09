set filename=Chitchat
git describe --tags --always > version
set /p version=< version
7za a .\builds\%filename%-%version%.zip %filename%