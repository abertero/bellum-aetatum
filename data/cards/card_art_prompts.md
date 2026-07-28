# Bellum Aetatum - Card Art Generation Guide

## Recommended AI Tool

### Primary: Leonardo.ai
- **Model**: Lucid Origin (modelo más nuevo y recomendado)
- **Feature clave**: "Style Reference" - sube una imagen base y referencia con Image Guidance
- **Ventaja**: Excelente para estilos clásicos e históricos, alta fidelidad y adherencia al prompt
- **Costo**: 150 tokens/dia gratis (suficiente para ~30 imagenes/dia)
- **Configuracion recomendada**:
  - Resolution: 768x1024 (portrait 3:4) o 832x1216 (portrait 2:3)
  - Guidance Scale: 7-9
  - Steps: 30-40
  - Tiling: OFF
  - Style: Cinematic (mejor opción disponible)
  - Alchemy: OFF
  - PhotoReal: OFF
  - Prompt Magic: ON (v3 si está disponible)

### Alternative Models en Leonardo.ai:
- **Phoenix 1.0**: "Precise prompt adherence with reliable text handling" - buena alternativa si Lucid Origin no funciona
- **Seedream 4.5**: "Rich, high-quality images with refined visual detail" - excelente calidad visual
- **NO usar**: Lucid Realism (es fotorrealista), modelos de anime, ni modelos 3D

### Alternative: Midjourney
- **Modo**: `--v 6.0` (NO usar --niji, es muy anime moderno)
- **Style Reference**: `--sref [URL]` para consistencia
- **Ventaja**: Mejor para estilos clásicos y realistas, excelente detalle histórico
- **Costo**: $10/mes basico
- **Parametros adicionales**: `--ar 3:4` para formato vertical, `--style raw` para menos estetización

### Alternative: Stable Diffusion + LoRA
- **Model**: Stable Diffusion XL + LoRA de estilo clásico
- **Ventaja**: Control total, puedes entrenar LoRAs específicos para cada época
- **Costo**: Gratis si corres localmente, o ~$5-10/mes en servicios cloud
- **Mejor para**: Máxima consistencia y control de estilo histórico

---

## Style Guide (BASE STYLE)

Este es el anchor de estilo que DEBE aparecer en cada prompt para mantener consistencia:

```
classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes and armor, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration, no multiple views, no turnaround sheet, no equipment breakdown
```

### Negative Prompt (usar siempre):
```
character sheet, turnaround, multiple views, multiple angles, reference sheet, equipment breakdown, armor pieces separated, weapon details sheet, concept art sheet, design sheet, blueprint, technical drawing, anime, modern, futuristic, sci-fi, chibi, cartoon, cute, childish, deformed, bad anatomy, bad proportions, blurry, noisy, dark, gloomy, complex background, multiple characters, text, watermark, signature, extra limbs, ugly, poorly drawn, low quality, 3D render, photorealistic, neon colors, glowing effects, magical auras, fantasy elements
```

### Parametros recomendados:
- **Aspect Ratio**: 3:4 (vertical) o 2:3 (portrait)
- **Style**: Classic Animation / Historical Illustration
- **Model**: Lucid Origin (NO usar Lucid Realism, NO usar modelos de anime)
- **Consistency**: Usar la misma seed o style reference para todas

---

## Leonardo.ai - Modelo Correcto

### Cómo encontrar Lucid Origin:
1. Ve a "Image Generation" en el menú lateral
2. En la parte superior, haz click en el dropdown de modelos
3. Selecciona **"Lucid Origin"** de la lista (es el modelo featured/new)
4. NO uses: Lucid Realism, Phoenix 0.9, modelos de anime, ni 3D Animation Style

### Modelos disponibles (actualizado 2026):
- **Lucid Origin** (RECOMENDADO) - "High-fidelity images with strong prompt adherence"
- **Phoenix 1.0** (ALTERNATIVA) - "Precise prompt adherence with reliable text handling"
- **Seedream 4.5** (ALTERNATIVA) - "Rich, high-quality images with refined visual detail"
- **NO usar**: Lucid Realism, GPT-Image, Nano Banana, FLUX, Ideogram (no son adecuados para este estilo)

### Configuración recomendada en Leonardo:
- **Model**: Lucid Origin
- **Style**: Cinematic (es la mejor opción disponible, funciona bien para estilo clásico)
- **Resolution**: 768x1024 (3:4 portrait)
- **Guidance Scale**: 7
- **Steps**: 30
- **Alchemy**: OFF (causa más variaciones indeseadas)
- **PhotoReal**: OFF
- **Prompt Magic**: ON (v3 si está disponible)

### Nota sobre "Auto" mode:
- Si ves una opción "Auto" que no muestra precio, probablemente sea un selector automático de modelo
- NO lo uses - selecciona manualmente "Lucid Origin" para tener control total
- Los modelos "unlimited" (anime, 3D) son ilimitados pero no adecuados para nuestro estilo histórico

