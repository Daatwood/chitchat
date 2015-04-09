set /p filename=< .project
set /p addon_path=< .development
git describe --tags --always > .version
set /p version=< .version
7za a .\builds\%filename%-%version%.zip %filename%
7za x .\builds\%filename%-%version%.zip -o%addon_path%