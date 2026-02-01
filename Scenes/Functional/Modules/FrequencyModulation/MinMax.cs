using Godot;

namespace Infobreach.Scenes.Functional.Modules.FrequencyModulation;

[GlobalClass]
public partial class MinMax(float min, float max) : Resource
{
    [Export] public float Min = min;
    [Export] public float Max = max;

    public MinMax() : this(0f, 1f)
    {
    }
}