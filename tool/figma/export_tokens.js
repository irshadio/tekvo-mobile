// Run with figmcp's use_figma in the Tekvo Figma file. It returns the design
// tokens as JSON; save the result to packages/core/tokens/tekvo_tokens.json
// and run `melos run tokens`.
const hex = (c) =>
  '#' +
  [c.a ?? 1, c.r, c.g, c.b]
    .map((v) => Math.round(v * 255).toString(16).padStart(2, '0'))
    .join('');
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const variables = await figma.variables.getLocalVariablesAsync();
const byId = new Map(variables.map((v) => [v.id, v]));
const collection = (name) => collections.find((c) => c.name === name);
const values = (name) => {
  const c = collection(name);
  const mode = c.modes[0].modeId;
  return c.variableIds.map((id) => [byId.get(id), byId.get(id).valuesByMode[mode]]);
};
const palette = {};
for (const [v, value] of values('Tekvo · Primitives')) {
  if (v.resolvedType === 'COLOR') palette[v.name.replace(/^color\//, '')] = hex(value);
}
const roles = (name) => {
  const out = {};
  for (const [v, value] of values(name)) {
    if (v.name.startsWith('web/')) continue;
    out[v.name] = value.type === 'VARIABLE_ALIAS'
      ? '@' + byId.get(value.id).name.replace(/^color\//, '')
      : hex(value);
  }
  return out;
};
const dimension = {};
for (const [v, value] of values('DS · Dimension')) {
  if (!v.name.startsWith('layout/')) dimension[v.name] = Math.round(value * 1000) / 1000;
}
const weights = { Regular: 400, Medium: 500, 'Semi Bold': 600, Bold: 700, 'Extra Bold': 800 };
const typography = {};
for (const s of await figma.getLocalTextStylesAsync()) {
  if (!s.name.startsWith('DS/')) continue;
  typography[s.name.slice(3)] = {
    family: s.fontName.family,
    weight: weights[s.fontName.style],
    size: s.fontSize,
    lineHeight: s.lineHeight.value,
    tracking: Math.round(s.letterSpacing.value * 100) / 100,
  };
}
const elevation = {};
for (const s of await figma.getLocalEffectStylesAsync()) {
  if (!s.name.startsWith('DS/Elevation/')) continue;
  elevation[s.name.split('/').pop()] = s.effects
    .filter((e) => e.type === 'DROP_SHADOW')
    .map((e) => ({ x: e.offset.x, y: e.offset.y, blur: e.radius, spread: e.spread ?? 0, color: hex(e.color) }));
}
return {
  palette,
  light: roles('Tekvo · Color Light'),
  dark: roles('Tekvo · Color Dark'),
  dimension,
  typography,
  elevation,
};
