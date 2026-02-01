using Godot;

namespace Infobreach.Scenes.Functional.Modules.FrequencyModulation;

public partial class SinusoidalCurve2D : Line2D
{
    [Export] private float _amplitude = 80f;
    [Export] private float _period = 1f;
    [Export] private float _staticPhase = 0f;
    [Export] private float _stepPercent = 0.025f;
    [Export] private float _xAxisLengthPx = 256f;

    private Vector2 _originRelativeXAxisBeginningPoint;
    private float _frequency;
    private int _count;
    private float _dynamicPhase = 0f;
    

    public override void _Ready()
    {
        Initialize();
        Rebuild();
    }
    
    public void SetAmplitude(float amplitudePx)
    {
        _amplitude = amplitudePx;
    }
    
    public void SetPeriod(float periodPx)
    {
        _period = periodPx;
        _frequency = Mathf.Tau / _period;
    }
    
    public void SetStaticPhase(float staticPhase)
    {
        _staticPhase = staticPhase;
    }
    
    public void UpdateDynamicPhase(float deltaPhase)
    {
        _dynamicPhase = (_dynamicPhase + deltaPhase) % Mathf.Tau;
        Rebuild();
    }

    private void Rebuild()
    {
        ClearPoints();
        
        var pts = new Vector2[_count];

        for (int i = 0; i < _count; i++)
        {
            var mult = i * _stepPercent;
            
            var point = new Vector2(_xAxisLengthPx * (-1 + 2 * mult) / 2,
                _amplitude * Mathf.Sin(_frequency * mult + _staticPhase + _dynamicPhase));
            
            pts[i] = point;
        }

        SetPoints(pts);
    }
    
    private void Initialize()
    {
        _frequency = Mathf.Tau / _period;
        _count = Mathf.CeilToInt(1f / _stepPercent) + 1;
    }
}