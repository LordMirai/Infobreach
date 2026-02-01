using System;
using Godot;

namespace Infobreach.Scenes.Functional.Modules.FrequencyModulation;

public partial class FrequencyModulationMinigame : Control
{
    [Export] private Label _countdownLabel;
    [Export] private SinusoidalCurve2D _expectedCurve;
    [Export] private SinusoidalCurve2D _userCurve;
    [Export] private Slider _amplitudeSlider;
    [Export] private Slider _periodSlider;
    [Export] private Slider _staticPhaseSlider;
    [Export] private MinMax _amplitudeRange = new(30f, 120f);
    [Export] private MinMax _periodRange = new(0.5f, 4f);
    [Export] private MinMax _staticPhaseRange = new(0f, Mathf.Tau);
    [Export] private ProgressBar _holdProgressBar;
    [Export] private float _amplitudeErrorTolerance = 6f;
    [Export] private float _periodErrorTolerance = 0.4f;
    [Export] private float _staticPhaseErrorTolerance = Mathf.Tau / 20;
    [Export] private float _timeToSolve = 30f;
    [Export] private float _holdDuration = 3f;

    [Signal]
    public delegate void MinigameCompletedEventHandler();

    [Signal]
    public delegate void MinigameFailedEventHandler();

    private float _expectedAmplitude;
    private float _expectedPeriod;
    private float _expectedStaticPhase;
    private float _userAmplitude;
    private float _userPeriod;
    private float _userStaticPhase;
    private Timer _countdownTimer;
    private Timer _holdTimer;

    private readonly Random _random = new();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        InitializeExpectedCurve();
        InitializeUserCurve();

        InitializeSliders();

        AddCountdownTimer();
        InitializeHoldTimer();
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        if (_countdownTimer.TimeLeft <= 0)
        {
            return;
        }

        var seconds = Math.Floor(_countdownTimer.TimeLeft);
        var miliseconds = _countdownTimer.TimeLeft % 1 * 1000;
        _countdownLabel.Text = $"{seconds:00}:{miliseconds:000}";

        _holdProgressBar.Value = _holdTimer.TimeLeft <= 0
            ? 0
            : (_holdDuration - _holdTimer.TimeLeft) / _holdDuration * 100;

