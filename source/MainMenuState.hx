package;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import editors.MasterEditorMenu;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	var curSelected:Int = 0;

	var xval:Int = 585;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var soundCooldown:Bool = true;

	var optionShit:Array<String> = [
		'story_mode',
		'encore',
		'freeplay',
		'sound_test',
		'options',
		'extras'
	];

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var bgdesat:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	var debugKeys:Array<FlxKey>;


	override function create()
	{
		/*#if debug
		optionShit.push('sound test');
		#else
		optionShit.push('sound test locked');
		#end
		if(!ClientPrefs.beatweek){
			optionShit.push('sound_test locked');
			optionShit.push('encore locked');
		}
		else{
			optionShit.push('sound_test');
			optionShit.push('encore');
		}*/


		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.playMusic(Paths.music('storymodemenumusic'));
		var yScroll:Float = Math.max((0.05 * (optionShit.length - 4)), 0.1);
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('Main_Menu_Spritesheet_Animation');
		bg.animation.addByPrefix('a', 'BG instance 1');
		bg.animation.play('a', true);
		bg.scale.y += 1;
		bg.scale.x += 1;
		bg.scrollFactor.set(0, yScroll);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		bgdesat = new FlxSprite(-80).loadGraphic(Paths.image('backgroundlool2'));
		bgdesat.scrollFactor.x = 0;
		bgdesat.scrollFactor.y = 0;
		bgdesat.setGraphicSize(Std.int(bgdesat.width * .5));
		bgdesat.updateHitbox();
		bgdesat.screenCenter();
		bgdesat.visible = false;
		bgdesat.antialiasing = true;
		bgdesat.color = 0xFFfd719b;
		add(bgdesat);
		// bgdesat.scrollFactor.set();


		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);


		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-500, (i * 100)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('lock', optionShit[i] + " locked", 24);

				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.play('idle');
			
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			
			
			if (firstStart)
				FlxTween.tween(menuItem,{x: xval},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween)
					{
						if(i == optionShit.length - 1)
						{
							finishedFunnyMove = true;
							changeItem();
						}
					}});
			else{
				menuItem.x = xval;
				finishedFunnyMove=true;
			}

			xval = xval + 70;
		}


		firstStart = false;

	//	FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		FlxG.camera.follow(camFollowPos, null, 1);

		var dataerase:FlxText = new FlxText(FlxG.width - 300, FlxG.height - 18 * 2, 300, "Hold DEL to erase ALL data (this doesn't include ALL options)", 3);
		dataerase.scrollFactor.set();
		dataerase.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dataerase);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.DELETE)
		{
			var urmom = 0;
			new FlxTimer().start(0.1, function(hello:FlxTimer)
			{
				urmom += 1;
				if (urmom == 30)
				{
					FlxG.save.data.storyProgress = 0; // lol.
					FlxG.save.data.soundTestUnlocked = true;
					FlxG.save.data.songArray = [];
					FlxG.switchState(new MainMenuState());
				}
				if (FlxG.keys.pressed.DELETE)
				{
					hello.reset();
				}
			});
		}



		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}

				if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}

				if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.expoOut});
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'encore':
										MusicBeatState.switchState(new EncoreState());
									case 'sound_test':										
										MusicBeatState.switchState(new SoundTestMenu());									
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			if (FlxG.keys.justPressed.SIX)
			{
				MusicBeatState.switchState(new EncoreState());
			}
			if (FlxG.keys.justPressed.SEVEN)
			{
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			if (FlxG.keys.justPressed.EIGHT)
			{
				MusicBeatState.switchState(new FreeplayState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;
			
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			
			
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			var daChoice:String = optionShit[curSelected];

			spr.animation.play('idle');
			
			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - menuItems.length * 8);
				spr.centerOffsets(); 
			}

			spr.updateHitbox();
		});
	}
}
