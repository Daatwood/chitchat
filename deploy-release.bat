set /p filename=< .project
set /p build_path=< .build_path
git rev-list HEAD --count > .commit
set /p version=< .commit
set /p wow_version=< .wow_version
7za a %build_path%\%filename%\%filename%_%wow_version%-2.%version%.zip %filename%