import { test } from './prepare-test-env-ava.js';
import { applyLabelingError } from '../apply-labeling-error.js';

const { Fail } = assert;

test('test applyLabelingError', async t => {
  t.is(
    applyLabelingError(x => x * 2, [8]),
    16,
  );
  t.is(
    applyLabelingError(x => x * 2, [8], 'foo'),
    16,
  );
  t.is(await applyLabelingError(async x => x * 2, [8], 'foo'), 16);
  t.throws(() => applyLabelingError(x => Fail`${x}`, ['e']), {
    message: '"e"',
  });
  t.throws(() => applyLabelingError(x => Fail`${x}`, ['e'], 'foo'), {
    message: 'foo: "e"',
  });
  await t.throwsAsync(
    async () => applyLabelingError(x => Fail`${x}`, ['e'], 'foo'),
    {
      message: 'foo: "e"',
    },
  );
});
