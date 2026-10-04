# Light Rewrite - Cohgent fork

> **This is an unofficial fork of [webspam/LightRewrite](https://github.com/webspam/LightRewrite) by Cohgent.**
> Work lives on the `cohgent` branch, which tracks upstream by merging (currently up to v0.15.0).
> The original mod, its releases and support are upstream. The original README follows [below](#light-rewrite-or-next-gen-lighting-fix).

## What this fork adds

### 1. Per-light matching: `<match_position>`

Upstream rules match by template file and layer path, so every copy of a template on a layer gets the same values.
This fork adds a position filter, so a rule can target one placed light:

```xml
<override tag_name="LR_Example" label="example" brightness="20.91">
  <match mode="exact">baron_candle_holder.w2ent</match>
  <match_position x="1709.631" y="970.622" z="8.242" />
</override>
```

- Compares the entity's world position per axis within `tolerance` (default `0.05` m). `z` is optional.
- Also works in a group's `<matches>`; with a large `tolerance` it limits a group to a box-shaped area.
- Defined in `src/xml/CLightRewritePositionRule.ws`; documented in `data/LightRewriteDefinitions.xsd`.

### 2. Relative adjustments: `*_scale` (experimental)

`brightness_scale`, `radius_scale` and `attenuation_scale`, on overrides, `<light index>` and `<spotlight>`:

```xml
<override tag_name="LR_Example_Brazier" label="example_brazier" brightness_scale="0.7" radius_scale="1.3">
  <match>brazier</match>
  <spotlight brightness_scale="0.7" />
</override>
```

- Multiplies the value resolved by lower-weight overrides, or the light's vanilla value if none set it.
- Always applied to the saved original, so re-applying (ignition, profile change, mod toggle) never compounds.
- A later absolute value replaces it; stacked scales multiply; an element with both uses the absolute value.
- Lets blanket rules dim whole families of lights without flattening their differences.

### 3. Debug editor improvements

- **Per-light export:** each exported light carries its world position, and `tools/Export-Lights.ps1` writes one
  override per light with `<match_position>`, instead of collapsing copies into a `_Duplicates` block.
- **HUD layout for any aspect ratio:** the attribute grid and side labels are placed in HUD units from screen centre,
  so they no longer overlap on 16:9 (they were tuned for 21:9). Columns are spaced for their longest rows.
- **Mod state indicator:** shows `LightRewrite ON` / `OFF (originals)`, so the mod toggle isn't mistaken for an edit.
- Point/spot selection is upstream's `LRDebug_CycleLight` action; spotlights are only editable when it is bound.

### 4. The Cohgent profile (`data/cohgent/`)

Cohgent's personal profile, built on Realistic, mostly from in-game editor sessions.

| Path | Weight | Contents | Works on upstream? |
|---|---|---|---|
| `cohgent.xml` | 0 | Profile base: `<inherits>Realistic</inherits>` | Yes |
| `blanket.xml` | 90 | Relative `*_scale` rules | **No** - needs this fork |
| `compat/<layer>.xml` | 95 | Template + layer rules, absolute values only | **Yes** |
| `instance/<layer>.xml` | 100 | Per-light `<match_position>` entries | **No** - needs this fork |

#### Upstream compatibility

- `compat/` uses only upstream features; the consolidation tooling refuses to write positions or scales there.
- `instance/` and `blanket.xml` depend on this fork. Upstream ignores unknown elements and attributes rather than
  rejecting them, so on upstream per-light entries would apply to every copy of their template, and scale rules would have no effect.
- All rules use `profile_name="Cohgent"` and Cohgent's weights; the matches and values are independent of the profile.
- Values were tuned on top of Realistic, with RT on and HDR at peak 300 / paper white 100 nits.

---

# Light Rewrite, or Next Gen Lighting Fix

_Edits lights like candles and torches to be next-gen ray trace friendly, by editing the entities at runtime._

## Comparisons

<https://webspam.github.io/LightRewrite/>

## The problem

Most light sources in the game were designed to only influence a tiny little sphere. Witcher 3 was written for 2015 hardware; a candle was intended to tint and highlight objects sitting right in front of it, not light an entire room. Scene lighting was handled by **much** cheaper lighting tricks.

With modern RT lighting, the result is tiny spheres of super-bright light, that end abruptly on an inexplicable ocean of blackness.

## The traditional solution

You could update every level and light source to use modern lighting styles. Folks have done this before. Editing level files requires diligence to do cleanly, is a huge job to do once, and maintaining it is actually worse. Most lighting mods have been abandoned and are often compatibility nightmares for users.

Unless CDPR gives us a new baseline, this is just impractical.

## Introducing: dirty hax

This mod instead edits the properties of lights at runtime. When entities are first spawned, light sources are identified and classified (in a semi-optimised way, purportedly). Candles get edited to have more candle-like candlelight. Torches get torched. etc.

#### Before

<img width="3840" height="1440" alt="vizima-welcome-before-219" src="https://github.com/user-attachments/assets/0c185c38-c12e-48b0-ac2d-968e8fd7f641" />

#### After

<img width="3840" height="1440" alt="vizima-welcome-after-219" src="https://github.com/user-attachments/assets/9efcdcec-d6f8-4aae-ac18-ed0da16f8997" />

---

#### Caveats and other fine print

This isn't perfect. It matches by layer & entity paths (so most rules hit more than one light).

I _guarantee_ this will not work with **every** combination of mods.

That said, I'm extremely keen (at time of writing) to hear about any misidentified light sources or terrible results. ... assuming you can give me a screen shot and a mod list.

---

### Installation instructions

- Install with W3MM / Vortex

-OR-

- &lt;insert link to generic manual mod installation guide here&gt;

### Requirements

- Witcher 3 - Next-Gen 4.04 (probably)
- [Community Patch - Shared Imports](https://www.nexusmods.com/witcher3/mods/2110)

### Recommended

- [Cozy RTX Fires](https://www.nexusmods.com/witcher3/mods/8772) - Slightly increase direct light ray distance (causes colour bleeding at high settings)
