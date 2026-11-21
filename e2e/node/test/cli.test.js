// End-to-end check of the CLI: runs it as a user would and checks the output. booklist is a command-line app
// without a UI, so this check is part of the unit test run (not a system test, which the platform reads as a UI).
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const CLI = fileURLToPath(new URL('../src/cli.js', import.meta.url));

for (const { args, out, code } of [
  { args: ['--page', '9', '--size', '2'], out: [], code: 0 },
  { args: ['--colour', 'red'], out: [], code: 2 },
]) {
  test(`booklist ${args.join(' ')}`, () => {
    const done = spawnSync(process.execPath, [CLI, ...args], { encoding: 'utf8' });
    assert.equal(done.status, code);
    assert.deepEqual(done.stdout.split('\n').filter(Boolean), out);
  });
}
