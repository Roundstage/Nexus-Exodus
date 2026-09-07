'use strict';
const {assemble}=require('./PlanetChunks.cjs');
const args=process.argv.slice(2), planet=args.shift();
if(args.some(a=>!['--check','--acknowledge-manual-output-edits-lost'].includes(a))) throw Error('Unknown option; --force is intentionally unsupported');
const {output,...report}=assemble(planet,{check:args.includes('--check'),acknowledgeManualOutputEdits:args.includes('--acknowledge-manual-output-edits-lost')});
console.log(JSON.stringify(report,null,2));
