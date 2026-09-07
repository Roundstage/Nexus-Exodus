'use strict';
// Earth now uses protected 100x100 source chunks. Historical geography generators
// are retained for reference, never for overwriting authored maps.
const {spawnSync}=require('node:child_process'),path=require('node:path');
const result=spawnSync(process.execPath,[path.join(__dirname,'MapAssembly/AssemblePlanetMaps.cjs'),'SuperEarth',...process.argv.slice(2)],{stdio:'inherit'});
if(result.error)throw result.error;
process.exitCode=result.status??1;
