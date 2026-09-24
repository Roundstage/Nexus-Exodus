// Exercise the actual creator preview sorter with the outer layer submitted first.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync(path.resolve(__dirname, '../src/Code/CharacterCreation/NexusCharacterCreation.dm'), 'utf8');
const functionLine = source.split(/\r?\n/).find(line => line.includes('function previewClothingOrder()'));
assert(functionLine, 'Missing clothing preview ordering');
const javascript = functionLine.trim().replace(/\\([\[\]])/g, '$1');
for (const [selected, expected] of [
  [['skirt', 'jumpsuit'], ['jumpsuit', 'skirt']],
  [['jumpsuit', 'skirt'], ['jumpsuit', 'skirt']],
  [['custom', 'shirt', 'jumpsuit'], ['custom', 'shirt', 'jumpsuit']],
  [['skirt', 'custom', 'shirt', 'jumpsuit'], ['custom', 'shirt', 'jumpsuit', 'skirt']],
]) {
  const context = vm.createContext({ selectedClothing: () => selected,
    clothingPreviews: { skirt: { priority: 600 }, jumpsuit: { priority: 500 }, shirt: { priority: 500 } } });
  vm.runInContext(javascript, context);
  assert.deepEqual(Array.from(vm.runInContext('previewClothingOrder()', context)), expected);
}
console.log('Viltrumite preview layering passed: skirt above jumpsuit, ordinary/custom order preserved.');
