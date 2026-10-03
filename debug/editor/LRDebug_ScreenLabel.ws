class LRDebug_ScreenLabel extends LRDebug_HudLabel {
    private var ratioX: float;
    private var ratioY: float;
    // In HUD units: the HUD is always 1080 units tall, but 1920 (16:9) to 2520 (21:9) wide,
    // so unit offsets keep a fixed spacing against text where screen ratios would not
    private var offsetX: float;
    private var offsetY: float;

    public function Init(id: int, ratioX: float, ratioY: float, optional offsetX: float, optional offsetY: float) {
        this.id = id;
        this.ratioX = ratioX;
        this.ratioY = ratioY;
        this.offsetX = offsetX;
        this.offsetY = offsetY;

        AcquireFlash();
    }

    /** The flash oneliner has no text setter, so changed text means rebuilding the sprite. */
    public function SetText(newText: string) {
        if (newText == this.text) return;

        this.text = newText;

        if (!created) return;

        // Nothing to show; defer the rebuild until Show() has text again.
        if (newText == "") Remove();
        else Rebuild();
    }

    public function Show() {
        if (text == "") return;

        if (!created) Rebuild();
        SetVisible(true);
    }

    private function Rebuild() {
        Remove();
        Create();
        Reposition();
    }

    private function Reposition() {
        var point: Vector = this.hud.GetScaleformPoint(ratioX, ratioY);

        SetScreenPosition(point.X + offsetX, point.Y + offsetY);
    }
}
