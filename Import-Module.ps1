# Import-Module.ps1
# 
# Place any pre-initialisation script here
# Note: 
# * When executed the module is not yet loaded
# * Everything you define here (e.g. a variable) is defined OUTSIDE the module scope.

# If this script is loaded via "ScriptsToProcess" it will incorrectly 
# show up as loaded module, see the bug on Microsoft Connect below: 
# https://connect.microsoft.com/PowerShell/feedback/details/903654/scripts-loaded-via-a-scriptstoprocess-attribute-in-a-module-manifest-appear-as-if-they-are-loaded-modules

/##
 #
 #
 # Copyright 2014, 2015 Ronald Rink, d-fens GmbH
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 #/
