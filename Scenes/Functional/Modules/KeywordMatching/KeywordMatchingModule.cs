using System;
using System.Linq;
using Godot;

namespace Infobreach.Scenes.Functional.Modules.KeywordMatching;

public partial class KeywordMatchingModule : Control
{
    [Export] private GridContainer _gridContainer;
    [Export] private Label _keywordLabel;
    [Export] private Label _countdownLabel;
    [Export] private HBoxContainer _failMarksContainer;
    [Export] private int _lengthOfKeyword;
    [Export] private DifficultyLevel _difficulty = DifficultyLevel.Medium;

    [Signal]
    public delegate void MinigameCompletedEventHandler();

    [Signal]
    public delegate void MinigameFailedEventHandler();

    private Label[] _gridLabelChildren;
    private int _keywordIndex;
    private int _maskIndex;
    private double _shiftPeriod;
    private int _shiftMaxAmount;
    private double _timeToSolve;
    private Timer _shiftTimer;
    private Timer _countdownTimer;
    private int _maxFailedAttempts;
    private int _failedAttempts;
    private Label[] _failMarkLabels;
    private bool _isMinigameActive = true;

    private readonly Random _random = new();
    private const string Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        if (!IsScriptValid())
        {
            return;
        }

        InitializeDifficultySettings();

        _gridLabelChildren = _gridContainer.GetChildren().Where(child => child is Label).Cast<Label>().ToArray();

        var maskMiddleCharacterIndex =
            (_gridLabelChildren.Length + _gridContainer.Columns) / 2;
        _maskIndex = maskMiddleCharacterIndex - _lengthOfKeyword / 2;

        _failMarkLabels = _failMarksContainer.GetChildren().Where(child => child is Label).Cast<Label>().ToArray();
        for (var i = _maxFailedAttempts; i < _failMarkLabels.Length; i++)
        {
            _failMarkLabels[i].QueueFree();
        }

        var remainingFailMarkLabels = new Label[_maxFailedAttempts];
        Array.Copy(_failMarkLabels, remainingFailMarkLabels, _maxFailedAttempts);
        _failMarkLabels = remainingFailMarkLabels;

        GenerateGridAndKeyword();

        AddShiftTimer();