---

## Historical Accuracy Notes

Para maximizar la distintividad de cada época, cada prompt incluye:
- **Materiales específicos** de la época (cuero crudo, bronce, hierro, acero)
- **Técnicas de construcción** históricas (remaches, forjado, tejido manual)
- **Colores auténticos** (tierras naturales, no colores saturados)
- **Desgaste realista** (armaduras abolladas, telas remendadas, armas usadas)
- **Proporciones culturales** (cada civilización tiene siluetas distintas)

---

## Character Prompts - Base Historical Units

### PREHISTORIC ERA (10,000 BCE - 3,000 BCE)

#### 1. Caveman Warrior
```
A prehistoric caveman warrior wearing animal fur pelts and bone jewelry, wielding a stone-tipped spear and crude hand axe, muscular build from hunting, wild unkempt hair, face paint with natural ochre, barefoot with leather wraps, aggressive stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 2. Tribal Shaman
```
A prehistoric tribal shaman wearing elaborate feather headdress and animal skull necklace, holding a carved wooden staff with bone charms, painted ritual symbols on skin, wearing layered animal hides and woven grass, mystical but grounded appearance, wise aged face, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### ANCIENT ERA (3,000 BCE - 500 CE)

#### 3. Iron Age Nomad
```
An Iron Age nomadic warrior wearing layered wool and leather armor with bronze buckles, carrying a composite bow and short iron sword, wearing a fur-lined cap and wrapped trousers, weathered face from travel, riding gear attached to belt, practical and mobile appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 4. Roman Legionary
```
A Roman legionary soldier wearing segmented lorica segmentata plate armor, red wool tunic underneath, carrying large rectangular scutum shield and gladius short sword, wearing iron gallic helmet with cheek guards, caligae sandals with hobnails, clean-shaven face, disciplined military stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 5. Roman Centurion
```
A Roman centurion officer wearing ornate lorica musculata bronze breastplate with decorative motifs, crimson cloak pinned at shoulder, transverse crest helmet indicating rank, carrying vine staff of command, pugio dagger at belt, armored skirt with leather pteruges, authoritative stance, veteran soldier appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### MEDIEVAL ERA (500 CE - 1500 CE) - EUROPE

#### 6. Viking Raider
```
A Viking raider wearing layered wool tunic over chainmail hauberk, round wooden shield with iron boss, bearded axe, wearing leather helmet with nose guard (NOT horned), fur-trimmed cloak, wool leg wraps, practical seafaring gear, rugged weathered face, braided beard, aggressive stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 7. Viking Berserker
```
A Viking berserker warrior wearing minimal armor, bare-chested with wolf pelt over shoulders, wielding large Dane axe with two hands, wild eyes and screaming expression, body paint and ritual tattoos, iron armbands and bronze brooches, frenzied combat stance, muscular build, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 8. Knight Templar
```
A Knight Templar wearing white surcoat with red cross pattée over chainmail hauberk, great helm with flat top and eye slits, carrying heater shield with templar seal, longsword at hip, wearing mail coif under helm, armored gauntlets, disciplined upright posture, clean-shaven face showing piety, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 9. Medieval Witch
```
A medieval village witch wearing simple wool dress with linen apron, leather belt with herb pouches and glass vials, wooden staff with carved runes, wearing a pointed wool hood, weathered aged face with knowing expression, carrying basket of gathered herbs, practical peasant clothing with mystical accessories, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 10. Crusader Knight
```
A Crusader knight wearing chainmail hauberk with blue surcoat displaying cross, kettle helm or early great helm, carrying kite shield with crusader emblem, longsword and mace, mail chausses covering legs, battle-worn armor showing campaign wear, tanned face from eastern sun, determined expression, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 11. Mongol Horse Archer
```
A Mongol horse archer wearing layered silk and leather lamellar armor, fur-trimmed hat with ear flaps, composite recurve bow made from horn and sinew, quiver of arrows at belt, wearing practical riding boots and trousers, weathered steppe face with high cheekbones, compact muscular build from riding, alert scanning pose, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### FEUDAL JAPAN ERA (1185 CE - 1868 CE)

#### 12. Samurai Warrior
```
A samurai warrior wearing ornate lacquered lamellar armor (lamellar plates laced together), kabuto helmet with family crest (mon), menpo face mask, carrying katana and wakizashi daisho pair, wearing hakama trousers and waraji sandals, disciplined posture, shaved forehead with topknot, honorable bearing, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 13. Ronin
```
A ronin masterless samurai wearing worn and faded armor with mismatched pieces, straw hat (kasa) hiding face, carrying katana with worn wrapping, wearing travel-stained kimono and geta sandals, unshaven face with weary expression, carrying belongings in cloth bundle, wandering swordsman appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 14. Shinobi Ninja
```
A shinobi ninja wearing dark indigo-dyed shozoku outfit with hooded mask, lightweight armor hidden under cloth, carrying ninjato straight sword and climbing tools, wearing tabi split-toe boots, carrying shuriken and smoke bombs at belt, crouched stealthy pose, only eyes visible above mask, athletic build, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### RENAISSANCE ERA (1400 CE - 1600 CE)

