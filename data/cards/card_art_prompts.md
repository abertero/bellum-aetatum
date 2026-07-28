# Bellum Aetatum - Card Art Generation Guide

## Recommended AI Tool

### Primary: Leonardo.ai
- **Model**: Leonardo Diffusion XL o Leonardo Anime XL
- **Feature clave**: "Style Reference" - sube una imagen base y referencia con `--sref` o usa Image Guidance
- **Ventaja**: Especializado en game assets, permite entrenar LoRAs personalizados
- **Costo**: 150 tokens/dia gratis (suficiente para ~30 imagenes/dia)
- **Configuracion recomendada**:
  - Resolution: 768x768 o 512x768 (portrait)
  - Guidance Scale: 7-9
  - Steps: 30-40
  - Tiling: OFF

### Alternative: Midjourney
- **Modo**: `--niji 5` (anime/illustration style)
- **Style Reference**: `--sref [URL]` para consistencia
- **Ventaja**: Mejor calidad artistica, mas control de estilo
- **Costo**: $10/mes basico

---

## Style Guide (BASE STYLE)

Este es el anchor de estilo que DEBE aparecer en cada prompt para mantener consistencia:

```
2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions (large head, small body), no background details, game asset style, high contrast, flat colors with subtle gradients
```

### Negative Prompt (usar siempre):
```
realistic, photorealistic, 3D render, blurry, noisy, dark, gloomy, complex background, multiple characters, text, watermark, signature, deformed, extra limbs, bad anatomy
```

### Parametros recomendados:
- **Aspect Ratio**: 1:1 (cuadrado) o 3:4 (vertical)
- **Style**: Illustration / Anime
- **Consistency**: Usar la misma seed o style reference para todas

---

## Character Prompts

### Existing Characters (1-10)

#### 1. Knight
```
A brave knight warrior in shiny silver armor, holding a longsword and round shield, determined expression, blue cape flowing, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 2. Archer
```
A nimble elven archer with green hood and leather armor, holding a wooden longbow, quiver of arrows on back, alert pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 3. Shield Bearer (Tank)
```
A heavily armored shield bearer with massive tower shield, thick plate armor, short and stocky build, protective stance, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 4. Shadow Blade (Assassin)
```
A mysterious shadow assassin in dark purple cloak, dual daggers, hood covering face, glowing eyes, agile crouching pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 5. Cleric
```
A holy cleric in white and gold robes, holding a glowing staff with cross symbol, gentle smile, divine aura, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 6. Fire Mage
```
A powerful fire mage in red and orange robes, casting fireball from one hand, long beard, pointy hat with flame emblem, intense expression, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 7. Spearman
```
A disciplined spearman with bronze armor and long spear, rectangular shield, military helmet with crest, ready stance, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 8. War Rider (Cavalry)
```
A mounted cavalry warrior on armored warhorse, lance and banner, heavy plate armor, charging pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 9. Stone Giant
```
A massive stone giant with rocky skin, moss patches, glowing crystal eyes, huge fists, towering presence, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 10. Goblin Scout
```
A sneaky goblin scout with green skin, pointed ears, ragged leather armor, short dagger, mischievous grin, crouching pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

---

### New Characters (11-22)