        _expectedCurve.UpdateDynamicPhase((float)delta);
        _userCurve.UpdateDynamicPhase((float)delta);
    }

    private void InitializeExpectedCurve()
    {
        _expectedAmplitude =
            (float)_random.NextDouble() * (_amplitudeRange.Max - _amplitudeRange.Min) + _amplitudeRange.Min;
        _expectedPeriod =
            (float)_random.NextDouble() * (_periodRange.Max - _periodRange.Min) + _periodRange.Min;
        _expectedStaticPhase =
            (float)_random.NextDouble() * (_staticPhaseRange.Max - _staticPhaseRange.Min) + _staticPhaseRange.Min;

        _expectedCurve.SetAmplitude(_expectedAmplitude);
        _expectedCurve.SetPeriod(_expectedPeriod);
        _expectedCurve.SetStaticPhase(_expectedStaticPhase);
    }

    private void InitializeUserCurve()
    {
        _userAmplitude =
            (float)_random.NextDouble() * (_amplitudeRange.Max - _amplitudeRange.Min) + _amplitudeRange.Min;
        _userPeriod =
            (float)_random.NextDouble() * (_periodRange.Max - _periodRange.Min) + _periodRange.Min;
        _userStaticPhase =
            (float)_random.NextDouble() * (_staticPhaseRange.Max - _staticPhaseRange.Min) + _staticPhaseRange.Min;

        _userCurve.SetAmplitude(_userAmplitude);
        _userCurve.SetPeriod(_userPeriod);
        _userCurve.SetStaticPhase(_userStaticPhase);
    }

    private void InitializeSliders()
    {
        _amplitudeSlider.MinValue = _amplitudeRange.Min;
        _amplitudeSlider.MaxValue = _amplitudeRange.Max;
        _amplitudeSlider.Value = _userAmplitude;
        _amplitudeSlider.Step = (_amplitudeRange.Max - _amplitudeRange.Min) / 100f;
        _amplitudeSlider.ValueChanged += OnAmplitudeSliderValueChanged;
        _amplitudeSlider.DragEnded += (wasValueChanged) =>
            OnAmplitudeSliderDragEnded(_amplitudeSlider, wasValueChanged);

        _periodSlider.MinValue = _periodRange.Min;
        _periodSlider.MaxValue = _periodRange.Max;
        _periodSlider.Value = _userPeriod;
        _periodSlider.Step = (_periodRange.Max - _periodRange.Min) / 100f;
        _periodSlider.ValueChanged += OnPeriodSliderValueChanged;
        _periodSlider.DragEnded += (wasValueChanged) =>
            OnPeriodSliderDragEnded(_periodSlider, wasValueChanged);

        _staticPhaseSlider.MinValue = _staticPhaseRange.Min;
        _staticPhaseSlider.MaxValue = _staticPhaseRange.Max;
        _staticPhaseSlider.Value = _userStaticPhase;
        _staticPhaseSlider.Step = (_staticPhaseRange.Max - _staticPhaseRange.Min) / 100f;
        _staticPhaseSlider.ValueChanged += OnStaticPhaseSliderValueChanged;
        _staticPhaseSlider.DragEnded += (wasValueChanged) =>
            OnStaticPhaseSliderDragEnded(_staticPhaseSlider, wasValueChanged);
    }

    private void OnAmplitudeSliderValueChanged(double value)
    {
        _userAmplitude = (float)value;
        _userCurve.SetAmplitude(_userAmplitude);
    }

    private void OnAmplitudeSliderDragEnded(Slider slider, bool wasValueChanged)
    {
        if (!wasValueChanged)
        {
            return;
        }

        OnAmplitudeSliderValueChanged(slider.Value);

        CheckForCompletion();
    }

    private void OnPeriodSliderValueChanged(double value)
    {
        _userPeriod = (float)value;
        _userCurve.SetPeriod(_userPeriod);
    }

    private void OnPeriodSliderDragEnded(Slider slider, bool wasValueChanged)
    {
        if (!wasValueChanged)
        {
            return;
        }

        OnPeriodSliderValueChanged(slider.Value);

        CheckForCompletion();
    }

    private void OnStaticPhaseSliderValueChanged(double value)
    {
        _userStaticPhase = (float)value;
        _userCurve.SetStaticPhase(_userStaticPhase);
    }

    private void OnStaticPhaseSliderDragEnded(Slider slider, bool wasValueChanged)
    {
        if (!wasValueChanged)
        {
            return;
        }

        OnStaticPhaseSliderValueChanged(slider.Value);

        CheckForCompletion();
    }

    private void AddCountdownTimer()
    {
        _countdownTimer = new Timer
        {
            WaitTime = _timeToSolve,
            Autostart = true,
            OneShot = true
        };

        _countdownTimer.Timeout += FailMinigame;

        AddChild(_countdownTimer);
    }

    private void InitializeHoldTimer()
    {
        _holdTimer = new Timer
        {
            WaitTime = _holdDuration,
            OneShot = true
        };

        _holdTimer.Timeout += CompleteMinigame;

        AddChild(_holdTimer);
    }

    private void FailMinigame()
    {
        _countdownTimer.Stop();
        _amplitudeSlider.Editable = false;
        _periodSlider.Editable = false;
        _staticPhaseSlider.Editable = false;

        var timer = new Timer
        {
            WaitTime = 1.0,
            OneShot = true,
            Autostart = true
        };
        timer.Timeout += () => { EmitSignal(SignalName.MinigameFailed); };
        AddChild(timer);
    }

    private void CompleteMinigame()
    {
        _countdownTimer.Stop();
        _amplitudeSlider.Editable = false;
        _periodSlider.Editable = false;
        _staticPhaseSlider.Editable = false;

        var timer = new Timer
        {
            WaitTime = 1.0,
            OneShot = true,
            Autostart = true
        };
        timer.Timeout += () => { EmitSignal(SignalName.MinigameCompleted); };
        AddChild(timer);
    }

    private void CheckForCompletion()
    {
        var amplitudeDiff = Math.Abs(_userAmplitude - _expectedAmplitude);
        var periodDiff = Math.Abs(_userPeriod - _expectedPeriod);
        var staticPhaseDiff = Math.Abs(_userStaticPhase - _expectedStaticPhase);
        staticPhaseDiff = staticPhaseDiff > Mathf.Pi ? Mathf.Tau - staticPhaseDiff : staticPhaseDiff;


        if (amplitudeDiff <= _amplitudeErrorTolerance &&
            periodDiff <= _periodErrorTolerance &&
            staticPhaseDiff <= _staticPhaseErrorTolerance)
        {
            if (_holdTimer.IsStopped())
            {
                _holdTimer.Start();
            }
        }
        else
        {
            if (!_holdTimer.IsStopped())
            {
                _holdTimer.Stop();
            }
        }
    }
}