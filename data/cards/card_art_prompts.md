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

#### 3. Mammoth Hunter (mammoth_hunter.png)
```
A prehistoric mammoth hunter wearing thick mammoth fur cloak with bone needle stitching, wielding a large bone-tipped harpoon and stone scraper knife, wearing protective mammoth bone plate armor on chest, sinew-wrapped arms and legs, face marked with mammoth blood ritual paint, muscular stocky build from tracking megafauna, alert tracking stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 4. Cave Painter (cave_painter.png)
```
A prehistoric cave painter wearing simple animal hide tunic with pigment-stained hands, carrying a hollow bone blowpipe for spraying pigments and a clay palette with red ochre and charcoal, wearing a small pouch of ground minerals at belt, lean artistic build, thoughtful observant expression, fingers stained with natural pigments, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 5. Rock Thrower (rock_thrower.png)
```
A prehistoric rock thrower wearing heavy cave bear pelt with the skull still attached as shoulder armor, wielding a large rounded boulder in each massive hands, wearing thick leather leg wraps and barefoot with calloused soles, enormous muscular build from lifting stones, broad powerful shoulders, fierce intimidating stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### ANCIENT ERA (3,000 BCE - 500 CE)

#### 6. Iron Age Nomad
```
An Iron Age nomadic warrior wearing layered wool and leather armor with bronze buckles, carrying a composite bow and short iron sword, wearing a fur-lined cap and wrapped trousers, weathered face from travel, riding gear attached to belt, practical and mobile appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 7. Roman Legionary
```
A Roman legionary soldier wearing segmented lorica segmentata plate armor, red wool tunic underneath, carrying large rectangular scutum shield and gladius short sword, wearing iron gallic helmet with cheek guards, caligae sandals with hobnails, clean-shaven face, disciplined military stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 8. Roman Centurion
```
A Roman centurion officer wearing ornate lorica musculata bronze breastplate with decorative motifs, crimson cloak pinned at shoulder, transverse crest helmet indicating rank, carrying vine staff of command, pugio dagger at belt, armored skirt with leather pteruges, authoritative stance, veteran soldier appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 9. Spartan Hoplite (spartan_hoplite.png)
```
A Spartan hoplite warrior wearing bronze bell cuirass with muscle relief detailing, large round aspis shield with lambda emblem, long doru spear with leaf-shaped bronze tip, wearing bronze Corinthian helmet with horsehair crest dyed red, bronze greaves on shins, short red wool tunic visible under armor, imposing disciplined stance, battle-scarred muscular build, long hair in accordance with Spartan custom, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 10. Egyptian Archer (egyptian_archer.png)
```
An Egyptian archer wearing pleated white linen kilt with broad decorative collar, leather scale armor on chest, wielding a tall self bow made of acacia wood, quiver of bronze-tipped reed arrows at back, wearing a nemes headcloth with false beard indicating royal service, kohl-lined eyes, barefoot with leather sandals at belt, lean athletic build from training, steady aiming stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 11. Persian Immortal (persian_immortal.png)
```
A Persian Immortal elite guard wearing layered scale armor over colorful long-sleeved tunic, carrying a short spear with silver pomegranate butt and a composite bow, wearing a soft Persian tiara headband that can be pulled up as face protection, ornate gold jewelry and armlets, carrying a decorated gorytos bow case at hip, well-groomed beard and curly hair, regal disciplined bearing, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 12. Celtic Warrior (celtic_warrior.png)
```
A Celtic warrior wearing bronze chainmail shirt with intricate spiral engravings, carrying a large oval wooden shield with painted La Tene swirl designs and a long iron slashing sword, wearing a bronze torc necklace at neck, bare-chested under mail showing body paint and woad blue tattoos, wild spiky lime-washed hair, fierce battle cry expression, muscular lean build, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### MEDIEVAL ERA (500 CE - 1500 CE) - EUROPE