#### 11. Necromancer
```
A dark necromancer in tattered black and green robes, holding a skull staff with green glow, pale skin, sunken eyes, hooded cloak, ominous pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 12. Ancient Dragon
```
A majestic ancient dragon with red scales, large wings spread, fiery breath, sharp claws, wise glowing eyes, powerful stance, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 13. Swamp Witch
```
A creepy swamp witch with warty green skin, tattered purple dress, crooked hat, holding a bubbling potion bottle, wicked smile, hunched pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 14. Berserker
```
A furious berserker warrior with wild red hair, bare chest with war paint, dual wielding axes, muscular build, raging expression, aggressive stance, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 15. Holy Paladin
```
A noble holy paladin in ornate white and gold plate armor, large blessed shield, glowing warhammer, divine halo, righteous pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 16. Crossbowman
```
A skilled crossbowman with steel crossbow, bolt pouch, leather vest and chainmail, focused expression, aiming pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 17. War Monk
```
A disciplined war monk in orange and brown robes, bald head, prayer beads, martial arts stance, glowing fists with spiritual energy, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 18. Dark Warlock
```
A sinister dark warlock in crimson and black robes, floating orbs of dark energy, curved horns, glowing red eyes, menacing pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 19. Pegasus Rider
```
A graceful pegasus rider on white winged horse, light silver armor, flowing blue cape, spear raised, soaring pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 20. Crystal Golem
```
A massive crystal golem with translucent blue crystal body, glowing core in chest, geometric facets, heavy stone fists, imposing stance, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 21. Sea Pirate
```
A rugged sea pirate with tricorn hat, eyepatch, cutlass sword and flintlock pistol, striped shirt, brown boots, confident swagger, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

#### 22. Tribal Shaman
```
A tribal shaman with feathered headdress, bone necklace, wooden staff with spirit totems, war paint, mystical aura, dancing pose, 2D cartoon game card art, chibi style, bold outlines, vibrant colors, clean vector-like shading, fantasy theme, full body character centered on white background, front-facing pose, simple geometric shapes, stylized proportions, no background details, game asset style
```

---

## Workflow for Consistent Results

### Step 1: Generate Test Image
1. Toma el prompt del Knight (#1)
2. Genera 4 variaciones
3. Elige la que mejor represente el estilo deseado
4. Guarda esta imagen como "style_reference.png"

### Step 2: Usar Style Reference
- **Leonardo.ai**: Sube style_reference.png como "Image Guidance" con modo "Style Reference"
- **Midjourney**: Usa `--sref [URL de la imagen]` en cada prompt

### Step 3: Batch Generation
1. Genera cada personaje usando el mismo style reference
2. Mantén los mismos parámetros (seed, guidance, steps)
3. Si un personaje no queda consistente, regenera con variaciones del prompt

### Step 4: Post-Processing
1. Recorta todas las imágenes al mismo tamaño
2. Ajusta brillo/contraste uniformemente
3. Remueve fondos si es necesario (usa remove.bg o similar)

---

## Tips for Consistency

1. **Mismo orden de palabras**: Mantén la estructura del prompt idéntica
2. **Mismos adjetivos de estilo**: Siempre usa "2D cartoon game card art, chibi style, bold outlines"
3. **Mismo fondo**: Siempre "white background" o "transparent background"
4. **Misma pose**: Siempre "front-facing pose" o "3/4 view" (elige uno y mantenlo)
5. **Misma iluminación**: Agrega "soft studio lighting" a todos si quieres luz uniforme
6. **Seed fija**: En Leonardo.ai, usa la misma seed para todos después de encontrar una buena

---

## Alternative: Custom LoRA (Advanced)

Si quieres máxima consistencia:
1. Genera 10-15 imágenes base con el estilo deseado
2. Entrena un LoRA en Leonardo.ai o Civitai
3. Usa ese LoRA para generar todos los personajes
4. Resultado: 95%+ consistencia de estilo

**Costo**: ~$5-10 USD para entrenamiento
**Tiempo**: 2-4 horas de entrenamiento

---

## File Naming Convention

Guarda las imágenes generadas como:
```
assets/cards/knight.png
assets/cards/archer.png
assets/cards/tank.png
assets/cards/assassin.png
assets/cards/cleric.png
assets/cards/mage.png
assets/cards/spearman.png
assets/cards/cavalry.png
assets/cards/giant.png
assets/cards/goblin.png
assets/cards/necromancer.png
assets/cards/dragon.png
assets/cards/witch.png
assets/cards/berserker.png
assets/cards/paladin.png
assets/cards/crossbowman.png
assets/cards/monk.png
assets/cards/warlock.png
assets/cards/pegasus.png
assets/cards/golem.png
assets/cards/pirate.png
assets/cards/shaman.png
```
