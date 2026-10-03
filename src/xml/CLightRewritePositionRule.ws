/** Matches an entity by its world position, singling out one placed instance among copies of a template */
class CLightRewritePositionRule extends ILightRewriteMatchRule {
    public var position : Vector;
    public var tolerance: float;
    // Without z, stacked lights (e.g. on different floors) share a match
    public var matchZ   : bool;

    default tolerance = 0.05;
    default matchZ = true;

    public function Matches(entity: CGameplayEntity): bool {
        var entityPos: Vector = entity.GetWorldPosition();

        if (AbsF(entityPos.X - position.X) > tolerance) return false;
        if (AbsF(entityPos.Y - position.Y) > tolerance) return false;
        return !matchZ || AbsF(entityPos.Z - position.Z) <= tolerance;
    }
}
