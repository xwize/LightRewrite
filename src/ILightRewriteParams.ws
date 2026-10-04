/*
 * Base class for light entry params. Holds the light component properties that
 * are shared between point light overrides and spotlight overrides.
 *
 * Effectively maps to CLightComponent fields.
 */
abstract class ILightRewriteParams {
    public var enabled: SLightRewriteOptionalBool;

    public var brightness: SLightRewriteOptionalFloat;

    public var radius: SLightRewriteOptionalFloat;

    // Attenuation - how quickly the light fades out with distance
    public var attenuation: SLightRewriteOptionalFloat;

    // Distance at which the player shadow starts to fade
    public var shadowFadeDistance: SLightRewriteOptionalFloat;

    // Range over which the shadow fades from shadowFadeDistance
    public var shadowFadeRange: SLightRewriteOptionalFloat;

    public var shadowBlendFactor: SLightRewriteOptionalFloat;

    public var castShadows: SLightRewriteOptionalShadowMode;

    public var color: SLightRewriteOptionalColour;

    // Local-space position override for the light
    public var offset: SLightRewriteOptionalVector;

    // Multipliers for blanket adjustments. A scale multiplies the value resolved by earlier
    // overrides, or the light's vanilla value when none set it; a later absolute value replaces it.
    public var brightnessScale : SLightRewriteOptionalFloat;
    public var radiusScale     : SLightRewriteOptionalFloat;
    public var attenuationScale: SLightRewriteOptionalFloat;

    public function ApplyBaseTo(target: ILightRewriteParams) {
        if (enabled.has) target.enabled = enabled;

        // An absolute value wins over a scale on the same entry
        if (brightness.has) {
            target.brightness = brightness;
            target.brightnessScale.has = false;
        }
        else if (brightnessScale.has) {
            if (target.brightness.has) target.brightness.value *= brightnessScale.value;
            else target.brightnessScale = LR_CombineScale(target.brightnessScale, brightnessScale.value);
        }

        if (radius.has) {
            target.radius = radius;
            target.radiusScale.has = false;
        }
        else if (radiusScale.has) {
            if (target.radius.has) target.radius.value *= radiusScale.value;
            else target.radiusScale = LR_CombineScale(target.radiusScale, radiusScale.value);
        }

        if (attenuation.has) {
            target.attenuation = attenuation;
            target.attenuationScale.has = false;
        }
        else if (attenuationScale.has) {
            if (target.attenuation.has) target.attenuation.value *= attenuationScale.value;
            else target.attenuationScale = LR_CombineScale(target.attenuationScale, attenuationScale.value);
        }

        if (shadowFadeDistance.has) target.shadowFadeDistance = shadowFadeDistance;
        if (shadowFadeRange.has) target.shadowFadeRange = shadowFadeRange;
        if (shadowBlendFactor.has) target.shadowBlendFactor = shadowBlendFactor;
        if (castShadows.has) target.castShadows = castShadows;
        if (color.has) target.color = color;
        if (offset.has) target.offset = offset;
    }
}

/** Stacked scales multiply, so two blanket rules of x0.8 give x0.64 */
function LR_CombineScale(current: SLightRewriteOptionalFloat, scale: float): SLightRewriteOptionalFloat {
    var combined: SLightRewriteOptionalFloat = current;

    if (combined.has) {
        combined.value *= scale;
    }
    else {
        combined.has = true;
        combined.value = scale;
    }
    return combined;
}

/** Absolute value if set, else the vanilla value times any scale */
function LR_ResolveScaled(
    value: SLightRewriteOptionalFloat,
    scale: SLightRewriteOptionalFloat,
    vanilla: float
): float {
    if (value.has) return value.value;
    if (scale.has) return vanilla * scale.value;
    return vanilla;
}
