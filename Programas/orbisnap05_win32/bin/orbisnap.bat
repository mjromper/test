@echo off
setlocal
rem **************************************************************************
rem **************************************************************************
rem 
rem             Script file to run Orbisnap
rem
rem             $Revision: 1.1.8.2 $
rem             $Date: 2006/10/20 15:54:32 $
rem             $Author: batserve $
rem
rem 		Copyright 1998-2006 HUMUSOFT s.r.o.
rem
rem **************************************************************************
rem **************************************************************************


if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
"%~dp0win64\orbisnap" %*
) else if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
"%~dp0win64\orbisnap" %*
) else (
"%~dp0win32\orbisnap" %*
)
