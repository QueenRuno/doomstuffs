// ------------------------------------------------------------
// 16 gauge shells in 3 varieties
// ------------------------------------------------------------
class HD16Gauge275InchShellAmmo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+hdpickup.multipickup
		inventory.pickupmessage "Seized 16 gauge 2.3/4 inch shells";
		scale 0.3;
		tag "16 gauge 2.3/4's";
		hdpickup.refid "2in";
		hdpickup.bulk ENC_16SHELL234;
		inventory.icon "234IA0";
	}
	override void SplitPickup(){
		SplitPickupBoxableRound(4,20,"ShellBoxPickup16Gauge","234IA0","2341A0");
	}
	override string pickupmessage(){
		if(amount>1)return Stringtable.Localize("Seized some shells");
		return super.pickupmessage();
	}
	states{
	spawn:
		2341 A -1;
		stop;
	death:
		GSHL A -1{
			HD16GaugeSpentShell.FDShellTranslate(self);
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}

}


class HD16GaugeSpentShell:HDDebris{
	default{
		-noteleport +forcexybillboard
		seesound "misc/casing2";scale 0.3;height 2;radius 2;
		bouncefactor 0.5;
	}
	static void FDShellTranslate(actor caller){
		if(
			!HDMath.PlayingId()
			&&!HDMath.CheckLumpReplaced("GSHLA0",Wads.AnyNamespace)
		)caller.A_SetTranslation("FreeShell");
	}
	override void postbeginplay(){
		super.postbeginplay();
		FDShellTranslate(self);
		if(vel==(0,0,0))A_ChangeVelocity(0.0001,0,-0.1,CVF_RELATIVE);
	}
	states{
	spawn:
		GSHL ABCDEFGH 2;
		loop;
	death:
		GSHL A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}
//a shell that can be caught in hand, launched from the Suave
class HD16GaugeUnSpentShell:HD16GaugeSpentShell{
	states{
	spawn:
		GSHL ABCDE 2;
		TNT1 A 0{
			if(A_JumpIfInTargetInventory("HD16Gauge275InchShellAmmo",0,"null"))
			A_SpawnItemEx("HD16GaugeFumblingShell",
				0,0,0,vel.x+frandom(-1,1),vel.y+frandom(-1,1),vel.z,
				0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
			);else A_GiveToTarget("HD16Gauge275InchShellAmmo",1);
		}
		stop;
	}
}
//any other single shell tumbling out
class HD16GaugeFumblingShell:HD16GaugeSpentShell{
	default{
		bouncefactor 0.3;
	}
	states{
	spawn:
		GSHL ABCDEFGH 2;
		loop;
	death:
		TNT1 A 0{
			let sss=spawn("HD16Gauge275InchShellAmmo",pos);
			sss.vel.xy=lastvel.xy+lastvel.xy.unit()*abs(lastvel.z);
			sss.setstatelabel("death");
			if(sss.vel.x||sss.vel.y){
				sss.A_FaceMovementDirection();
				sss.angle+=90;
				sss.frame=randompick(0,4);
			}else sss.frame=randompick(0,0,0,4,4,4,2,2,5);
			inventory(sss).amount=1;
		}stop;
	}
}


class ShellBoxPickup16Gauge:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of 2.3/4 16s"
		//$Sprite "234IB0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Seized a box of 2.3/4 inch shells";
		hdupk.pickuptype "HD16Gauge275InchShellAmmo";
	}
	states{
	spawn:
		234I B -1 nodelay{
			if(!HDMath.PlayingId())scale=(0.25,0.25);
			if(!HDMath.CheckLumpReplaced("234IB0",Wads.AnyNamespace))A_SetTranslation("GreyShell");
		}

	}
}
class ShellPickup16Gauge:IdleDummy{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four 16 gauge 2.3/4 shells"
		//$Sprite "234IA0"
	}
	states{
	spawn:
		234I A 0 nodelay{
			let iii=hdpickup(spawn("HD16Gauge275InchShellAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}











class HD16Gauge3InchShellAmmo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+hdpickup.multipickup
		inventory.pickupmessage "Got 16 gauge magnum's";
		scale 0.35;
		tag "16 gauge Magnum's";
		hdpickup.refid "3in";
		hdpickup.bulk ENC_16SHELL3;
		inventory.icon "3INCA0";
	}
	override void SplitPickup(){
		SplitPickupBoxableRound(4,20,"ShellBoxPickup16Gauge3Inch","3INCA0","31NCA0");
	}
	override string pickupmessage(){
		if(amount>1)return Stringtable.Localize("$PICKUP_ShotgunShellPlural");
		return super.pickupmessage();
	}
	states{
	spawn:
		31NC A -1;
		stop;
	death:
		GSHL A -1{
			HD16GaugeSpentShell.FDShellTranslate(self);
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}


class HD16GaugeSpentShell3Inch:HDDebris{
	default{
		-noteleport +forcexybillboard
		seesound "misc/casing2";scale 0.3;height 2;radius 2;
		bouncefactor 0.5;
	}
	static void FDShellTranslate(actor caller){
		if(
			!HDMath.PlayingId()
			&&!HDMath.CheckLumpReplaced("GSHLA0",Wads.AnyNamespace)
		)caller.A_SetTranslation("FreeShell");
	}
	override void postbeginplay(){
		super.postbeginplay();
		FDShellTranslate(self);
		if(vel==(0,0,0))A_ChangeVelocity(0.0001,0,-0.1,CVF_RELATIVE);
	}
	states{
	spawn:
		GSHL ABCDEFGH 2;
		loop;
	death:
		GSHL A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}
//a shell that can be caught in hand, launched from the Suave
class HD16GaugeUnSpentShell3Inch:HD16GaugeSpentShell3Inch{
	states{
	spawn:
		GSHL ABCDE 2;
		TNT1 A 0{
			if(A_JumpIfInTargetInventory("HD16Gauge3InchShellAmmo",0,"null"))
			A_SpawnItemEx("HD16GaugeFumblingShell3Inch",
				0,0,0,vel.x+frandom(-1,1),vel.y+frandom(-1,1),vel.z,
				0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
			);else A_GiveToTarget("HD16Gauge3InchShellAmmo",1);
		}
		stop;
	}
}
//any other single shell tumbling out
class HD16GaugeFumblingShell3Inch:HD16GaugeSpentShell3Inch{
	default{
		bouncefactor 0.3;
	}
	states{
	spawn:
		GSHL ABCDEFGH 2;
		loop;
	death:
		TNT1 A 0{
			let sss=spawn("HD16Gauge3InchShellAmmo",pos);
			sss.vel.xy=lastvel.xy+lastvel.xy.unit()*abs(lastvel.z);
			sss.setstatelabel("death");
			if(sss.vel.x||sss.vel.y){
				sss.A_FaceMovementDirection();
				sss.angle+=90;
				sss.frame=randompick(0,4);
			}else sss.frame=randompick(0,0,0,4,4,4,2,2,5);
			inventory(sss).amount=1;
		}stop;
	}
}


class ShellBoxPickup16Gauge3Inch:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of Magnum 16's"
		//$Sprite "3INCB0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Seized a box of magnum shells";
		hdupk.pickuptype "HD16Gauge3InchShellAmmo";
	}
	states{
	spawn:
		3INC B -1 nodelay{
			if(!HDMath.PlayingId())scale=(0.25,0.25);
			if(!HDMath.CheckLumpReplaced("3INCB0",Wads.AnyNamespace))A_SetTranslation("GreyShell");
		}

	}
}
class ShellPickup16Gauge3Inch:IdleDummy{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four 16 gauge 3 Inch Shells"
		//$Sprite "3INCA0"
	}
	states{
	spawn:
		3INC A 0 nodelay{
			let iii=hdpickup(spawn("HD16Gauge3InchShellAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}














class HD16Gauge35InchShellAmmo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+hdpickup.multipickup
		inventory.pickupmessage "Got 16 Gauge Super Magnums";
		scale 0.4;
		tag "16 gauge Super Magnum's";
		hdpickup.refid "35I";
		hdpickup.bulk ENC_16SHELL35;
		inventory.icon "35SUA0";
	}
	override void SplitPickup(){
		SplitPickupBoxableRound(4,20,"ShellBoxPickup16GaugeLong","35SUA0","351NA0");
	}
	override string pickupmessage(){
		if(amount>1)return Stringtable.Localize("$PICKUP_ShotgunShellPlural");
		return super.pickupmessage();
	}
	states{
	spawn:
		351N A -1;
		stop;
	death:
		GSHL A -1{
			HD16GaugeSpentShellLong.FDShellTranslate(self);
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}


class HD16GaugeSpentShellLong:HDDebris{
	default{
		-noteleport +forcexybillboard
		seesound "misc/casing2";scale 0.3;height 2;radius 2;
		bouncefactor 0.5;
	}
	static void FDShellTranslate(actor caller){
		if(
			!HDMath.PlayingId()
			&&!HDMath.CheckLumpReplaced("GSHLA0",Wads.AnyNamespace)
		)caller.A_SetTranslation("FreeShell");
	}
	override void postbeginplay(){
		super.postbeginplay();
		FDShellTranslate(self);
		if(vel==(0,0,0))A_ChangeVelocity(0.0001,0,-0.1,CVF_RELATIVE);
	}
	states{
	spawn:
		GSHL ABCDEFGH 2;
		loop;
	death:
		GSHL A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}

//a shell that can be caught in hand, launched from the Suave
class HD16GaugeUnSpentShellLong:HD16GaugeSpentShellLong{
	states{
	spawn:
		GSHL ABCDE 2;
		TNT1 A 0{
			if(A_JumpIfInTargetInventory("HD16Gauge35InchShellAmmo",0,"null"))
			A_SpawnItemEx("HD16GaugeFumblingShell",
				0,0,0,vel.x+frandom(-1,1),vel.y+frandom(-1,1),vel.z,
				0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
			);else A_GiveToTarget("HD16Gauge3InchShellAmmo",1);
		}
		stop;
	}
}

//any other single shell tumbling out
class HD16GaugeFumblingShellLong:HD16GaugeSpentShellLong{
	default{
		bouncefactor 0.3;
	}
	states{
	spawn:
		GSHL ABCDEFGH 2;
		loop;
	death:
		TNT1 A 0{
			let sss=spawn("HD16Gauge35InchShellAmmo",pos);
			sss.vel.xy=lastvel.xy+lastvel.xy.unit()*abs(lastvel.z);
			sss.setstatelabel("death");
			if(sss.vel.x||sss.vel.y){
				sss.A_FaceMovementDirection();
				sss.angle+=90;
				sss.frame=randompick(0,4);
			}else sss.frame=randompick(0,0,0,4,4,4,2,2,5);
			inventory(sss).amount=1;
		}stop;
	}
}


class ShellBoxPickup16GaugeLong:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of Super Magnum 16's"
		//$Sprite "35SUB0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Seized a box of super magnum shells";
		hdupk.pickuptype "HD16Gauge35InchShellAmmo";
	}
	states{
	spawn:
		35SU B -1 nodelay{
			if(!HDMath.PlayingId())scale=(0.25,0.25);
			if(!HDMath.CheckLumpReplaced("35SUB0",Wads.AnyNamespace))A_SetTranslation("GreyShell");
		}

	}
}
class ShellPickup16GaugeLong:IdleDummy{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four 16 gauge Super Magnum's"
		//$Sprite "35SUA0"
	}
	states{
	spawn:
		35SU A 0 nodelay{
			let iii=hdpickup(spawn("HD16Gauge35InchShellAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}


