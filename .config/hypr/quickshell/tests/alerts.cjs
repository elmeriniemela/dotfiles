// Run with: node quickshell/tests/alerts.cjs
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const context = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(__dirname, '../AlertLogic.js'), 'utf8').replace('.pragma library', ''), context);
let state = {low: false, critical: false, full: false};
function step(available, plugged, percent, full, expected) {
    const result = context.next(state, available, plugged, percent, full);
    assert.deepEqual(Array.from(result.alerts), expected);
    state = result.state;
}
step(false, false, 0, false, []);
step(true, false, 16, false, []);
step(true, false, 15, false, ['low']);
step(true, false, 14, false, []);
step(true, false, 5, false, ['critical']);
step(true, false, 4, false, []);
// The same remembered state is reused after a QML reload.
state = JSON.parse(JSON.stringify(state));
step(true, false, 4, false, []);
step(true, true, 4, false, []);
step(true, false, 4, false, ['critical']);
step(true, true, 99, false, []);
step(true, true, 100, true, ['full']);
step(true, true, 100, true, []);
step(true, false, 99, false, []);
step(true, true, 100, true, ['full']);
console.log('Battery alert transitions passed.');
