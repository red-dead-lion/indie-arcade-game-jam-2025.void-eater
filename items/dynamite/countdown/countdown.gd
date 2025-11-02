class_name Countdown;
extends Node2D;

# Settings

@export var label: Label;
@export var animation: AnimationPlayer;

# Signals

signal on_timer_tick_animation_complete();

# Triggers

func _on_countdown_animation_finished(_anim_name: StringName) -> void:
	print('anim finished');
	on_timer_tick_animation_complete.emit();

# Methods

func play_countdown_label(label_text: String):
	label.text = label_text;
	animation.play("countdown_timer_fade_out");

func play_countdown_label_red(label_text: String):
	label.text = label_text;
	animation.play("countdown_timer_fade_out_red");