#### 15. Ottoman Janissary
```
An Ottoman janissary wearing distinctive white felt borek headdress, blue caftan robe with decorative trim, carrying matchlock musket and kilij curved sword, wearing leather armor over robes, leather boots with pointed toes, disciplined military stance, clean-shaven face with mustache, elite imperial soldier appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 16. French Musketeer
```
A French musketeer wearing blue cassock with white cross, broad-brimmed hat with feather, carrying wheel-lock musket and rapier sword, wearing leather bandolier with powder charges, leather boots with fold-over cuffs, flamboyant noble bearing, styled mustache and goatee, confident swaggering pose, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

## Workflow for Consistent Results

### Step 1: Generate Test Image
1. Toma el prompt del Caveman Warrior (#1) con el estilo Ghibli/histórico
2. Genera 4 variaciones en **Lucid Origin** (NO Lifelike, NO modelos de anime)
3. Elige la que mejor represente el estilo clásico deseado
4. Guarda esta imagen como "style_reference.png"
5. Verifica que tenga: detalle histórico, materiales realistas, colores tierra, sin elementos futuristas
6. Verifica que sea UNA SOLA imagen del personaje, NO un character sheet

### Step 2: Usar Style Reference
- **Leonardo.ai**: Sube style_reference.png como "Image Guidance" con modo "Style Reference"
- **Midjourney**: Usa `--sref [URL de la imagen]` en cada prompt
- **Stable Diffusion**: Usa img2img con denoising strength 0.3-0.5

### Step 3: Batch Generation
1. Genera cada personaje usando el mismo style reference
2. Mantén los mismos parámetros (seed, guidance, steps)
3. Si un personaje no queda consistente, regenera con variaciones del prompt
4. Verifica que cada época sea visualmente distinta

### Step 4: Post-Processing
1. Recorta todas las imágenes al mismo tamaño
2. Ajusta brillo/contraste uniformemente
3. Remueve fondos si es necesario (usa remove.bg o similar)
4. Verifica consistencia de escala entre personajes

---

## Tips for Historical Consistency

1. **Mismo orden de palabras**: Mantén la estructura del prompt idéntica
2. **Mismos adjetivos de estilo**: Siempre usa "classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy"
3. **Mismo fondo**: Siempre "white background" para consistencia
4. **Misma pose**: Siempre "front-facing pose" para cards
5. **Misma iluminación**: "warm natural lighting" para todos
6. **Seed fija**: Usa la misma seed para todos después de encontrar una buena
7. **Materiales específicos**: Cada prompt menciona materiales de su época
8. **Colores de época**: Usa solo colores disponibles en cada período histórico
9. **Desgaste realista**: Todos deben mostrar uso y edad apropiados
10. **Sin elementos anacrónicos**: Revisa que no haya cremalleras, botones modernos, etc.

---

## Alternative: Custom LoRA (Advanced)

Si quieres máxima consistencia:
1. Genera 10-15 imágenes base con el estilo Ghibli/histórico deseado
2. Entrena un LoRA en Leonardo.ai o Civitai usando estas imágenes
3. Usa ese LoRA para generar todos los personajes
4. Resultado: 95%+ consistencia de estilo

**Modelos recomendados para LoRA**:
- Lucid Origin (base para entrenar) - MEJOR para este estilo
- Phoenix 1.0 (alternativa sólida)
- Seedream 4.5 (excelente calidad visual)
- NO usar: Lucid Realism, modelos de anime, modelos 3D

**Costo**: ~$5-10 USD para entrenamiento
**Tiempo**: 2-4 horas de entrenamiento

---

## File Naming Convention

Guarda las imágenes generadas como:
```
assets/cards/caveman.png
assets/cards/tribal_shaman.png
assets/cards/iron_nomad.png
assets/cards/roman_legionary.png
assets/cards/roman_centurion.png
assets/cards/viking_raider.png
assets/cards/viking_berserker.png
assets/cards/knight_templar.png
assets/cards/medieval_witch.png
assets/cards/samurai.png
assets/cards/ronin.png
assets/cards/ninja.png
assets/cards/mongol_archer.png
assets/cards/crusader.png
assets/cards/ottoman_janissary.png
assets/cards/musketeer.png
```

---

## Future: Legendary Characters

Cuando agregues personajes legendarios, mantén el mismo style guide pero agrega:
- "legendary hero aura" o "mythical presence"
- "iconic historical appearance"
- "famous recognizable features"

Ejemplo para Gilgamesh:
```
Gilgamesh, legendary Sumerian king, wearing ornate golden armor with lion motifs, holding divine weapon, majestic beard, crown of horns, heroic imposing stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate ancient Mesopotamian costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration, legendary hero aura, iconic historical appearance
```