        AddCountdownTimer();
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        if (_countdownTimer.TimeLeft > 0)
        {
            var seconds = Math.Floor(_countdownTimer.TimeLeft);
            var miliseconds = _countdownTimer.TimeLeft % 1 * 1000;
            _countdownLabel.Text = $"{seconds:00}:{miliseconds:000}";
        }
    }

    public override void _Input(InputEvent @event)
    {
        if (!_isMinigameActive)
        {
            return;
        }

        if (@event.IsActionPressed("minigame_keyword_up"))
        {
            MoveMaskVertical(-1);
        }
        else if (@event.IsActionPressed("minigame_keyword_left"))
        {
            MoveMaskHorizontal(-1);
        }
        else if (@event.IsActionPressed("minigame_keyword_down"))
        {
            MoveMaskVertical(1);
        }
        else if (@event.IsActionPressed("minigame_keyword_right"))
        {
            MoveMaskHorizontal(1);
        }
        else if (@event.IsActionPressed("minigame_keyword_select"))
        {
            IsMaskOnKeyword();
        }
    }

    private void ShiftArrayLeft()
    {
        var shiftAmount = _random.Next(1, _shiftMaxAmount + 1);

        var leftMostStrings = new string[shiftAmount];
        for (var i = 0; i < shiftAmount; i++)
        {
            leftMostStrings[i] = _gridLabelChildren[i].Text;
            _gridLabelChildren[i].Text = _gridLabelChildren[(i + shiftAmount) % _gridLabelChildren.Length].Text;
        }

        for (var i = shiftAmount; i < _gridLabelChildren.Length - shiftAmount; i++)
        {
            _gridLabelChildren[i].Text = _gridLabelChildren[i + shiftAmount].Text;
        }

        for (var i = _gridLabelChildren.Length - shiftAmount; i < _gridLabelChildren.Length; i++)
        {
            _gridLabelChildren[i].Text = leftMostStrings[i - (_gridLabelChildren.Length - shiftAmount)];
        }

        _keywordIndex = _keywordIndex - shiftAmount;
        _keywordIndex = _keywordIndex < 0 ? _keywordIndex + _gridLabelChildren.Length : _keywordIndex;
    }

    private void GenerateGridAndKeyword()
    {
        var randomCharactersArray = Enumerable.Repeat(Characters, _gridLabelChildren.Length)
            .Select(s => s[_random.Next(s.Length)]).ToArray();
        foreach (var (index, label) in _gridLabelChildren.Select((item, index) => (index, item)))
        {
            label.Text = randomCharactersArray[index].ToString();
            label.Set("theme_override_colors/font_color",
                index >= _maskIndex && index < _maskIndex + _lengthOfKeyword ? Colors.Red : Colors.White);
        }

        _keywordIndex = _random.Next(0, randomCharactersArray.Length);
        var keywordChars = new char[_lengthOfKeyword];
        for (var i = 0; i < _lengthOfKeyword; i++)
        {
            keywordChars[i] = randomCharactersArray[(_keywordIndex + i) % randomCharactersArray.Length];
        }

        _keywordLabel.Text = new string(keywordChars);
    }

    private void AddShiftTimer()
    {
        _shiftTimer = new Timer
        {
            WaitTime = 1.0,
            Autostart = true
        };

        _shiftTimer.Timeout += ShiftArrayLeft;

        AddChild(_shiftTimer);
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

    private void MoveMaskVertical(int numberOfRowsDown)
    {
        for (var i = 0; i < _lengthOfKeyword; i++)
        {
            var labelIndex = (_maskIndex + i) % _gridLabelChildren.Length;
            _gridLabelChildren[labelIndex].Set("theme_override_colors/font_color", Colors.White);
        }

        _maskIndex = (_maskIndex + numberOfRowsDown * _gridContainer.Columns) %
                     _gridLabelChildren.Length;
        _maskIndex = _maskIndex < 0 ? _maskIndex + _gridLabelChildren.Length : _maskIndex;

        for (var i = 0; i < _lengthOfKeyword; i++)
        {
            var labelIndex = (_maskIndex + i) % _gridLabelChildren.Length;
            _gridLabelChildren[labelIndex].Set("theme_override_colors/font_color", Colors.Red);
        }
    }

    private void MoveMaskHorizontal(int numberOfColumnsRight)
    {
        for (var i = 0; i < _lengthOfKeyword; i++)
        {
            var labelIndex = (_maskIndex + i) % _gridLabelChildren.Length;
            _gridLabelChildren[labelIndex].Set("theme_override_colors/font_color", Colors.White);
        }

        _maskIndex = (_maskIndex + numberOfColumnsRight) %
                     _gridLabelChildren.Length;
        _maskIndex = _maskIndex < 0 ? _maskIndex + _gridLabelChildren.Length : _maskIndex;

        for (var i = 0; i < _lengthOfKeyword; i++)
        {
            var labelIndex = (_maskIndex + i) % _gridLabelChildren.Length;
            _gridLabelChildren[labelIndex].Set("theme_override_colors/font_color", Colors.Red);
        }
    }

    private void IsMaskOnKeyword()
    {
        if (_maskIndex == _keywordIndex)
        {
            CompleteMinigame();
        }
        else
        {
            _failMarkLabels[_failedAttempts].Set("theme_override_colors/font_color", Colors.Red);

            _failedAttempts++;
            if (_failedAttempts >= _maxFailedAttempts)
            {
                FailMinigame();
            }
        }
    }

    private bool IsScriptValid()
    {
        if (_gridContainer == null)
        {
            GD.PrintErr("GridContainer is not assigned in the KeywordMatchingModule.");
            return false;
        }

        if (_keywordLabel == null)
        {
            GD.PrintErr("Keyword Label is not assigned in the KeywordMatchingModule.");
            return false;
        }

        var gridLabelChildren = _gridContainer.GetChildren().Where(child => child is Label).Cast<Label>().ToArray();
        if (_lengthOfKeyword <= 0 || _lengthOfKeyword > gridLabelChildren.Length)
        {
            GD.PrintErr("Length of keyword must be greater than zero and less than or equal to number of characters.");
            return false;
        }

        return true;
    }

    private void InitializeDifficultySettings()
    {
        switch (_difficulty)
        {
            case DifficultyLevel.Easy:
                _shiftPeriod = 2.5;
                _shiftMaxAmount = 1;
                _timeToSolve = 25.0;
                _maxFailedAttempts = 6;
                break;
            case DifficultyLevel.Medium:
                _shiftPeriod = 1.5;
                _shiftMaxAmount = 1;
                _timeToSolve = 20.0;
                _maxFailedAttempts = 4;
                break;
            case DifficultyLevel.Hard:
                _shiftPeriod = 1.0;
                _shiftMaxAmount = 3;
                _timeToSolve = 15.0;
                _maxFailedAttempts = 2;
                break;
            default:
                _shiftPeriod = 1.5;
                _shiftMaxAmount = 1;
                _timeToSolve = 20.0;
                _maxFailedAttempts = 2;
                break;
        }
    }

    private void FailMinigame()
    {
        _isMinigameActive = false;
        _shiftTimer.Stop();
        _countdownTimer.Stop();

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
        _isMinigameActive = false;
        _shiftTimer.Stop();
        _countdownTimer.Stop();

        var timer = new Timer
        {
            WaitTime = 1.0,
            OneShot = true,
            Autostart = true
        };
        timer.Timeout += () => { EmitSignal(SignalName.MinigameCompleted); };
        AddChild(timer);
    }
}