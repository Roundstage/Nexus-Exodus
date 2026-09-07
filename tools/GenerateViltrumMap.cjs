'use strict';
// Author 100x100 chunks; the runtime map is now a generated artifact.
// The protected original blockout generator lives in docs/Maps/RebuildBaseline.
const {spawnSync}=require('node:child_process');
const path=require('node:path');
const result=spawnSync(process.execPath,[path.join(__dirname,'MapAssembly/AssemblePlanetMaps.cjs'),'Viltrum',...process.argv.slice(2)],{stdio:'inherit'});
if(result.error)throw result.error;
process.exitCode=result.status??1;