#### 13. Viking Raider
```
A Viking raider wearing layered wool tunic over chainmail hauberk, round wooden shield with iron boss, bearded axe, wearing leather helmet with nose guard (NOT horned), fur-trimmed cloak, wool leg wraps, practical seafaring gear, rugged weathered face, braided beard, aggressive stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 14. Viking Berserker
```
A Viking berserker warrior wearing minimal armor, bare-chested with wolf pelt over shoulders, wielding large Dane axe with two hands, wild eyes and screaming expression, body paint and ritual tattoos, iron armbands and bronze brooches, frenzied combat stance, muscular build, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 15. Knight Templar
```
A Knight Templar wearing white surcoat with red cross pattée over chainmail hauberk, great helm with flat top and eye slits, carrying heater shield with templar seal, longsword at hip, wearing mail coif under helm, armored gauntlets, disciplined upright posture, clean-shaven face showing piety, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 16. Medieval Witch
```
A medieval village witch wearing simple wool dress with linen apron, leather belt with herb pouches and glass vials, wooden staff with carved runes, wearing a pointed wool hood, weathered aged face with knowing expression, carrying basket of gathered herbs, practical peasant clothing with mystical accessories, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 17. Crusader Knight
```
A Crusader knight wearing chainmail hauberk with blue surcoat displaying cross, kettle helm or early great helm, carrying kite shield with crusader emblem, longsword and mace, mail chausses covering legs, battle-worn armor showing campaign wear, tanned face from eastern sun, determined expression, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 18. Mongol Horse Archer
```
A Mongol horse archer wearing layered silk and leather lamellar armor, fur-trimmed hat with ear flaps, composite recurve bow made from horn and sinew, quiver of arrows at belt, wearing practical riding boots and trousers, weathered steppe face with high cheekbones, compact muscular build from riding, alert scanning pose, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 19. English Longbowman (english_longbowman.png)
```
An English longbowman wearing a simple padded gambeson with chainmail shirt underneath, green and brown wool hood, carrying a tall yew longbow as tall as himself, quiver of bodkin-tipped arrows tucked into a leather belt, wearing leather bracers on forearms, practical peasant cloth leggings and leather ankle boots, weathered sun-tanned face with squinting archer eyes, strong forearms from years of drawing heavy bow, steady confident stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 20. Scottish Highlander (scottish_highlander.png)
```
A Scottish highland warrior wearing a belted plaid great kilt of tartan wool in muted earth tones draped over one shoulder, carrying a claymore two-handed sword and a round targe shield with leather boss, wearing a blue bonnet with clan badge, bare legs with wool tartan hose, brogue shoes, rugged weathered face with reddish beard, tall athletic build, defiant proud stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 21. Teutonic Knight (teutonic_knight.png)
```
A Teutonic knight wearing a white surcoat with black cross over full plate armor, great helm with narrow eye slits and breathing holes, heavy steel gauntlets, carrying a longsword with cruciform hilt and a kite shield bearing the Teutonic black cross, chainmail visible at joints, armored boots, broad imposing build, rigid pious posture beneath the heavy armor, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### FEUDAL JAPAN ERA (1185 CE - 1868 CE)

#### 22. Samurai Warrior
```
A samurai warrior wearing ornate lacquered lamellar armor (lamellar plates laced together), kabuto helmet with family crest (mon), menpo face mask, carrying katana and wakizashi daisho pair, wearing hakama trousers and waraji sandals, disciplined posture, shaved forehead with topknot, honorable bearing, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 23. Ronin
```
A ronin masterless samurai wearing worn and faded armor with mismatched pieces, straw hat (kasa) hiding face, carrying katana with worn wrapping, wearing travel-stained kimono and geta sandals, unshaven face with weary expression, carrying belongings in cloth bundle, wandering swordsman appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 24. Shinobi Ninja
```
A shinobi ninja wearing dark indigo-dyed shozoku outfit with hooded mask, lightweight armor hidden under cloth, carrying ninjato straight sword and climbing tools, wearing tabi split-toe boots, carrying shuriken and smoke bombs at belt, crouched stealthy pose, only eyes visible above mask, athletic build, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 25. Ashigaru Foot Soldier (ashigaru.png)
```
An ashigaru foot soldier wearing a simple okini (conical hat) and light lacquered leather armor with rope lacing, carrying a long yari spear with iron tip, wearing a short sword at waist as secondary weapon, straw waraji sandals, simple indigo cotton kimono underneath armor, weathered peasant face with determined expression, lean wiry build from marching and drilling, disciplined formation stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 26. Onna-musha (onna_musha.png)
```
An onna-musha female warrior wearing colorful lacquered lamellar armor with decorative lacing in red and gold, carrying a naginata polearm with curved blade, wearing a ornate kabuto helmet with flowing hair visible beneath, a short kaiken dagger tucked in obi sash, wearing hakama trousers and armored boots, fierce determined expression, graceful yet deadly posture, long black hair partially tied back, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 27. Sohei Warrior Monk (sohei_monk.png)
```
A sohei warrior monk wearing a white and saffron Buddhist monk robe with lightweight chain armor underneath, carrying a large wooden naginata polearm, wearing a Zukin head cloth covering the head, prayer beads wrapped around wrist, wearing simple waraji straw sandals, shaved head visible under cloth, calm meditative expression contrasting with martial stance, lean athletic build from ascetic training, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

---

### RENAISSANCE ERA (1400 CE - 1600 CE)

#### 28. Ottoman Janissary
```
An Ottoman janissary wearing distinctive white felt borek headdress, blue caftan robe with decorative trim, carrying matchlock musket and kilij curved sword, wearing leather armor over robes, leather boots with pointed toes, disciplined military stance, clean-shaven face with mustache, elite imperial soldier appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 29. French Musketeer
```
A French musketeer wearing blue cassock with white cross, broad-brimmed hat with feather, carrying wheel-lock musket and rapier sword, wearing leather bandolier with powder charges, leather boots with fold-over cuffs, flamboyant noble bearing, styled mustache and goatee, confident swaggering pose, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 30. Spanish Conquistador (spanish_conquistador.png)
```
A Spanish conquistador wearing polished steel morion helmet with tall crest, half-plate armor over a rich doublet with gold embroidery, carrying a long steel rapier and a small round buckler shield, wearing leather riding boots with spurs, a cape draped over one shoulder, well-groomed beard and stern aristocratic face, upright commanding posture, battle-hardened veteran appearance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 31. Swiss Halberdier (swiss_halberdier.png)
```
A Swiss halberdier wearing a tall black felt hat with a white ostrich feather plume, padded slashed doublet in white and blue, carrying a large halberd with axe blade and spear point, wearing a steel breastplate over the doublet, leather gauntlets, puffed slashed sleeves in the Swiss style, sturdy boots, broad powerful build, stern disciplined stance, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 32. Landsknecht (landsknecht.png)
```
A German landsknecht mercenary wearing an outrageously colorful slashed doublet with puffed sleeves in contrasting fabrics, a wide flat beret hat with ostrich feathers, carrying a large zweihander two-handed sword with parrying hooks, wearing a ornate chain at neck, puffy trunk hose with striped patterns, leather shoes with slash details, flamboyant confident pose, well-groomed mustache and chin tuft, theatrical bearing, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
```

#### 20. Venetian Admiral (venetian_admiral.png)
```
A Venetian admiral wearing an ornate navy blue coat with gold braid and Venetian lion emblem, a tricorn hat with gold cockade and plume, carrying a spyglass telescope and a ceremonial cutlass sword at hip, wearing a fine white lace cravat at neck, leather riding boots polished to a shine, a heavy gold chain of office around neck, distinguished silver-streaked beard, weathered seafaring face with sharp intelligent eyes, upright authoritative posture, classic animation illustration style, Studio Ghibli aesthetic, detailed historical accuracy, period-accurate costumes, hand-painted texture, warm natural lighting, rich earth tones, realistic proportions, detailed fabric textures, weathered materials, single character standing pose, full body centered on plain white background, front-facing view, single complete illustration
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
assets/cards/mammoth_hunter.png
assets/cards/cave_painter.png
assets/cards/rock_thrower.png
assets/cards/iron_nomad.png
assets/cards/roman_legionary.png
assets/cards/roman_centurion.png
assets/cards/spartan_hoplite.png
assets/cards/egyptian_archer.png
assets/cards/persian_immortal.png
assets/cards/celtic_warrior.png
assets/cards/viking_raider.png
assets/cards/viking_berserker.png
assets/cards/knight_templar.png
assets/cards/medieval_witch.png
assets/cards/english_longbowman.png
assets/cards/scottish_highlander.png
assets/cards/teutonic_knight.png
assets/cards/mongol_archer.png
assets/cards/crusader.png
assets/cards/samurai.png
assets/cards/ronin.png
assets/cards/ninja.png
assets/cards/ashigaru.png
assets/cards/onna_musha.png
assets/cards/sohei_monk.png
assets/cards/ottoman_janissary.png
assets/cards/musketeer.png
assets/cards/spanish_conquistador.png
assets/cards/swiss_halberdier.png
assets/cards/landsknecht.png
assets/cards/venetian_admiral.png
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
