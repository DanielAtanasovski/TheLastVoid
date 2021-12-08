using Godot;
using System;

public class Base : Node
{
    public override void _Ready()
    {
        GD.Print("Hello World!");
    }
}
