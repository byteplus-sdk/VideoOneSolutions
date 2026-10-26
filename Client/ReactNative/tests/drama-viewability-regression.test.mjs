import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';
import ts from 'typescript';

const source = readFileSync(new URL('../app/drama_player.tsx', import.meta.url), 'utf8');
const start = source.indexOf('  // Create viewability config callback pairs');
const end = source.indexOf('  const handleFullscreenFreeze', start);
assert.ok(start >= 0 && end > start);
const code = ts.transpileModule(source.slice(start, end), {
  compilerOptions: { target: ts.ScriptTarget.ES2022 },
}).outputText;

// Fast Refresh keeps refs while invalidating memo dependency comparisons.
function mountViewability() {
  let ref;
  let memo;
  let currentIndex = 0;
  const suppression = { current: false };
  return {
    suppression,
    index: () => currentIndex,
    render(refresh = false) {
      return vm.runInNewContext(`${code}\nviewabilityConfigCallbackPairs`, {
        useRef: initial => (ref ??= { current: initial }),
        useMemo: factory => {
          if (!memo || refresh) memo = factory();
          return memo;
        },
        suppressViewabilityRef: suppression,
        setCurrentIndex: update => { currentIndex = update(currentIndex); },
      });
    },
  };
}

test('the mounted episode list keeps its viewability pairs across Fast Refresh', () => {
  const page = mountViewability();
  const initial = page.render();
  assert.strictEqual(page.render(), initial);
  assert.strictEqual(page.render(true), initial);
});

test('the retained visibility callback follows the current fullscreen suppression flag', () => {
  const page = mountViewability();
  const [{ onViewableItemsChanged }] = page.render();
  onViewableItemsChanged({ viewableItems: [{ index: 1 }] });
  assert.equal(page.index(), 1);
  page.suppression.current = true;
  page.render(true);
  onViewableItemsChanged({ viewableItems: [{ index: 2 }] });
  assert.equal(page.index(), 1);
  page.suppression.current = false;
  onViewableItemsChanged({ viewableItems: [] });
  assert.equal(page.index(), 1);
  onViewableItemsChanged({ viewableItems: [{ index: 2 }] });
  assert.equal(page.index(), 2);
});
